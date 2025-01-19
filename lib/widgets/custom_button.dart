import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width; // Optional width parameter
  final EdgeInsetsGeometry padding;
  final Color color; // Background color of the button
  final BorderRadiusGeometry borderRadius;
  final double elevation;
  final Color shadowColor;

  const CustomButton({
    required this.onPressed,
    required this.text,
    this.width, // Optional width parameter
    this.padding = const EdgeInsets.all(0),
    this.color = Colors.blue, // Default button color
    this.borderRadius = BorderRadius.zero,
    this.elevation = 0,
    this.shadowColor = Colors.transparent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Set the width if provided
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: color, // Use backgroundColor instead of primary
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          elevation: elevation,
          shadowColor: shadowColor,
        ),
        child: Text(text),
      ),
    );
  }
}
