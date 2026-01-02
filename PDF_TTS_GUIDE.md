# Hướng Dẫn Sử Dụng PDF Text-to-Speech

## ✅ Đã hoàn thành

### 1. **PDF Text Extractor Service** (`lib/utils/pdf_text_extractor.dart`)
Service để trích xuất text từ PDF file sử dụng Syncfusion PDF library.

**Tính năng:**
- ✅ Trích xuất text từ một trang cụ thể
- ✅ Trích xuất text từ nhiều trang
- ✅ Trích xuất toàn bộ text từ PDF
- ✅ Download PDF từ URL
- ✅ Cleanup text (loại bỏ khoảng trắng thừa, ký tự đặc biệt)
- ✅ Lấy thông tin PDF (số trang, title, author, etc.)

**API chính:**
```dart
// Trích xuất text từ một trang (0-based index)
final text = await PdfTextExtractorService.extractTextFromPage(pdfBytes, pageNumber);

// Trích xuất text từ nhiều trang
final textMap = await PdfTextExtractorService.extractTextFromPages(pdfBytes, startPage: 0, endPage: 5);

// Trích xuất toàn bộ text
final allText = await PdfTextExtractorService.extractAllText(pdfBytes);

// Download và extract từ URL
final text = await PdfTextExtractorService.extractTextFromUrl(url, pageNumber: 0);
```

### 2. **Tích hợp vào PDF Viewer** (`pdf_viewer_with_selection_screen.dart`)
- ✅ Tự động download PDF bytes khi mở màn hình
- ✅ Trích xuất text tự động khi nhấn "Đọc trang này"
- ✅ Đọc liên tục qua nhiều trang
- ✅ Fallback sang text đã chọn nếu không extract được
- ✅ Hiển thị thông báo chi tiết (số ký tự đọc được)

### 3. **Dependencies đã thêm**
```yaml
syncfusion_flutter_pdf: ^28.1.33  # PDF parsing and text extraction
```

## 🚀 Cách sử dụng

### Trong PDF Viewer With Selection:

1. **Mở file PDF:**
   - Vào thư viện → Chọn sách PDF
   - PDF sẽ tự động load và download bytes

2. **Đọc text từ trang hiện tại:**
   - Mở menu (⋮) → Chọn **"Đọc trang này"**
   - Hoặc nhấn nút TTS (🔊) màu xanh
   - App sẽ tự động:
     - Trích xuất text từ trang hiện tại
     - Đọc text bằng TTS
     - Hiển thị số ký tự đã đọc

3. **Đọc liên tục:**
   - Mở menu → Chọn **"Đọc liên tục"**
   - App sẽ tự động chuyển trang và đọc tiếp

4. **Đọc text đã chọn:**
   - Chọn text bằng tay trong PDF
   - Nhấn nút TTS
   - App sẽ ưu tiên đọc text đã chọn

## 📋 Quy trình hoạt động

```
User nhấn "Đọc trang này"
    ↓
Kiểm tra có text đã chọn?
    ├─ Có → Đọc text đã chọn
    └─ Không → Trích xuất text từ PDF
        ↓
    Kiểm tra đã có PDF bytes?
        ├─ Có → Extract text ngay
        └─ Không → Download PDF → Extract text
            ↓
        Cleanup text (loại bỏ khoảng trắng, ký tự đặc biệt)
            ↓
        Gửi text vào TTS Service
            ↓
        Bắt đầu đọc
```

## 🔧 Cài đặt

### 1. Thêm package:
```bash
flutter pub add syncfusion_flutter_pdf
```

### 2. Import trong code:
```dart
import 'package:readbox/utils/pdf_text_extractor.dart';
```

### 3. Sử dụng:
```dart
// Load PDF bytes
final bytes = await PdfTextExtractorService.downloadPdf(url);

// Extract text từ trang 1 (index 0)
final text = await PdfTextExtractorService.extractTextFromPage(bytes, 0);

// Đọc bằng TTS
await ttsService.speak(text);
```

## 📊 Performance

- **Download PDF**: Phụ thuộc vào kích thước file và tốc độ mạng
- **Text extraction**: ~100-500ms cho 1 trang (phụ thuộc vào độ phức tạp)
- **Memory**: PDF bytes được cache trong memory để tái sử dụng

## ⚠️ Lưu ý

### 1. **PDF phải có text layer**
- Chỉ extract được text từ PDF có text layer
- PDF scan (ảnh) không có text → Không extract được
- Cần OCR cho PDF scan

### 2. **Formatting**
- Text được extract theo thứ tự đọc
- Có thể mất format (bold, italic, color)
- Tables và columns có thể bị lộn xộn

### 3. **Memory management**
- PDF bytes được lưu trong memory
- Dispose khi không dùng nữa
- Với file lớn (>10MB), cân nhắc streaming

### 4. **Error handling**
- Nếu extract thất bại → Fallback sang text selection
- User vẫn có thể chọn text bằng tay để đọc

## 🐛 Troubleshooting

### Lỗi: "Không thể trích xuất text"
**Nguyên nhân:**
- PDF không có text layer (PDF scan)
- PDF bị mã hóa/bảo vệ
- Lỗi network khi download

**Giải pháp:**
- Chọn text bằng tay trong PDF viewer
- Kiểm tra file PDF có text layer không
- Thử file PDF khác

### Lỗi: "PDF bytes not loaded"
**Nguyên nhân:**
- Network error
- URL không hợp lệ
- File quá lớn

**Giải pháp:**
- Kiểm tra kết nối mạng
- Thử lại sau
- Dùng file nhỏ hơn

### Text extraction chậm
**Giải pháp:**
- Cache PDF bytes
- Extract theo batch (nhiều trang cùng lúc)
- Dùng isolate cho file lớn

## 📈 Cải tiến trong tương lai

### 1. **OCR Support**
Thêm OCR để đọc PDF scan:
```dart
// Sử dụng google_ml_kit hoặc tesseract
final text = await OcrService.extractTextFromImage(pageImage);
```

### 2. **Streaming**
Extract text theo chunk cho file lớn:
```dart
Stream<String> extractTextStream(Uint8List pdfBytes) async* {
  for (int i = 0; i < pageCount; i++) {
    yield await extractTextFromPage(pdfBytes, i);
  }
}
```

### 3. **Caching**
Cache extracted text để tái sử dụng:
```dart
final cache = <int, String>{};
if (cache.containsKey(pageNumber)) {
  return cache[pageNumber];
}
```

### 4. **Background extraction**
Extract text trong background:
```dart
compute(extractTextFromPage, {
  'bytes': pdfBytes,
  'page': pageNumber,
});
```

## 📚 Tham khảo

- [Syncfusion PDF Documentation](https://help.syncfusion.com/flutter/pdf/overview)
- [PdfTextExtractor API](https://help.syncfusion.com/flutter/pdf/working-with-text-extraction)
- [Flutter TTS Package](https://pub.dev/packages/flutter_tts)

## 🎯 Demo

Xem demo trong app:
1. Mở menu → "Demo Text-to-Speech" (text sẵn có)
2. Hoặc: Mở PDF → Menu → "Đọc trang này" (extract từ PDF)

---

**Tác giả:** ReadBox Team  
**Ngày cập nhật:** 2026-01-02

