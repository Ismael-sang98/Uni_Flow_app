import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../models/student_profile.dart';
import 'api_config_service.dart';

/// Synchronise en une seule opération, depuis le backend distant
/// `obs-assistant-backend` :
/// 1. `GET {baseUrl}/profil` → met à jour `name`/`faculty` du [StudentProfile]
///    local (jamais `className`/`schoolName`, toujours saisis manuellement).
/// 2. `GET {baseUrl}/alinan-dersler` → remplace entièrement `subjects` par
///    les valeurs "matiere" (dédupliquées) des cours reçus.
/// 3. `GET {baseUrl}/emploi-du-temps/export` → crée/met à jour les [Course]
///    dans la box Hive `courses` (voir [_syncCourses] pour le contrat JSON
///    détaillé, confirmé depuis la réponse réelle du backend).
///
/// Chaque étape est indépendante : l'échec de l'une n'empêche pas les
/// suivantes de s'exécuter, et rien n'est jamais annulé — si le profil a été
/// mis à jour avec succès mais que l'emploi du temps échoue, la mise à jour
/// du profil reste appliquée. Toutes les erreurs sont accumulées dans le
/// [FullSyncResult] final ([FullSyncResult.errors], une [SyncStepError] par
/// étape en échec) plutôt que de faire échouer toute l'opération.
///
/// Si aucun [StudentProfile] local n'existe encore (onboarding "Configurer
/// depuis mon compte OBS"), les étapes 1 et 2 en créent un à la volée
/// (`className`/`schoolName` vides, à renseigner ensuite manuellement) au
/// lieu d'échouer.
class FullSyncService {
  static final FullSyncService _instance = FullSyncService._internal();

  factory FullSyncService() {
    return _instance;
  }

  FullSyncService._internal();

  static const String _profileEndpointPath = '/profil';
  static const String _subjectsEndpointPath = '/alinan-dersler';
  static const String _coursesEndpointPath = '/emploi-du-temps/export';
  static const int _defaultColor = 0xFF6C63FF;

  /// Le backend (Render) peut être en veille et mettre du temps à redémarrer
  /// sur le tout premier appel après une période d'inactivité.
  static const Duration _requestTimeout = Duration(seconds: 60);

  final ApiConfigService _apiConfigService = ApiConfigService();

  /// Étape en cours de [syncAll], pour affichage de la progression dans
  /// l'UI (ex: `ValueListenableBuilder` dans `ApiSettingsPage`). Repasse à
  /// [SyncStep.idle] à la fin, succès ou échec.
  final ValueNotifier<SyncStep> currentStep = ValueNotifier<SyncStep>(
    SyncStep.idle,
  );

  /// Exécute les 3 synchronisations et retourne un résultat récapitulatif
  /// unique. Ne lève jamais d'exception : tout échec est capturé et reflété
  /// dans [FullSyncResult.errors].
  Future<FullSyncResult> syncAll() async {
    final baseUrl = await _apiConfigService.getBaseUrl();
    final apiKey = await _apiConfigService.getApiKey();

    if (baseUrl == null ||
        baseUrl.trim().isEmpty ||
        apiKey == null ||
        apiKey.trim().isEmpty) {
      return FullSyncResult(
        profileUpdated: false,
        subjectsCount: 0,
        coursesCreated: 0,
        coursesUpdated: 0,
        coursesSkipped: 0,
        sampleSkippedCourseEntry: null,
        errors: const [
          SyncStepError(
            step: 'config',
            errorType: 'missing_config',
            message: "L'URL du backend et la clé API doivent être configurées.",
          ),
        ],
      );
    }

    final trimmedBaseUrl = _stripTrailingSlash(baseUrl.trim());
    final trimmedApiKey = apiKey.trim();
    final errors = <SyncStepError>[];

    try {
      currentStep.value = SyncStep.profile;
      final profileUpdated = await _syncProfile(
        trimmedBaseUrl,
        trimmedApiKey,
        errors,
      );

      currentStep.value = SyncStep.subjects;
      final subjectsCount = await _syncSubjects(
        trimmedBaseUrl,
        trimmedApiKey,
        errors,
      );

      currentStep.value = SyncStep.schedule;
      final coursesOutcome = await _syncCourses(
        trimmedBaseUrl,
        trimmedApiKey,
        errors,
      );

      // Horodatage de la dernière synchro réussie, dès qu'au moins une étape
      // a effectivement changé quelque chose localement (voir objectif 2 :
      // affiché dans ProfilePage sous forme relative, ex. "il y a 2 heures").
      final hasAnySuccess =
          profileUpdated ||
          subjectsCount > 0 ||
          coursesOutcome.created > 0 ||
          coursesOutcome.updated > 0;
      if (hasAnySuccess) {
        await Hive.box('settings').put('last_sync_at', DateTime.now());
      }

      return FullSyncResult(
        profileUpdated: profileUpdated,
        subjectsCount: subjectsCount,
        coursesCreated: coursesOutcome.created,
        coursesUpdated: coursesOutcome.updated,
        coursesSkipped: coursesOutcome.skipped,
        sampleSkippedCourseEntry: coursesOutcome.sampleSkippedEntry,
        createdCourses: coursesOutcome.createdCourses,
        updatedCourses: coursesOutcome.updatedCourses,
        errors: errors,
      );
    } finally {
      currentStep.value = SyncStep.idle;
    }
  }

