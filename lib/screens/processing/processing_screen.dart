import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/scan_controller.dart';
import '../../widgets/app_button.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('[CaptionIQ] ProcessingScreen.initState() — new State instance created');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stage = ref.read(scanControllerProvider).stage;
      debugPrint('[CaptionIQ] ProcessingScreen post-frame check, stage=$stage');
      if (stage == ScanStage.picking || stage == ScanStage.error) {
        ref.read(scanControllerProvider.notifier).startScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ScanState>(scanControllerProvider, (previous, next) {
      if (next.stage == ScanStage.success) {
        context.go('/result');
      }
    });

    final state = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Processing'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: state.stage == ScanStage.error
              ? _ErrorView(message: state.errorMessage ?? 'Something went wrong.')
              : _ProgressView(state: state),
        ),
      ),
    );
  }
}

class _ProgressView extends StatelessWidget {
  final ScanState state;
  const _ProgressView({required this.state});

  @override
  Widget build(BuildContext context) {
    final isOcr = state.stage == ScanStage.scanning;
    final isSummarizing = state.stage == ScanStage.summarizing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 132,
                height: 132,
                child: CircularProgressIndicator(
                  value: isOcr && state.ocrTotal > 0 ? state.ocrProgress : null,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceAlt,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              Text(
                isOcr && state.ocrTotal > 0
                    ? '${(state.ocrProgress * 100).round()}%'
                    : '',
                style: AppTextStyles.displayMd,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          isOcr ? 'Reading your screenshots' : 'Writing your summary',
          style: AppTextStyles.headline,
          textAlign: TextAlign.center,
        ).animate(key: ValueKey(isOcr)).fadeIn(duration: 250.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          isOcr
              ? 'Extracting text with on-device OCR — ${state.ocrCompleted} of ${state.ocrTotal} done'
              : 'Gemini is turning the conversation into English and Roman Urdu summaries',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _StepDots(
          steps: const ['Scan text', 'Summarize'],
          activeIndex: isSummarizing ? 1 : 0,
        ),
      ],
    );
  }
}

class _StepDots extends StatelessWidget {
  final List<String> steps;
  final int activeIndex;
  const _StepDots({required this.steps, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftDone = (i ~/ 2) < activeIndex;
          return Container(
            width: 28,
            height: 2,
            color: leftDone ? AppColors.primary : AppColors.border,
          );
        }
        final index = i ~/ 2;
        final active = index == activeIndex;
        final done = index < activeIndex;
        return Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (active || done) ? AppColors.primary : AppColors.border,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              steps[index],
              style: AppTextStyles.caption.copyWith(
                color: (active || done) ? AppColors.primaryDark : AppColors.muted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
          ],
        );
      }),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: Color(0xFFFDEDEC),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded, color: AppColors.destructive, size: 36),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Scan interrupted', style: AppTextStyles.headline, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xxl),
        Consumer(
          builder: (context, ref, _) => AppButton(
            label: 'Try again',
            icon: Icons.refresh_rounded,
            onPressed: () => ref.read(scanControllerProvider.notifier).startScan(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Back to screenshots'),
        ),
      ],
    );
  }
}
