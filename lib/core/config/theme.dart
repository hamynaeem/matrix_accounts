import 'package:flutter/material.dart';

ThemeData buildMatrixTheme() {
  const primaryBlue = Color(0xFF007ACC);
  final base = ThemeData.light();

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primaryBlue,
      secondary: primaryBlue,
    ),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    textTheme: base.textTheme
        .copyWith(
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: const TextStyle(
            fontSize: 13,
          ),
          bodySmall: const TextStyle(
            fontSize: 11,
            color: Color(0xFF757575),
          ),
        )
        .apply(
          fontFamily: 'Roboto',
          bodyColor: const Color(0xFF1A1A1A),
          displayColor: const Color(0xFF1A1A1A),
        ),
    visualDensity: VisualDensity.compact,
  );
}
