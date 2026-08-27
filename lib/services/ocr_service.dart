import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Result of running OCR across a batch of screenshots.
class OcrBatchResult {
  final String combinedText;
  final int successCount;
  final int failedCount;

  const OcrBatchResult({
    required this.combinedText,
    required this.successCount,
    required this.failedCount,
  });
}

/// Runs Google ML Kit's on-device text recognition across a (potentially
/// large, 100+) batch of screenshot images, sequentially so memory stays
/// bounded, reporting progress as it goes.
class OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// [onProgress] is called after each image finishes with
  /// (completedCount, totalCount).
  Future<OcrBatchResult> recognizeBatch(
    List<File> images, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final buffer = StringBuffer();
    var success = 0;
    var failed = 0;

    for (var i = 0; i < images.length; i++) {
      try {
        final inputImage = InputImage.fromFile(images[i]);
        final result = await _recognizer.processImage(inputImage);
        final text = result.text.trim();
        if (text.isNotEmpty) {
          buffer.writeln('--- Screenshot ${i + 1} of ${images.length} ---');
          buffer.writeln(text);
          buffer.writeln();
          success++;
        } else {
          failed++;
        }
      } catch (_) {
        failed++;
      }
      onProgress?.call(i + 1, images.length);
    }

    return OcrBatchResult(
      combinedText: buffer.toString().trim(),
      successCount: success,
      failedCount: failed,
    );
  }

  void dispose() {
    _recognizer.close();
  }
}
