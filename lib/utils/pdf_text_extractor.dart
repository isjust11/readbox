import 'dart:ui' show Rect;
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:dio/dio.dart';

/// Kết quả trích xuất text trang kèm vị trí (bounds) từng từ để đánh dấu trên PDF
class PageTextWithBounds {
  final String fullText;
  final int pageNumber;
  final List<WordBoundEntry> wordBounds;

  PageTextWithBounds({
    required this.fullText,
    required this.pageNumber,
    required this.wordBounds,
  });
}

/// Một từ và vùng bounds tương ứng (chỉ số ký tự trong fullText)
class WordBoundEntry {
  final int startIndex;
  final int endIndex;
  final Rect bounds;

  WordBoundEntry({
    required this.startIndex,
    required this.endIndex,
    required this.bounds,
  });
}

/// Service để trích xuất text từ PDF file
class PdfTextExtractorService {
  /// Trích xuất text từ một trang PDF
  /// 
  /// [pdfBytes] - Bytes của file PDF
  /// [pageNumber] - Số trang cần trích xuất (bắt đầu từ 0)
  /// Returns: Text của trang, hoặc null nếu không có text
  static Future<String?> extractTextFromPage(
    Uint8List pdfBytes,
    int pageNumber,
  ) async {
    try {
      // Load PDF document từ bytes
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Kiểm tra page number hợp lệ
      if (pageNumber < 0 || pageNumber >= document.pages.count) {
        debugPrint('Invalid page number: $pageNumber');
        document.dispose();
        return null;
      }
      
      // Sử dụng PdfTextExtractor để extract text
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      // Extract text từ trang cụ thể
      final String text = extractor.extractText(
        startPageIndex: pageNumber,
        endPageIndex: pageNumber,
      );
      
      // Dispose document để giải phóng bộ nhớ
      document.dispose();
      
      // Cleanup text: loại bỏ khoảng trắng thừa, xuống dòng liên tiếp
      final cleanText = _cleanupText(text);
      
      return cleanText.isEmpty ? null : cleanText;
    } catch (e) {
      debugPrint('Error extracting text from page: $e');
      return null;
    }
  }

  /// Trích xuất text trang kèm bounds từng từ (để đánh dấu từ đang đọc lên PDF).
  /// [pdfBytes] - Bytes của file PDF
  /// [pageIndex] - Chỉ số trang (0-based)
  /// Returns: fullText (đã cleanup, trùng với text gửi TTS) và danh sách (start, end, bounds) theo thứ tự từ.
  static Future<PageTextWithBounds?> extractPageTextWithWordBounds(
    Uint8List pdfBytes,
    int pageIndex,
  ) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      if (pageIndex < 0 || pageIndex >= document.pages.count) {
        document.dispose();
        return null;
      }

      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String rawText = extractor.extractText(
        startPageIndex: pageIndex,
        endPageIndex: pageIndex,
      );
      final String fullText = _cleanupText(rawText);
      if (fullText.isEmpty) {
        document.dispose();
        return null;
      }

      final List<TextLine> lines = extractor.extractTextLines(
        startPageIndex: pageIndex,
        endPageIndex: pageIndex,
      );
      final List<WordBoundEntry> wordBounds = [];
      int searchStart = 0;
      final int pageNumber = pageIndex + 1;

      for (final TextLine line in lines) {
        for (final TextWord word in line.wordCollection) {
          final String w = word.text;
          if (w.isEmpty) continue;
          final int idx = fullText.indexOf(w, searchStart);
          if (idx >= 0) {
            wordBounds.add(WordBoundEntry(
              startIndex: idx,
              endIndex: idx + w.length,
              bounds: word.bounds,
            ));
            searchStart = idx + w.length;
          }
        }
      }

