import 'package:flutter/material.dart';

ThemeData customThemeData() {
  return ThemeData(
    primaryColor: const Color(0xFF370E4A),
    primaryColorLight: const Color(0xffFDBCB4),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF370E4A).withOpacity(0.9),
      titleTextStyle: const TextStyle(fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white)
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(const Color(0xFF370E4A)),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      titleMedium: titleMedium,
      titleLarge: titleLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      labelLarge: labelLarge,
      labelMedium: labelMedium
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF370E4A),
      textTheme: ButtonTextTheme.primary,
    ),
  );
}

const headlineLarge = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const displayLarge = TextStyle(
  color: Color(0xFFE3E3E3),
  fontSize: 28,
  fontWeight: FontWeight.bold,
);

const labelMedium = TextStyle(
  color: Color(0xFFE3E3E3),
  fontWeight: FontWeight.bold,
  fontSize: 20,
);

const titleMedium = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.normal,
  color: Colors.white,
);

const titleLarge = TextStyle(
  color: Colors.white,
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);

const bodyLarge = TextStyle(
  color: Colors.white,
  fontSize: 17.0,
  fontWeight: FontWeight.bold,
  decoration: TextDecoration.underline,
);

const headlineMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const bodyMedium = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFF370E4A),
);

const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF370E4A),
    letterSpacing: 2,
    fontStyle: FontStyle.italic);
