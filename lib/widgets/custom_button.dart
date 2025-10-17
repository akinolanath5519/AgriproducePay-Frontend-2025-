import 'package:flutter/material.dart';

enum ButtonType { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? textColor;
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final ButtonType type;
  final IconData? icon;
  final double iconSize;
  final Color? borderColor;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.color,
    this.textColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.elevation = 0,
    this.type = ButtonType.filled,
    this.icon,
    this.iconSize = 20,
    this.borderColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    OutlinedBorder shape = RoundedRectangleBorder(borderRadius: borderRadius);

    switch (type) {
      case ButtonType.filled:
        backgroundColor = isDisabled
            ? Colors.grey.shade300
            : (color ?? theme.primaryColor);
        foregroundColor = textColor ?? Colors.white;
        break;
      case ButtonType.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? (color ?? theme.primaryColor);
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        foregroundColor = textColor ?? theme.primaryColor;
        break;
    }

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      shape: shape,
      elevation: type == ButtonType.filled ? elevation : 0,
      side: type == ButtonType.outlined
          ? BorderSide(color: borderColor ?? (color ?? theme.primaryColor))
          : BorderSide.none,
      minimumSize: Size(width ?? double.infinity, height),
    );

    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(icon, size: iconSize, color: foregroundColor),
                ),
              Text(
                text,
                style: textStyle ??
                    TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: child,
      ),
    );
  }
}
