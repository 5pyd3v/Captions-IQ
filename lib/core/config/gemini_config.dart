/// Gemini API configuration. The API key itself is never hard-coded here —
/// it is entered by the user in Settings and stored in encrypted device
/// storage (see `SecureKeyStore`).
class GeminiConfig {
  GeminiConfig._();

  /// Model used for summarization. Pinned to Google's self-updating
  /// "-latest" alias rather than a dated model id, since Gemini model
  /// names get retired/renamed fairly often — this always resolves to
  /// whatever Google currently recommends as its fast/cheap model.
  static const String model = 'gemini-flash-latest';

  /// No API key in the URL on purpose — it's sent via the `x-goog-api-key`
  /// header instead (see GeminiService), so it can never end up embedded
  /// in an exception's toString() and leak into an on-screen error message.
  static final Uri endpoint =
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');

  static const int maxOutputTokens = 2048;
  static const Duration requestTimeout = Duration(seconds: 120);
}
