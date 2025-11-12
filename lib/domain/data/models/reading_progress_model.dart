import 'package:readbox/domain/data/entities/entities.dart';

class ReadingProgressModel extends ReadingProgressEntity {
  ReadingProgressModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  double get progressPercentage => (progress ?? 0.0) * 100;
  
  String get progressFormatted => '${progressPercentage.toStringAsFixed(1)}%';
  
  String get readingTimeFormatted {
    if (totalReadingTime == null || totalReadingTime == 0) return '0 min';
    final hours = totalReadingTime! ~/ 3600;
    final minutes = (totalReadingTime! % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
  
  bool get hasProgress => progress != null && progress! > 0;
}

