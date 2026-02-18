// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mon Planning';

  @override
  String get schedule => 'Emploi du temps';

  @override
  String get settings => 'Paramètres';

  @override
  String get welcomeTitle => 'Organisez votre\nréussite.';

  @override
  String get welcomeSubtitle =>
      'Cours, devoirs, examens...\nTout votre planning dans votre poche.';

  @override
  String get getStartedButton => 'Commencer maintenant';

  @override
  String get ajoutMatiereErreur => 'Ajoutez au moins une matière !';

  @override
  String get profilEnregistre => 'Profil mis à jour !';

  @override
  String get labProfil => 'Mon Profil';

  @override
  String get labMatiere => 'Mes Matières Enregistrées';

  @override
  String get aucuneMatiere => 'Aucune matière définie.';

  @override
  String get labCrPr => 'Créer mon profil';

  @override
  String get labMdPr => 'Modifier le profil';

  @override
  String get btMod => 'Modifier';

  @override
  String get labNom => 'Nom complet';

  @override
  String get labFkt => 'Faculté';

  @override
  String get labCl => 'Classe';

  @override
  String get labEc => 'École';

  @override
  String get labSsMat => 'Saisissez vos matières';

  @override
  String get hintAjoutMatiere => 'Ex: Mathematique...';

  @override
  String get btnEnregistrerProfil => 'Enregistrer le profil';

  @override
  String get addTask => 'Nouveau Devoir';

  @override
  String get taskTitle => 'Titre';

  @override
  String get notesLibrary => 'Bibliothèque de notes';

  @override
  String get addNote => 'Nouvelle note';

  @override
  String get noteTitle => 'Titre';

  @override
  String get noteSubject => 'Matière';

  @override
  String get noteContent => 'Contenu';

  @override
  String get noteTags => 'Tags (séparés par des virgules)';

  @override
  String get noteRequiredFields => 'Le titre et le contenu sont obligatoires.';

  @override
  String get noteImages => 'Images';

  @override
  String get addFromGallery => 'Galerie';

  @override
  String get addFromCamera => 'Caméra';

  @override
  String get noImagesYet => 'Aucune image pour l\'instant.';

  @override
  String get noteTagsHelp =>
      'Les tags servent à classer et retrouver les notes (ex: examen, chapitre).';

  @override
  String get notesEmpty => 'Aucune note pour l\'instant.';

  @override
  String get noteDetails => 'Détails de la note';

  @override
  String get editNote => 'Modifier la note';

  @override
  String noteCreatedAt(Object date) {
    return 'Créée le $date';
  }

  @override
  String noteUpdatedAt(Object date) {
    return 'Modifiée le $date';
  }

  @override
  String get mt => 'Matière';

  @override
  String get noSubjectsDefined => 'Aucune matière définie dans le profil';

  @override
  String get dueDate => 'Pour le :';

  @override
  String get rejet => 'Annuler';

  @override
  String get ajt => 'Ajouter';

  @override
  String get bvn => 'Bienvenue !';

  @override
  String get planning => 'Planning';

  @override
  String get tasks => 'Tâches';

  @override
  String get pleaseSelectASubject => 'Veuillez sélectionner une matière';

  @override
  String get endTimeMustBeAfterStartTime => 'La fin doit être après le début';

  @override
  String get addCourse => 'Ajouter un cours';

  @override
  String get noSubjectMnessage => 'Aucune matière trouvée !';

  @override
  String get noSubjectExplanation =>
      'Vous devez d\'abord définir vos matières dans votre Profil (icône stylo).';

  @override
  String get goBack => 'Retour';

  @override
  String get location => 'Salle';

  @override
  String get day => 'Jour';

  @override
  String get j1 => 'Lundi';

  @override
  String get j2 => 'Mardi';

  @override
  String get j3 => 'Mercredi';

  @override
  String get j4 => 'Jeudi';

  @override
  String get j5 => 'Vendredi';

  @override
  String get j6 => 'Samedi';

  @override
  String get j7 => 'Dimanche';

  @override
  String get startLab => 'Début';

  @override
  String get endLab => 'Fin';

  @override
  String get selectColor => 'Couleur';

  @override
  String get savePlan => 'Ajouter au planning';

  @override
  String get videLab => 'Rien de prévu';

  @override
  String get videTacheLab => 'Il n\'y a pas de Tâche.';

  @override
  String get jAb1 => 'Lun';

  @override
  String get jAb2 => 'Mar';

  @override
  String get jAb3 => 'Mer';

  @override
  String get jAb4 => 'Jeu';

  @override
  String get jAb5 => 'Ven';

  @override
  String get jAb6 => 'Sam';

  @override
  String get jAb7 => 'Dim';

  @override
  String get confirmSupprTitle => 'Confirmer la suppression';

  @override
  String get mess1 => 'Voulez-vous vraiment supprimer?';

  @override
  String get mess2 => 'Cette action est irréversible.';

  @override
  String get supp => 'Supprimer';

  @override
  String get labLocation => 'Salle non spécifié';

  @override
  String get hrs => 'Horaires';

  @override
  String get courseDetails => 'Détails du cours';

  @override
  String get save => 'Sauvegarder';

  @override
  String get editCours => 'Modifier le cours';

  @override
  String get courseUpdated => 'Cours modifié !';

  @override
  String get courseAdded => 'Cours ajouté !';

  @override
  String get exactAlarmTitle => 'Autoriser les alarmes exactes';

  @override
  String get exactAlarmMessage =>
      'Pour garantir les rappels programmés, activez l\'autorisation \"Alarmes et rappels\" dans les réglages système.';

  @override
  String get notificationPermissionTitle => 'Autoriser les notifications';

  @override
  String get notificationPermissionMessage =>
      'Pour recevoir les rappels, autorisez les notifications dans les réglages système.';

  @override
  String get later => 'Plus tard';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get courseReminderTitle => 'Rappel de cours !';

  @override
  String courseReminderBody(Object courseTitle, Object locationSuffix) {
    return 'Votre cours de $courseTitle commence dans 10 minutes$locationSuffix.';
  }

  @override
  String courseReminderLocationSuffix(Object room) {
    return ' en salle $room';
  }

  @override
  String get courseNotFound => 'Cours introuvable';

  @override
  String get deleteCourseMessage => 'Voulez-vous vraiment supprimer ce cours ?';

  @override
  String get testNotifButton => 'Tester notif';

  @override
  String get testInstantTitle => 'Test instantané';

  @override
  String get testInstantBody => 'Si vous voyez ceci, le canal fonctionne !';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get madeWithLoveBy => 'Fait avec amour par ';

  @override
  String get weeklyNotificationScheduled =>
      '✓ Notification hebdomadaire programmée';

  @override
  String weeklyReminderMessage(Object courseName, Object date) {
    return 'Rappel chaque semaine 10 min avant \"$courseName\" le $date';
  }

  @override
  String get courseTooClose => 'Cours trop proche';

  @override
  String courseTooCloseMessage(Object courseName) {
    return 'Le cours \"$courseName\" est trop proche pour programmer une notification.';
  }

  @override
  String notificationError(Object error) {
    return 'Erreur notification: $error';
  }

  @override
  String notificationInMinutes(Object minutes) {
    return 'dans $minutes min';
  }

  @override
  String notificationInHoursMinutes(Object hours, Object minutes) {
    return 'dans $hours h $minutes min';
  }

  @override
  String notificationOnDate(
    Object dayShort,
    Object day,
    Object month,
    Object hour,
    Object minute,
  ) {
    return '$dayShort $day/$month a $hour:$minute';
  }

  @override
  String get shareNoteImage => 'Image de ma note';

  @override
  String charactersCount(Object count) {
    return '$count caractères';
  }

  @override
  String get requiredField => 'Requis *';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String updateCurrentVersion(Object version) {
    return 'Version actuelle: $version';
  }

  @override
  String updateNewVersion(Object version) {
    return 'Nouvelle version: $version';
  }

  @override
  String get updateWhatsNew => 'Nouveautés:';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateTestTitle => 'Test Mise à Jour';

  @override
  String get updateReadyToTest => 'Prêt à tester';

  @override
  String get updateChecking => 'Vérification en cours...';

  @override
  String get updateAvailableStatus => '✅ Mise à jour disponible!';

  @override
  String get updateUpToDate => '✅ Vous avez la dernière version';

  @override
  String updateError(Object error) {
    return '❌ Erreur: $error';
  }

  @override
  String get updateInfo => '📱 Informations';

  @override
  String get updateCurrentVersionLabel => 'Version actuelle';

  @override
  String get updateLatestVersionLabel => 'Dernière version';

  @override
  String get updateHowToTest => 'Comment tester ?';

  @override
  String updateTestInstructions(Object version) {
    return '1. Utilise \"Simuler\" pour voir le dialogue de mise à jour\n\n2. Ou crée une release GitHub avec une version supérieure à $version et clique sur \"Vérifier\"';
  }

  @override
  String get updateSimulate => '🧪 Simuler une mise à jour';

  @override
  String get updateCheckGitHub => '🔍 Vérifier sur GitHub';

  @override
  String get updateGitHubRelease => '📦 Release GitHub';

  @override
  String get updateReleaseInstructions =>
      'Pour créer une release de test:\n1. github.com/Ismael-sang98/Uni_Flow_app/releases/new\n2. Tag: v1.5.6 (ou supérieur)\n3. Upload un APK\n4. Publier';

  @override
  String get updateSimulationNote =>
      'Ceci est une simulation pour tester le dialogue de mise à jour.';
}
