import 'package:flutter/material.dart';

class CustomDecorations {
  static BoxDecoration backgroundDecoration({
    required String imagePath,
    ColorFilter? colorFilter,
    BoxFit fit = BoxFit.cover,
    BlendMode blendMode = BlendMode.darken,
    Color color = Colors.black45,
  }) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: fit,
        colorFilter: colorFilter ?? ColorFilter.mode(color, blendMode),
      ),
    );
  }
}