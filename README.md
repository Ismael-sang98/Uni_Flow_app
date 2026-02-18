# 🎓 Student Planner (UniFlow)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-Database-orange?style=for-the-badge)
![Provider](https://img.shields.io/badge/State-Provider-purple?style=for-the-badge)

**UniFlow** is a comprehensive offline mobile application designed to help students organize their academic life. It allows users to manage their schedules, create rich notes with images, and personalize their profiles—all while working 100% offline with full multi-language support.

---

## ✨ Main Features

* 📅 **Weekly Planner:** Clear view of classes day by day (Monday to Sunday).
* 📚 **Notes Library:** Complete note-taking system with rich features:
  * Create, edit, and organize notes by subject
  * Add tags for easy categorization and search
  * Attach multiple images from gallery or camera
  * Share images directly from notes
  * Real-time validation with character counter
  * Full-screen image preview with zoom support
* 👤 **Student Profile:** Customize your name, school, class, and profile picture.
* 🎨 **Dynamic Themes:** Full support for **Dark Mode** and **Light Mode**.
* 🌍 **Multilingual:** Available in **French 🇫🇷**, **English 🇺🇸**, and **Turkish 🇹🇷**.
* 🔔 **Notification:** Alert 10 minutes before class.
* 💾 **100% Offline:** All data is persistent thanks to the Hive database.

---

## 📱 Screenshots

| Welcome page | Home (Schedule) |
|:---:|:---:|
| ![Home](screenshots/wcm.png) | ![Homework](screenshots/home.png) |

| Course details page | Notes Library |
|:---:|:---:|
| ![Profil](screenshots/detail.png) | ![Notes](screenshots/tasks.png) |

| Student Profile | Dark Mode |
|:---:|:---:|
| ![Profil](screenshots/profile.png) | ![Dark Mode](screenshots/dark_mode.png) |


---

## 🛠️ Technologies Used

* **Framework:** [Flutter](https://flutter.dev/)
* **Language:** Dart
* **State Management:** [Provider](https://pub.dev/packages/provider)
* **Local Database:** [Hive](https://pub.dev/packages/hive) (NoSQL, fast and lightweight)
* **Image Management:** [image_picker](https://pub.dev/packages/image_picker) (Gallery & Camera)
* **Sharing:** [share_plus](https://pub.dev/packages/share_plus) (Share images across apps)
* **Internationalization:** flutter_localizations & intl
* **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
* **Design:** Google Fonts (Poppins), Hero Animations, Custom Slivers
* **Architecture:** 
  * Clean code with reusable components (UIConstants, Services, Mixins, Widgets)
  * Singleton pattern for services (ImageManager)
  * Mixin-based form validation
  * Modular widget architecture

---

## 🎯 Recent Improvements

### Code Optimization (February 2026)
* **~260 lines of duplicate code eliminated**
* **Created reusable components:**
  * `UIConstants` - Centralized UI constants (spacing, sizes, colors, durations)
  * `ImageManager` - Singleton service for all image operations
  * `FormValidationMixin` - Reusable real-time form validation
  * `ImageGridWidget` - Flexible image gallery component
* **100% localized** - No hardcoded French text, all strings use l10n keys
* **Clean architecture** - Following Flutter best practices and DRY principles

### Notes Library Features
* Full CRUD operations (Create, Read, Update, Delete)
* Multi-image support with gallery and camera integration
* Image sharing functionality across apps
* Tag-based organization system
* Real-time validation with visual feedback
* Character counter for content tracking
* Full-screen image viewer with InteractiveViewer zoom

---

## 📥 Download the APK

You can test the app on your Android phone by downloading the latest version:

👉 **[Download the latest release](https://github.com/Ismael-sang98/Uni_Flow_app/releases)**

*Choose version `arm64-v8a` for newer phones.*

---

## 🚀 Developer Setup

If you want to clone and modify this project:

1. **Clone the repository:**
```bash
git clone [https://github.com/Ismael-sang98/Uni_Flow_app.git](https://github.com/Ismael-sang98/Uni_Flow_app.git)
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Build Hive and translation files:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

4. **Run the application:**
```bash
flutter run
```

### 📦 Key Dependencies

```yaml
dependencies:
  # State Management
  provider: ^6.1.5+1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Images
  image_picker: ^1.2.1
  path_provider: ^2.1.5
  share_plus: ^10.1.0
  
  # UI
  google_fonts: ^8.0.0
  table_calendar: ^3.2.0
  
  # Notifications
  flutter_local_notifications: ^20.1.0
  flutter_timezone: ^5.0.1
  permission_handler: ^12.0.1
  
  # Localization
  intl: ^0.20.2
  flutter_localizations:
    sdk: flutter
```

---

Made with ❤️ using Flutter.