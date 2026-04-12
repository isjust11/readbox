---
description: Readbox Flutter Workflow: Quy trình phát triển, build và kiểm tra dự án.
---
# Readbox Flutter Workflow

Dưới đây là quy trình chuẩn khi làm việc với dự án Readbox:

## 1. Chuẩn bị Môi trường
Mỗi khi bắt đầu hoặc cập nhật code mới, chạy lệnh:
`flutter pub get`

## 2. Code Generation
Nếu có thay đổi về Models, Assets, hoặc Localization, hãy chạy lệnh generate:
`dart run build_runner build --delete-conflicting-outputs`

## 3. Kiểm tra Mã nguồn (Checking)
Trước khi tạo PR hoặc chuyển giao, hãy đảm bảo code sạch:
`flutter analyze`

## 4. Kiểm thử (Testing)
Chạy unit test và widget test:
`flutter test`

## 5. Chạy Ứng dụng (Running)
Chạy app ở mode Debug:
`flutter run`

## 6. Đóng gói (Building)
Đóng gói ứng dụng cho các nền tảng:
- Android: `flutter build apk` hoặc `flutter build appbundle`
- iOS: `flutter build ios`
- Web: `flutter build web`
