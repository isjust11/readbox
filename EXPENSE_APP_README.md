# Ứng dụng Quản lý Chi tiêu - Expense Manager

## 📱 Giới thiệu
Ứng dụng di động quản lý chi tiêu cá nhân được xây dựng với Flutter (Frontend) và Spring Boot (Backend).

## ✨ Tính năng

### 🎯 Chức năng chính
- ✅ Thêm chi tiêu mới với đầy đủ thông tin
- ✅ Xem danh sách chi tiêu với UI đẹp mắt
- ✅ Chỉnh sửa và xóa chi tiêu
- ✅ Tìm kiếm chi tiêu theo từ khóa
- ✅ Lọc chi tiêu theo 7 danh mục
- ✅ Xem tổng chi tiêu và số lượng khoản
- ✅ Pull-to-refresh để cập nhật dữ liệu
- ✅ Xác nhận trước khi xóa

### 📊 Danh mục Chi tiêu
1. 🍽️ **Ăn uống** - màu cam
2. 🚗 **Di chuyển** - màu xanh dương
3. 🛍️ **Mua sắm** - màu tím
4. 🎬 **Giải trí** - màu hồng
5. 📚 **Học tập** - màu xanh lá
6. 🏥 **Y tế** - màu đỏ
7. 💰 **Khác** - màu xám

## 🏗️ Kiến trúc

### Backend (Spring Boot)
```
com.example.demo
├── entity
│   └── Expense.java
├── dto
│   └── ExpenseRequest.java
├── repository
│   └── ExpenseRepository.java
├── services
│   └── ExpenseService.java
└── controller
    └── ExpenseController.java
```

### Frontend (Flutter) - Clean Architecture
```
lib/
├── domain/
│   ├── data/
│   │   ├── entities/
│   │   │   └── expense_entity.dart
│   │   ├── models/
│   │   │   └── expense_model.dart
│   │   └── datasources/
│   │       └── remote/
│   │           └── expense_remote_data_source.dart
│   ├── repositories/
│   │   └── expense_repository.dart
│   └── usecases/
│       ├── get_expense_list_usecase.dart
│       ├── add_expense_usecase.dart
│       ├── update_expense_usecase.dart
│       ├── delete_expense_usecase.dart
│       └── search_expenses_usecase.dart
├── blocs/
│   └── expense/
│       └── expense_cubit.dart
├── ui/
│   └── screen/
│       ├── main_screen.dart (Hiển thị chi tiêu)
│       └── expense/
│           └── expense_form_screen.dart
└── injection_container.dart
```

## 🚀 Cài đặt và Chạy

### Yêu cầu
- Java 17+
- Flutter 3.0+
- MySQL (hoặc H2 Database)

### 1. Chạy Backend

```bash
cd d:\Develops\java\training-backend\demo
./gradlew bootRun
```

Backend sẽ chạy tại: `http://10.59.91.142:8088`

### 2. Chạy Flutter App

```bash
cd d:\Develops\java\app\scan_app_v1
flutter pub get
flutter run
```

### 3. Sử dụng ứng dụng

1. **Đăng nhập** vào app
2. Màn hình chính sẽ hiển thị **Quản lý chi tiêu**
3. Nhấn nút **+** để thêm chi tiêu mới
4. Mở **drawer menu** (☰) để:
   - Lọc theo danh mục
   - Xem tất cả chi tiêu
   - Truy cập thư viện sách
   - Đăng xuất

## 📡 API Endpoints

### Base URL
```
http://10.59.91.142:8088/api/expenses
```

