import 'package:readbox/domain/data/entities/entities.dart';

class BookModel extends BookEntity {

  BookModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  factory BookModel.local(
    String filePath,
    String fileName,
    String fileType,
    int fileSize,
    int totalPages,
  ){
    return BookModel.fromJson(
      {
        'fileUrl': filePath,
        'title': fileName,
        'fileType': fileType,
        'fileSize': fileSize,
        'totalPages': totalPages,
        'isLocalBook': true,
      }
    );
  }
  // Helper methods
  bool get isEpub => fileType == BookType.epub;
  bool get isPdf => fileType == BookType.pdf;
  
  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
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

    // Extract author if filename format is "Title - Author.pdf"
  String get displayAuthor {
    if (title?.contains(' - ') ?? false) {
      final parts = title?.split(' - ') ?? [];
      return parts.length > 1 ? parts[1].trim() : 'Unknown';
    }
    return 'Unknown';
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

