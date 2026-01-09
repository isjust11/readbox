import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/theme_cubit.dart';

/// Utility class để kiểm tra và làm việc với theme
class ThemeHelper {
  ThemeHelper._();

  /// Kiểm tra theme hiện tại là dark mode hay light mode
  /// 
  /// Cách 1: Kiểm tra từ BuildContext (Khuyến nghị)
  /// ```dart
  /// final isDark = ThemeHelper.isDarkMode(context);
  /// if (isDark) {
  ///   // Dark mode
  /// } else {
  ///   // Light mode
  /// }
  /// ```
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Kiểm tra theme hiện tại là light mode
  /// 
  /// ```dart
  /// if (ThemeHelper.isLightMode(context)) {
  ///   // Light mode
  /// }
  /// ```
  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  /// Lấy brightness hiện tại (Brightness.dark hoặc Brightness.light)
  /// 
  /// ```dart
  /// final brightness = ThemeHelper.getBrightness(context);
  /// if (brightness == Brightness.dark) {
  ///   // Dark mode
  /// }
  /// ```
  static Brightness getBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }

  /// Kiểm tra theme từ ThemeCubit state
  /// 
  /// Sử dụng khi cần check theme mà không có BuildContext,
  /// hoặc cần check theme trước khi build widget
  /// 
  /// ```dart
  /// final themeCubit = context.read<ThemeCubit>();
  /// final isDark = ThemeHelper.isDarkModeFromCubit(themeCubit);
  /// ```
  static bool isDarkModeFromCubit(ThemeCubit themeCubit) {
    return themeCubit.state == 'dark';
  }

  /// Kiểm tra theme từ ThemeCubit state (dùng context)
  /// 
  /// ```dart
  /// final isDark = ThemeHelper.isDarkModeFromContext(context);
  /// ```
  static bool isDarkModeFromContext(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    return themeCubit.state == 'dark';
  }

  /// Lấy theme string từ ThemeCubit ('dark' hoặc 'light')
  /// 
  /// ```dart
  /// final theme = ThemeHelper.getThemeString(context);
  /// // theme = 'dark' hoặc 'light'
  /// ```
  static String getThemeString(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    return themeCubit.state;
  }

  /// Thay đổi theme
  /// 
  /// ```dart
  /// // Chuyển sang dark mode
  /// ThemeHelper.setTheme(context, 'dark');
  /// 
  /// // Chuyển sang light mode
  /// ThemeHelper.setTheme(context, 'light');
  /// ```
  static void setTheme(BuildContext context, String theme) {
    context.read<ThemeCubit>().changeTheme(theme);
  }

  /// Toggle theme (chuyển đổi giữa dark và light)
  /// 
  /// ```dart
  /// ThemeHelper.toggleTheme(context);
  /// ```
  static void toggleTheme(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final currentTheme = themeCubit.state;
    themeCubit.changeTheme(currentTheme == 'dark' ? 'light' : 'dark');
  }
}

