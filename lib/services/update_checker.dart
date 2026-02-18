import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateChecker {
  static const String _githubRepo = 'Ismael-sang98/Uni_Flow_app';
  static const String _releasesUrl =
      'https://api.github.com/repos/$_githubRepo/releases/latest';

  /// Vérifie si une mise à jour est disponible
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      // Récupérer la version actuelle de l'app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Récupérer la dernière version depuis GitHub
      final response = await http.get(Uri.parse(_releasesUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        final downloadUrl = _getDownloadUrl(data);
        final releaseNotes = data['body'] ?? '';

        // Comparer les versions
        if (_isNewerVersion(currentVersion, latestVersion)) {
          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            downloadUrl: downloadUrl,
            releaseNotes: releaseNotes,
          );
        }
      }
    } catch (e) {
      print('Erreur vérification mise à jour: $e');
    }
    return null;
  }

  /// Récupère l'URL de téléchargement de l'APK arm64-v8a
  static String _getDownloadUrl(Map<String, dynamic> releaseData) {
    try {
      final assets = releaseData['assets'] as List;

      // Chercher l'APK arm64-v8a (le plus courant)
      for (var asset in assets) {
        final name = asset['name'] as String;
        if (name.contains('arm64-v8a') && name.endsWith('.apk')) {
          return asset['browser_download_url'];
        }
      }

      // Sinon, prendre le premier APK disponible
      for (var asset in assets) {
        final name = asset['name'] as String;
        if (name.endsWith('.apk')) {
          return asset['browser_download_url'];
        }
      }
    } catch (e) {
      print('Erreur récupération URL: $e');
    }
    return '';
  }

  /// Compare deux versions (ex: "1.0.0" vs "1.0.1")
  static bool _isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final currentNum = i < currentParts.length ? currentParts[i] : 0;
        final latestNum = i < latestParts.length ? latestParts[i] : 0;

        if (latestNum > currentNum) return true;
        if (latestNum < currentNum) return false;
      }
    } catch (e) {
      print('Erreur comparaison version: $e');
    }
    return false;
  }
}

/// Informations sur la mise à jour disponible
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  });
}