      document.dispose();
      return PageTextWithBounds(
        fullText: fullText,
        pageNumber: pageNumber,
        wordBounds: wordBounds,
      );
    } catch (e) {
      debugPrint('Error extracting page text with bounds: $e');
      return null;
    }
  }

  /// Trích xuất text từ nhiều trang PDF
  /// 
  /// [pdfBytes] - Bytes của file PDF
  /// [startPage] - Trang bắt đầu (từ 0)
  /// [endPage] - Trang kết thúc (từ 0)
  /// Returns: Map với key là page number, value là text
  static Future<Map<int, String>> extractTextFromPages(
    Uint8List pdfBytes, {
    int startPage = 0,
    int? endPage,
  }) async {
    final Map<int, String> result = {};
    
    try {
      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      final int lastPage = endPage ?? document.pages.count - 1;
      
      // Sử dụng PdfTextExtractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      // Extract text từng trang
      for (int i = startPage; i <= lastPage && i < document.pages.count; i++) {
        final text = extractor.extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        
        final cleanText = _cleanupText(text);
        if (cleanText.isNotEmpty) {
          result[i] = cleanText;
        }
      }
      
      document.dispose();
      return result;
    } catch (e) {
      debugPrint('Error extracting text from pages: $e');
      return result;
    }
  }

  /// Trích xuất toàn bộ text từ PDF
  /// 
  /// [pdfBytes] - Bytes của file PDF
  /// Returns: Text của toàn bộ document
  static Future<String?> extractAllText(Uint8List pdfBytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Sử dụng PdfTextExtractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      // Extract text từ toàn bộ document
      final String text = extractor.extractText();
      
      document.dispose();
      
      final cleanText = _cleanupText(text);
      return cleanText.isEmpty ? null : cleanText;
    } catch (e) {
      debugPrint('Error extracting all text: $e');
      return null;
    }
  }


  /// Download PDF từ URL và trả về bytes
  static Future<Uint8List?> downloadPdf(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return null;
    }
  }

  /// Extract text từ PDF URL
  static Future<String?> extractTextFromUrl(
    String url, {
    int? pageNumber,
  }) async {
    final pdfBytes = await downloadPdf(url);
    if (pdfBytes == null) return null;
    
    if (pageNumber != null) {
      return await extractTextFromPage(pdfBytes, pageNumber);
    } else {
      return await extractAllText(pdfBytes);
    }
  }

  /// Cleanup text: loại bỏ khoảng trắng thừa, xuống dòng liên tiếp
  static String _cleanupText(String text) {
    if (text.isEmpty) return '';
    
    // Loại bỏ khoảng trắng thừa
    String clean = text.trim();
    
    // Thay thế nhiều khoảng trắng liên tiếp bằng 1 khoảng trắng
    clean = clean.replaceAll(RegExp(r'\s+'), ' ');

    // Thay thế nhiều dấu gạch ngang liên tiếp bằng 1 dấu gạch ngang
    clean = clean.replaceAll(RegExp(r'-{2,}'), '-');

    // Thay thế nhiều dấu gạch dưới liên tiếp bằng 1 dấu gạch dưới
    clean = clean.replaceAll(RegExp(r'_{2,}'), '_');
    
    // Thay thế nhiều xuống dòng liên tiếp bằng 1 xuống dòng
    clean = clean.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');
    
    // Loại bỏ ký tự đặc biệt không cần thiết
    clean = clean.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F]'), '');
    
    return clean;
  }

  /// Lấy thông tin về PDF document
  static Future<PdfInfo?> getPdfInfo(Uint8List pdfBytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      final info = PdfInfo(
        pageCount: document.pages.count,
        title: document.documentInformation.title,
        author: document.documentInformation.author,
        subject: document.documentInformation.subject,
        keywords: document.documentInformation.keywords,
        creator: document.documentInformation.creator,
        producer: document.documentInformation.producer,
      );
      
      document.dispose();
      return info;
    } catch (e) {
      debugPrint('Error getting PDF info: $e');
      return null;
    }
  }
}

/// Model chứa thông tin về PDF document
class PdfInfo {
  final int pageCount;
  final String title;
  final String author;
  final String subject;
  final String keywords;
  final String creator;
  final String producer;

  PdfInfo({
    required this.pageCount,
    required this.title,
    required this.author,
    required this.subject,
    required this.keywords,
    required this.creator,
    required this.producer,
  });

  @override
  String toString() {
    return 'PdfInfo(pages: $pageCount, title: $title, author: $author)';
  }
}

