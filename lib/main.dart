import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'screens/setup_required_screen.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? setupError;
  if (!SupabaseConfig.isConfigured) {
    setupError =
        'Supabase credentials are still placeholders, so Caption IQ has nothing to save history to yet.';
  } else {
    try {
      await SupabaseService.init();
    } catch (e) {
      setupError = 'Could not connect to Supabase: $e';
    }
  }

  runApp(ProviderScope(child: CaptionIqApp(setupError: setupError)));
}

class CaptionIqApp extends ConsumerWidget {
  final String? setupError;
  const CaptionIqApp({super.key, this.setupError});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (setupError != null) {
      return MaterialApp(
        title: 'Caption IQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: SetupRequiredScreen(reason: setupError!),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Caption IQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
