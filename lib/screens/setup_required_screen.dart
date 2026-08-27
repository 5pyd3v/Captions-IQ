import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Shown instead of the app when lib/core/config/supabase_config.dart
/// still has placeholder credentials, so first run fails loudly and
/// helpfully instead of crashing on a network call.
class SetupRequiredScreen extends StatelessWidget {
  final String reason;
  const SetupRequiredScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.settings_suggest_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('One-time setup needed', style: AppTextStyles.displayMd),
              const SizedBox(height: AppSpacing.sm),
              Text(reason, style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '1. Create a free project at supabase.com\n'
                '2. Run supabase/schema.sql in its SQL editor\n'
                '3. Enable Authentication → Providers → Anonymous\n'
                '4. Put your Project URL + anon key into\n'
                '   lib/core/config/supabase_config.dart\n'
                '   (or pass them with --dart-define)\n'
                '5. Rebuild the app',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.7),
              ),
              const SizedBox(height: AppSpacing.lg),
              SelectableText(
                'lib/core/config/supabase_config.dart',
                style: AppTextStyles.caption.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