  // --- Étape 1 : profil (name/faculty uniquement) ---

  Future<bool> _syncProfile(
    String baseUrl,
    String apiKey,
    List<SyncStepError> errors,
  ) async {
    try {
      final body = await _fetchJson(baseUrl, apiKey, _profileEndpointPath);
      // Le backend enveloppe parfois la donnée sous une clé du même nom que
      // l'endpoint (vu sur /alinan-dersler) : on tente les deux formes.
      final profileData = (body['profil'] is Map)
          ? Map<String, dynamic>.from(body['profil'] as Map)
          : body;

      final nomComplet = profileData['nom_complet']?.toString().trim();
      final faculte = profileData['faculte']?.toString().trim();

      if ((nomComplet == null || nomComplet.isEmpty) &&
          (faculte == null || faculte.isEmpty)) {
        errors.add(
          const SyncStepError(
            step: 'profil',
            errorType: 'no_data',
            message: 'Aucun champ "nom_complet"/"faculte" dans la réponse.',
          ),
        );
        return false;
      }

      final settingsBox = Hive.box('settings');
      // `existing` est null lors d'un premier lancement (onboarding "depuis
      // mon compte OBS") : on crée alors le profil au lieu d'échouer.
      // className/schoolName ne sont JAMAIS synchronisés : toujours saisis
      // manuellement (vides ici s'il n'y a pas encore de profil local ; à
      // renseigner juste après par l'écran d'onboarding).
      final existing = settingsBox.get('profile') as StudentProfile?;

      final updated = StudentProfile(
        name: (nomComplet != null && nomComplet.isNotEmpty)
            ? nomComplet
            : (existing?.name ?? ''),
        className: existing?.className ?? '',
        schoolName: existing?.schoolName ?? '',
        faculty: (faculte != null && faculte.isNotEmpty)
            ? faculte
            : (existing?.faculty ?? ''),
        profilePicturePath: existing?.profilePicturePath,
        subjects: existing?.subjects ?? const [],
      );
      await settingsBox.put('profile', updated);
      return true;
    } on _FullSyncStepException catch (e) {
      errors.add(
        SyncStepError(step: 'profil', errorType: e.code, message: e.message),
      );
      return false;
    } catch (e) {
      errors.add(
        SyncStepError(step: 'profil', errorType: 'unknown', message: '$e'),
      );
      return false;
    }
  }

  // --- Étape 2 : matières (remplacement total depuis les cours suivis) ---

  Future<int> _syncSubjects(
    String baseUrl,
    String apiKey,
    List<SyncStepError> errors,
  ) async {
    try {
      final body = await _fetchJson(baseUrl, apiKey, _subjectsEndpointPath);
      final coursesJson = body['alinan_dersler'];
      if (coursesJson is! List) {
        errors.add(
          const SyncStepError(
            step: 'matieres',
            errorType: 'invalid_format',
            message: 'Champ "alinan_dersler" manquant ou invalide.',
          ),
        );
        return 0;
      }

      final subjects = <String>{};
      for (final rawEntry in coursesJson) {
        if (rawEntry is! Map) continue;
        final matiere = rawEntry['matiere']?.toString().trim();
        if (matiere != null && matiere.isNotEmpty) {
          subjects.add(matiere);
        }
      }

      final subjectsList = subjects.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      final settingsBox = Hive.box('settings');
      // `existing` est null lors d'un premier lancement (onboarding) : on
      // crée alors le profil (école/classe vides, à renseigner ensuite).
      final existing = settingsBox.get('profile') as StudentProfile?;

      final updated = StudentProfile(
        name: existing?.name ?? '',
        className: existing?.className ?? '',
        schoolName: existing?.schoolName ?? '',
        faculty: existing?.faculty ?? '',
        profilePicturePath: existing?.profilePicturePath,
        subjects: subjectsList, // remplacement total, pas de fusion
      );
      await settingsBox.put('profile', updated);
      return subjectsList.length;
    } on _FullSyncStepException catch (e) {
      errors.add(
        SyncStepError(step: 'matieres', errorType: e.code, message: e.message),
      );
      return 0;
    } catch (e) {
      errors.add(
        SyncStepError(step: 'matieres', errorType: 'unknown', message: '$e'),
      );
      return 0;
    }
  }

