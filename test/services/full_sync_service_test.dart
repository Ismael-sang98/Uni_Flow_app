import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mon_temps/models/course.dart';
import 'package:mon_temps/services/full_sync_service.dart';
import 'package:mon_temps/services/notification_service.dart';

/// Tests de la logique de dédup/mise à jour des [Course] dans
/// [FullSyncService.syncCoursesFromJson] — la partie de la synchro d'emploi
/// du temps qui décide, pour chaque cours reçu du backend, s'il faut créer
/// un nouveau [Course] ou mettre à jour un [Course] local existant.
///
/// Utilise une box Hive réelle mais isolée dans un répertoire temporaire
/// (même pattern que test/widget_test.dart), jamais la box de l'appareil.
void main() {
  late Directory tempDir;
  final syncService = FullSyncService();

  /// Construit une entrée de cours au format JSON réellement renvoyé par le
  /// backend `obs-assistant-backend` (voir dartdoc de `_syncCourses`).
  Map<String, dynamic> courseJson({
    required String code,
    required String matiere,
    required int jour,
    required String heureDebut,
    required String heureFin,
    String? salle,
    String? professeur,
  }) {
    return {
      'code': code,
      'matiere': matiere,
      'jour': jour,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'salle': ?salle,
      'professeur': ?professeur,
    };
  }

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('full_sync_service_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(CourseAdapter());
  });

  setUp(() async {
    // Box fraîche à chaque test : évite toute pollution entre les cas.
    await Hive.openBox<Course>('courses');
  });

  tearDown(() async {
    final box = Hive.box<Course>('courses');
    await box.clear();
    await box.close();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'creates one Course per JSON entry with correctly mapped fields',
    () async {
      final coursesJson = [
        courseJson(
          code: 'YZM104',
          matiere: 'Algoritma ve Programlama II',
          jour: 1,
          heureDebut: '10:00',
          heureFin: '10:45',
          salle: 'EL-Z-16 BLD104',
        ),
      ];

      final outcome = await syncService.syncCoursesFromJson(coursesJson);

      expect(outcome.created, 1);
      expect(outcome.updated, 0);
      expect(outcome.skipped, 0);

      final box = Hive.box<Course>('courses');
      expect(box.length, 1);

      final course = box.values.single;
      expect(course.title, 'Algoritma ve Programlama II');
      expect(course.externalCode, 'YZM104');
      expect(course.location, 'EL-Z-16 BLD104');
      expect(course.dayOfWeeks, 1);
      expect(course.startTime.hour, 10);
      expect(course.startTime.minute, 0);
      expect(course.endTime.hour, 10);
      expect(course.endTime.minute, 45);
    },
  );

  test('re-syncing identical data does not create duplicates', () async {
    final coursesJson = [
      courseJson(
        code: 'YZM104',
        matiere: 'Algoritma ve Programlama II',
        jour: 1,
        heureDebut: '10:00',
        heureFin: '10:45',
        salle: 'EL-Z-16',
      ),
    ];

    final first = await syncService.syncCoursesFromJson(coursesJson);
    expect(first.created, 1);
    expect(first.updated, 0);

    final box = Hive.box<Course>('courses');
    expect(box.length, 1);

    // Deuxième synchro avec exactement les mêmes données.
    final second = await syncService.syncCoursesFromJson(coursesJson);
    expect(second.created, 0);
    expect(second.updated, 1);
    expect(box.length, 1); // toujours un seul cours, pas de doublon
  });

  test(
    'a changed room updates the existing Course in place (same Hive id)',
    () async {
      final original = [
        courseJson(
          code: 'YZM104',
          matiere: 'Algoritma ve Programlama II',
          jour: 1,
          heureDebut: '10:00',
          heureFin: '10:45',
          salle: 'Salle A',
          professeur: 'Prof. X',
        ),
      ];
      await syncService.syncCoursesFromJson(original);

      final box = Hive.box<Course>('courses');
      final idBefore = box.values.single.id;

      // Même code + jour + heure_debut, mais salle et professeur différents.
      final changed = [
        courseJson(
          code: 'YZM104',
          matiere: 'Algoritma ve Programlama II',
          jour: 1,
          heureDebut: '10:00',
          heureFin: '10:45',
          salle: 'Salle B',
          professeur: 'Prof. Y',
        ),
      ];
      final outcome = await syncService.syncCoursesFromJson(changed);

      expect(outcome.created, 0);
      expect(outcome.updated, 1);
      expect(box.length, 1); // toujours un seul cours

      final courseAfter = box.values.single;
      expect(courseAfter.id, idBefore, reason: 'id Hive doit rester stable');
      expect(courseAfter.location, 'Salle B');
    },
  );

  test(
    'notification id stays stable across syncs when nothing changed',
    () async {
      final coursesJson = [
        courseJson(
          code: 'YZM104',
          matiere: 'Algoritma ve Programlama II',
          jour: 1,
          heureDebut: '10:00',
          heureFin: '10:45',
        ),
      ];

      await syncService.syncCoursesFromJson(coursesJson);
      final box = Hive.box<Course>('courses');
      final courseBeforeId = box.values.single.id;
      final notificationIdBefore =
          NotificationService.notificationIdFromCourseId(courseBeforeId);

      // Resynchro avec les mêmes données : ne doit recréer ni le cours ni,
      // donc, la notification qui lui est associée.
      await syncService.syncCoursesFromJson(coursesJson);
      final courseAfterId = box.values.single.id;
      final notificationIdAfter =
          NotificationService.notificationIdFromCourseId(courseAfterId);

      expect(courseAfterId, courseBeforeId);
      expect(notificationIdAfter, notificationIdBefore);
    },
  );

  test('a course whose time slot changes is treated as a new course, not an '
      'update of the old one (matching includes heure_debut on purpose — see '
      'the dartdoc above _syncCourses for why)', () async {
    final original = [
      courseJson(
        code: 'YZM104',
        matiere: 'Algoritma ve Programlama II',
        jour: 1,
        heureDebut: '10:00',
        heureFin: '10:45',
      ),
    ];
    await syncService.syncCoursesFromJson(original);

    final box = Hive.box<Course>('courses');
    expect(box.length, 1);

    // Même code et même jour, mais heure_debut différente : traité comme
    // un cours distinct, l'ancien créneau (10:00) reste dans la box.
    final rescheduled = [
      courseJson(
        code: 'YZM104',
        matiere: 'Algoritma ve Programlama II',
        jour: 1,
        heureDebut: '11:00',
        heureFin: '11:45',
      ),
    ];
    final outcome = await syncService.syncCoursesFromJson(rescheduled);

    expect(outcome.created, 1);
    expect(outcome.updated, 0);
    expect(box.length, 2);
    expect(box.values.map((c) => c.startTime.hour), containsAll([10, 11]));
  });

  test('a course absent from the new response is never deleted', () async {
    final coursesJson = [
      courseJson(
        code: 'A1',
        matiere: 'Cours A',
        jour: 1,
        heureDebut: '08:00',
        heureFin: '09:00',
      ),
      courseJson(
        code: 'B1',
        matiere: 'Cours B',
        jour: 2,
        heureDebut: '10:00',
        heureFin: '11:00',
      ),
    ];
    await syncService.syncCoursesFromJson(coursesJson);

    final box = Hive.box<Course>('courses');
    expect(box.length, 2);

    // Nouvelle synchro sans le cours B1 : B1 doit rester tel quel.
    final onlyA = [
      courseJson(
        code: 'A1',
        matiere: 'Cours A',
        jour: 1,
        heureDebut: '08:00',
        heureFin: '09:00',
      ),
    ];
    final outcome = await syncService.syncCoursesFromJson(onlyA);

    expect(outcome.created, 0);
    expect(outcome.updated, 1);
    expect(box.length, 2, reason: 'B1 ne doit pas être supprimé');
    expect(box.values.any((c) => c.externalCode == 'B1'), isTrue);
  });
}
