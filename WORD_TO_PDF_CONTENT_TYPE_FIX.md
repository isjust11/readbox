# ✅ Word to PDF - ContentType Fix

## 🎯 Vấn đề đã giải quyết

Server NestJS yêu cầu validate mimetype của file upload phải là:
- `.docx` → `application/vnd.openxmlformats-officedocument.wordprocessingml.document`
- `.doc` → `application/msword`

Flutter app **trước đây không gửi contentType** → Server reject!

## 🔧 Giải pháp

### 1. Thêm package `http_parser`

**File**: `pubspec.yaml`
```yaml
dependencies:
  http_parser: ^4.0.2  # ✅ Added
```

### 2. Update ConverterRemoteDataSource

**File**: `lib/domain/data/datasources/remote/converter_remote_data_source.dart`

```dart
import 'package:http_parser/http_parser.dart';  // ✅ Added

// Map extension → MIME type
final MediaType contentType = extension == 'docx'
    ? MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document')
    : MediaType('application', 'msword');

// Set contentType trong MultipartFile
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
    contentType: contentType,  // ✅ Added
  ),
});
```

### 3. Thêm API endpoint constant

**File**: `lib/domain/network/api_constant.dart`

```dart
// Converter endpoints
static final converterWordToPdf = "converter/word-to-pdf";
static final converterWordToPdfPublic = "converter/word-to-pdf-public";  // ✅ Added
```

## 📋 Thay đổi chi tiết

### Trước:
```dart
// ❌ Missing contentType
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
  ),
});
```

**Kết quả**: Server nhận `file.mimetype = null` → Reject file!

### Sau:
```dart
// ✅ With contentType
final MediaType contentType = extension == 'docx'
    ? MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document')
    : MediaType('application', 'msword');

final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: fileName,
    contentType: contentType,
  ),
});
```

**Kết quả**: Server nhận đúng mimetype → ✅ Pass validation!

## 🎉 Kết quả

### Request từ Flutter:
```
POST /converter/word-to-pdf-public
Content-Type: multipart/form-data; boundary=...

------WebKitFormBoundary...
Content-Disposition: form-data; name="file"; filename="document.docx"
Content-Type: application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                                                                    ↑
                                                                    ✅ Server nhận được mimetype!
[binary data]
------WebKitFormBoundary...--
```

### Server validation:
```typescript
// Server check
if (file.mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
  // ✅ PASS!
}
```

## 📦 Cài đặt

```bash
cd readbox
flutter pub get
```

## 🧪 Test

1. Chọn file .docx hoặc .doc
2. Nhấn Convert
3. Server sẽ accept file và convert thành công! ✅

## 📚 Tài liệu

- Chi tiết: `lib/ui/screen/tools/CONTENT_TYPE_FIX.md`
- Refactoring summary: `lib/ui/screen/tools/CONVERTER_REFACTORING_SUMMARY.md`
- Setup guide: `CONVERTER_CUBIT_SETUP.md`
