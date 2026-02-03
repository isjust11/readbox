# Word to PDF API Configuration

## Cấu hình API Server

File đã được cập nhật để gọi API server thay vì chuyển đổi local.

### Thay đổi API URL

Mở file `word_to_pdf_converter_screen.dart` và tìm đến dòng:

```dart
// API Configuration - Thay đổi URL này theo server của bạn
static const String _apiBaseUrl = 'http://10.59.91.64:3000';  // Hoặc http://localhost:3000
static const String _converterEndpoint = '/converter/word-to-pdf-public';
```

### Các tùy chọn cấu hình:

#### 1. Server Local (Development)
```dart
static const String _apiBaseUrl = 'http://localhost:3000';
```

#### 2. Server trong mạng LAN
```dart
static const String _apiBaseUrl = 'http://10.59.91.64:3000';
```

#### 3. Server Production
```dart
static const String _apiBaseUrl = 'https://your-api-domain.com';
```

### Endpoints có sẵn:

1. **Public Endpoint** (không cần authentication):
```dart
static const String _converterEndpoint = '/converter/word-to-pdf-public';
```

2. **Protected Endpoint** (cần JWT token):
```dart
static const String _converterEndpoint = '/converter/word-to-pdf';
```

Nếu sử dụng protected endpoint, bạn cần thêm JWT token vào headers:

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: _apiBaseUrl,
    headers: {
      'Authorization': 'Bearer YOUR_JWT_TOKEN',
    },
  ),
);
```

## Kiểm tra kết nối

### Test server có đang chạy không:

```bash
# Từ terminal/command prompt
curl http://10.59.91.64:3000

# Hoặc mở browser và truy cập:
http://10.59.91.64:3000
```

### Test converter endpoint:

```bash
# Test với file
curl -X POST http://10.59.91.64:3000/converter/word-to-pdf-public \
  -F "file=@test.docx" \
  --output result.pdf
```

## Xử lý lỗi thường gặp

### 1. Connection refused / Timeout
- **Nguyên nhân:** Server không chạy hoặc firewall block
- **Giải pháp:** 
  - Kiểm tra server đã start chưa: `npm run start:dev`
  - Kiểm tra firewall cho phép port 3000

### 2. Network unreachable (trên emulator)
- **Nguyên nhân:** Emulator không thể truy cập localhost
- **Giải pháp:**
  - **Android Emulator:** Sử dụng `http://10.0.2.2:3000`
  - **iOS Simulator:** Sử dụng IP máy trong mạng LAN
  - **Real Device:** Sử dụng IP máy trong mạng LAN (đảm bảo cùng WiFi)

### 3. DioError: 400 Bad Request
- **Nguyên nhân:** File không hợp lệ hoặc không phải Word
- **Giải pháp:** Chỉ chọn file .doc hoặc .docx

### 4. DioError: 413 Payload Too Large
- **Nguyên nhân:** File quá lớn (> 50MB)
- **Giải pháp:** Nén file hoặc tăng limit trên server

### 5. DioError: 500 Internal Server Error
- **Nguyên nhân:** Lỗi server khi xử lý file
- **Giải pháp:** Kiểm tra logs server để xem chi tiết

## Testing

### Trên Android Emulator

```dart
static const String _apiBaseUrl = 'http://10.0.2.2:3000';
```

### Trên iOS Simulator

```dart
static const String _apiBaseUrl = 'http://localhost:3000';
```

### Trên Real Device (cùng WiFi)

1. Tìm IP của máy server:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

2. Sử dụng IP đó:
```dart
static const String _apiBaseUrl = 'http://192.168.1.100:3000';
```

## Features

✅ Upload file Word lên server
✅ Progress tracking khi upload
✅ Nhận PDF từ server
✅ Lưu PDF vào local storage
✅ Xem PDF ngay sau khi convert
✅ Error handling chi tiết
✅ Support cả .doc và .docx
✅ Validate file size và type

## Lưu ý quan trọng

1. **Server phải đang chạy** trước khi test
2. **Kiểm tra network** - device và server phải kết nối được với nhau
3. **File size limit**: Mặc định là 50MB
4. **Timeout**: Mặc định là 2 phút cho connect và receive
5. **Debug mode**: Bật logs trong debug mode để theo dõi process

## Debug Tips

Bật debug logs bằng cách set:

```dart
if (kDebugMode) {
  print('Converting file: $fileName');
  print('File size: $fileSize bytes');
  print('Upload progress: ${(_uploadProgress * 100).toStringAsFixed(2)}%');
  print('PDF saved at: $outputPath');
}
```

Logs sẽ hiển thị trong console khi chạy app.

## Next Steps

Để cải thiện thêm:

1. **Cache API URL** trong SharedPreferences
2. **Settings screen** để config API URL từ UI
3. **Retry mechanism** khi gặp lỗi network
4. **Queue system** để convert nhiều file
5. **Background processing** cho file lớn
6. **Notification** khi conversion hoàn thành
