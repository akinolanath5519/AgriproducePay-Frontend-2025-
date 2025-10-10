import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? header; // Flexible: Text, Row, Avatar, etc.
  final List<Widget> content; // Main content (can be any widgets)
  final VoidCallback? onTap; // Tap action
  final Color? backgroundColor; // Custom background
  final EdgeInsetsGeometry? padding; // Custom padding
  final EdgeInsetsGeometry? margin; // Custom margin
  final double borderRadius; // Custom border radius
  final double elevation; // Shadow depth
  final BorderSide? border; // Optional border (fixed type!)

  const CustomCard({
    super.key,
    this.header,
    required this.content,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius = 8.0,
    this.elevation = 0.5,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: margin ?? const EdgeInsets.only(bottom: 14.0),
        elevation: elevation,
        color: backgroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border ??
              BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (header != null) ...[
                header!,
                const SizedBox(height: 8),
              ],
              ...content,
            ],
          ),
        ),
      ),
    );
  }
}
