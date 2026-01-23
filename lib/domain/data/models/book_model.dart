import 'package:readbox/domain/data/entities/entities.dart';

class BookModel extends BookEntity {
  BookModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);
  
  // Helper methods
  String get displayTitle => title ?? 'Untitled';
  String get displayAuthor => author ?? 'Unknown Author';
  final bool _isLocalBook = false;
  bool get isEpub => fileType == BookType.EPUB_BOOK;
  bool get isPdf => fileType == BookType.PDF_BOOK;
  
  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  set isLocalBook(bool value) {
    isLocalBook = value;
  }

  bool get isLocalBook => _isLocalBook;
  
  double get progressPercentage {
    // This will be calculated from reading progress
    return 0.0;
  }
  
  String get categoriesDisplay {
    if (categories == null || categories!.isEmpty) return 'No category';
    return categories!.join(', ');
  }
}

