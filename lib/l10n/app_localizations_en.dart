// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Student Planner';

  @override
  String get schedule => 'Schedule';

  @override
  String get settings => 'Settings';

  @override
  String get welcomeTitle => 'Organize your\nsuccess.';

  @override
  String get welcomeSubtitle =>
      'Classes, homework, exams...\nYour entire schedule in your pocket.';

  @override
  String get getStartedButton => 'Start now';

  @override
  String get ajoutMatiereErreur => 'Add at least one more material!';

  @override
  String get profilEnregistre => 'Profile updated!';

  @override
  String get labProfil => 'My Profile';

  @override
  String get labMatiere => 'My Recorded Lessons';

  @override
  String get aucuneMatiere => 'No defined subject Lessons.';

  @override
  String get labCrPr => 'Create my profile';

  @override
  String get labMdPr => 'Edit profile';

  @override
  String get btMod => 'Edit';

  @override
  String get labNom => 'Full name';

  @override
  String get labFkt => 'Faculty';

  @override
  String get labCl => 'Class';

  @override
  String get labEc => 'School';

  @override
  String get labSsMat => 'Enter your lessons';

  @override
  String get hintAjoutMatiere => 'Examples: Mathematics...';

  @override
  String get btnEnregistrerProfil => 'Save profile';

  @override
  String get addTask => 'New Duty';

  @override
  String get taskTitle => 'Title';

  @override
  String get notesLibrary => 'Notes Library';

  @override
  String get addNote => 'New Note';

  @override
  String get noteTitle => 'Title';

  @override
  String get noteSubject => 'Subject';

  @override
  String get noteContent => 'Content';

  @override
  String get noteTags => 'Tags (comma separated)';

  @override
  String get noteRequiredFields => 'Title and content are required.';

  @override
  String get noteImages => 'Images';

  @override
  String get addFromGallery => 'Gallery';

  @override
  String get addFromCamera => 'Camera';

  @override
  String get noImagesYet => 'No images yet.';

  @override
  String get noteTagsHelp =>
      'Tags help you group and search notes (e.g. exam, chapter).';

  @override
  String get notesEmpty => 'No notes yet.';

  @override
  String get noteDetails => 'Note details';

  @override
  String get editNote => 'Edit note';

  @override
  String noteCreatedAt(Object date) {
    return 'Created on $date';
  }

  @override
  String noteUpdatedAt(Object date) {
    return 'Updated on $date';
  }

  @override
  String get mt => 'Lessons';

  @override
  String get noSubjectsDefined => 'No lessons defined in the profile';

  @override
  String get dueDate => 'For the :';

  @override
  String get rejet => 'Cancel';

  @override
  String get ajt => 'Add';

  @override
  String get bvn => 'Welcome !';

  @override
  String get planning => 'Planning';

  @override
  String get tasks => 'Tasks';

  @override
  String get pleaseSelectASubject => 'Please select a material.';

  @override
  String get endTimeMustBeAfterStartTime =>
      'The end must come after the beginning.';

  @override
  String get addCourse => 'Add a course';

  @override
  String get noSubjectMnessage => 'No course found!';

  @override
  String get noSubjectExplanation =>
      'You must first define your subjects in your Profile (pencil icon).';

  @override
  String get goBack => 'Back';

  @override
  String get location => 'Room';

  @override
  String get day => 'Day';

  @override
  String get j1 => 'Monday';

  @override
  String get j2 => 'Tuesday';

  @override
  String get j3 => 'Wednesday';

  @override
  String get j4 => 'Thursday';

  @override
  String get j5 => 'Friday';

  @override
  String get j6 => 'Saturday';

  @override
  String get j7 => 'Sunday';

  @override
  String get startLab => 'Start';

  @override
  String get endLab => 'End';

  @override
  String get selectColor => 'Color';

  @override
  String get savePlan => 'Add to planning';

  @override
  String get videLab => 'Nothing planned';

  @override
  String get videTacheLab => 'There is no task.';

  @override
  String get jAb1 => 'Mon';

  @override
  String get jAb2 => 'Tue';

  @override
  String get jAb3 => 'Wed';

  @override
  String get jAb4 => 'Thu';

  @override
  String get jAb5 => 'Fri';

  @override
  String get jAb6 => 'Sat';

  @override
  String get jAb7 => 'Sun';

  @override
  String get confirmSupprTitle => 'Confirm deletion';

  @override
  String get mess1 => 'Do you really want to delete it?';

  @override
  String get mess2 => 'This action is irreversible.';

  @override
  String get supp => 'Delete';

  @override
  String get labLocation => 'Unspecified room';

  @override
  String get hrs => 'Hour';

  @override
  String get courseDetails => 'Course details';

  @override
  String get save => 'Save';

  @override
  String get editCours => 'Edit the course';

  @override
  String get courseUpdated => 'Course modified !';

  @override
  String get courseAdded => 'Course added !';

  @override
  String get exactAlarmTitle => 'Allow exact alarms';

  @override
  String get exactAlarmMessage =>
      'To ensure scheduled reminders, enable the \"Alarms & reminders\" permission in system settings.';

  @override
  String get notificationPermissionTitle => 'Allow notifications';

  @override
  String get notificationPermissionMessage =>
      'To receive reminders, allow notifications in system settings.';

  @override
  String get later => 'Later';

  @override
  String get openSettings => 'Open settings';

  @override
  String get courseReminderTitle => 'Course reminder!';

  @override
  String courseReminderBody(Object courseTitle, Object locationSuffix) {
    return 'Your course of $courseTitle starts in 10 minutes$locationSuffix.';
  }

  @override
  String courseReminderLocationSuffix(Object room) {
    return ' in room $room';
  }

  @override
  String get courseNotFound => 'Course not found';

  @override
  String get deleteCourseMessage => 'Do you really want to delete this course?';

  @override
  String get testNotifButton => 'Test notification';

  @override
  String get testInstantTitle => 'Instant test';

  @override
  String get testInstantBody => 'If you see this, the channel works!';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get madeWithLoveBy => 'Made with love by ';

  @override
  String get weeklyNotificationScheduled => '✓ Weekly notification scheduled';

  @override
  String weeklyReminderMessage(Object courseName, Object date) {
    return 'Reminder every week 10 min before \"$courseName\" on $date';
  }

  @override
  String get courseTooClose => 'Course too close';

  @override
  String courseTooCloseMessage(Object courseName) {
    return 'The course \"$courseName\" is too close to schedule a notification.';
  }

  @override
  String notificationError(Object error) {
    return 'Notification error: $error';
  }

  @override
  String notificationInMinutes(Object minutes) {
    return 'in $minutes min';
  }

  @override
  String notificationInHoursMinutes(Object hours, Object minutes) {
    return 'in $hours h $minutes min';
  }

  @override
  String notificationOnDate(
    Object dayShort,
    Object day,
    Object month,
    Object hour,
    Object minute,
  ) {
    return '$dayShort $day/$month at $hour:$minute';
  }

  @override
  String get shareNoteImage => 'Image from my note';

  @override
  String charactersCount(Object count) {
    return '$count characters';
  }

  @override
  String get requiredField => 'Required *';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String updateCurrentVersion(Object version) {
    return 'Current version: $version';
  }

  @override
  String updateNewVersion(Object version) {
    return 'New version: $version';
  }

  @override
  String get updateWhatsNew => 'What\'s new:';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownload => 'Download';

  @override
  String get updateTestTitle => 'Update Test';

  @override
  String get updateReadyToTest => 'Ready to test';

  @override
  String get updateChecking => 'Checking...';

  @override
  String get updateAvailableStatus => '✅ Update available!';

  @override
  String get updateUpToDate => '✅ You have the latest version';

  @override
  String updateError(Object error) {
    return '❌ Error: $error';
  }

  @override
  String get updateInfo => '📱 Information';

  @override
  String get updateCurrentVersionLabel => 'Current version';

  @override
  String get updateLatestVersionLabel => 'Latest version';

  @override
  String get updateHowToTest => 'How to test?';

  @override
  String updateTestInstructions(Object version) {
    return '1. Use \"Simulate\" to see the update dialog\n\n2. Or create a GitHub release with a version higher than $version and click \"Check\"';
  }

  @override
  String get updateSimulate => '🧪 Simulate an update';

  @override
  String get updateCheckGitHub => '🔍 Check on GitHub';

  @override
  String get updateGitHubRelease => '📦 GitHub Release';

  @override
  String get updateReleaseInstructions =>
      'To create a test release:\n1. github.com/Ismael-sang98/Uni_Flow_app/releases/new\n2. Tag: v1.5.6 (or higher)\n3. Upload an APK\n4. Publish';

  @override
  String get updateSimulationNote =>
      'This is a simulation to test the update dialog.';
}
