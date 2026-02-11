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
  String get hintAjoutMatiere => 'Examples: Mathematics, English...';

  @override
  String get btnEnregistrerProfil => 'Save profile';

  @override
  String get addTask => 'New Duty';

  @override
  String get taskTitle => 'Title';

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
  String get location => 'Room (Optional)';

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
}
