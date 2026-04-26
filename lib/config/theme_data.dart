import 'package:flutter/material.dart';
import 'package:readbox/res/colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    primaryColor: Colors.indigo,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
    dividerTheme: DividerThemeData(
      color: AppColors.lightBackgroundAlt.withValues(alpha: 0.2),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.indigo,
    primaryColor: Colors.indigo,
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightBackgroundAlt),
      bodyMedium: TextStyle(color: AppColors.lightBackgroundAlt),
      bodySmall: TextStyle(color: AppColors.lightBackgroundAlt),
      titleLarge: TextStyle(color: AppColors.lightBackgroundAlt),
      titleMedium: TextStyle(color: AppColors.lightBackgroundAlt),
      titleSmall: TextStyle(color: AppColors.lightBackgroundAlt),
      headlineLarge: TextStyle(color: AppColors.lightBackgroundAlt),
      headlineMedium: TextStyle(color: AppColors.lightBackgroundAlt),
      headlineSmall: TextStyle(color: AppColors.lightBackgroundAlt),
      displayLarge: TextStyle(color: AppColors.lightBackgroundAlt),
      displayMedium: TextStyle(color: AppColors.lightBackgroundAlt),
      displaySmall: TextStyle(color: AppColors.lightBackgroundAlt),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      titleTextStyle: TextStyle(color: AppColors.black),
      iconTheme: IconThemeData(color: AppColors.black),
    ),
    scaffoldBackgroundColor: AppColors.white,
    cardColor: AppColors.white,
    cardTheme: CardThemeData(color: AppColors.white),
    iconTheme: IconThemeData(color: AppColors.black),
    dividerTheme: DividerThemeData(
      color: AppColors.lightBackgroundAlt.withValues(alpha: 0.2),
    ),
  );

  // gradient theme
  static LinearGradient indigoCyanGradient({
    double? opacity,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    List<Color> colors = const [Colors.indigo, Colors.cyanAccent],
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.map((e) => e.withValues(alpha: opacity ?? 0.2)).toList(),
    );
  }
}
