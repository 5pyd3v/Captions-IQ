import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/gemini_config.dart';

class GeminiSummary {
  final String summaryEn;
  final String summaryRomanUrdu;

  const GeminiSummary({required this.summaryEn, required this.summaryRomanUrdu});
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);
  @override
  String toString() => message;
}

/// Calls the Gemini API directly from the device using the user's own
/// API key (stored locally, never sent anywhere but Google's endpoint).
class GeminiService {
  static const _systemPrompt = '''
You are turning raw, messy OCR text captured from a series of chat/caption
screenshots (WhatsApp-style conversation captions) into a clear recap for
someone who did not read the conversation.

The OCR text may contain artifacts: repeated speaker initials, timestamps,
battery/signal icons, cut-off words, out-of-order fragments. Read past the
noise and reconstruct the actual meaning and flow of the conversation.

Produce TWO versions of the same summary:

1. "summary_en": A natural, humanized summary in clear English. Write like
   a sharp colleague catching someone up — flowing prose or short
   paragraphs, not a robotic list of facts. Capture the key topics,
   decisions, disagreements, and conclusions. Keep it concise but complete.

2. "summary_roman_ur": The SAME summary, but written in Roman Urdu — that
   is, the Urdu language spelled out using the English/Latin alphabet
   (NOT Arabic/Nastaliq script, e.g. "aap kaisay hain" not "آپ کیسے ہیں").
   It must read naturally when spoken aloud by a Pakistani/Urdu speaker:
   casual, humanized, and conversational — the way people actually text
   each other in Roman Urdu, not a stiff literal translation.

Return ONLY the two summaries in the requested JSON shape. Do not include
screenshot numbers, timestamps, or meta-commentary about the OCR process.
''';

  Future<GeminiSummary> summarize({
    required String apiKey,
    required String rawText,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiException(
        'No Gemini API key set yet. Add one in Settings to continue.',
      );
    }
    if (rawText.trim().isEmpty) {
      throw GeminiException('No readable text was found in these screenshots.');
    }

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$_systemPrompt\n\n--- OCR TEXT START ---\n$rawText\n--- OCR TEXT END ---'}
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.6,
        'maxOutputTokens': GeminiConfig.maxOutputTokens,
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'summary_en': {'type': 'STRING'},
            'summary_roman_ur': {'type': 'STRING'},
          },
          'required': ['summary_en', 'summary_roman_ur'],
        },
      },
    });

    final sw = Stopwatch()..start();
    debugPrint('[CaptionIQ] Gemini POST starting, body=${body.length} bytes, timeout=${GeminiConfig.requestTimeout.inSeconds}s');

    late final http.Response response;
    try {
      response = await http
          .post(
            GeminiConfig.endpoint,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey.trim(),
            },
            body: body,
          )
          .timeout(GeminiConfig.requestTimeout);
      debugPrint('[CaptionIQ] Gemini POST returned status=${response.statusCode} after ${sw.elapsedMilliseconds}ms');
    } on TimeoutException {
      debugPrint('[CaptionIQ] Gemini POST timed out after ${sw.elapsedMilliseconds}ms');
      throw GeminiException(
        'Gemini took longer than ${GeminiConfig.requestTimeout.inSeconds}s to respond — '
        'this can happen on a slow connection with a large batch of screenshots. '
        'Try again, or scan fewer screenshots at once.',
      );
    } on SocketException catch (e) {
      debugPrint('[CaptionIQ] SocketException after ${sw.elapsedMilliseconds}ms: $e');
      throw GeminiException('Could not reach Gemini: no network connection (${e.osError?.message ?? e.message}).');
    } on HandshakeException catch (e) {
      debugPrint('[CaptionIQ] HandshakeException after ${sw.elapsedMilliseconds}ms: $e');
      throw GeminiException('Could not reach Gemini: a secure connection could not be established.');
    } catch (e, st) {
      debugPrint('[CaptionIQ] Unexpected HTTP error after ${sw.elapsedMilliseconds}ms: $e\n$st');
      throw GeminiException('Could not reach Gemini: ${e.runtimeType}.');
    }

    if (response.statusCode == 400 || response.statusCode == 403) {
      throw GeminiException(
        'Gemini rejected the request — your API key may be invalid. Double-check it in Settings.',
      );
    }
    if (response.statusCode == 429) {
      throw GeminiException('Gemini rate limit reached. Please wait a moment and try again.');
    }
    if (response.statusCode >= 500) {
      throw GeminiException('Gemini is temporarily unavailable. Please try again shortly.');
    }
    if (response.statusCode != 200) {
      throw GeminiException('Gemini request failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      final blockReason = decoded['promptFeedback']?['blockReason'];
      throw GeminiException(
        blockReason != null
            ? 'Gemini blocked this request ($blockReason).'
            : 'Gemini returned no result. Please try again.',
      );
    }

    final parts = candidates.first['content']?['parts'] as List?;
    final text = (parts != null && parts.isNotEmpty) ? parts.first['text'] as String? : null;
    if (text == null || text.trim().isEmpty) {
      throw GeminiException('Gemini returned an empty summary. Please try again.');
    }

    final parsed = jsonDecode(text) as Map<String, dynamic>;
    return GeminiSummary(
      summaryEn: (parsed['summary_en'] as String? ?? '').trim(),
      summaryRomanUrdu: (parsed['summary_roman_ur'] as String? ?? '').trim(),
    );
  }
}
