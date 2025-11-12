import 'package:readbox/domain/data/entities/entities.dart';

class ChapterModel extends ChapterEntity {
  ChapterModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String get displayTitle => title ?? 'Chapter ${order ?? 0}';
}

