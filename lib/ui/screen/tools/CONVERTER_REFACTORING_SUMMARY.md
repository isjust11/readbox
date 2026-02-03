# Word to PDF Converter - Refactoring Summary

## Tổng quan
Đã refactor tính năng Word to PDF Converter từ việc gọi trực tiếp API bằng Dio trong StatefulWidget sang kiến trúc Cubit chuẩn, giống với các màn hình khác trong ứng dụng (như AdminCubit).

## Các file đã tạo mới

### 1. ConverterRemoteDataSource
**Đường dẫn**: `lib/domain/data/datasources/remote/converter_remote_data_source.dart`

**Chức năng**:
- Xử lý tất cả các API calls liên quan đến converter
- Method `convertWordToPdf()`: Gửi file Word lên server và nhận về PDF bytes
- Validate file extension (.doc, .docx)
- Validate file size (max 50MB)
- Xử lý progress upload
- Xử lý errors và trả về ApiResponse chuẩn

**Đặc điểm**:
- Sử dụng Dio riêng với timeout 2 phút
- ResponseType.bytes để nhận PDF file
- Hỗ trợ callback onProgress để track upload progress
- Error handling chi tiết theo status codes

### 2. ConverterCubit
**Đường dẫn**: `lib/blocs/converter/converter_cubit.dart`

**Chức năng**:
- Quản lý state cho Word to PDF converter
- Extends `Cubit<BaseState>` (chuẩn của app)
- Các methods:
  - `selectFile(File)`: Chọn file để convert
  - `convertWordToPdf()`: Thực hiện conversion
  - `reset()`: Reset state về ban đầu
  - `resetFile()`: Reset file đã chọn

**State Management**:
- `_selectedFile`: File đã chọn
- `_outputPath`: Đường dẫn PDF output
- `_uploadProgress`: Progress upload (0.0 - 1.0)

**Getters**:
- `selectedFile`
- `outputPath`
- `uploadProgress`

**States được emit**:
- `InitState`: Trạng thái ban đầu
- `LoadingState`: Đang convert
- `LoadedState`: Convert thành công
- `ErrorState`: Có lỗi xảy ra

## Các file đã chỉnh sửa

### 1. WordToPdfConverterScreen
**Thay đổi**:
- **Trước**: StatefulWidget với logic API call trực tiếp bằng Dio
- **Sau**: StatelessWidget với BlocProvider

**Cấu trúc mới**:
```dart
WordToPdfConverterScreen (StatelessWidget)
  └── BlocProvider<ConverterCubit>
      └── WordToPdfConverterBody (StatefulWidget)
          └── BlocConsumer<ConverterCubit, BaseState>
```

**BlocConsumer**:
- **Listener**: Hiển thị SnackBar khi có LoadedState hoặc ErrorState
- **Builder**: Rebuild UI khi state thay đổi

**Logic đã loại bỏ**:
- Không còn gọi trực tiếp Dio
- Không còn quản lý state bằng setState()
- Không còn hardcode API URL trong screen

**Logic giữ nguyên**:
- UI layout
- File picker từ PdfScannerScreen
- Format file size
- Navigate đến PdfViewerScreen

### 2. injection_container.dart
**Thêm**:
- `ConverterRemoteDataSource` trong `registerDataSource()`
- `ConverterCubit` trong `registerCubit()`

### 3. lib/blocs/cubit.dart
**Thêm**:
- Export `converter/converter_cubit.dart`

### 4. lib/domain/data/datasources/datasource.dart
**Thêm**:
- Export `converter_remote_data_source.dart`

## So sánh với AdminCubit

### Điểm giống:
1. Cùng extends `Cubit<BaseState>`
2. Sử dụng RemoteDataSource để gọi API
3. Emit các state: LoadingState, LoadedState, ErrorState
4. Sử dụng BlocUtils.getMessageError() để xử lý errors
5. Inject qua GetIt dependency injection

### Điểm khác:
1. **AdminCubit**:
   - Upload file → Trả về URL từ server
   - Nhiều methods (upload, create, update)
   - Lưu URL vào internal state

2. **ConverterCubit**:
   - Upload file → Nhận bytes PDF về
   - Đơn giản hơn (chỉ convert)
   - Lưu file PDF vào local storage
   - Track upload progress

## Lợi ích của refactoring

### 1. Tách biệt concerns
- UI logic (WordToPdfConverterScreen)
- Business logic (ConverterCubit)
- Network logic (ConverterRemoteDataSource)

### 2. Testability
- Có thể test ConverterCubit độc lập
- Có thể mock ConverterRemoteDataSource

### 3. Reusability
- ConverterRemoteDataSource có thể dùng ở màn hình khác
- ConverterCubit có thể share state giữa nhiều widgets

### 4. Consistency
- Giống cấu trúc với các màn hình khác (Admin, Library, Book...)
- Dễ maintain và extend

### 5. State Management
- Reactive UI với BlocBuilder
- Tự động rebuild khi state thay đổi
- Không còn setState() rải rác

## Cách sử dụng

### Trong Screen:
```dart
// Chọn file
context.read<ConverterCubit>().selectFile(file);

// Convert
await context.read<ConverterCubit>().convertWordToPdf();

// Access state
final cubit = context.read<ConverterCubit>();
final selectedFile = cubit.selectedFile;
final outputPath = cubit.outputPath;
final progress = cubit.uploadProgress;

// Reset
context.read<ConverterCubit>().reset();
```

### Listen state changes:
```dart
BlocConsumer<ConverterCubit, BaseState>(
  listener: (context, state) {
    if (state is LoadedState) {
      // Show success message
    } else if (state is ErrorState) {
      // Show error message
    }
  },
  builder: (context, state) {
    final isConverting = state is LoadingState;
    // Build UI
  },
)
```

## API Endpoint

**URL**: `http://{API_HOST}:{API_PORT}/converter/word-to-pdf-public`

**Method**: POST

**Request**:
- Content-Type: multipart/form-data
- Body: FormData with 'file' field

**Response**:
- Content-Type: application/pdf
- Body: PDF file bytes

**Errors**:
- 400: File không hợp lệ
- 401: Không có quyền
- 413: File quá lớn (>50MB)
- 500: Lỗi server

## Notes

1. Timeout được set 2 phút (120000ms) cho cả connect và receive
2. File size limit: 50MB
3. Supported formats: .doc, .docx
4. PDF được lưu vào app documents directory
5. Upload progress được track và hiển thị realtime
6. Sử dụng Dio riêng để handle binary response (ResponseType.bytes)

## Migration từ code cũ

### Trước:
```dart
// Direct Dio call in widget
final dio = Dio(...);
final response = await dio.post(...);
setState(() { _outputPath = ... });
```

### Sau:
```dart
// Clean separation
await context.read<ConverterCubit>().convertWordToPdf();
// UI tự động update qua BlocBuilder
```

## Tương lai mở rộng

Có thể dễ dàng thêm:
1. Convert các format khác (Excel, PowerPoint)
2. Batch conversion (nhiều files)
3. Conversion history
4. Cloud storage integration
5. Offline mode với queue
6. Custom conversion settings (quality, compression...)

Chỉ cần thêm methods vào ConverterCubit và ConverterRemoteDataSource!
