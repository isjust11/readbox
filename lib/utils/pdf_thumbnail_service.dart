import 'dart:typed_data';

import 'package:pdfx/pdfx.dart';

/// Service tạo thumbnail từ trang đầu tiên của file PDF.
/// Dùng cache in-memory để tránh render lại khi scroll.
class PdfThumbnailService {
  PdfThumbnailService._();

  static final _cache = <String, Uint8List>{};
  static final _pending = <String, Future<Uint8List?>>{};

  /// Kích thước thumbnail mặc định (tỉ lệ gần bìa sách)
  static const int defaultWidth = 140;
  static const int defaultHeight = 200;

  /// Lấy thumbnail trang đầu của PDF. Trả về null nếu lỗi hoặc không phải PDF.
  /// [filePath] đường dẫn file local.
  static Future<Uint8List?> getThumbnail(
    String filePath, {
    int width = defaultWidth,
    int height = defaultHeight,
  }) async {
    if (_cache.containsKey(filePath)) return _cache[filePath];
    if (_pending.containsKey(filePath)) return _pending[filePath];

    final future = _generate(filePath, width: width, height: height);
    _pending[filePath] = future;
    try {
      final bytes = await future;
      if (bytes != null) _cache[filePath] = bytes;
      return bytes;
    } finally {
      _pending.remove(filePath);
    }
  }

  static Future<Uint8List?> _generate(
    String filePath, {
    required int width,
    required int height,
  }) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      try {
        if (document.pagesCount < 1) return null;
        final page = await document.getPage(1);
        try {
          final pw = page.width;
          final ph = page.height;
          if (pw <= 0 || ph <= 0) return null;
          // Giữ tỉ lệ, scale vừa khung width x height
          final scale = (width / pw).clamp(0.5, 3.0);
          final rw = (pw * scale).round().clamp(1, 800).toDouble();
          final rh = (ph * scale).round().clamp(1, 1200).toDouble();
          final image = await page.render(
            width: rw,
            height: rh,
            format: PdfPageImageFormat.jpeg,
            backgroundColor: '#FFFFFF',
          );
          return image?.bytes;
        } finally {
          page.close();
        }
      } finally {
        await document.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Xóa một path khỏi cache (gọi khi user xóa sách khỏi thư viện).
  static void removeFromCache(String filePath) {
    _cache.remove(filePath);
  }

  /// Xóa toàn bộ cache.
  static void clearCache() {
    _cache.clear();
  }
}
