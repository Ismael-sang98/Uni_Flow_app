import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Planner'**
  String get appTitle;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your\nsuccess.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Classes, homework, exams...\nYour entire schedule in your pocket.'**
  String get welcomeSubtitle;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get getStartedButton;

  /// No description provided for @ajoutMatiereErreur.
  ///
  /// In en, this message translates to:
  /// **'Add at least one more material!'**
  String get ajoutMatiereErreur;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile: {error}'**
  String profileSaveError(Object error);

  /// No description provided for @profilEnregistre.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profilEnregistre;

  /// No description provided for @labProfil.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get labProfil;

  /// No description provided for @labMatiere.
  ///
  /// In en, this message translates to:
  /// **'My Recorded Lessons'**
  String get labMatiere;

  /// No description provided for @aucuneMatiere.
  ///
  /// In en, this message translates to:
  /// **'No defined subject Lessons.'**
  String get aucuneMatiere;

  /// No description provided for @labCrPr.
  ///
  /// In en, this message translates to:
  /// **'Create my profile'**
  String get labCrPr;

  /// No description provided for @labMdPr.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get labMdPr;

  /// No description provided for @btMod.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btMod;

  /// No description provided for @labNom.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get labNom;

  /// No description provided for @labFkt.
  ///
  /// In en, this message translates to:
  /// **'Faculty'**
  String get labFkt;

  /// No description provided for @labCl.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get labCl;

  /// No description provided for @labEc.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get labEc;

  /// No description provided for @labSsMat.
  ///
  /// In en, this message translates to:
  /// **'Enter your lessons'**
  String get labSsMat;

  /// No description provided for @hintAjoutMatiere.
  ///
  /// In en, this message translates to:
  /// **'Examples: Mathematics...'**
  String get hintAjoutMatiere;

  /// No description provided for @btnEnregistrerProfil.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get btnEnregistrerProfil;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'New Duty'**
  String get addTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitle;

  /// No description provided for @notesLibrary.
  ///
  /// In en, this message translates to:
  /// **'Notes Library'**
  String get notesLibrary;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get addNote;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get noteTitle;

  /// No description provided for @noteSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get noteSubject;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get noteContent;

  /// No description provided for @noteTags.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get noteTags;

  /// No description provided for @noteRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Title and content are required.'**
  String get noteRequiredFields;

  /// No description provided for @noteImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get noteImages;

  /// No description provided for @addFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get addFromGallery;

  /// No description provided for @addFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get addFromCamera;

  /// No description provided for @noImagesYet.
  ///
  /// In en, this message translates to:
  /// **'No images yet.'**
  String get noImagesYet;

  /// No description provided for @noteTagsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tags help you group and search notes (e.g. exam, chapter).'**
  String get noteTagsHelp;

  /// No description provided for @notesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get notesEmpty;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note details'**
  String get noteDetails;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @noteCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String noteCreatedAt(Object date);

  /// No description provided for @noteUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated on {date}'**
  String noteUpdatedAt(Object date);

  /// No description provided for @mt.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get mt;

  /// No description provided for @noSubjectsDefined.
  ///
  /// In en, this message translates to:
  /// **'No lessons defined in the profile'**
  String get noSubjectsDefined;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'For the :'**
  String get dueDate;

  /// No description provided for @rejet.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get rejet;

  /// No description provided for @ajt.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get ajt;

  /// No description provided for @bvn.
  ///
  /// In en, this message translates to:
  /// **'Welcome !'**
  String get bvn;

  /// No description provided for @planning.
  ///
  /// In en, this message translates to:
  /// **'Planning'**
  String get planning;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @pleaseSelectASubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a material.'**
  String get pleaseSelectASubject;

  /// No description provided for @endTimeMustBeAfterStartTime.
  ///
  /// In en, this message translates to:
  /// **'The end must come after the beginning.'**
  String get endTimeMustBeAfterStartTime;

  /// No description provided for @addCourse.
  ///
  /// In en, this message translates to:
  /// **'Add a course'**
  String get addCourse;

  /// No description provided for @noSubjectMnessage.
  ///
  /// In en, this message translates to:
  /// **'No course found!'**
  String get noSubjectMnessage;

  /// No description provided for @noSubjectExplanation.
  ///
  /// In en, this message translates to:
  /// **'You must first define your subjects in your Profile (pencil icon).'**
  String get noSubjectExplanation;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get goBack;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get location;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @j1.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get j1;

  /// No description provided for @j2.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get j2;

  /// No description provided for @j3.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get j3;

  /// No description provided for @j4.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get j4;

  /// No description provided for @j5.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get j5;

  /// No description provided for @j6.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get j6;

  /// No description provided for @j7.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get j7;

  /// No description provided for @startLab.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLab;

  /// No description provided for @endLab.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLab;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get selectColor;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Add to planning'**
  String get savePlan;

  /// No description provided for @videLab.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned'**
  String get videLab;

  /// No description provided for @videTacheLab.
  ///
  /// In en, this message translates to:
  /// **'There is no task.'**
  String get videTacheLab;

  /// No description provided for @jAb1.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get jAb1;

  /// No description provided for @jAb2.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get jAb2;

  /// No description provided for @jAb3.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get jAb3;

  /// No description provided for @jAb4.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get jAb4;

  /// No description provided for @jAb5.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get jAb5;

  /// No description provided for @jAb6.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get jAb6;

  /// No description provided for @jAb7.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get jAb7;

  /// No description provided for @confirmSupprTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmSupprTitle;

  /// No description provided for @mess1.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete it?'**
  String get mess1;

  /// No description provided for @mess2.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.'**
  String get mess2;

  /// No description provided for @supp.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get supp;

  /// No description provided for @labLocation.
  ///
  /// In en, this message translates to:
  /// **'Unspecified room'**
  String get labLocation;

  /// No description provided for @hrs.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hrs;

  /// No description provided for @courseDetails.
  ///
  /// In en, this message translates to:
  /// **'Course details'**
  String get courseDetails;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editCours.
  ///
  /// In en, this message translates to:
  /// **'Edit the course'**
  String get editCours;

  /// No description provided for @courseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Course modified !'**
  String get courseUpdated;

  /// No description provided for @courseAdded.
  ///
  /// In en, this message translates to:
  /// **'Course added !'**
  String get courseAdded;

  /// No description provided for @exactAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow exact alarms'**
  String get exactAlarmTitle;

  /// No description provided for @exactAlarmMessage.
  ///
  /// In en, this message translates to:
  /// **'To ensure scheduled reminders, enable the \"Alarms & reminders\" permission in system settings.'**
  String get exactAlarmMessage;

  /// No description provided for @notificationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notificationPermissionTitle;

  /// No description provided for @notificationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To receive reminders, allow notifications in system settings.'**
  String get notificationPermissionMessage;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @courseReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Course reminder!'**
  String get courseReminderTitle;

  /// No description provided for @courseReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Your course of {courseTitle} starts in 10 minutes{locationSuffix}.'**
  String courseReminderBody(Object courseTitle, Object locationSuffix);

  /// No description provided for @courseReminderLocationSuffix.
  ///
  /// In en, this message translates to:
  /// **' in room {room}'**
  String courseReminderLocationSuffix(Object room);

  /// No description provided for @courseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Course not found'**
  String get courseNotFound;

  /// No description provided for @deleteCourseMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete this course?'**
  String get deleteCourseMessage;

  /// No description provided for @testNotifButton.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get testNotifButton;

  /// No description provided for @testInstantTitle.
  ///
  /// In en, this message translates to:
  /// **'Instant test'**
  String get testInstantTitle;

  /// No description provided for @testInstantBody.
  ///
  /// In en, this message translates to:
  /// **'If you see this, the channel works!'**
  String get testInstantBody;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);

  /// No description provided for @madeWithLoveBy.
  ///
  /// In en, this message translates to:
  /// **'Made with love by '**
  String get madeWithLoveBy;

  /// No description provided for @weeklyNotificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'✓ Weekly notification scheduled'**
  String get weeklyNotificationScheduled;

  /// No description provided for @weeklyReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Reminder every week 10 min before \"{courseName}\" on {date}'**
  String weeklyReminderMessage(Object courseName, Object date);

  /// No description provided for @courseTooClose.
  ///
  /// In en, this message translates to:
  /// **'Course too close'**
  String get courseTooClose;

  /// No description provided for @courseTooCloseMessage.
  ///
  /// In en, this message translates to:
  /// **'The course \"{courseName}\" is too close to schedule a notification.'**
  String courseTooCloseMessage(Object courseName);

  /// No description provided for @notificationError.
  ///
  /// In en, this message translates to:
  /// **'Notification error: {error}'**
  String notificationError(Object error);

  /// No description provided for @notificationInMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes} min'**
  String notificationInMinutes(Object minutes);

  /// No description provided for @notificationInHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours} h {minutes} min'**
  String notificationInHoursMinutes(Object hours, Object minutes);

  /// No description provided for @notificationOnDate.
  ///
  /// In en, this message translates to:
  /// **'{dayShort} {day}/{month} at {hour}:{minute}'**
  String notificationOnDate(
    Object dayShort,
    Object day,
    Object month,
    Object hour,
    Object minute,
  );

  /// No description provided for @shareNoteImage.
  ///
  /// In en, this message translates to:
  /// **'Image from my note'**
  String get shareNoteImage;

  /// No description provided for @charactersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String charactersCount(Object count);

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required *'**
  String get requiredField;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String updateCurrentVersion(Object version);

  /// No description provided for @updateNewVersion.
  ///
  /// In en, this message translates to:
  /// **'New version: {version}'**
  String updateNewVersion(Object version);

  /// No description provided for @updateWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s new:'**
  String get updateWhatsNew;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownload;

  /// No description provided for @updateTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Test'**
  String get updateTestTitle;

  /// No description provided for @updateReadyToTest.
  ///
  /// In en, this message translates to:
  /// **'Ready to test'**
  String get updateReadyToTest;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get updateChecking;

  /// No description provided for @updateAvailableStatus.
  ///
  /// In en, this message translates to:
  /// **'✅ Update available!'**
  String get updateAvailableStatus;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'✅ You have the latest version'**
  String get updateUpToDate;

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error: {error}'**
  String updateError(Object error);

  /// No description provided for @updateInfo.
  ///
  /// In en, this message translates to:
  /// **'📱 Information'**
  String get updateInfo;

  /// No description provided for @updateCurrentVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get updateCurrentVersionLabel;

  /// No description provided for @updateLatestVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get updateLatestVersionLabel;

  /// No description provided for @updateHowToTest.
  ///
  /// In en, this message translates to:
  /// **'How to test?'**
  String get updateHowToTest;

  /// No description provided for @updateTestInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Use \"Simulate\" to see the update dialog\n\n2. Or create a GitHub release with a version higher than {version} and click \"Check\"'**
  String updateTestInstructions(Object version);

  /// No description provided for @updateSimulate.
  ///
  /// In en, this message translates to:
  /// **'🧪 Simulate an update'**
  String get updateSimulate;

  /// No description provided for @updateCheckGitHub.
  ///
  /// In en, this message translates to:
  /// **'🔍 Check on GitHub'**
  String get updateCheckGitHub;

  /// No description provided for @updateGitHubRelease.
  ///
  /// In en, this message translates to:
  /// **'📦 GitHub Release'**
  String get updateGitHubRelease;

  /// No description provided for @updateReleaseInstructions.
  ///
  /// In en, this message translates to:
  /// **'To create a test release:\n1. github.com/Ismael-sang98/Uni_Flow_app/releases/new\n2. Tag: v1.5.6 (or higher)\n3. Upload an APK\n4. Publish'**
  String get updateReleaseInstructions;

  /// No description provided for @updateSimulationNote.
  ///
  /// In en, this message translates to:
  /// **'This is a simulation to test the update dialog.'**
  String get updateSimulationNote;

  /// No description provided for @notesCreateNotebook.
  ///
  /// In en, this message translates to:
  /// **'Create a notebook'**
  String get notesCreateNotebook;

  /// No description provided for @notesNotebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get notesNotebook;

  /// No description provided for @notesNotebookName.
  ///
  /// In en, this message translates to:
  /// **'Notebook name'**
  String get notesNotebookName;

  /// No description provided for @notesNotebookRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a notebook'**
  String get notesNotebookRequired;

  /// No description provided for @notesNoNotebook.
  ///
  /// In en, this message translates to:
  /// **'No notebook available'**
  String get notesNoNotebook;

  /// No description provided for @notesDeleteNotebookPrompt.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the notebook \"{name}\"?'**
  String notesDeleteNotebookPrompt(String name);

  /// No description provided for @notesDeleteNotebookKeepPages.
  ///
  /// In en, this message translates to:
  /// **'Delete notebook, keep pages'**
  String get notesDeleteNotebookKeepPages;

  /// No description provided for @notesDeleteNotebookDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete notebook + pages'**
  String get notesDeleteNotebookDeleteAll;

  /// No description provided for @notesPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =0{page} =1{page} other{pages}}'**
  String notesPagesCount(int count);

  /// No description provided for @noteFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get noteFiles;

  /// No description provided for @noteAddFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get noteAddFile;

  /// No description provided for @noteNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No files added.'**
  String get noteNoFiles;

  /// No description provided for @noteImageCaptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo caption'**
  String get noteImageCaptionTitle;

  /// No description provided for @noteImageCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get noteImageCaptionLabel;

  /// No description provided for @noteImageCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: Results chart...'**
  String get noteImageCaptionHint;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggested;

  /// No description provided for @notesOrCustomName.
  ///
  /// In en, this message translates to:
  /// **'Or create a custom notebook'**
  String get notesOrCustomName;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @notesSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes found'**
  String get notesSearchEmpty;

  /// No description provided for @apiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'API settings'**
  String get apiSettingsTitle;

  /// No description provided for @apiSettingsBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Backend base URL'**
  String get apiSettingsBaseUrlLabel;

  /// No description provided for @apiSettingsBaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://my-app.onrender.com'**
  String get apiSettingsBaseUrlHint;

  /// No description provided for @apiSettingsApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API key (X-API-Key)'**
  String get apiSettingsApiKeyLabel;

  /// No description provided for @apiSettingsApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Your API key'**
  String get apiSettingsApiKeyHint;

  /// No description provided for @apiSettingsInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL starting with http:// or https://'**
  String get apiSettingsInvalidUrl;

  /// No description provided for @apiSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'API settings saved'**
  String get apiSettingsSaved;

  /// No description provided for @apiSettingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load API settings: {error}'**
  String apiSettingsLoadError(Object error);

  /// No description provided for @apiSettingsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save API settings: {error}'**
  String apiSettingsSaveError(Object error);

  /// No description provided for @apiSettingsTestButton.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get apiSettingsTestButton;

  /// No description provided for @apiSettingsTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get apiSettingsTestSuccess;

  /// No description provided for @apiSettingsTestInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key'**
  String get apiSettingsTestInvalidKey;

  /// No description provided for @apiSettingsTestHttpError.
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode})'**
  String apiSettingsTestHttpError(Object statusCode);

  /// No description provided for @apiSettingsTestNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Backend unreachable: {error}'**
  String apiSettingsTestNetworkError(Object error);

  /// No description provided for @fullSyncButton.
  ///
  /// In en, this message translates to:
  /// **'Synchronize'**
  String get fullSyncButton;

  /// No description provided for @fullSyncProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get fullSyncProfileUpdated;

  /// No description provided for @fullSyncProfileNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile unchanged'**
  String get fullSyncProfileNotUpdated;

  /// No description provided for @fullSyncSubjectsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} subject(s) synced'**
  String fullSyncSubjectsCount(Object count);

  /// No description provided for @fullSyncCoursesCount.
  ///
  /// In en, this message translates to:
  /// **'{created} course(s) created, {updated} updated'**
  String fullSyncCoursesCount(Object created, Object updated);

  /// No description provided for @scheduleSyncSkippedInfo.
  ///
  /// In en, this message translates to:
  /// **'{skipped} entry(ies) ignored (unexpected format)'**
  String scheduleSyncSkippedInfo(Object skipped);

  /// No description provided for @scheduleSyncSampleDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Ignored entry (raw data)'**
  String get scheduleSyncSampleDialogTitle;

  /// No description provided for @scheduleSyncSampleDialogHint.
  ///
  /// In en, this message translates to:
  /// **'This is the JSON received for one of the ignored entries. Share this with the developer so the expected format can be fixed.'**
  String get scheduleSyncSampleDialogHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @onboardingChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you want to get started?'**
  String get onboardingChoiceTitle;

  /// No description provided for @onboardingChoiceObsTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up from my OBS account'**
  String get onboardingChoiceObsTitle;

  /// No description provided for @onboardingChoiceObsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically import your profile, subjects and class schedule.'**
  String get onboardingChoiceObsDescription;

  /// No description provided for @onboardingChoiceManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual setup'**
  String get onboardingChoiceManualTitle;

  /// No description provided for @onboardingChoiceManualDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in your profile and courses yourself.'**
  String get onboardingChoiceManualDescription;

  /// No description provided for @obsSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'OBS account'**
  String get obsSetupTitle;

  /// No description provided for @obsSetupDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your backend URL and API key to automatically sync your profile, subjects and class schedule.'**
  String get obsSetupDescription;

  /// No description provided for @obsSetupConnectButton.
  ///
  /// In en, this message translates to:
  /// **'Connect and sync'**
  String get obsSetupConnectButton;

  /// No description provided for @obsSetupNoProfileError.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve your profile from this account. Check the URL and API key.'**
  String get obsSetupNoProfileError;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Last step'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your school and class to finish setting up.'**
  String get completeProfileDescription;

  /// No description provided for @completeProfileContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get completeProfileContinueButton;

  /// No description provided for @syncStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get syncStepProfile;

  /// No description provided for @syncStepSubjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get syncStepSubjects;

  /// No description provided for @syncStepSchedule.
  ///
  /// In en, this message translates to:
  /// **'Class schedule'**
  String get syncStepSchedule;

  /// No description provided for @syncErrorInvalidApiKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API key, check your settings configuration'**
  String get syncErrorInvalidApiKey;

  /// No description provided for @syncErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'The OBS session expired on the server side, a manual re-sync is needed on your end'**
  String get syncErrorSessionExpired;

  /// No description provided for @syncErrorObsUnreachable.
  ///
  /// In en, this message translates to:
  /// **'The university system isn\'t responding right now, try again later'**
  String get syncErrorObsUnreachable;

  /// No description provided for @syncErrorDatabaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The backend server has a temporary issue, try again later'**
  String get syncErrorDatabaseUnavailable;

  /// No description provided for @syncErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking a while to respond (it may have been asleep), try again in a minute.'**
  String get syncErrorTimeout;

  /// No description provided for @syncErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server, check your connection and the configured URL'**
  String get syncErrorNetwork;

  /// No description provided for @syncErrorMissingConfig.
  ///
  /// In en, this message translates to:
  /// **'The backend URL and API key must be configured.'**
  String get syncErrorMissingConfig;

  /// No description provided for @syncErrorInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'Unreadable server response.'**
  String get syncErrorInvalidResponse;

  /// No description provided for @syncErrorInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response format from the server.'**
  String get syncErrorInvalidFormat;

  /// No description provided for @syncProgressProfile.
  ///
  /// In en, this message translates to:
  /// **'Syncing profile...'**
  String get syncProgressProfile;

  /// No description provided for @syncProgressSubjects.
  ///
  /// In en, this message translates to:
  /// **'Syncing subjects...'**
  String get syncProgressSubjects;

  /// No description provided for @syncProgressSchedule.
  ///
  /// In en, this message translates to:
  /// **'Syncing class schedule...'**
  String get syncProgressSchedule;

  /// No description provided for @lastSyncLabel.
  ///
  /// In en, this message translates to:
  /// **'Last sync: {value}'**
  String lastSyncLabel(Object value);

  /// No description provided for @lastSyncNever.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get lastSyncNever;

  /// No description provided for @lastSyncJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get lastSyncJustNow;

  /// No description provided for @lastSyncMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String lastSyncMinutesAgo(Object minutes);

  /// No description provided for @lastSyncHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String lastSyncHoursAgo(Object hours);

  /// No description provided for @lastSyncDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} d ago'**
  String lastSyncDaysAgo(Object days);

  /// No description provided for @subjectsEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet — sync your OBS account or add one manually'**
  String get subjectsEmptyStateMessage;

  /// No description provided for @subjectsEmptyStateManualButton.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get subjectsEmptyStateManualButton;

  /// No description provided for @scheduleEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'No classes imported yet — sync your OBS account to fill in your class schedule'**
  String get scheduleEmptyStateMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
