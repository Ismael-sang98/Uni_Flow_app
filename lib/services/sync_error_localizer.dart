import '../l10n/app_localizations.dart';
import 'full_sync_service.dart';

/// `"<Étape> : <message localisé>"` pour une [SyncStepError], ex.
/// "Profil : Clé API invalide, vérifie ta configuration dans les réglages".
/// L'erreur "config" (URL/clé non configurées) n'a pas d'étape à préfixer.
///
/// Partagé entre `ApiSettingsPage` et `ObsAccountSetupPage` (toutes deux
/// affichent des [SyncStepError] issues de `FullSyncService`).
String describeSyncError(AppLocalizations l10n, SyncStepError error) {
  final message = _syncErrorMessage(l10n, error);
  if (error.step == 'config') return message;
  return '${_syncStepLabel(l10n, error.step)} : $message';
}

String _syncStepLabel(AppLocalizations l10n, String step) {
  switch (step) {
    case 'profil':
      return l10n.syncStepProfile;
    case 'matieres':
      return l10n.syncStepSubjects;
    case 'emploi_du_temps':
      return l10n.syncStepSchedule;
    default:
      return step;
  }
}

/// Message localisé pour les codes d'erreur connus ; repli sur le message
/// brut (backend ou description locale) fourni par le service sinon.
String _syncErrorMessage(AppLocalizations l10n, SyncStepError error) {
  switch (error.errorType) {
    case 'invalid_api_key':
      return l10n.syncErrorInvalidApiKey;
    case 'session_expired':
      return l10n.syncErrorSessionExpired;
    case 'obs_unreachable':
      return l10n.syncErrorObsUnreachable;
    case 'database_unavailable':
      return l10n.syncErrorDatabaseUnavailable;
    case 'timeout':
      return l10n.syncErrorTimeout;
    case 'network_error':
      return l10n.syncErrorNetwork;
    case 'missing_config':
      return l10n.syncErrorMissingConfig;
    case 'invalid_response':
      return l10n.syncErrorInvalidResponse;
    case 'invalid_format':
    case 'no_data':
      return l10n.syncErrorInvalidFormat;
    default:
      return error.message;
  }
}
