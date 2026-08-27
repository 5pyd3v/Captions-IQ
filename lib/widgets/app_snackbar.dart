import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.destructive : AppColors.foreground,
        ),
      );
  }
}
