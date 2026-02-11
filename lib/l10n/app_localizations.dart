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
  /// **'Examples: Mathematics, English...'**
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
  /// **'Room (Optional)'**
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
