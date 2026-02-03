# Content-Type Fix cho Word to PDF Converter

## ❌ Vấn đề

Server (NestJS) validate mimetype của file upload:

```typescript
// Server validation
const allowedMimeTypes = [
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
  'application/msword', // .doc
];

if (!allowedMimeTypes.includes(file.mimetype)) {
  throw new BadRequestException('Chỉ chấp nhận file Word (.doc, .docx)');
}
```

**Trước đây**, Flutter không gửi contentType → Server reject file!

## ✅ Giải pháp

### 1. Import http_parser package

```dart
import 'package:http_parser/http_parser.dart';
```

### 2. Set contentType khi tạo MultipartFile

```dart
// Determine contentType based on file extension
final MediaType contentType = extension == 'docx'
    ? MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document')
    : MediaType('application', 'msword');

// Create MultipartFile with contentType
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
    contentType: contentType,  // ✅ Thêm contentType
  ),
});
```

## 📋 MIME Types cho Word files

| Extension | MIME Type | MediaType |
|-----------|-----------|-----------|
| `.docx` | `application/vnd.openxmlformats-officedocument.wordprocessingml.document` | `MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document')` |
| `.doc` | `application/msword` | `MediaType('application', 'msword')` |

## 🔧 Code hoàn chỉnh

```dart
import 'package:http_parser/http_parser.dart';

// Validate extension
final extension = fileName.toLowerCase().split('.').last;
if (extension != 'doc' && extension != 'docx') {
  return ApiResponse.error('Chỉ hỗ trợ file .doc và .docx');
}

// Map extension → contentType
final MediaType contentType = extension == 'docx'
    ? MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document')
    : MediaType('application', 'msword');

// Create FormData với contentType
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
    contentType: contentType,
  ),
});

// Send request
final response = await dio.post(
  'converter/word-to-pdf-public',
  data: formData,
  options: Options(
    responseType: ResponseType.bytes,  // PDF bytes
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  ),
);
```

## 🎯 Kết quả

### Request Header từ Flutter:
```
Content-Type: multipart/form-data; boundary=...
```

### Form Data:
```
------WebKitFormBoundary...
Content-Disposition: form-data; name="file"; filename="document.docx"
Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document

[binary data]
------WebKitFormBoundary...--
```

### Server nhận được:
```javascript
file.mimetype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
// ✅ PASS validation!
```

## 🔍 Debug

Nếu vẫn bị reject, check:

1. **Package import đúng chưa?**
   ```dart
   import 'package:http_parser/http_parser.dart';
   ```

2. **contentType có được set không?**
   ```dart
   print('ContentType: ${contentType.mimeType}');
   // Phải in ra: application/vnd.openxmlformats-officedocument.wordprocessingml.document
   ```

3. **File extension có đúng không?**
   ```dart
   print('Extension: $extension');
   // Phải là 'doc' hoặc 'docx' (lowercase)
   ```

4. **Server log**
   ```bash
   # Check server console
   console.log('Received mimetype:', file.mimetype);
   ```

## 📦 Dependencies

Đảm bảo có trong `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.0.0
  http_parser: ^4.0.0  # ✅ Cần package này
```

## 🎉 Kết luận

Với việc set đúng `contentType` cho `MultipartFile`, server sẽ nhận đúng mimetype và pass được validation!

**Trước**: ❌ File upload bị reject vì missing mimetype

**Sau**: ✅ File upload thành công với đúng mimetype
