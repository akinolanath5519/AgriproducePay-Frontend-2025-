import 'package:flutter/material.dart';
import 'custom_button.dart';

/// A reusable, flexible dialog widget for confirmation, info, or form actions.
/// Works for Delete, Edit, Save, Confirm, etc.
class CustomDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final bool showCancelButton;
  final bool isLoading;
  final double radius;

  const CustomDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmText = "OK",
    this.cancelText = "Cancel",
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.showCancelButton = true,
    this.isLoading = false,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      content: content,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        if (showCancelButton)
          TextButton(
            onPressed: isLoading ? null : (onCancel ?? () => Navigator.pop(context)),
            child: Text(
              cancelText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        CustomButton(
          text: confirmText,
          onPressed: isLoading ? null : (onConfirm ?? () => Navigator.pop(context)),
          color: confirmColor ?? theme.colorScheme.primary,
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ],
    );
  }
}
