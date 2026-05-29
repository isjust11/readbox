import 'package:readbox/domain/data/entities/entities.dart';

class BookFileModel extends BookFileEntity {
  BookFileModel.fromJson(super.json) : super.fromJson();

  /// Hiển thị format dạng viết hoa (PDF, EPUB, MOBI…).
  String get formatDisplay => format?.toUpperCase() ?? '';
}
