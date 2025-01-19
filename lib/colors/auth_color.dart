// lib/widgets/box_decoration.dart

import 'package:flutter/material.dart';

class AppBoxDecoration {
  static BoxDecoration get gradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF4A0072), // Darker deep purple color
          Color(0xFF7B1FA2), // Slightly lighter purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
