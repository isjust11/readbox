# Flutter Word to PDF Integration - Summary

## ✅ Đã hoàn thành

### Files đã sửa đổi:

#### 1. `lib/ui/screen/tools/word_to_pdf_converter_screen.dart`

**Thay đổi chính:**
- ❌ **Loại bỏ:** Local conversion với syncfusion_flutter_pdf
- ❌ **Loại bỏ:** Parse DOCX XML local
- ✅ **Thêm:** API call đến NestJS server
- ✅ **Thêm:** Progress tracking khi upload
- ✅ **Thêm:** Better error handling

**Packages sử dụng:**
- `dio` - HTTP client để call API
- `path_provider` - Lưu PDF vào local storage
- `flutter/foundation` - Debug mode check

### Luồng hoạt động mới:

```
User chọn file Word
     ↓
Validate file (extension, size)
     ↓
Upload lên server qua API
     ↓
[Progress Bar hiển thị tiến trình]
     ↓
Server chuyển đổi Word → PDF
     ↓
Nhận PDF từ server (binary)
     ↓
Lưu vào local storage
     ↓
Hiển thị thành công & cho phép xem PDF
```

## 🔧 Cấu hình

### API Configuration

Mở file và tìm đến:
```dart
// API Configuration - Line ~27
static const String _apiBaseUrl = 'http://10.59.91.64:3000';
static const String _converterEndpoint = '/converter/word-to-pdf-public';
```

### Các trường hợp sử dụng:

#### Testing trên Android Emulator:
```dart
static const String _apiBaseUrl = 'http://10.0.2.2:3000';
```

#### Testing trên iOS Simulator:
```dart
static const String _apiBaseUrl = 'http://localhost:3000';
```

#### Testing trên Real Device (cùng WiFi):
```dart
static const String _apiBaseUrl = 'http://YOUR_COMPUTER_IP:3000';
```
Ví dụ: `'http://192.168.1.100:3000'`

#### Production:
```dart
static const String _apiBaseUrl = 'https://your-api-domain.com';
```

## 🚀 Cách test

### 1. Đảm bảo server đang chạy

```bash
cd d:\Develops\codebase\codebase-admin
npm run start:dev
```

Server sẽ chạy tại: `http://localhost:3000`

### 2. Kiểm tra network

Đảm bảo Flutter app có thể kết nối đến server:

```bash
# Test từ terminal
curl http://10.59.91.64:3000

# Test converter endpoint
curl -X POST http://10.59.91.64:3000/converter/word-to-pdf-public \
  -F "file=@test.docx" \
  --output result.pdf
```

### 3. Run Flutter app

```bash
cd d:\Develops\java\app\readbox
flutter run
```

### 4. Test workflow

1. Mở app → Tools → Word to PDF
2. Chọn file Word (.doc hoặc .docx)
3. Click "Convert to PDF"
4. Xem progress bar (upload %)
5. Đợi server xử lý
6. PDF được lưu và hiển thị
7. Tap vào result để xem PDF

## 📊 Features

### ✅ Implemented

- [x] Upload file Word lên server
- [x] Progress tracking (upload %)
- [x] Server-side conversion
- [x] Download PDF result
- [x] Save to local storage
- [x] View PDF after conversion
- [x] Error handling với messages chi tiết
- [x] Validation file type (.doc, .docx)
- [x] Validation file size (max 50MB)
- [x] Loading states
- [x] Success/Error feedback

### ❌ Removed (Not needed anymore)

- Local Word parsing
- Local PDF generation
- Syncfusion PDF dependencies usage
- XML parsing
- Complex formatting logic

## 🐛 Error Handling

### Client-side errors:

```dart
// No file selected
"Vui lòng chọn file trước"

// Invalid file type
"Chỉ hỗ trợ file .doc và .docx"

// File too large
"File quá lớn! Kích thước tối đa là 50MB"
```

### Server errors:

```dart
// 400 Bad Request
"Lỗi: File không hợp lệ"

// 401 Unauthorized
"Lỗi: Không có quyền truy cập"

// 413 Payload Too Large
"Lỗi: File quá lớn (tối đa 50MB)"

// 500 Internal Server Error
"Lỗi server khi chuyển đổi file"

// Network errors
"Lỗi kết nối server"
```

