import 'package:flutter/material.dart';

/// Caption IQ design tokens — light, premium teal/orange system.
/// Derived from the ui-ux-pro-max "Product Demo + Features" / Flat Design
/// recommendation for a modern AI productivity tool.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF5EEAD4);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF14B8A6);
  static const Color onSecondary = Color(0xFF0F172A);

  static const Color accent = Color(0xFFEA580C);
  static const Color onAccent = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFF6FBFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF7F6);

  static const Color foreground = Color(0xFF0F2A28);
  static const Color muted = Color(0xFF64857F);
  static const Color mutedForeground = Color(0xFF475569);

  static const Color border = Color(0xFFD9EEEB);
  static const Color divider = Color(0xFFE6F2F0);

  static const Color destructive = Color(0xFFDC2626);
  static const Color onDestructive = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);

  static const Color whatsapp = Color(0xFF25D366);
  static const Color whatsappDark = Color(0xFF128C7E);

  /// English summary card accent.
  static const Color englishAccent = Color(0xFF0D9488);
  /// Roman Urdu summary card accent.
  static const Color urduAccent = Color(0xFF7C3AED);
  static const Color urduAccentSoft = Color(0xFFF3EEFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8FBF8), Color(0xFFF6FBFA)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEA580C), Color(0xFFF97316)],
  );
}
