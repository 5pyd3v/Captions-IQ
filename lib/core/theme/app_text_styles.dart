import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type system: DM Sans for display/headings, Inter for UI/body text.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _dmSans => GoogleFonts.dmSans(color: AppColors.foreground);
  static TextStyle get _inter => GoogleFonts.inter(color: AppColors.foreground);

  static TextStyle get displayLg => _dmSans.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.6,
      );

  static TextStyle get displayMd => _dmSans.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
      );

  static TextStyle get headline => _dmSans.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle get title => _dmSans.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get bodyLg => _inter.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  static TextStyle get body => _inter.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.mutedForeground,
      );

  static TextStyle get bodyMedium => _inter.copyWith(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get label => _inter.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
      );

  static TextStyle get caption => _inter.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.muted,
      );

  static TextStyle get button => _inter.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.1,
      );
}
