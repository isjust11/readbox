import 'package:equatable/equatable.dart';

class AppThemeState extends Equatable {
  final String themeMode; // 'light' or 'dark'
  final int primaryColorValue; // e.g., Colors.indigo.value
  final double textScaleFactor;
  final String backgroundType; // 'default', 'image1', 'pattern_1', 'pattern_2', 'solid'

  const AppThemeState({
    this.themeMode = 'light',
    this.primaryColorValue = 0xFF3F51B5, // Colors.indigo
    this.textScaleFactor = 1.0,
    this.backgroundType = 'default',
  });

  AppThemeState copyWith({
    String? themeMode,
    int? primaryColorValue,
    double? textScaleFactor,
    String? backgroundType,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      backgroundType: backgroundType ?? this.backgroundType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'primaryColorValue': primaryColorValue,
      'textScaleFactor': textScaleFactor,
      'backgroundType': backgroundType,
    };
  }

  factory AppThemeState.fromJson(Map<String, dynamic> json) {
    return AppThemeState(
      themeMode: json['themeMode'] ?? 'light',
      primaryColorValue: json['primaryColorValue'] ?? 0xFF3F51B5,
      textScaleFactor: (json['textScaleFactor'] ?? 1.0).toDouble(),
      backgroundType: json['backgroundType'] ?? 'default',
    );
  }

  @override
  List<Object?> get props => [themeMode, primaryColorValue, textScaleFactor, backgroundType];
}
