# Word to PDF Converter - Cấu trúc Cubit mới

## ✅ Đã hoàn thành

### 1. Tạo các file mới
- ✅ `lib/domain/data/datasources/remote/converter_remote_data_source.dart`
- ✅ `lib/blocs/converter/converter_cubit.dart`

### 2. Refactor file hiện có
- ✅ `lib/ui/screen/tools/word_to_pdf_converter_screen.dart`
  - Chuyển từ StatefulWidget → BlocProvider pattern
  - Loại bỏ logic gọi API trực tiếp
  - Sử dụng BlocConsumer để quản lý state

### 3. Cập nhật dependency injection
- ✅ `lib/injection_container.dart`: Thêm ConverterCubit và ConverterRemoteDataSource
- ✅ `lib/blocs/cubit.dart`: Export ConverterCubit
- ✅ `lib/domain/data/datasources/datasource.dart`: Export ConverterRemoteDataSource

## 📋 Cấu trúc mới

### Architecture Flow
```
WordToPdfConverterScreen (UI)
    ↓ (sử dụng)
ConverterCubit (Business Logic)
    ↓ (gọi)
ConverterRemoteDataSource (Network Layer)
    ↓ (gọi)
API Server (/converter/word-to-pdf-public)
```

### State Management
```dart
// States
InitState          // Ban đầu
LoadingState       // Đang convert (+ progress)
LoadedState        // Thành công
ErrorState         // Lỗi
```

## 🎯 Điểm khác biệt chính

### Trước (Old approach)
```dart
class _WordToPdfConverterScreenState extends State<...> {
  File? _selectedFile;
  bool _isConverting = false;
  double _uploadProgress = 0.0;
  
  Future<void> _convertToPdf() async {
    final dio = Dio(...);
    final response = await dio.post(...);
    setState(() { _outputPath = ... });
  }
}
```

### Sau (New approach - giống AdminCubit)
```dart
class WordToPdfConverterScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConverterCubit>(),
      child: const WordToPdfConverterBody(),
    );
  }
}

class _WordToPdfConverterBodyState extends State<...> {
  Future<void> _convertToPdf() async {
    await context.read<ConverterCubit>().convertWordToPdf();
  }
  
  Widget build(BuildContext context) {
    return BlocConsumer<ConverterCubit, BaseState>(
      listener: (context, state) { /* Handle success/error */ },
      builder: (context, state) { /* Build UI */ },
    );
  }
}
```

## 🔄 So sánh với AdminCubit

| Đặc điểm | AdminCubit | ConverterCubit |
|----------|------------|----------------|
| Extends | `Cubit<BaseState>` | `Cubit<BaseState>` ✅ |
| DataSource | AdminRemoteDataSource | ConverterRemoteDataSource ✅ |
| DI | GetIt | GetIt ✅ |
| State emit | LoadingState, LoadedState, ErrorState | LoadingState, LoadedState, ErrorState ✅ |
| Error handling | BlocUtils.getMessageError() | BlocUtils.getMessageError() ✅ |
| Network layer | Tách biệt | Tách biệt ✅ |

## 🚀 Cách sử dụng

### 1. Inject Cubit (tự động qua BlocProvider trong screen)
```dart
// Đã setup trong WordToPdfConverterScreen
BlocProvider(
  create: (_) => getIt<ConverterCubit>(),
  child: const WordToPdfConverterBody(),
)
```

### 2. Sử dụng trong Widget
```dart
// Chọn file
context.read<ConverterCubit>().selectFile(file);

// Convert
await context.read<ConverterCubit>().convertWordToPdf();

// Access state
final cubit = context.read<ConverterCubit>();
print(cubit.selectedFile);
print(cubit.outputPath);
print(cubit.uploadProgress);
```

### 3. Listen state changes
```dart
BlocConsumer<ConverterCubit, BaseState>(
  listener: (context, state) {
    if (state is LoadedState) {
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.msgError)),
      );
    } else if (state is ErrorState) {
      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.data)),
      );
    }
  },
  builder: (context, state) {
    final isConverting = state is LoadingState;
    final cubit = context.read<ConverterCubit>();
    // Build UI với state
    return YourWidget(...);
  },
)
```

## 📦 API Configuration

API endpoint được cấu hình tự động từ `.env`:

```dart
// Trong ConverterRemoteDataSource
final dio = Dio(
  BaseOptions(
    baseUrl: ApiConstant.apiHost,  // Đọc từ .env
    connectTimeout: 120000,        // 2 phút
    receiveTimeout: 120000,
  ),
);

// Endpoint
'converter/word-to-pdf-public'
```

Không cần hardcode URL nữa!

## ✨ Lợi ích

1. **Consistent với codebase**: Giống AdminCubit, LibraryCubit, BookDetailCubit...
2. **Separation of Concerns**: UI / Business Logic / Network hoàn toàn tách biệt
3. **Testable**: Dễ dàng test từng layer
4. **Maintainable**: Dễ bảo trì và mở rộng
5. **Type-safe**: Full Dart type checking
6. **Reactive**: UI tự động update khi state thay đổi

## 🧪 Testing

### Test ConverterCubit
```dart
test('convertWordToPdf should emit LoadedState on success', () async {
  // Mock ConverterRemoteDataSource
  final mockDataSource = MockConverterRemoteDataSource();
  when(mockDataSource.convertWordToPdf(...))
    .thenAnswer((_) async => ApiResponse.success(...));
  
  final cubit = ConverterCubit(mockDataSource);
  cubit.selectFile(File('test.docx'));
  
  await cubit.convertWordToPdf();
  
  expect(cubit.state, isA<LoadedState>());
});
```

## 🔧 Troubleshooting

### Lỗi: "ConverterCubit not found"
- Kiểm tra `injection_container.dart` đã register chưa
- Kiểm tra `lib/blocs/cubit.dart` đã export chưa

### Lỗi: "ConverterRemoteDataSource not found"
- Kiểm tra `injection_container.dart` đã register chưa
- Kiểm tra `lib/domain/data/datasources/datasource.dart` đã export chưa

### UI không update
- Kiểm tra đang dùng BlocBuilder/BlocConsumer
- Không dùng context.read() trong builder (dùng context.watch() hoặc để Bloc tự rebuild)

### Progress không hiển thị
- Progress được update trong LoadingState
- Kiểm tra BlocBuilder đang rebuild khi state change

## 📚 Tài liệu tham khảo

- `CONVERTER_REFACTORING_SUMMARY.md`: Chi tiết đầy đủ về refactoring
- `lib/blocs/admin/admin_cubit.dart`: Template tham khảo
- `lib/ui/screen/admin/admin_upload_screen.dart`: Ví dụ sử dụng BlocProvider

## 🎉 Kết luận

Cấu trúc mới này hoàn toàn đồng nhất với các Cubit khác trong app (AdminCubit, LibraryCubit, BookDetailCubit...), giúp codebase dễ hiểu, dễ maintain và dễ mở rộng hơn!
