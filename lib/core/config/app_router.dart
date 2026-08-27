import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/history_item.dart';
import '../../screens/history/history_detail_screen.dart';
import '../../screens/processing/processing_screen.dart';
import '../../screens/result/result_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/shell/root_shell.dart';
import '../../state/history_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const RootShell()),
      GoRoute(path: '/home', builder: (context, state) => const RootShell()),
      GoRoute(path: '/processing', builder: (context, state) => const ProcessingScreen()),
      GoRoute(path: '/result', builder: (context, state) => const ResultScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) {
          final passed = state.extra as HistoryItem?;
          if (passed != null) return HistoryDetailScreen(item: passed);

          final id = state.pathParameters['id'];
          final match = ref
              .read(historyProvider)
              .items
              .where((e) => e.id == id)
              .cast<HistoryItem?>()
              .firstWhere((_) => true, orElse: () => null);
          if (match != null) return HistoryDetailScreen(item: match);

          return const RootShell();
        },
      ),
    ],
  );
});
