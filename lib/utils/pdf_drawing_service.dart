import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Chuyển đổi stroke từ tọa độ overlay (màn hình) sang tọa độ PDF.
/// PDF dùng gốc bottom-left, overlay dùng top-left.
Offset _screenToPdf(
  Offset screenPoint,
  Size overlaySize,
  Size pdfPageSize,
) {
  if (overlaySize.width <= 0 || overlaySize.height <= 0) {
    return screenPoint;
  }
  final scaleX = pdfPageSize.width / overlaySize.width;
  final scaleY = pdfPageSize.height / overlaySize.height;
  return Offset(
    screenPoint.dx * scaleX,
    pdfPageSize.height - (screenPoint.dy * scaleY),
  );
}

/// Nhúng các nét vẽ trực tiếp vào file PDF.
/// Vẽ được ghi vĩnh viễn vào nội dung trang PDF (không phải annotation).
class PdfDrawingService {
  /// Nhúng strokes vào PDF và trả về bytes mới.
  ///
  /// [pdfBytes] - bytes của PDF gốc
  /// [strokesByPage] - Map: pageNumber (1-based) -> List<List<Offset>>
  /// [overlaySize] - kích thước overlay khi user vẽ (dùng để chuyển tọa độ)
  /// [strokeColor] - màu nét vẽ (mặc định đỏ)
  /// [strokeWidth] - độ dày nét
  static Future<Uint8List?> embedDrawings({
    required Uint8List pdfBytes,
    required Map<int, List<List<Offset>>> strokesByPage,
    required Size overlaySize,
    Color strokeColor = Colors.red,
    double strokeWidth = 3.0,
  }) async {
    if (strokesByPage.isEmpty) return pdfBytes;

    try {
      final document = PdfDocument(inputBytes: pdfBytes);
      final pdfColor = PdfColor(
        strokeColor.red,
        strokeColor.green,
        strokeColor.blue,
      );
      final pen = PdfPen(pdfColor, width: strokeWidth);

      for (final entry in strokesByPage.entries) {
        final pageNum = entry.key;
        final strokes = entry.value;
        if (strokes.isEmpty) continue;

        final pageIndex = pageNum - 1;
        if (pageIndex < 0 || pageIndex >= document.pages.count) continue;

        final page = document.pages[pageIndex];
        final graphics = page.graphics;
        final pageSize = graphics.size;

        for (final stroke in strokes) {
          if (stroke.length < 2) continue;
          for (var i = 0; i < stroke.length - 1; i++) {
            final p1 = _screenToPdf(stroke[i], overlaySize, pageSize);
            final p2 = _screenToPdf(stroke[i + 1], overlaySize, pageSize);
            graphics.drawLine(pen, p1, p2);
          }
        }
      }

      final result = await document.save();
      document.dispose();
      return result is Uint8List ? result : Uint8List.fromList(result);
    } catch (e) {
      debugPrint('PdfDrawingService.embedDrawings error: $e');
      return null;
    }
  }
}
