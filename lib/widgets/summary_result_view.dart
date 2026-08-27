import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/history_item.dart';
import 'summary_card.dart';
import 'whatsapp_share_button.dart';

/// Shared "two summaries + share" layout, reused by the post-scan Result
/// screen and the History detail screen.
class SummaryResultView extends StatelessWidget {
  final HistoryItem item;
  final Widget? footer;

  const SummaryResultView({super.key, required this.item, this.footer});

  String get _shareText =>
      '${item.summaryEn}\n\n— Roman Urdu —\n${item.summaryRomanUr}\n\nSummarized by Caption IQ';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_rounded, size: 15, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                '${item.imageCount} screenshot${item.imageCount == 1 ? '' : 's'} · '
                '${DateFormat('MMM d, h:mm a').format(item.createdAt)}',
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SummaryCard(language: SummaryLanguage.english, text: item.summaryEn)
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: AppSpacing.lg),
        SummaryCard(language: SummaryLanguage.romanUrdu, text: item.summaryRomanUr)
            .animate()
            .fadeIn(duration: 350.ms, delay: 90.ms)
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
        const SizedBox(height: AppSpacing.xl),
        WhatsAppShareButton(text: _shareText)
            .animate()
            .fadeIn(duration: 350.ms, delay: 160.ms),
        if (footer != null) ...[const SizedBox(height: AppSpacing.lg), footer!],
      ],
    );
  }
}