  // --- Étape 3 : emploi du temps (création/mise à jour des Course) ---

  /// Contrat JSON attendu (confirmé depuis la réponse réelle du backend) :
  /// ```json
  /// {
  ///   "cours": [
  ///     {
  ///       "code": "YZM104",              // optionnel, voir Course.externalCode
  ///       "matiere": "Algoritma ve...",  // titre du cours
  ///       "salle": "EL-Z-16 ...",        // optionnel, emplacement
  ///       "jour": 1,                     // 1 = lundi ... 7 = dimanche
  ///       "heure_debut": "10:00",        // "HH:mm" ou ISO 8601 complet ;
  ///       "heure_fin": "10:45"           // seule l'heure est conservée
  ///       // "professeur" est ignoré : Course n'a pas de champ correspondant.
  ///     }
  ///   ]
  /// }
  /// ```
  /// Les noms `title`/`location`/`dayOfWeeks`/`startTime`/`endTime`/`color`
  /// sont aussi acceptés en repli.
  ///
  /// Un cours reçu correspond à un cours local déjà enregistré si
  /// (dayOfWeeks, heure de début) coïncident ET :
  /// - si le backend fournit un "code", le cours local doit avoir le même
  ///   [Course.externalCode] ;
  /// - sinon, le cours local doit être sans [Course.externalCode] et avoir
  ///   le même [Course.title] (cas d'un cours créé manuellement dans l'app).
  ///
  /// Un cours qui correspond est mis à jour EN PLACE (même `id`) pour ne pas
  /// perdre de notification déjà programmée pour ce cours. Les cours locaux
  /// absents de la réponse ne sont jamais supprimés.
  ///
  /// Pourquoi l'heure de début fait partie de la clé de correspondance (et
  /// pas seulement code + jour) : de nombreux cours ont plusieurs séances le
  /// même jour (ex. "theorie_pratique": "2+2" vu dans les données réelles du
  /// backend = cours théorique + TP, souvent le même jour sous le même
  /// code). Matcher uniquement sur (code, jour) fusionnerait à tort ces
  /// séances distinctes en une seule. En échange, un cours dont l'horaire
  /// change (même code/jour, heure différente) est traité comme un nouveau
  /// cours plutôt qu'une mise à jour de l'ancien — l'ancien créneau (devenu
  /// obsolète) reste dans la box (jamais supprimé, voir ci-dessus) jusqu'à
  /// suppression manuelle par l'utilisateur. Ce compromis a été jugé
  /// préférable : une fusion silencieuse de deux séances réelles distinctes
  /// serait une perte de données plus grave qu'un doublon visible et
  /// corrigeable à la main.
  Future<CourseSyncOutcome> _syncCourses(
    String baseUrl,
    String apiKey,
    List<SyncStepError> errors,
  ) async {
    try {
      final body = await _fetchJson(baseUrl, apiKey, _coursesEndpointPath);
      final coursesJson = body['cours'];
      if (coursesJson is! List) {
        errors.add(
          const SyncStepError(
            step: 'emploi_du_temps',
            errorType: 'invalid_format',
            message: 'Champ "cours" manquant ou invalide.',
          ),
        );
        return _emptyCourseSyncOutcome;
      }

      return await syncCoursesFromJson(coursesJson);
    } on _FullSyncStepException catch (e) {
      errors.add(
        SyncStepError(
          step: 'emploi_du_temps',
          errorType: e.code,
          message: e.message,
        ),
      );
      return _emptyCourseSyncOutcome;
    } catch (e) {
      errors.add(
        SyncStepError(
          step: 'emploi_du_temps',
          errorType: 'unknown',
          message: '$e',
        ),
      );
      return _emptyCourseSyncOutcome;
    }
  }

