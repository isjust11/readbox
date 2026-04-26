import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:readbox/blocs/theme_state.dart';

class ThemeCubit extends Cubit<AppThemeState> {
  ThemeCubit(super.initialState);

  /// Helper to initialize the cubit asynchronously from main.dart
  static Future<ThemeCubit> init() async {
    final json = await SharedPreferenceUtil.getAppThemeStateJson();
    AppThemeState state;
    if (json != null) {
      state = AppThemeState.fromJson(json);
    } else {
      // Fallback to the old simple string theme mode if no complex state exists
      final oldThemeString = await SharedPreferenceUtil.getTheme();
      state = AppThemeState(themeMode: oldThemeString);
    }
    return ThemeCubit(state);
  }

  /// Update the entire theme state
  void updateThemeState(AppThemeState newState) async {
    await SharedPreferenceUtil.saveAppThemeStateJson(newState.toJson());
    // Keep backward compatibility for the old string setting
    await SharedPreferenceUtil.setTheme(newState.themeMode);
    emit(newState);
  }

  /// Backward compatibility for existing changeTheme('light'/'dark')
  void changeTheme(String themeMode) {
    updateThemeState(state.copyWith(themeMode: themeMode));
  }
}
