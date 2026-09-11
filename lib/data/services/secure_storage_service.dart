import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _llmApiKey = 'llm_api_key';
  static const String _llmEndpoint = 'llm_endpoint';
  static const String _userName = 'user_name';
  static const String _preferredSport = 'preferred_sport';

  Future<void> saveLlmApiKey(String key) => _storage.write(key: _llmApiKey, value: key);
  Future<String?> getLlmApiKey() => _storage.read(key: _llmApiKey);
  Future<void> deleteLlmApiKey() => _storage.delete(key: _llmApiKey);

  Future<void> saveLlmEndpoint(String endpoint) => _storage.write(key: _llmEndpoint, value: endpoint);
  Future<String?> getLlmEndpoint() => _storage.read(key: _llmEndpoint);

  Future<void> saveUserName(String name) => _storage.write(key: _userName, value: name);
  Future<String?> getUserName() => _storage.read(key: _userName);

  Future<void> savePreferredSport(String sport) => _storage.write(key: _preferredSport, value: sport);
  Future<String?> getPreferredSport() => _storage.read(key: _preferredSport);
}
