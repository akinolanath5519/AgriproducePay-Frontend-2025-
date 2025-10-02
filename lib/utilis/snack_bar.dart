import 'package:flutter/material.dart';
import 'package:agriproduce/theme/app_theme.dart';

/// Show a success snackbar
void showSuccessSnackbar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
    ),
  );
}

/// Show an error snackbar
void showErrorSnackbar(BuildContext context, String message) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: theme.mediumBorderRadius),
    ),
  );
}
