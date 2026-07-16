# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

UniFlow (package name `mon_temps`) is an offline-first Flutter student planner app. It manages a weekly class schedule with notifications, a notebook-based note-taking system with image/attachment support, and a student profile — all persisted locally via Hive, with no backend. UI text is fully localized (French, English, Turkish).

## Commands

```bash
flutter pub get                                                    # install dependencies
flutter pub run build_runner build --delete-conflicting-outputs    # regenerate Hive *.g.dart adapters after editing any model in lib/models/
flutter gen-l10n                                                   # regenerate lib/l10n/app_localizations*.dart after editing lib/l10n/*.arb
flutter run                                                        # run the app
flutter analyze                                                    # static analysis (flutter_lints)
flutter test                                                       # run all tests
flutter test test/widget_test.dart                                 # run a single test file
flutter build apk --release --split-per-abi                        # release build (see GUIDE_MISE_A_JOUR.md for the full release/publish flow)
```

After changing any `@HiveType`/`@HiveField` model or any `.arb` file, you must re-run the corresponding generator above — the app will not compile or will silently use stale data otherwise.

## Architecture

**State management:** `provider`. Three app-wide `ChangeNotifierProvider`s are wired in `lib/main.dart`: `CourseProvider`, `NotesProvider`, `ThemeProvider`. All three are constructed before `runApp` and expected to already be loaded (`..loadCourses()` / `..loadNotes()`) by the time widgets read them.

**Persistence:** Hive, fully offline, no remote sync. Boxes are opened once in `main.dart`:
- `settings` (untyped box) — stores the single `StudentProfile` under key `'profile'`, the theme mode, and `custom_notebooks` (a `List<String>` of user-created notebook names not yet backed by any note).
- `courses` (`Box<Course>`)
- `notes` (`Box<StudyNote>`)

Models live in `lib/models/` and are hand-written; the matching `*.g.dart` adapter is generated, never edited directly. `typeId` values already in use: `Course` = 0, `StudentProfile` = 1, `StudyNote` = 3 (2 is currently unused — pick a new unused id for any new `@HiveType`, never reuse one, or existing stored data will deserialize incorrectly).

**Notebooks are a derived concept, not a stored entity.** A "notebook" is just the distinct set of `StudyNote.subject` values, unioned with the user-created names kept in `settings/custom_notebooks` for notebooks that don't have any notes yet. See `NotesProvider.notebooks` / `notesByNotebook` / `createNotebook` / `deleteNotebook` in `lib/providers/notes_provider.dart` — there is no `Notebook` model.

**Course scheduling:** `Course.dayOfWeeks` is an `int` (1 = Monday ... 7 = Sunday, see usage in `lib/widgets/course_list_by_day.dart` and `lib/screens/course_details_page.dart`), not a `DateTime` weekday enum. `startTime`/`endTime` are full `DateTime`s where only the time-of-day component is meaningful. `CourseProvider.loadCourses()` always sorts by `(dayOfWeeks, startTime)`, so the in-memory list is always presented week-ordered.

**Notifications:** `NotificationService` (singleton) schedules a recurring weekly reminder per course via `scheduleWeeklyNotification` (uses `matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime`, so a single call recurs indefinitely rather than needing rescheduling). The notification id for a course is deterministic: `NotificationService.notificationIdFromCourseId(courseId)` (hash of the course id) — always use this helper rather than inventing ids, so `CourseProvider.deleteCourse` can cancel the matching notification.

**Images/attachments:** All file I/O for notes goes through the `ImageManager` singleton (`lib/services/image_manager.dart`), which copies picked images/files into the app documents directory (`notes/` and `attachments/` subfolders) before storing paths on the `StudyNote`. Don't store picker-returned temp paths directly on a model — they aren't durable.

**In-app update flow:** `UpdateChecker` polls the GitHub releases API for `Ismael-sang98/Uni_Flow_app` and compares semver against `PackageInfo.fromPlatform()`; `UpdateDialog.checkAndShow` (invoked from `HomePage.initState`, delayed 2s) surfaces it via a dialog that deep-links to the APK asset. There is no auto-update mechanism beyond this — publishing a new version means bumping `pubspec.yaml`'s `version:` and cutting a GitHub release with the APKs attached (see `GUIDE_MISE_A_JOUR.md`).

**Shared UI/logic building blocks** (reuse these instead of re-deriving values):
- `UIConstants` (`lib/constants/ui_constants.dart`) — all spacing, sizing, icon, duration, and opacity constants used across screens/widgets.
- `FormValidationMixin` (`lib/mixins/form_validation_mixin.dart`) — real-time title/content validation + character count, mixed into note/course form screens.
- `ImageGridWidget` (`lib/widgets/image_grid_widget.dart`) — the reusable image gallery grid used by note screens.

**Localization:** Source strings live in `lib/l10n/app_{en,fr,tr}.arb`; `lib/l10n/app_localizations*.dart` is generated output (do not hand-edit). English is the fallback locale (`MyApp.localeResolutionCallback` in `lib/my_app.dart`) when the device locale isn't one of the three supported languages. All user-facing strings must go through `AppLocalizations.of(context)!` — there should be no hardcoded UI text in screens/widgets.

**Entry flow:** `main.dart` initializes Hive/adapters/boxes and `NotificationService` before `runApp`. `MyApp` (`lib/my_app.dart`) checks whether `settings/profile` exists to decide the initial route: `WelcomePage` (onboarding, creates the profile) vs `HomePage` (main tabbed shell: schedule / notes library / profile).
