import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service de gestion centralisée de la configuration API (URL backend + clé API)
class ApiConfigService {
  static final ApiConfigService _instance = ApiConfigService._internal();

  factory ApiConfigService() {
    return _instance;
  }

  ApiConfigService._internal();

  static const String _baseUrlKey = 'api_base_url';
  static const String _apiKeyKey = 'api_key';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Récupère l'URL de base du backend, ou null si non configurée
  Future<String?> getBaseUrl() {
    return _storage.read(key: _baseUrlKey);
  }

  /// Enregistre l'URL de base du backend
  Future<void> setBaseUrl(String baseUrl) {
    return _storage.write(key: _baseUrlKey, value: baseUrl.trim());
  }

  /// Récupère la clé API (X-API-Key), ou null si non configurée
  Future<String?> getApiKey() {
    return _storage.read(key: _apiKeyKey);
  }

  /// Enregistre la clé API (X-API-Key)
  Future<void> setApiKey(String apiKey) {
    return _storage.write(key: _apiKeyKey, value: apiKey.trim());
  }

  /// Supprime la configuration API enregistrée
  Future<void> clear() async {
    await _storage.delete(key: _baseUrlKey);
    await _storage.delete(key: _apiKeyKey);
  }
}