## 📱 UI Changes

### Thêm mới:

**Progress Indicator:**
```dart
if (_isConverting) ...[
  LinearProgressIndicator(value: _uploadProgress),
  Text('Đang tải lên: XX%'),
],
```

Hiển thị:
- Upload progress (0-100%)
- "Đang xử lý trên server..." khi upload xong

### Giữ nguyên:

- File picker UI
- Selected file info card
- Convert button
- Success result card
- Info/Instructions section

## 🔍 Debug

### Enable debug logs:

Debug logs tự động hiển thị khi chạy debug mode:

```dart
if (kDebugMode) {
  print('Converting file: $fileName');
  print('File size: $fileSize bytes');
  print('Upload progress: XX%');
  print('PDF saved at: $outputPath');
}
```

### Common issues:

#### 1. "Lỗi kết nối server"

**Check:**
- Server có đang chạy không?
- URL có đúng không?
- Device và server có kết nối được không?

**Solution:**
```bash
# Kiểm tra server
curl http://10.59.91.64:3000

# Ping IP
ping 10.59.91.64
```

#### 2. Timeout

**Nguyên nhân:** File quá lớn hoặc mạng chậm

**Solution:** Tăng timeout:
```dart
connectTimeout: 300000, // 5 minutes
receiveTimeout: 300000,
```

#### 3. "File không hợp lệ"

**Check:**
- File có đúng định dạng không?
- File có bị corrupt không?

**Solution:** Thử mở file bằng Word trước

## 📈 Performance

### Expected times:

| File Size | Upload Time | Server Process | Total    |
|-----------|-------------|----------------|----------|
| < 1MB     | 1-3s        | 2-5s          | 3-8s     |
| 1-5MB     | 3-10s       | 5-15s         | 8-25s    |
| 5-20MB    | 10-30s      | 15-45s        | 25-75s   |
| 20-50MB   | 30-90s      | 45-120s       | 75-210s  |

*Thời gian thực tế phụ thuộc vào network speed và server performance*

## 🔐 Security Notes

### Current setup:

- Sử dụng **public endpoint** (không cần auth)
- Chỉ nên dùng cho testing/development

### Production recommendations:

1. **Switch to protected endpoint:**
```dart
static const String _converterEndpoint = '/converter/word-to-pdf';
```

2. **Add JWT token:**
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    headers: {
      'Authorization': 'Bearer $jwtToken',
    },
  ),
);
```

3. **Use HTTPS:**
```dart
static const String _apiBaseUrl = 'https://your-api-domain.com';
```

## 🎯 Next Steps

### Improvements:

1. **Config UI:**
   - Settings screen để config API URL
   - Save URL in SharedPreferences

2. **Enhanced UX:**
   - Queue multiple files
   - Background processing
   - Push notification khi done
   - Retry failed conversions

3. **Advanced features:**
   - PDF options (page size, orientation)
   - Watermark
   - Merge multiple PDFs

4. **Offline mode:**
   - Fallback to local conversion nếu offline
   - Queue and sync khi có network

## 📝 Code Quality

### Before (Local conversion):
- ✅ Works offline
- ❌ Limited formatting support
- ❌ Large codebase
- ❌ Vietnamese characters issues
- ❌ Complex parsing logic

### After (API-based):
- ✅ Better formatting support (server uses mammoth + puppeteer)
- ✅ Simpler code
- ✅ Full Unicode support
- ✅ Progress tracking
- ✅ Better error handling
- ❌ Requires network

## 🎉 Kết luận

Flutter app đã được cập nhật thành công để:
- ✅ Gọi API server thay vì local conversion
- ✅ Hiển thị progress khi upload
- ✅ Xử lý errors tốt hơn
- ✅ Đơn giản hóa codebase
- ✅ Hỗ trợ Unicode/Vietnamese đầy đủ

**Ready to test!** 🚀

Chỉ cần:
1. Start NestJS server
2. Cấu hình đúng API URL
3. Run Flutter app
4. Test với file Word

Xem file `WORD_TO_PDF_API_CONFIG.md` để biết chi tiết cấu hình!
