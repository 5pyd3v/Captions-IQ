import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

class ImageGridTile extends StatelessWidget {
  final File file;
  final int index;
  final VoidCallback onRemove;

  const ImageGridTile({
    super.key,
    required this.file,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.surfaceAlt),
          Image.file(file, fit: BoxFit.cover),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                '${index + 1}',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: Material(
              color: Colors.black.withValues(alpha: 0.55),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddMoreTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddMoreTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: DottedBorderBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 26),
              const SizedBox(height: AppSpacing.xs),
              Text('Add more', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed-border container (no external package dependency).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Padding(padding: const EdgeInsets.all(4), child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadius.sm),
    );
    final path = Path()..addRRect(rrect);
    final dashed = _dashPath(path, dashLength: 6, gapLength: 4);
    canvas.drawPath(dashed, paint);
  }

  Path _dashPath(Path source, {required double dashLength, required double gapLength}) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        final next = (distance + length).clamp(0, metric.length).toDouble();
        if (draw) {
          dest.addPath(metric.extractPath(distance, next), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
