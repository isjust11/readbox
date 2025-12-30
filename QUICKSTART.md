# 🚀 Quick Start - Ứng dụng Quản lý Chi tiêu

## Chạy nhanh trong 3 bước

### Bước 1️⃣: Chạy Backend
```bash
cd d:\Develops\java\training-backend\demo
./gradlew bootRun
```
✅ Backend chạy tại: http://10.59.91.142:8088

### Bước 2️⃣: Chạy Flutter App
```bash
cd d:\Develops\java\app\scan_app_v1
flutter pub get
flutter run
```

### Bước 3️⃣: Sử dụng App
1. **Đăng nhập** với tài khoản của bạn
2. Màn hình chính = **Quản lý chi tiêu** 💰
3. Nhấn **+** để thêm chi tiêu mới
4. Mở **≡** (drawer) để lọc theo danh mục

## ⚡ Tính năng chính

### Màn hình chính
- 📊 Tổng chi tiêu và số lượng khoản (ở đầu màn hình)
- 📝 Danh sách chi tiêu với card đẹp
- 🔍 Tìm kiếm chi tiêu (icon search)
- 🎯 Lọc theo danh mục (icon filter)
- ➕ Thêm chi tiêu mới (nút + dưới góc phải)

### Thêm chi tiêu
1. Nhấn nút **+**
2. Nhập **số tiền** (bắt buộc)
3. Nhập **mô tả** (bắt buộc)
4. Chọn **danh mục** từ dropdown
5. Chọn **ngày** chi tiêu
6. Thêm **ghi chú** (tùy chọn)
7. Nhấn **✓** hoặc nút "Thêm chi tiêu"

### Sửa/Xóa chi tiêu
- Nhấn **⋮** (3 chấm) ở mỗi card
- Chọn **Chỉnh sửa** hoặc **Xóa**

### Lọc theo danh mục
- Mở drawer **≡**
- Chọn một trong 7 danh mục:
  - 🍽️ Ăn uống
  - 🚗 Di chuyển
  - 🛍️ Mua sắm
  - 🎬 Giải trí
  - 📚 Học tập
  - 🏥 Y tế
  - 💰 Khác

## 📱 Screenshots Flow

```
┌─────────────────────────┐
│   LOGIN SCREEN          │
└──────────┬──────────────┘
           │ Đăng nhập
           ▼
┌─────────────────────────┐
│   MAIN SCREEN           │
│   (Quản lý chi tiêu)    │
│                         │
│  💰 Tổng: 1,500,000 đ   │
│  📊 Số khoản: 15        │
│                         │
│  ┌───────────────────┐  │
│  │ 🍽️ Ăn trưa       │  │
│  │ 50,000 đ         │  │
│  │ Ăn uống • 15/01  │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ 🚗 Xăng xe       │  │
│  │ 200,000 đ        │  │
│  │ Di chuyển • 14/01│  │
│  └───────────────────┘  │
│                         │
│              [+]  FAB   │
└─────────────────────────┘
           │ Nhấn +
           ▼
┌─────────────────────────┐
│  EXPENSE FORM SCREEN    │
│                         │
│  Số tiền                │
│  ┌───────────────────┐  │
│  │ 50000          đ  │  │
│  └───────────────────┘  │
│                         │
│  Mô tả                  │
│  ┌───────────────────┐  │
│  │ Ăn trưa           │  │
│  └───────────────────┘  │
│                         │
│  Danh mục               │
│  🍽️ Ăn uống ▼          │
│                         │
│  Ngày: 15/01/2025       │
│                         │
│  [  Thêm chi tiêu  ]    │
└─────────────────────────┘
           │ Lưu
           ▼
┌─────────────────────────┐
│   MAIN SCREEN           │
│   (Đã cập nhật)         │
└─────────────────────────┘
```

## 🎯 Test nhanh với API

### Tạo chi tiêu bằng cURL
```bash
curl -X POST http://10.59.91.142:8088/api/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Test expense",
    "amount": 100000,
    "expenseDate": "2025-01-15",
    "category": "Ăn uống"
  }'
```

### Xem tất cả chi tiêu
```bash
curl http://10.59.91.142:8088/api/expenses
```

## 🐛 Gặp lỗi?

### Backend không chạy
```bash
cd d:\Develops\java\training-backend\demo
./gradlew clean build
./gradlew bootRun
```

### Flutter có vấn đề
```bash
cd d:\Develops\java\app\scan_app_v1
flutter clean
flutter pub get
flutter run
```

### Không kết nối được API
- Kiểm tra backend đang chạy: http://10.59.91.142:8088/api/expenses
- Kiểm tra IP trong file: `lib/domain/network/api_constant.dart`

## 📚 Tài liệu chi tiết
Xem file `EXPENSE_APP_README.md` để biết thêm chi tiết.

## ✨ Xong! Enjoy your expense tracking! 💰📊

