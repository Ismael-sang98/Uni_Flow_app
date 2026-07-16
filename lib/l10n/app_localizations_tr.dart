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
  String profileSaveError(Object error) {
    return 'Profil kaydedilemedi: $error';
  }

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
  String get notesLibrary => 'Notlar';

  @override
  String get addNote => 'Yeni Not';

  @override
  String get noteTitle => 'Başlık';

  @override
  String get noteSubject => 'Ders';

  @override
  String get noteContent => 'İçerik';

  @override
  String get noteTags => 'Etiketler (virgülle ayrılmış)';

  @override
  String get noteRequiredFields => 'Başlık ve İçerik zorunludur.';

  @override
  String get noteImages => 'Gorseller';

  @override
  String get addFromGallery => 'Galeri';

  @override
  String get addFromCamera => 'Kamera';

  @override
  String get noImagesYet => 'Henuz gorsel yok.';

  @override
  String get noteTagsHelp =>
      'Etiketler notları gruplar ve aramayı kolaylaştırır (or: sınav, konu).';

  @override
  String get notesEmpty => 'Henuz not yok.';

  @override
  String get noteDetails => 'Not detayları';

  @override
  String get editNote => 'Notu düzenle';

  @override
  String noteCreatedAt(Object date) {
    return 'Olusturma: $date';
  }

  @override
  String noteUpdatedAt(Object date) {
    return 'Güncelleme: $date';
  }

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

  @override
  String get shareNoteImage => 'Notumdan görsel';

  @override
  String charactersCount(Object count) {
    return '$count karakter';
  }

  @override
  String get requiredField => 'Gerekli *';

  @override
  String get updateAvailable => 'Güncelleme Mevcut';

  @override
  String updateCurrentVersion(Object version) {
    return 'Mevcut sürüm: $version';
  }

  @override
  String updateNewVersion(Object version) {
    return 'Yeni sürüm: $version';
  }

  @override
  String get updateWhatsNew => 'Yenilikler:';

  @override
  String get updateLater => 'Sonra';

  @override
  String get updateDownload => 'İndir';

  @override
  String get updateTestTitle => 'Güncelleme Testi';

  @override
  String get updateReadyToTest => 'Test etmeye hazır';

  @override
  String get updateChecking => 'Kontrol ediliyor...';

  @override
  String get updateAvailableStatus => '✅ Güncelleme mevcut!';

  @override
  String get updateUpToDate => '✅ En son sürüme sahipsiniz';

  @override
  String updateError(Object error) {
    return '❌ Hata: $error';
  }

  @override
  String get updateInfo => '📱 Bilgiler';

  @override
  String get updateCurrentVersionLabel => 'Mevcut sürüm';

  @override
  String get updateLatestVersionLabel => 'Son sürüm';

  @override
  String get updateHowToTest => 'Nasıl test edilir?';

  @override
  String updateTestInstructions(Object version) {
    return '1. Güncelleme diyaloğunu görmek için \"Simüle Et\" kullanın\n\n2. Veya $version sürümünden daha yüksek bir GitHub sürümü oluşturun ve \"Kontrol Et\"\'e tıklayın';
  }

  @override
  String get updateSimulate => '🧪 Güncelleme simüle et';

  @override
  String get updateCheckGitHub => '🔍 GitHub\'da kontrol et';

  @override
  String get updateGitHubRelease => '📦 GitHub Sürümü';

  @override
  String get updateReleaseInstructions =>
      'Test sürümü oluşturmak için:\n1. github.com/Ismael-sang98/Uni_Flow_app/releases/new\n2. Etiket: v1.5.6 (veya daha yüksek)\n3. APK yükle\n4. Yayınla';

  @override
  String get updateSimulationNote =>
      'Bu, güncelleme diyaloğunu test etmek için bir simülasyondur.';

  @override
  String get notesCreateNotebook => 'Defter oluştur';

  @override
  String get notesNotebook => 'Defter';

  @override
  String get notesNotebookName => 'Defter adı';

  @override
  String get notesNotebookRequired => 'Lütfen bir defter seçin';

  @override
  String get notesNoNotebook => 'Mevcut defter yok';

  @override
  String notesDeleteNotebookPrompt(String name) {
    return '\"$name\" defterini silmek istiyor musunuz?';
  }

  @override
  String get notesDeleteNotebookKeepPages => 'Defteri sil, sayfaları koru';

  @override
  String get notesDeleteNotebookDeleteAll => 'Defter + sayfaları sil';

  @override
  String notesPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sayfa',
      one: 'sayfa',
      zero: 'sayfa',
    );
    return '$count $_temp0';
  }

  @override
  String get noteFiles => 'Dosyalar';

  @override
  String get noteAddFile => 'Dosya ekle';

  @override
  String get noteNoFiles => 'Eklenmiş dosya yok.';

  @override
  String get noteImageCaptionTitle => 'Fotoğraf açıklaması';

  @override
  String get noteImageCaptionLabel => 'Açıklama';

  @override
  String get noteImageCaptionHint => 'Örn: Sonuç grafiği...';

  @override
  String get optional => 'isteğe bağlı';

  @override
  String get skip => 'Atla';

  @override
  String get suggested => 'Öneriler';

  @override
  String get notesOrCustomName => 'Veya özel bir defter oluşturun';

  @override
  String get search => 'Ara...';

  @override
  String get notesSearchEmpty => 'Hiç not bulunamadı';

  @override
  String get apiSettingsTitle => 'API ayarları';

  @override
  String get apiSettingsBaseUrlLabel => 'Backend temel URL\'si';

  @override
  String get apiSettingsBaseUrlHint => 'https://uygulamam.onrender.com';

  @override
  String get apiSettingsApiKeyLabel => 'API anahtarı (X-API-Key)';

  @override
  String get apiSettingsApiKeyHint => 'API anahtarınız';

  @override
  String get apiSettingsInvalidUrl =>
      'http:// veya https:// ile başlayan geçerli bir URL girin';

  @override
  String get apiSettingsSaved => 'API ayarları kaydedildi';

  @override
  String apiSettingsLoadError(Object error) {
    return 'API ayarları yüklenemedi: $error';
  }

  @override
  String apiSettingsSaveError(Object error) {
    return 'API ayarları kaydedilemedi: $error';
  }

  @override
  String get apiSettingsTestButton => 'Bağlantıyı test et';

  @override
  String get apiSettingsTestSuccess => 'Bağlantı başarılı';

  @override
  String get apiSettingsTestInvalidKey => 'Geçersiz API anahtarı';

  @override
  String apiSettingsTestHttpError(Object statusCode) {
    return 'Sunucu hatası ($statusCode)';
  }

  @override
  String apiSettingsTestNetworkError(Object error) {
    return 'Backend\'e ulaşılamıyor: $error';
  }

  @override
  String get fullSyncButton => 'Senkronize et';

  @override
  String get fullSyncProfileUpdated => 'Profil güncellendi';

  @override
  String get fullSyncProfileNotUpdated => 'Profil değişmedi';

  @override
  String fullSyncSubjectsCount(Object count) {
    return '$count ders senkronize edildi';
  }

  @override
  String fullSyncCoursesCount(Object created, Object updated) {
    return '$created ders oluşturuldu, $updated güncellendi';
  }

  @override
  String scheduleSyncSkippedInfo(Object skipped) {
    return '$skipped giriş yok sayıldı (beklenmeyen format)';
  }

  @override
  String get scheduleSyncSampleDialogTitle => 'Yok sayılan giriş (ham veri)';

  @override
  String get scheduleSyncSampleDialogHint =>
      'Yok sayılan girişlerden birine ait JSON verisi. Beklenen formatın düzeltilmesi için bunu geliştiriciyle paylaş.';

  @override
  String get close => 'Kapat';

  @override
  String get onboardingChoiceTitle => 'Nasıl başlamak istersin?';

  @override
  String get onboardingChoiceObsTitle => 'OBS hesabımdan yapılandır';

  @override
  String get onboardingChoiceObsDescription =>
      'Profilini, derslerini ve ders programını otomatik olarak içe aktar.';

  @override
  String get onboardingChoiceManualTitle => 'Manuel yapılandırma';

  @override
  String get onboardingChoiceManualDescription =>
      'Profilini ve derslerini kendin gir.';

  @override
  String get obsSetupTitle => 'OBS hesabı';

  @override
  String get obsSetupDescription =>
      'Profilini, derslerini ve ders programını otomatik senkronize etmek için backend URL\'ni ve API anahtarını gir.';

  @override
  String get obsSetupConnectButton => 'Bağlan ve senkronize et';

  @override
  String get obsSetupNoProfileError =>
      'Bu hesaptan profilin alınamadı. URL\'yi ve API anahtarını kontrol et.';

  @override
  String get completeProfileTitle => 'Son adım';

  @override
  String get completeProfileDescription =>
      'Yapılandırmayı tamamlamak için okulunu ve sınıfını gir.';

  @override
  String get completeProfileContinueButton => 'Bitir';

  @override
  String get syncStepProfile => 'Profil';

  @override
  String get syncStepSubjects => 'Dersler';

  @override
  String get syncStepSchedule => 'Ders programı';

  @override
  String get syncErrorInvalidApiKey =>
      'Geçersiz API anahtarı, ayarlarındaki yapılandırmanı kontrol et';

  @override
  String get syncErrorSessionExpired =>
      'OBS oturumu sunucu tarafında sona erdi, senin tarafında manuel bir yeniden senkronizasyon gerekiyor';

  @override
  String get syncErrorObsUnreachable =>
      'Üniversite sistemi şu anda yanıt vermiyor, daha sonra tekrar dene';

  @override
  String get syncErrorDatabaseUnavailable =>
      'Backend sunucusunda geçici bir sorun var, daha sonra tekrar dene';

  @override
  String get syncErrorTimeout =>
      'Sunucu yanıt vermekte gecikiyor (uykuda olabilir), bir dakika içinde tekrar dene.';

  @override
  String get syncErrorNetwork =>
      'Sunucuya ulaşılamadı, bağlantını ve yapılandırılan URL\'yi kontrol et';

  @override
  String get syncErrorMissingConfig =>
      'Backend URL\'si ve API anahtarı yapılandırılmalıdır.';

  @override
  String get syncErrorInvalidResponse => 'Sunucu yanıtı okunamıyor.';

  @override
  String get syncErrorInvalidFormat => 'Sunucudan beklenmeyen yanıt formatı.';

  @override
  String get syncProgressProfile => 'Profil senkronize ediliyor...';

  @override
  String get syncProgressSubjects => 'Dersler senkronize ediliyor...';

  @override
  String get syncProgressSchedule => 'Ders programı senkronize ediliyor...';

  @override
  String lastSyncLabel(Object value) {
    return 'Son senkronizasyon: $value';
  }

  @override
  String get lastSyncNever => 'hiçbir zaman';

  @override
  String get lastSyncJustNow => 'az önce';

  @override
  String lastSyncMinutesAgo(Object minutes) {
    return '$minutes dakika önce';
  }

  @override
  String lastSyncHoursAgo(Object hours) {
    return '$hours saat önce';
  }

  @override
  String lastSyncDaysAgo(Object days) {
    return '$days gün önce';
  }

  @override
  String get subjectsEmptyStateMessage =>
      'Henüz ders yok — OBS hesabını senkronize et veya manuel olarak ekle';

  @override
  String get subjectsEmptyStateManualButton => 'Manuel ekle';

  @override
  String get scheduleEmptyStateMessage =>
      'Henüz ders programı içe aktarılmadı — ders programını doldurmak için OBS hesabını senkronize et';
}