  static const CourseSyncOutcome _emptyCourseSyncOutcome = (
    created: 0,
    updated: 0,
    skipped: 0,
    sampleSkippedEntry: null,
    createdCourses: [],
    updatedCourses: [],
  );

  /// Applique une liste de cours déjà décodée (contrat JSON documenté sur
  /// [_syncCourses]) à la box Hive `courses` : crée ou met à jour chaque
  /// [Course] correspondant. Séparé de la récupération réseau pour être
  /// testable directement avec des données JSON fabriquées, sans mock HTTP
  /// (voir `test/services/full_sync_service_test.dart`).
  ///
  /// Remonte aussi les [Course] créés/mis à jour (pas seulement leur compte)
  /// pour que l'appelant (voir `ApiSettingsPage`/`ObsAccountSetupPage`) puisse
  /// y programmer un rappel de notification — [FullSyncService] lui-même n'a
  /// pas accès à `AppLocalizations` pour construire le texte de la
  /// notification.
  Future<CourseSyncOutcome> syncCoursesFromJson(
    List<dynamic> coursesJson,
  ) async {
    final box = Hive.box<Course>('courses');
    int created = 0;
    int updated = 0;
    int skipped = 0;
    String? sampleSkippedEntry;
    final createdCourses = <Course>[];
    final updatedCourses = <Course>[];

    for (final rawEntry in coursesJson) {
      if (rawEntry is! Map) {
        skipped++;
        sampleSkippedEntry ??= _describeSkippedEntry(rawEntry);
        debugPrint(
          'FullSyncService: skipping non-object course entry: $rawEntry',
        );
        continue;
      }
      final entry = Map<String, dynamic>.from(rawEntry);

      final _ParsedCourse parsed;
      try {
        parsed = _parseCourse(entry);
      } catch (e) {
        skipped++;
        sampleSkippedEntry ??= _describeSkippedEntry(entry);
        debugPrint('FullSyncService: skipping invalid course entry $entry: $e');
        continue;
      }

      final existing = _findMatchingCourse(box, parsed);

      if (existing != null) {
        final course = parsed.toCourse(id: existing.id);
        await box.put(existing.id, course);
        updatedCourses.add(course);
        updated++;
      } else {
        final newId = const Uuid().v4();
        final course = parsed.toCourse(id: newId);
        await box.put(newId, course);
        createdCourses.add(course);
        created++;
      }
    }

    return (
      created: created,
      updated: updated,
      skipped: skipped,
      sampleSkippedEntry: sampleSkippedEntry,
      createdCourses: createdCourses,
      updatedCourses: updatedCourses,
    );
  }

  /// Un cours avec un "code" reçu du backend ne peut correspondre qu'à un
  /// cours local portant le même [Course.externalCode] : comparer par
  /// [Course.title] serait incorrect si le titre affiché diffère du code.
  /// Un cours sans "code" ne peut correspondre qu'à un cours local qui n'a
  /// lui-même jamais reçu de code (créé manuellement dans l'app).
  Course? _findMatchingCourse(Box<Course> box, _ParsedCourse parsed) {
    for (final course in box.values) {
      final identityMatches = parsed.code != null
          ? course.externalCode == parsed.code
          : (course.externalCode == null && course.title == parsed.title);
      if (!identityMatches) continue;
      if (course.dayOfWeeks != parsed.dayOfWeeks) continue;
      if (course.startTime.hour != parsed.startHour ||
          course.startTime.minute != parsed.startMinute) {
        continue;
      }
      return course;
    }
    return null;
  }

