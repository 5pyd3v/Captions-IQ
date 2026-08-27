import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_snackbar.dart';

enum SummaryLanguage { english, romanUrdu }

class SummaryCard extends StatelessWidget {
  final SummaryLanguage language;
  final String text;

  const SummaryCard({super.key, required this.language, required this.text});

  bool get _isEnglish => language == SummaryLanguage.english;

  @override
  Widget build(BuildContext context) {
    final accent = _isEnglish ? AppColors.englishAccent : AppColors.urduAccent;
    final soft = _isEnglish ? const Color(0xFFE6F7F5) : AppColors.urduAccentSoft;
    final badge = _isEnglish ? 'EN' : 'UR';
    final title = _isEnglish ? 'English summary' : 'Roman Urdu summary';
    final subtitle = _isEnglish ? 'Clear recap in English' : 'Speakable, humanized Roman Urdu';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
                child: Text(
                  badge,
                  style: AppTextStyles.label.copyWith(color: accent, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.title),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              _CopyButton(text: text, accent: accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(text, style: AppTextStyles.bodyLg.copyWith(color: AppColors.foreground)),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String text;
  final Color accent;
  const _CopyButton({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: text));
          if (context.mounted) {
            AppSnackbar.show(context, 'Copied to clipboard');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(Icons.copy_rounded, size: 17, color: accent),
        ),
      ),
    );
  }
}
