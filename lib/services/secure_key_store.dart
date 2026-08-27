import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted on-device storage for the user's Gemini API key
/// (Android Keystore / iOS Keychain backed). The key never touches
/// Supabase or any other backend — it stays local to the device and is
/// only ever sent directly to Google's Gemini endpoint.
class SecureKeyStore {
  SecureKeyStore._();

  static const _storage = FlutterSecureStorage();

  static const _geminiKeyKey = 'gemini_api_key';

  static Future<String?> getGeminiKey() => _storage.read(key: _geminiKeyKey);

  static Future<void> setGeminiKey(String value) =>
      _storage.write(key: _geminiKeyKey, value: value.trim());

  static Future<void> clearGeminiKey() => _storage.delete(key: _geminiKeyKey);

  static Future<bool> hasGeminiKey() async {
    final key = await getGeminiKey();
    return key != null && key.trim().isNotEmpty;
  }
}
