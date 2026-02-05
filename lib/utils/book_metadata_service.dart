import 'dart:io';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Model chứa metadata cơ bản của sách được extract từ file.
class BookMetadata {
  final int? totalPages;
  final String? title;
  final String? author;
  final String? subject;
  final String? keywords;
  final String? creator;
  final String? producer;
  final DateTime? creationDate;
  final DateTime? modificationDate;
  final int? fileSize; // bytes
  final String? language;
  final String? publisher;
  final String? isbn;

  BookMetadata({
    this.totalPages,
    this.title,
    this.author,
    this.subject,
    this.keywords,
    this.creator,
    this.producer,
    this.creationDate,
    this.modificationDate,
    this.fileSize,
    this.language,
    this.publisher,
    this.isbn,
  });

  /// Convert sang Map để dễ sử dụng
  Map<String, dynamic> toMap() {
    return {
      'totalPages': totalPages,
      'title': title,
      'author': author,
      'subject': subject,
      'keywords': keywords,
      'creator': creator,
      'producer': producer,
      'creationDate': creationDate?.toIso8601String(),
      'modificationDate': modificationDate?.toIso8601String(),
      'fileSize': fileSize,
      'language': language,
      'publisher': publisher,
      'isbn': isbn,
    };
  }

  @override
  String toString() {
    return 'BookMetadata('
        'totalPages: $totalPages, '
        'title: $title, '
        'author: $author, '
        'fileSize: $fileSize'
        ')';
  }
}

/// Service extract metadata từ file sách (PDF, EPUB, MOBI, ...).
class BookMetadataService {
  BookMetadataService._();

  /// Extract metadata từ file PDF.
  /// Trả về [BookMetadata] với các thông tin có thể lấy được.
  static Future<BookMetadata> extractFromPdf(String filePath) async {
    final file = File(filePath);
    final fileSize = await file.length();

    try {
      // Dùng pdfx để lấy số trang và metadata cơ bản
      final document = await pdfx.PdfDocument.openFile(filePath);
      try {
        final totalPages = document.pagesCount;

        // Dùng syncfusion để lấy metadata chi tiết hơn
        final pdfBytes = await file.readAsBytes();
        final pdfDocument = PdfDocument(inputBytes: pdfBytes);
        try {
          final documentInfo = pdfDocument.documentInformation;

          // Extract ISBN từ keywords hoặc subject nếu có
          String? isbn;
          final keywords = documentInfo.keywords.isNotEmpty == true ? documentInfo.keywords : '';
          final subject = documentInfo.subject.isNotEmpty == true ? documentInfo.subject : '';
          final combined = '$keywords $subject';
          
          // Tìm ISBN pattern (ISBN-10 hoặc ISBN-13)
          final isbnPattern = RegExp(r'ISBN[- ]?(?:13)?:?\s*([0-9X]{10,13})', caseSensitive: false);
          final match = isbnPattern.firstMatch(combined);
          if (match != null) {
            isbn = match.group(1)?.replaceAll(RegExp(r'[-\s]'), '');
          }

          return BookMetadata(
            totalPages: totalPages > 0 ? totalPages : null,
            title: documentInfo.title.isNotEmpty == true 
                ? documentInfo.title 
                : null,
            author: documentInfo.author.isNotEmpty == true 
                ? documentInfo.author 
                : null,
            subject: documentInfo.subject.isNotEmpty == true 
                ? documentInfo.subject 
                : null,
            keywords: keywords.isNotEmpty ? keywords : null,
            creator: documentInfo.creator.isNotEmpty == true 
                ? documentInfo.creator 
                : null,
            producer: documentInfo.producer.isNotEmpty == true 
                ? documentInfo.producer 
                : null,
            creationDate: documentInfo.creationDate,
            modificationDate: documentInfo.modificationDate,
            fileSize: fileSize,
            language: _extractLanguage(documentInfo),
            publisher: _extractPublisher(documentInfo),
            isbn: isbn,
          );
        } finally {
          pdfDocument.dispose();
        }
      } finally {
        await document.close();
      }
    } catch (e) {
      // Nếu lỗi, vẫn trả về metadata cơ bản (file size)
      return BookMetadata(
        fileSize: fileSize,
      );
    }
  }

  /// Extract metadata từ file EPUB (cần thêm package epub_parser nếu muốn hỗ trợ).
  /// Hiện tại chỉ trả về file size.
  static Future<BookMetadata> extractFromEpub(String filePath) async {
    final file = File(filePath);
    final fileSize = await file.length();

    return BookMetadata(
      fileSize: fileSize,
    );
  }

  /// Extract metadata từ file MOBI (cần thêm package mobi_parser nếu muốn hỗ trợ).
  /// Hiện tại chỉ trả về file size.
  static Future<BookMetadata> extractFromMobi(String filePath) async {
    final file = File(filePath);
    final fileSize = await file.length();

    return BookMetadata(
      fileSize: fileSize,
    );
  }

  /// Extract metadata tự động dựa vào extension của file.
  static Future<BookMetadata> extractFromFile(String filePath) async {
    final extension = filePath.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return extractFromPdf(filePath);
      case 'epub':
        return extractFromEpub(filePath);
      case 'mobi':
        return extractFromMobi(filePath);
      default:
        // Nếu không hỗ trợ, chỉ trả về file size
        final file = File(filePath);
        final fileSize = await file.length();
        return BookMetadata(fileSize: fileSize);
    }
  }

  /// Extract language từ document properties.
  /// Có thể từ keywords, subject hoặc metadata khác.
  static String? _extractLanguage(PdfDocumentInformation properties) {
    // Thử tìm language trong keywords hoặc subject
    final keywords = properties.keywords.isNotEmpty == true ? properties.keywords : '';
    final subject = properties.subject.isNotEmpty == true ? properties.subject : '';
    final combined = '$keywords $subject'.toLowerCase();

    // Common language codes
    final languagePattern = RegExp(
      r'\b(vi|en|fr|de|es|it|pt|ru|zh|ja|ko|ar|hi|th|id|ms)\b',
      caseSensitive: false,
    );
    final match = languagePattern.firstMatch(combined);
    if (match != null) {
      return match.group(1)?.toLowerCase();
    }

    return null;
  }

  /// Extract publisher từ document properties.
  /// Có thể từ creator, producer hoặc subject.
  static String? _extractPublisher(PdfDocumentInformation properties) {
    // Thử tìm publisher trong các field
    final creator = properties.creator.isNotEmpty == true ? properties.creator : '';
    final producer = properties.producer.isNotEmpty == true ? properties.producer : '';

    // Nếu creator hoặc producer có vẻ là tên nhà xuất bản
    if (creator.isNotEmpty && !creator.toLowerCase().contains('pdf')) {
      return creator;
    }
    if (producer.isNotEmpty && !producer.toLowerCase().contains('pdf')) {
      return producer;
    }

    return null;
  }

  /// Validate ISBN format.
  static bool isValidIsbn(String? isbn) {
    if (isbn == null || isbn.isEmpty) return false;
    
    // Remove hyphens and spaces
    final cleaned = isbn.replaceAll(RegExp(r'[-\s]'), '');
    
    // ISBN-10: 10 digits (last can be X)
    if (cleaned.length == 10) {
      return RegExp(r'^[0-9]{9}[0-9X]$').hasMatch(cleaned);
    }
    
    // ISBN-13: 13 digits starting with 978 or 979
    if (cleaned.length == 13) {
      return RegExp(r'^97[89][0-9]{10}$').hasMatch(cleaned);
    }
    
    return false;
  }
}
