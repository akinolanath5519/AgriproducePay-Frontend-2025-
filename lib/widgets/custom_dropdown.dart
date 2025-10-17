import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;
  final String Function(T) displayText;
  final String? Function(T?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final Color? borderColor;
  final Color? fillColor;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;
  final double borderRadius;
  final bool isDense;
  final bool isExpanded;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.displayText,
    this.validator,
    this.contentPadding,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.borderColor,
    this.fillColor,
    this.labelStyle,
    this.textStyle,
    this.borderRadius = 8.0,
    this.isDense = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: isExpanded,
      isDense: isDense,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle ?? const TextStyle(fontWeight: FontWeight.w500),
        hintText: hintText,
        filled: fillColor != null,
        fillColor: fillColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor ?? Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor ?? Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayText(item),
                style: textStyle ?? const TextStyle(fontSize: 15),
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
