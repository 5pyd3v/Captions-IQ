import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_key_store.dart';

class SettingsState {
  final bool loading;
  final String? geminiApiKey;

  const SettingsState({this.loading = true, this.geminiApiKey});

  bool get hasKey => geminiApiKey != null && geminiApiKey!.trim().isNotEmpty;

  SettingsState copyWith({bool? loading, String? geminiApiKey}) {
    return SettingsState(
      loading: loading ?? this.loading,
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final key = await SecureKeyStore.getGeminiKey();
    state = state.copyWith(loading: false, geminiApiKey: key ?? '');
  }

  Future<void> saveKey(String value) async {
    final trimmed = value.trim();
    await SecureKeyStore.setGeminiKey(trimmed);
    state = state.copyWith(geminiApiKey: trimmed);
  }

  Future<void> clearKey() async {
    await SecureKeyStore.clearGeminiKey();
    state = state.copyWith(geminiApiKey: '');
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(),
);
