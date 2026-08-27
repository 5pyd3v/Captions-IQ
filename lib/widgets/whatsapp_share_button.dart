import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_snackbar.dart';

/// Opens WhatsApp directly (contact/chat picker) with the summary text
/// pre-filled, using the universal wa.me link so it also degrades
/// gracefully to WhatsApp Web if the app isn't installed.
class WhatsAppShareButton extends StatelessWidget {
  final String text;

  const WhatsAppShareButton({super.key, required this.text});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppSnackbar.show(context, 'Could not open WhatsApp on this device.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.whatsapp,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _open(context),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _WhatsAppGlyph(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Share on WhatsApp',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal vector "chat + call" glyph (speech bubble with a handset)
/// drawn entirely with CustomPaint, so the button reads as a messaging/
/// call action without bundling a third-party brand asset.
class _WhatsAppGlyph extends StatelessWidget {
  const _WhatsAppGlyph();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _WhatsAppGlyphPainter()),
    );
  }
}

class _WhatsAppGlyphPainter extends CustomPainter {
  const _WhatsAppGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white;

    final bubble = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height * 0.82),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
          bottomLeft: const Radius.circular(6),
          bottomRight: Radius.zero,
        ),
      );
    canvas.drawPath(bubble, fill);

    final tail = Path()
      ..moveTo(size.width * 0.62, size.height * 0.82)
      ..lineTo(size.width * 0.62, size.height * 1.0)
      ..lineTo(size.width * 0.88, size.height * 0.82)
      ..close();
    canvas.drawPath(tail, fill);

    final knockout = Paint()..color = AppColors.whatsapp;
    final r = size.width * 0.11;
    for (final dx in [0.28, 0.5, 0.72]) {
      canvas.drawCircle(Offset(size.width * dx, size.height * 0.41), r, knockout);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
