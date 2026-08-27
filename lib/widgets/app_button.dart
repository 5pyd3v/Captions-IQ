import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';

/// Primary CTA button with a gradient fill, soft shadow, and a built-in
/// loading state so async actions never leave the user guessing.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;

    return Opacity(
      opacity: disabled && !loading ? 0.5 : 1,
      child: Container(
        width: expand ? double.infinity : null,
        height: 56,
        decoration: BoxDecoration(
          gradient: disabled ? null : AppColors.primaryGradient,
          color: disabled ? AppColors.muted.withValues(alpha: 0.3) : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: disabled ? null : onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (loading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ] else if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary, low-emphasis button (outlined) for dismissive/alt actions.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: icon != null
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: Text(label),
            ),
    );
  }
}
