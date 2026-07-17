import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/course.dart';
import '../models/deadline.dart';
import '../models/student_profile.dart';
import '../models/study_note.dart';
import 'notification_service.dart';

/// Récapitulatif d'un import, affiché à l'utilisateur après restauration.
class BackupImportSummary {
  final int coursesImported;
  final int notesImported;
  final int deadlinesImported;
  final bool profileImported;

  const BackupImportSummary({
    required this.coursesImported,
    required this.notesImported,
    required this.deadlinesImported,
    required this.profileImported,
  });
}

/// Sauvegarde/restauration complète des données locales (profil, cours,
/// notes + fichiers associés) dans une archive zip unique.
///
/// Volontairement 100% local et gratuit : aucun service cloud, l'archive
/// produite est ensuite partagée par l'utilisateur via le partage natif du
/// système (Drive, email, WhatsApp...) — voir BackupRestorePage. Les chemins
/// de fichiers absolus (spécifiques à l'appareil) ne sont jamais stockés tels
/// quels dans le JSON : chaque fichier référencé est copié dans l'archive
/// sous une clé stable (`files/<catégorie>/<n>_<nom>`), et c'est cette clé
/// qui remplace le chemin dans le JSON. À l'import, les fichiers sont
/// réécrits dans le dossier documents de l'app et une nouvelle map
/// clé -> chemin absolu est utilisée pour reconstruire les modèles.
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  static const int _formatVersion = 1;

  Future<File> exportBackup() async {
    final settingsBox = Hive.box('settings');
    final coursesBox = Hive.box<Course>('courses');
    final notesBox = Hive.box<StudyNote>('notes');
    final deadlinesBox = Hive.box<Deadline>('deadlines');

    final profile = settingsBox.get('profile') as StudentProfile?;
    final courses = coursesBox.values.toList();
    final notes = notesBox.values.toList();
    final deadlines = deadlinesBox.values.toList();
    final customNotebooks =
        (settingsBox.get('custom_notebooks') as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final isDarkMode =
        settingsBox.get('isDarkMode', defaultValue: false) as bool;

    final archive = Archive();
    final pathToArchiveKey = <String, String>{};
    var fileCounter = 0;

    String? addFileIfExists(String? path, String category) {
      if (path == null || path.isEmpty) return null;
      final cached = pathToArchiveKey[path];
      if (cached != null) return cached;
      final file = File(path);
      if (!file.existsSync()) return null;
      final bytes = file.readAsBytesSync();
      final key = 'files/$category/${fileCounter++}_${p.basename(path)}';
      archive.addFile(ArchiveFile(key, bytes.length, bytes));
      pathToArchiveKey[path] = key;
      return key;
    }

    final profileJson = profile == null
        ? null
        : {
            'name': profile.name,
            'className': profile.className,
            'schoolName': profile.schoolName,
            'faculty': profile.faculty,
            'department': profile.department,
            'subjects': profile.subjects,
            'profilePicture': addFileIfExists(
              profile.profilePicturePath,
              'profile',
            ),
          };

    final coursesJson = courses
        .map(
          (c) => {
            'id': c.id,
            'title': c.title,
            'location': c.location,
            'color': c.color,
            'dayOfWeeks': c.dayOfWeeks,
            'startTime': c.startTime.toIso8601String(),
            'endTime': c.endTime.toIso8601String(),
            'externalCode': c.externalCode,
            'reminderMinutesBefore': c.reminderMinutesBefore,
          },
        )
        .toList();

    final notesJson = notes.map((n) {
      final imageKeys = n.imagePaths
          .map((path) => addFileIfExists(path, 'images'))
          .whereType<String>()
          .toList();
      final attachmentKeys = n.attachmentPaths
          .map((path) => addFileIfExists(path, 'attachments'))
          .whereType<String>()
          .toList();
      final captionsByKey = <String, String>{};
      n.imageCaptions.forEach((path, caption) {
        final key = pathToArchiveKey[path];
        if (key != null) captionsByKey[key] = caption;
      });
      return {
        'id': n.id,
        'title': n.title,
        'content': n.content,
        'subject': n.subject,
        'createdAt': n.createdAt.toIso8601String(),
        'updatedAt': n.updatedAt?.toIso8601String(),
        'tags': n.tags,
        'imagePaths': imageKeys,
        'attachmentPaths': attachmentKeys,
        'imageCaptions': captionsByKey,
        'isPinned': n.isPinned,
        'isDeleted': n.isDeleted,
        'deletedAt': n.deletedAt?.toIso8601String(),
      };
    }).toList();

    final deadlinesJson = deadlines
        .map(
          (d) => {
            'id': d.id,
            'title': d.title,
            'type': d.type.index,
            'dueAt': d.dueAt.toIso8601String(),
            'subject': d.subject,
            'notes': d.notes,
            'isCompleted': d.isCompleted,
            'reminderMinutesBefore': d.reminderMinutesBefore,
          },
        )
        .toList();

    final backupJson = {
      'formatVersion': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'isDarkMode': isDarkMode,
      'customNotebooks': customNotebooks,
      'profile': profileJson,
      'courses': coursesJson,
      'notes': notesJson,
      'deadlines': deadlinesJson,
    };

    final jsonBytes = utf8.encode(jsonEncode(backupJson));
    archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));

    final zipBytes = ZipEncoder().encode(archive);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final zipFile = File('${tempDir.path}/UniFlow_backup_$timestamp.zip');
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }

  /// Restaure une sauvegarde, en remplaçant entièrement les données
  /// actuelles (cours, notes, profil, cahiers personnalisés, thème). Une
  /// fusion/dédup serait ambiguë (même id recréé différemment ?) et bien
  /// plus risquée qu'un remplacement complet assumé — l'utilisateur en est
  /// averti avant l'appel, voir BackupRestorePage.
  Future<BackupImportSummary> importBackup(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final jsonEntry = archive.files.where((f) => f.name == 'backup.json');
    if (jsonEntry.isEmpty) {
      throw const FormatException(
        'Fichier de sauvegarde invalide : backup.json introuvable.',
      );
    }
    final backupJson =
        jsonDecode(utf8.decode(jsonEntry.first.content))
            as Map<String, dynamic>;

    final documentsDir = await getApplicationDocumentsDirectory();
    final archiveKeyToPath = <String, String>{};

    for (final entry in archive.files) {
      if (!entry.isFile || entry.name == 'backup.json') continue;
      final parts = entry.name.split('/'); // files/<category>/<filename>
      if (parts.length != 3) continue;
      final category = parts[1];
      final filename = parts[2];
      final targetSubfolder = switch (category) {
        'images' => 'notes',
        'attachments' => 'attachments',
        'profile' => 'profile_pictures',
        _ => category,
      };
      final targetDir = Directory('${documentsDir.path}/$targetSubfolder');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final targetPath = '${targetDir.path}/$filename';
      await File(targetPath).writeAsBytes(entry.content);
      archiveKeyToPath[entry.name] = targetPath;
    }

    String? resolvePath(String? key) =>
        key == null ? null : archiveKeyToPath[key];

    final settingsBox = Hive.box('settings');
    final coursesBox = Hive.box<Course>('courses');
    final notesBox = Hive.box<StudyNote>('notes');
    final deadlinesBox = Hive.box<Deadline>('deadlines');

    await NotificationService().cancelAll();
    await coursesBox.clear();
    await notesBox.clear();
    await deadlinesBox.clear();

    final profileJson = backupJson['profile'] as Map<String, dynamic>?;
    var profileImported = false;
    if (profileJson != null) {
      final profile = StudentProfile(
        name: profileJson['name'] as String,
        className: profileJson['className'] as String,
        schoolName: profileJson['schoolName'] as String,
        faculty: profileJson['faculty'] as String,
        department: profileJson['department'] as String?,
        subjects: (profileJson['subjects'] as List)
            .map((e) => e.toString())
            .toList(),
        profilePicturePath: resolvePath(
          profileJson['profilePicture'] as String?,
        ),
      );
      await settingsBox.put('profile', profile);
      profileImported = true;
    }

    final customNotebooks = (backupJson['customNotebooks'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    await settingsBox.put('custom_notebooks', customNotebooks);

    final coursesJson = backupJson['courses'] as List? ?? [];
    for (final raw in coursesJson) {
      final c = raw as Map<String, dynamic>;
      final course = Course(
        id: c['id'] as String,
        title: c['title'] as String,
        location: c['location'] as String?,
        color: c['color'] as int,
        dayOfWeeks: c['dayOfWeeks'] as int,
        startTime: DateTime.parse(c['startTime'] as String),
        endTime: DateTime.parse(c['endTime'] as String),
        externalCode: c['externalCode'] as String?,
        reminderMinutesBefore: c['reminderMinutesBefore'] as int? ?? 10,
      );
      await coursesBox.put(course.id, course);
    }

    final notesJson = backupJson['notes'] as List? ?? [];
    for (final raw in notesJson) {
      final n = raw as Map<String, dynamic>;
      final imagePaths = (n['imagePaths'] as List)
          .map((key) => resolvePath(key as String))
          .whereType<String>()
          .toList();
      final attachmentPaths = (n['attachmentPaths'] as List)
          .map((key) => resolvePath(key as String))
          .whereType<String>()
          .toList();
      final captionsByKey = (n['imageCaptions'] as Map).cast<String, String>();
      final imageCaptions = <String, String>{};
      captionsByKey.forEach((key, caption) {
        final path = resolvePath(key);
        if (path != null) imageCaptions[path] = caption;
      });

      final note = StudyNote(
        id: n['id'] as String,
        title: n['title'] as String,
        content: n['content'] as String,
        subject: n['subject'] as String?,
        createdAt: DateTime.parse(n['createdAt'] as String),
        updatedAt: n['updatedAt'] == null
            ? null
            : DateTime.parse(n['updatedAt'] as String),
        tags: (n['tags'] as List).map((e) => e.toString()).toList(),
        imagePaths: imagePaths,
        attachmentPaths: attachmentPaths,
        imageCaptions: imageCaptions,
        isPinned: n['isPinned'] as bool? ?? false,
        isDeleted: n['isDeleted'] as bool? ?? false,
        deletedAt: n['deletedAt'] == null
            ? null
            : DateTime.parse(n['deletedAt'] as String),
      );
      await notesBox.put(note.id, note);
    }

    final deadlinesJson = backupJson['deadlines'] as List? ?? [];
    for (final raw in deadlinesJson) {
      final d = raw as Map<String, dynamic>;
      final deadline = Deadline(
        id: d['id'] as String,
        title: d['title'] as String,
        type: DeadlineType.values[d['type'] as int],
        dueAt: DateTime.parse(d['dueAt'] as String),
        subject: d['subject'] as String?,
        notes: d['notes'] as String?,
        isCompleted: d['isCompleted'] as bool? ?? false,
        reminderMinutesBefore: d['reminderMinutesBefore'] as int?,
      );
      await deadlinesBox.put(deadline.id, deadline);
    }

    await settingsBox.put(
      'isDarkMode',
      backupJson['isDarkMode'] as bool? ?? false,
    );

    return BackupImportSummary(
      coursesImported: coursesJson.length,
      notesImported: notesJson.length,
      deadlinesImported: deadlinesJson.length,
      profileImported: profileImported,
    );
  }
}
