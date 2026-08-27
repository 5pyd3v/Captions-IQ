import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../state/scan_controller.dart';
import '../../widgets/app_button.dart';
import '../../widgets/summary_result_view.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanControllerProvider);
    final result = state.result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(automaticallyImplyLeading: false, title: const Text('Summary')),
        body: const SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Summary ready'),
      ),
      body: SummaryResultView(item: result),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            label: 'Scan more screenshots',
            icon: Icons.add_photo_alternate_rounded,
            onPressed: () {
              ref.read(scanControllerProvider.notifier).clear();
              context.go('/home');
            },
          ),
        ),
      ),
    );
  }
}
