
import 'dart:ui';

import 'package:flutter/material.dart';

class LightAppColors {
  static const Color primaryColor = Color(0xFF86D668); // Example: Green
  static const Color primaryTextColor = Color(0xFFFFFFFF); // Example: White
  static const Color secondaryColor = Color(0xFFFFC107); // Example: Amber
  static const Color secondaryTextColor = Color(0xFF000000); // Example: Black

  // Optional: You can also define a ThemeData if needed
  static ThemeData get themeData => ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      titleLarge: TextStyle(color: primaryTextColor, fontSize: 18),
      bodyLarge: TextStyle(color: secondaryTextColor, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: primaryTextColor,
    ),
  );
}