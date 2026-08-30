/// Gemini API configuration. The API key itself is never hard-coded here —
/// it is entered by the user in Settings and stored in encrypted device
/// storage (see `SecureKeyStore`).
class GeminiConfig {
  GeminiConfig._();

  /// Model used for summarization.
  ///
  /// NOTE: this used to be 'gemini-flash-latest'. That name looks like a
  /// safe, auto-updating alias, but per Google's own model docs it
  /// specifically points to an *experimental* release with tighter,
  /// less reliable rate limits — not something meant for production
  /// traffic. That's what was causing scans to fail with "temporarily
  /// unavailable" so often. Pinned to an explicit stable/GA model id
  /// instead. Re-check https://ai.google.dev/gemini-api/docs/models
  /// before changing this, and avoid any other bare "-latest" alias —
  /// whether it resolves to stable or experimental varies by model line.
  static const String model = 'gemini-3.5-flash';

  /// No API key in the URL on purpose — it's sent via the `x-goog-api-key`
  /// header instead (see GeminiService), so it can never end up embedded
  /// in an exception's toString() and leak into an on-screen error message.
  static final Uri endpoint =
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');

  static const int maxOutputTokens = 2048;
  static const Duration requestTimeout = Duration(seconds: 120);
}