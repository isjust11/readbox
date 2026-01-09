import 'package:flutter/material.dart';
import 'package:readbox/res/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      titleLarge: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      titleMedium: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      titleSmall: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      headlineLarge: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      displayLarge: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      displayMedium: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
      displaySmall: TextStyle(
        color: AppColors.lightBackgroundAlt,
      ),
    ),
  );
}