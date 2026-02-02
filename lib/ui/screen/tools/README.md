# Tools Screen

Màn hình công cụ cung cấp các tiện ích hữu ích cho người dùng.

## Tính năng

### 1. Word to PDF Converter
- Chuyển đổi tài liệu Word (.doc, .docx) sang PDF
- Giao diện đơn giản, dễ sử dụng
- Tự động lưu file PDF vào thư mục app documents

**Cách sử dụng:**
1. Nhấn "Chọn file Word"
2. Chọn file .doc hoặc .docx từ thiết bị
3. Nhấn "Chuyển sang PDF"
4. File PDF sẽ được lưu tự động

**Lưu ý:** 
- Hiện tại đây là phiên bản cơ bản, chuyển đổi text content
- Để có chuyển đổi đầy đủ với formatting, cần thêm xử lý phức tạp hơn

### 2. Document Scanner
- Quét tài liệu bằng camera
- Chọn nhiều ảnh từ thư viện
- Thêm nhiều trang vào một tài liệu
- Lưu dưới dạng PDF

**Cách sử dụng:**
1. Nhấn nút "Quét tài liệu"
2. Chọn "Chụp ảnh" hoặc "Chọn từ thư viện"
3. Thêm nhiều trang nếu cần
4. Nhấn "Lưu dưới dạng PDF" trên thanh app bar

**Tính năng:**
- Xem trước các trang đã quét
- Xóa trang không mong muốn
- Tự động đánh số trang
- Tạo PDF với nhiều trang

## Files

- `tools_screen.dart` - Màn hình chính hiển thị danh sách công cụ
- `word_to_pdf_converter_screen.dart` - Màn hình chuyển đổi Word sang PDF
- `document_scanner_screen.dart` - Màn hình quét tài liệu

## Dependencies

- `file_picker` - Chọn file từ thiết bị
- `image_picker` - Chụp ảnh và chọn ảnh từ thư viện
- `syncfusion_flutter_pdf` - Tạo và xử lý file PDF
- `permission_handler` - Quản lý quyền camera và storage
- `path_provider` - Lấy đường dẫn lưu file

## Localization

Tất cả các chuỗi văn bản đều được localize trong:
- `intl_en.arb` - Tiếng Anh
- `intl_vi.arb` - Tiếng Việt

## Cải tiến tương lai

### Word to PDF Converter
- [ ] Hỗ trợ chuyển đổi formatting đầy đủ
- [ ] Preview trước khi chuyển đổi
- [ ] Hỗ trợ nhiều file cùng lúc
- [ ] Tùy chỉnh page size, margins

### Document Scanner
- [ ] Tự động detect và crop document boundaries
- [ ] Enhance image quality (contrast, brightness)
- [ ] OCR text extraction
- [ ] Sắp xếp lại thứ tự trang (drag & drop)
- [ ] Rotate và crop từng trang

## Testing

Sau khi generate localization, bạn có thể test:

1. Chạy app và mở màn hình Tools từ drawer
2. Test Word to PDF:
   - Thử chọn file .doc/.docx
   - Kiểm tra conversion
   - Xác nhận file PDF được tạo
3. Test Document Scanner:
   - Thử chụp ảnh mới
   - Thử chọn ảnh từ thư viện
   - Thêm nhiều trang
   - Xóa trang
   - Lưu dưới dạng PDF
