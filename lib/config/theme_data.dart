import 'package:flutter/material.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/blocs/theme_state.dart';

class AppTheme {
  late Color primaryColor;

  AppTheme.init() {
    primaryColor = Colors.indigo;
  }

  static ThemeData getLightTheme(AppThemeState state) {
    final Color primary = Color(state.primaryColorValue);
    final textTheme = Typography.material2021().black;

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
      useMaterial3: true,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: AppColors.lightBackgroundAlt.withValues(alpha: 0.2),
      ),
      chipTheme: ChipThemeData(backgroundColor: primary),
    );
  }

  static ThemeData getDarkTheme(AppThemeState state) {
    final Color primary = Color(state.primaryColorValue);
    final textTheme = Typography.material2021().white.apply(
      bodyColor: AppColors.lightBackgroundAlt,
      displayColor: AppColors.lightBackgroundAlt,
    );

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
      ),
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        titleTextStyle: TextStyle(color: AppColors.black, fontSize: 20),
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      scaffoldBackgroundColor:
          AppColors.white, // In dark theme? (Kept original logic)
      cardColor: AppColors.white,
      cardTheme: CardThemeData(color: AppColors.white),
      iconTheme: IconThemeData(color: AppColors.black),
      dividerTheme: DividerThemeData(
        color: AppColors.lightBackgroundAlt.withValues(alpha: 0.2),
      ),
    );
  }

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
