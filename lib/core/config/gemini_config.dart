/// Gemini API configuration. The API key itself is never hard-coded here —
/// it is entered by the user in Settings and stored in encrypted device
/// storage (see `SecureKeyStore`).
class GeminiConfig {
  GeminiConfig._();

  /// Model used for summarization. Update this constant if Google ships a
  /// newer/cheaper flash model — no other code needs to change.
  static const String model = 'gemini-2.5-flash';

  static String endpoint(String apiKey) =>
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

  static const int maxOutputTokens = 2048;
}
