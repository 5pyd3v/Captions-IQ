import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_item.dart';
import '../services/supabase_service.dart';

class HistoryState {
  final bool loading;
  final String? error;
  final List<HistoryItem> items;

  const HistoryState({this.loading = true, this.error, this.items = const []});

  HistoryState copyWith({bool? loading, String? error, List<HistoryItem>? items}) {
    return HistoryState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class HistoryController extends StateNotifier<HistoryState> {
  HistoryController() : super(const HistoryState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await SupabaseService.fetchHistory();
      state = state.copyWith(loading: false, items: items);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void prepend(HistoryItem item) {
    state = state.copyWith(items: [item, ...state.items]);
  }

  Future<void> delete(String id) async {
    final previous = state.items;
    state = state.copyWith(items: previous.where((e) => e.id != id).toList());
    try {
      await SupabaseService.deleteSession(id);
    } catch (e) {
      state = state.copyWith(items: previous, error: e.toString());
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryController, HistoryState>(
  (ref) => HistoryController(),
);