### Danh sách Endpoints

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/expenses` | Lấy tất cả chi tiêu |
| GET | `/api/expenses/{id}` | Lấy chi tiêu theo ID |
| POST | `/api/expenses` | Tạo chi tiêu mới |
| PUT | `/api/expenses/{id}` | Cập nhật chi tiêu |
| POST | `/api/expenses/{id}/update` | Cập nhật (Flutter) |
| DELETE | `/api/expenses/{id}` | Xóa chi tiêu |
| POST | `/api/expenses/{id}/delete` | Xóa (Flutter) |
| GET | `/api/expenses/search` | Tìm kiếm |
| GET | `/api/expenses/category/{cat}` | Lọc theo danh mục |
| GET | `/api/expenses/statistics` | Thống kê |

### Ví dụ Request

#### Tạo chi tiêu mới
```json
POST /api/expenses
{
  "description": "Ăn trưa",
  "amount": 50000,
  "expenseDate": "2025-01-15",
  "category": "Ăn uống",
  "note": "Cơm văn phòng"
}
```

#### Tìm kiếm
```
GET /api/expenses/search?keyword=ăn
```

#### Thống kê
```
GET /api/expenses/statistics
GET /api/expenses/statistics?category=Ăn uống
```

## 💾 Database Schema

```sql
CREATE TABLE expenses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    amount DOUBLE NOT NULL,
    expense_date DATE NOT NULL,
    category VARCHAR(100),
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## 🎨 Giao diện

### Màn hình chính
- Header hiển thị tổng chi tiêu và số lượng khoản
- Danh sách chi tiêu với card design
- Mỗi card hiển thị: icon danh mục, mô tả, số tiền, ngày, ghi chú
- Search bar để tìm kiếm
- Filter button để lọc theo danh mục
- FAB (+) để thêm chi tiêu mới

### Màn hình thêm/sửa chi tiêu
- Input số tiền (bắt buộc) - hiển thị lớn và nổi bật
- Input mô tả (bắt buộc)
- Dropdown chọn danh mục với icon
- Date picker chọn ngày
- TextArea ghi chú (tùy chọn)
- Validation đầy đủ
- Button lưu

### Drawer Menu
- Avatar và thông tin user
- Menu item "Tất cả chi tiêu"
- Danh sách 7 danh mục để filter
- Menu "Thư viện sách"
- Menu "Đăng xuất"

## 🔧 Công nghệ sử dụng

### Backend
- Spring Boot 3.x
- Spring Data JPA
- MySQL/H2 Database
- Lombok
- Maven/Gradle

### Frontend
- Flutter 3.x
- flutter_bloc (State Management)
- GetIt (Dependency Injection)
- Dio (HTTP Client)
- intl (Date/Number Formatting)
- page_transition

## 📝 Design Patterns

- ✅ **Clean Architecture** - Tách biệt domain, data, presentation
- ✅ **Repository Pattern** - Abstraction layer cho data
- ✅ **BLoC Pattern** - State management với Cubit
- ✅ **Use Case Pattern** - Business logic tách biệt
- ✅ **Dependency Injection** - Loose coupling
- ✅ **MVC** - Backend controller pattern

## 🧪 Test API với cURL

### Tạo chi tiêu
```bash
curl -X POST http://10.59.91.142:8088/api/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Ăn sáng",
    "amount": 25000,
    "expenseDate": "2025-01-15",
    "category": "Ăn uống"
  }'
```

### Lấy tất cả
```bash
curl http://10.59.91.142:8088/api/expenses
```

### Tìm kiếm
```bash
curl "http://10.59.91.142:8088/api/expenses/search?keyword=ăn"
```

### Lọc theo danh mục
```bash
curl http://10.59.91.142:8088/api/expenses/category/Ăn%20uống
```

## 🔮 Tính năng có thể mở rộng

- 📊 Biểu đồ thống kê chi tiêu theo thời gian
- 📅 Lọc theo khoảng ngày
- 💰 Đặt ngân sách và cảnh báo vượt mức
- 📸 Chụp và lưu ảnh hóa đơn
- 📤 Export dữ liệu ra Excel/PDF
- 👥 Quản lý đa người dùng
- 🔔 Nhắc nhở thanh toán định kỳ
- 🏦 Tích hợp với ngân hàng
- 💱 Hỗ trợ đa tiền tệ
- ☁️ Backup cloud tự động

## ❓ Troubleshooting

### Backend không khởi động
```bash
./gradlew clean build
./gradlew bootRun
```

### Flutter build failed
```bash
flutter clean
flutter pub get
flutter run
```

### Không kết nối được API
- Kiểm tra IP trong `api_constant.dart`
- Kiểm tra backend đang chạy
- Kiểm tra firewall/network

## 📄 License
MIT License

## 👨‍💻 Author
Được xây dựng với ❤️ sử dụng Flutter & Spring Boot