  _ParsedCourse _parseCourse(Map<String, dynamic> entry) {
    final title = (entry['matiere'] ?? entry['title'])?.toString().trim();
    if (title == null || title.isEmpty) {
      throw const FormatException('Champ "matiere"/"title" manquant ou vide');
    }

    final rawCode = entry['code']?.toString().trim();
    final code = (rawCode != null && rawCode.isNotEmpty) ? rawCode : null;

    final dayOfWeeks = _parseInt(entry['jour'] ?? entry['dayOfWeeks']);
    if (dayOfWeeks == null || dayOfWeeks < 1 || dayOfWeeks > 7) {
      throw FormatException(
        'Champ "jour"/"dayOfWeeks" invalide: ${entry['jour'] ?? entry['dayOfWeeks']}',
      );
    }

    final start = _parseTimeOfDay(entry['heure_debut'] ?? entry['startTime']);
    final end = _parseTimeOfDay(entry['heure_fin'] ?? entry['endTime']);
    if (start == null || end == null) {
      throw const FormatException(
        'Champs "heure_debut"/"heure_fin" (ou "startTime"/"endTime") invalides',
      );
    }

    final location = (entry['salle'] ?? entry['location'])?.toString().trim();
    final color = _parseInt(entry['color']) ?? _defaultColor;

    return _ParsedCourse(
      title: title,
      code: code,
      location: (location != null && location.isNotEmpty) ? location : null,
      color: color,
      dayOfWeeks: dayOfWeeks,
      startHour: start.hour,
      startMinute: start.minute,
      endHour: end.hour,
      endMinute: end.minute,
    );
  }

  int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  /// Accepte soit "HH:mm" / "HH:mm:ss", soit une chaîne ISO 8601 complète
  /// (seule l'heure est alors conservée).
  ({int hour, int minute})? _parseTimeOfDay(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;

    final hhmm = RegExp(r'^(\d{1,2}):(\d{2})');
    final match = hhmm.firstMatch(text);
    if (match != null && !text.contains('T')) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      if (hour > 23 || minute > 59) return null;
      return (hour: hour, minute: minute);
    }

    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return (hour: parsed.hour, minute: parsed.minute);
    }
    return null;
  }

  /// Sérialise une entrée ignorée pour affichage/diagnostic (ex: dans l'UI),
  /// afin de voir les vrais noms de champs envoyés par le backend sans avoir
  /// besoin d'outils externes (curl, Postman...).
  String _describeSkippedEntry(Object? entry) {
    try {
      return jsonEncode(entry);
    } catch (_) {
      return entry.toString();
    }
  }

  // --- Requête HTTP partagée ---

  /// Effectue un GET JSON authentifié et remonte une erreur structurée
  /// ([_FullSyncStepException]) en cas d'échec réseau, de timeout, HTTP ou
  /// de réponse illisible.
  Future<Map<String, dynamic>> _fetchJson(
    String baseUrl,
    String apiKey,
    String path,
  ) async {
    final uri = Uri.parse('$baseUrl$path');

    http.Response response;
    try {
      response = await http
          .get(uri, headers: {'X-API-Key': apiKey})
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw const _FullSyncStepException(
        'timeout',
        'Le serveur met du temps à répondre (il était peut-être en veille), '
            'réessaie dans une minute.',
      );
    } catch (e) {
      throw _FullSyncStepException('network_error', e.toString());
    }

    Map<String, dynamic>? body;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {
      // body reste null, géré ci-dessous.
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _classifyHttpError(response.statusCode, body);
    }

    if (body == null) {
      throw const _FullSyncStepException(
        'invalid_response',
        'Réponse du serveur illisible.',
      );
    }

    return body;
  }

  /// Traduit un statut HTTP + corps d'erreur backend en
  /// [_FullSyncStepException] portant un `code` stable ("errorType") que
  /// l'UI mappe vers un message localisé (voir `ApiSettingsPage`). Le
  /// message brut du backend sert de repli si le code n'est pas reconnu.
  _FullSyncStepException _classifyHttpError(
    int statusCode,
    Map<String, dynamic>? body,
  ) {
    final backendErrorCode = body?['error']?.toString();
    final backendMessage = body?['message']?.toString();

    if (statusCode == 401) {
      return _FullSyncStepException(
        'invalid_api_key',
        backendMessage ?? 'Invalid API key',
      );
    }
    if (backendErrorCode == 'session_expired') {
      return _FullSyncStepException(
        'session_expired',
        backendMessage ?? 'OBS session expired',
      );
    }
    if (backendErrorCode == 'obs_unreachable') {
      return _FullSyncStepException(
        'obs_unreachable',
        backendMessage ?? 'OBS unreachable',
      );
    }
    if (backendErrorCode == 'database_unavailable') {
      return _FullSyncStepException(
        'database_unavailable',
        backendMessage ?? 'Database unavailable',
      );
    }
    return _FullSyncStepException(
      backendErrorCode ?? 'http_$statusCode',
      backendMessage ?? 'Erreur serveur ($statusCode).',
    );
  }

  String _stripTrailingSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}

