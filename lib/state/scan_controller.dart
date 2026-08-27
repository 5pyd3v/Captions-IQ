import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_item.dart';
import '../services/gemini_service.dart';
import '../services/ocr_service.dart';
import '../services/supabase_service.dart';
import 'history_provider.dart';
import 'settings_provider.dart';

enum ScanStage { picking, scanning, summarizing, success, error }

class ScanState {
  final ScanStage stage;
  final List<File> images;
  final int ocrCompleted;
  final int ocrTotal;
  final String? errorMessage;
  final HistoryItem? result;

  const ScanState({
    this.stage = ScanStage.picking,
    this.images = const [],
    this.ocrCompleted = 0,
    this.ocrTotal = 0,
    this.errorMessage,
    this.result,
  });

  bool get isBusy => stage == ScanStage.scanning || stage == ScanStage.summarizing;

  double get ocrProgress => ocrTotal == 0 ? 0 : ocrCompleted / ocrTotal;

  ScanState copyWith({
    ScanStage? stage,
    List<File>? images,
    int? ocrCompleted,
    int? ocrTotal,
    String? errorMessage,
    HistoryItem? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ScanState(
      stage: stage ?? this.stage,
      images: images ?? this.images,
      ocrCompleted: ocrCompleted ?? this.ocrCompleted,
      ocrTotal: ocrTotal ?? this.ocrTotal,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

class ScanController extends StateNotifier<ScanState> {
  final Ref _ref;
  final OcrService _ocr = OcrService();
  final GeminiService _gemini = GeminiService();

  ScanController(this._ref) : super(const ScanState());

  void setImages(List<File> images) {
    state = ScanState(images: images);
  }

  void addImages(List<File> images) {
    state = state.copyWith(images: [...state.images, ...images], clearError: true);
  }

  void removeImageAt(int index) {
    final updated = [...state.images]..removeAt(index);
    state = state.copyWith(images: updated);
  }

  void clear() {
    state = const ScanState();
  }

  Future<void> startScan() async {
    debugPrint('[CaptionIQ] startScan() called, stage=${state.stage}, images=${state.images.length}');
    if (state.images.isEmpty) return;

    final apiKey = _ref.read(settingsProvider).geminiApiKey ?? '';
    if (apiKey.trim().isEmpty) {
      state = state.copyWith(
        stage: ScanStage.error,
        errorMessage: 'Add your Gemini API key in Settings before scanning.',
      );
      return;
    }

    state = state.copyWith(
      stage: ScanStage.scanning,
      ocrCompleted: 0,
      ocrTotal: state.images.length,
      clearError: true,
      clearResult: true,
    );

    try {
      final ocrResult = await _ocr.recognizeBatch(
        state.images,
        onProgress: (completed, total) {
          state = state.copyWith(ocrCompleted: completed, ocrTotal: total);
        },
      );

      if (ocrResult.combinedText.trim().isEmpty) {
        state = state.copyWith(
          stage: ScanStage.error,
          errorMessage:
              'No readable text was found in these screenshots. Try clearer captures and scan again.',
        );
        return;
      }

      state = state.copyWith(stage: ScanStage.summarizing);
      debugPrint('[CaptionIQ] OCR done, ${ocrResult.combinedText.length} chars. Calling Gemini...');

      final summary = await _gemini.summarize(
        apiKey: apiKey,
        rawText: ocrResult.combinedText,
      );

      final title = _deriveTitle(summary.summaryEn);

      final saved = await SupabaseService.saveSession(
        title: title,
        imageCount: state.images.length,
        rawText: ocrResult.combinedText,
        summaryEn: summary.summaryEn,
        summaryRomanUr: summary.summaryRomanUrdu,
      );

      _ref.read(historyProvider.notifier).prepend(saved);

      state = state.copyWith(stage: ScanStage.success, result: saved);
      debugPrint('[CaptionIQ] Success.');
    } on GeminiException catch (e) {
      debugPrint('[CaptionIQ] GeminiException: ${e.message}');
      state = state.copyWith(stage: ScanStage.error, errorMessage: e.message);
    } catch (e, st) {
      debugPrint('[CaptionIQ] Unexpected error: $e\n$st');
      state = state.copyWith(
        stage: ScanStage.error,
        errorMessage: 'Something went wrong while processing. Please try again.',
      );
    }
  }

  String _deriveTitle(String summaryEn) {
    final firstSentence = summaryEn.split(RegExp(r'(?<=[.!?])\s')).first.trim();
    if (firstSentence.length <= 60) return firstSentence;
    return '${firstSentence.substring(0, 57).trim()}...';
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }
}

final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>(
  (ref) => ScanController(ref),
);
