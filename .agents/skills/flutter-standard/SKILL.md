---
name: Readbox Coding Standard
description: Quy chuẩn coding và cấu trúc dự án Flutter cho Readbox.
---
# Readbox Flutter Coding Standard

Khi thực hiện code và phát triển tính năng trên dự án Readbox, tôi (AI) sẽ tuân thủ các quy tắc sau:

## 1. Cấu trúc Thư mục (Project Structure)
Tuân thủ cấu trúc thư mục hiện tại:
- `lib/ui/screen/`: Chứa các màn hình hoàn chỉnh.
- `lib/ui/widget/`: Chứa các component UI dùng chung hoặc component nhỏ.
- `lib/blocs/`: Quản lý Business Logic bằng BLoC/Cubit. Ưu tiên sử dụng `Cubit` và kế thừa `BaseBloc` hoặc `BaseListCubit` nếu có.
- `lib/domain/`: Định nghĩa các models, entities và repositories interfaces.
- `lib/services/`: Các dịch vụ xử lý dữ liệu (API, Repository implementation, Database).
- `lib/res/`: Quản lý styles, colors (`colors.dart`), dimensions (`dimens.dart`).
- `lib/utils/`: Các hàm tiện ích.

## 2. Quản lý Trạng thái (State Management)
- Sử dụng `flutter_bloc` (Bloc/Cubit).
- Sử dụng `equatable` cho State và Event để tối ưu hiệu năng so sánh.
- Đăng ký BLoC/Cubit trong `injection_container.dart` bằng `GetIt`.

## 3. Dependency Injection (DI)
- Sử dụng `GetIt` cho DI. Luôn kiểm tra và đăng ký các service, repository, và cubit mới vào `lib/injection_container.dart`.

## 4. UI & Resources
- Không dùng hardcode mã màu hoặc kích thước. Sử dụng các hằng số định nghĩa sẵn trong `lib/res/`.
- Tái sử dụng các widget có sẵn trong `lib/ui/widget/`.
- Hỗ trợ đa ngôn ngữ sử dụng `intl` (file `.arb`).

## 5. Coding Style
- Tuân thủ [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
- Sử dụng `camelCase` cho biến và hàm.
- Sử dụng `PascalCase` cho class.
- Sử dụng `snake_case` cho tên file `.dart`.
- Luôn sử dụng `const` cho các widget không đổi để tối ưu hiệu năng.

## 6. Xử lý Lỗi & Logging
- Luôn bọc các logic async (gọi API, doc file) trong khối `try-catch`.
- Sử dụng BLoC State để thông báo lỗi ra UI thay vì in ra console đơn thuần.