/// Erreur interne d'une étape de synchronisation, portant un code stable
/// ([code], repris tel quel comme [SyncStepError.errorType]) et un message
/// lisible (repris du backend quand disponible).
class _FullSyncStepException implements Exception {
  final String code;
  final String message;

  const _FullSyncStepException(this.code, this.message);
}

/// Cours parsé depuis le JSON distant, avant résolution de son [Course.id]
/// local (cours existant retrouvé, ou nouvel identifiant généré).
class _ParsedCourse {
  final String title;

  /// Code externe fourni par le backend (null si absent de la réponse).
  final String? code;
  final String? location;
  final int color;
  final int dayOfWeeks;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const _ParsedCourse({
    required this.title,
    required this.code,
    required this.location,
    required this.color,
    required this.dayOfWeeks,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  Course toCourse({required String id}) {
    final now = DateTime.now();
    return Course(
      id: id,
      title: title,
      externalCode: code,
      location: location,
      color: color,
      dayOfWeeks: dayOfWeeks,
      startTime: DateTime(now.year, now.month, now.day, startHour, startMinute),
      endTime: DateTime(now.year, now.month, now.day, endHour, endMinute),
    );
  }
}

/// Résultat de l'application d'une liste de cours JSON à la box Hive
/// `courses` (voir [FullSyncService.syncCoursesFromJson]).
typedef CourseSyncOutcome = ({
  int created,
  int updated,
  int skipped,
  String? sampleSkippedEntry,
  List<Course> createdCourses,
  List<Course> updatedCourses,
});

/// Étape de progression d'une synchronisation complète ([FullSyncService.syncAll]).
/// Reflète l'ordre réel d'exécution des 3 requêtes.
enum SyncStep {
  /// Aucune synchronisation en cours.
  idle,

  /// `GET /profil` en cours.
  profile,

  /// `GET /alinan-dersler` en cours.
  subjects,

  /// `GET /emploi-du-temps/export` en cours.
  schedule,
}

/// Erreur d'une étape de synchronisation individuelle.
class SyncStepError {
  /// "profil" | "matieres" | "emploi_du_temps" | "config" (config = URL/clé
  /// non configurées, avant même la première requête).
  final String step;

  /// Code stable identifiant le type d'erreur : "invalid_api_key" (401),
  /// "session_expired", "obs_unreachable", "database_unavailable", "timeout",
  /// "network_error", "missing_config", "invalid_response", "invalid_format",
  /// "no_data", "unknown", ou le code "error" brut renvoyé par le backend
  /// quand il ne correspond à aucun cas connu. L'UI choisit le message
  /// localisé à afficher à partir de ce code (voir `ApiSettingsPage`).
  final String errorType;

  /// Message lisible : repris du champ "message" du backend quand
  /// disponible, sinon une description générique. Sert de repli si l'UI ne
  /// reconnaît pas [errorType].
  final String message;

  const SyncStepError({
    required this.step,
    required this.errorType,
    required this.message,
  });

  @override
  String toString() => '$step: $message';
}

/// Résultat récapitulatif d'une synchronisation complète (profil + matières
/// + emploi du temps).
class FullSyncResult {
  final bool profileUpdated;
  final int subjectsCount;
  final int coursesCreated;
  final int coursesUpdated;
  final int coursesSkipped;

  /// JSON brut de la première entrée de cours ignorée (diagnostic direct
  /// depuis l'UI, sans outil externe).
  final String? sampleSkippedCourseEntry;

  /// Cours créés/mis à jour par cette synchronisation. Exposés (pas
  /// seulement leur nombre) pour que l'appelant puisse y programmer un
  /// rappel de notification (voir `scheduleCourseReminder` dans
  /// `course_reminder_scheduler.dart`) — [FullSyncService] n'a pas accès à
  /// `AppLocalizations` pour construire lui-même le texte des notifications.
  final List<Course> createdCourses;
  final List<Course> updatedCourses;

  /// Une [SyncStepError] par étape en échec. Vide si tout s'est bien passé.
  /// Le succès des autres étapes n'est jamais remis en cause par l'échec de
  /// l'une d'elles (pas de rollback global).
  final List<SyncStepError> errors;

  const FullSyncResult({
    required this.profileUpdated,
    required this.subjectsCount,
    required this.coursesCreated,
    required this.coursesUpdated,
    required this.coursesSkipped,
    required this.sampleSkippedCourseEntry,
    this.createdCourses = const [],
    this.updatedCourses = const [],
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}
