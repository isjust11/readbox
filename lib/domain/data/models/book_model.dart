import 'package:readbox/domain/data/entities/entities.dart';

class BookModel extends BookEntity {

  BookModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  factory BookModel.local(
    String filePath,
    String title,
    String author,
    String description,
    String publisher,
    String isbn,
    String language,
    String fileUrl,
    int totalPages,
    String fileType,
    int fileSize,
  ){
    return BookModel.fromJson(
      {
        'fileUrl': filePath,
        'title': title,
        'author': author,
        'description': description,
        'publisher': publisher,
        'isbn': isbn,
        'language': language,
        'isLocalBook': true,
        'totalPages': totalPages,
        'fileType': fileType,
        'fileSize': fileSize,
      }
    );
  }
  // Helper methods
  bool get isEpub => fileType == BookType.epub;
  bool get isPdf => fileType == BookType.pdf;
  
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  double get progressPercentage {
    // This will be calculated from reading progress
    return 0.0;
  }
  
  String get categoriesDisplay {
    if (categories == null || categories!.isEmpty) return 'No category';
    return categories!.join(', ');
  }


  // Get clean title without author
  String get displayTitle {
    if (title?.contains(' - ') ?? false) {
      return title?.split(' - ')[0].trim() ?? '';
    }
    return title ?? '';
  }

  BookModel copyWith({
    String? title,
    String? author,
    String? description,
    String? coverImageUrl,
    String? fileUrl,
    BookType? fileType,
    int? fileSize,
  }) {
    return BookModel.fromJson({
      ...toJson(),
      'title': title,
      'author': author,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'fileSize': fileSize,
    });
  }
}

