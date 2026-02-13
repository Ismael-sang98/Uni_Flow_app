// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Öğrenci Planlayıcı';

  @override
  String get schedule => 'Ders Programı';

  @override
  String get settings => 'Ayarlar';

  @override
  String get welcomeTitle => 'Başarınızı\norganize edin.';

  @override
  String get welcomeSubtitle =>
      'Dersler, ödevler, sınavlar...\nTüm programınız cebinizde.';

  @override
  String get getStartedButton => 'Şimdi başla';

  @override
  String get ajoutMatiereErreur => 'En az bir malzeme daha ekleyin!';

  @override
  String get profilEnregistre => 'Profil güncellendi!';

  @override
  String get labProfil => 'Profilim';

  @override
  String get labMatiere => 'Kaydettiğim Dersler';

  @override
  String get aucuneMatiere => 'Tanımlanmış bir ders yok.';

  @override
  String get labCrPr => 'Profilimi oluştur';

  @override
  String get labMdPr => 'Profili düzenle';

  @override
  String get btMod => 'Düzenleme';

  @override
  String get labNom => 'Ad Soyad';

  @override
  String get labFkt => 'Bölüm';

  @override
  String get labCl => 'Sınıf';

  @override
  String get labEc => 'Okul';

  @override
  String get labSsMat => 'Derslerinizi girin';

  @override
  String get hintAjoutMatiere => 'Örnekler: Matematik...';

  @override
  String get btnEnregistrerProfil => 'Profili kaydet';

  @override
  String get addTask => 'Yeni Görev';

  @override
  String get taskTitle => 'Başlık';

  @override
  String get mt => 'Ders';

  @override
  String get noSubjectsDefined => 'Profilde tanımlanmış ders yok.';

  @override
  String get dueDate => 'Tarih :';

  @override
  String get rejet => 'İptal';

  @override
  String get ajt => 'Ekle';

  @override
  String get bvn => 'Hoş geldin !';

  @override
  String get planning => 'Takvim';

  @override
  String get tasks => 'Görevler';

  @override
  String get pleaseSelectASubject => 'Lütfen bir ders seçin.';

  @override
  String get endTimeMustBeAfterStartTime =>
      'Başlangıcın ardından son gelmelidir.';

  @override
  String get addCourse => 'Ders ekle';

  @override
  String get noSubjectMnessage => 'Hiçbir dersi bulunamadı!';

  @override
  String get noSubjectExplanation =>
      'Öncelikle Profilinizde (kalem simgesi) ders konularınızı belirlemelisiniz.';

  @override
  String get goBack => 'Geri';

  @override
  String get location => 'Sınıf';

  @override
  String get day => 'Gün';

  @override
  String get j1 => 'Pazartesi';

  @override
  String get j2 => 'Salı';

  @override
  String get j3 => 'Çarşamba';

  @override
  String get j4 => 'Perşembe';

  @override
  String get j5 => 'Cuma';

  @override
  String get j6 => 'Cumartesi';

  @override
  String get j7 => 'Pazar';

  @override
  String get startLab => 'Başlangıç';

  @override
  String get endLab => 'Son';

  @override
  String get selectColor => 'Renk';

  @override
  String get savePlan => 'Takvime ekle';

  @override
  String get videLab => 'Planlanmış bir şey yok.';

  @override
  String get videTacheLab => 'Hiçbir görev yok.';

  @override
  String get jAb1 => 'Pzt';

  @override
  String get jAb2 => 'Sal';

  @override
  String get jAb3 => 'Çar';

  @override
  String get jAb4 => 'Per';

  @override
  String get jAb5 => 'Cum';

  @override
  String get jAb6 => 'Cmt';

  @override
  String get jAb7 => 'Paz';

  @override
  String get confirmSupprTitle => 'Silme işlemini onaylayın';

  @override
  String get mess1 => 'Gerçekten silmek istiyor musunuz?';

  @override
  String get mess2 => 'Bu işlem geri döndürülemez.';

  @override
  String get supp => 'Sil';

  @override
  String get labLocation => 'Sınıf belirtilmemiş';

  @override
  String get hrs => 'Saat';

  @override
  String get courseDetails => 'Ders detayları';

  @override
  String get save => 'Kaydet';

  @override
  String get editCours => 'Ders düzenle';

  @override
  String get courseUpdated => 'Ders düzenledi !';

  @override
  String get courseAdded => 'Ders eklendi !';

  @override
  String get exactAlarmTitle => 'Kesin alarmlara izin verin';

  @override
  String get exactAlarmMessage =>
      'Zamanlanmıs hatırlatmalar için \"Alarmlar ve hatırlatmalar\" iznini ayarlardan etkinlestirin.';

  @override
  String get notificationPermissionTitle => 'Bildirimlere izin ver';

  @override
  String get notificationPermissionMessage =>
      'Hatırlatmaları almak için bildirimlere izin verin.';

  @override
  String get later => 'Sonra';

  @override
  String get openSettings => 'Ayarları açın';

  @override
  String get courseReminderTitle => 'Ders hatirlatması!';

  @override
  String courseReminderBody(Object courseTitle, Object locationSuffix) {
    return '$courseTitle dersiniz 10 dakika sonra basliyor$locationSuffix.';
  }

  @override
  String courseReminderLocationSuffix(Object room) {
    return ' $room odasında';
  }

  @override
  String get courseNotFound => 'Ders bulunamadı';

  @override
  String get deleteCourseMessage => 'Bu dersi silmek istiyor musunuz?';

  @override
  String get testNotifButton => 'Bildirim test';

  @override
  String get testInstantTitle => 'Anlik test';

  @override
  String get testInstantBody => 'Bunu görüyorsaniz kanal calisiyor!';

  @override
  String versionLabel(Object version) {
    return 'Surum $version';
  }

  @override
  String get madeWithLoveBy => 'Sevgiyle hazırlandı: ';

  @override
  String get weeklyNotificationScheduled => '✓ Haftalık bildirim programlandı';

  @override
  String weeklyReminderMessage(Object courseName, Object date) {
    return '\"$courseName\" dersinden 10 dakika önce her hafta hatırlatma: $date';
  }

  @override
  String get courseTooClose => 'Ders çok yakın';

  @override
  String courseTooCloseMessage(Object courseName) {
    return '\"$courseName\" dersi bildirim planlamak için çok yakın.';
  }

  @override
  String notificationError(Object error) {
    return 'Bildirim hatası: $error';
  }

  @override
  String notificationInMinutes(Object minutes) {
    return '$minutes dk sonra';
  }

  @override
  String notificationInHoursMinutes(Object hours, Object minutes) {
    return '$hours saat $minutes dk sonra';
  }

  @override
  String notificationOnDate(
    Object dayShort,
    Object day,
    Object month,
    Object hour,
    Object minute,
  ) {
    return '$dayShort $day/$month saat $hour:$minute';
  }
}
