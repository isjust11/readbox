# Notification Feature Documentation

## Tổng quan
Hệ thống thông báo đầy đủ cho ứng dụng ReadBox, bao gồm danh sách thông báo, đánh dấu đã đọc/chưa đọc, xóa thông báo, và nhiều tính năng khác.

## Cấu trúc

### 1. Models & Entities

#### NotificationEntity (`lib/domain/data/entities/notification_entity.dart`)
- Entity cơ bản chứa các thuộc tính của thông báo
- Các trường: id, title, body, message, type, data, isRead, createdAt, readAt, userId, imageUrl, actionUrl, metadata
- Enum NotificationType: book, library, reminder, update, message, announcement, system, other

#### NotificationModel (`lib/domain/data/models/notification_model.dart`)
- Kế thừa từ NotificationEntity
- Các helper methods:
  - `displayTitle`: Tiêu đề hiển thị
  - `displayBody`: Nội dung hiển thị
  - `formattedDate`: Ngày giờ định dạng (Hôm nay, Hôm qua, etc.)
  - `isUnread`: Kiểm tra chưa đọc
  - `typeDisplay`: Hiển thị loại thông báo bằng tiếng Việt

### 2. Data Layer

#### NotificationRemoteDataSource (`lib/domain/data/datasources/remote/notification_remote_data_source.dart`)
API calls:
- `getNotifications()`: Lấy danh sách thông báo (với pagination, filter)
- `getNotificationById()`: Lấy chi tiết một thông báo
- `markAsRead()`: Đánh dấu đã đọc
- `markAsUnread()`: Đánh dấu chưa đọc
- `markAllAsRead()`: Đánh dấu tất cả đã đọc
- `deleteNotification()`: Xóa một thông báo
- `deleteAllNotifications()`: Xóa tất cả thông báo
- `getUnreadCount()`: Lấy số lượng thông báo chưa đọc

#### NotificationRepository (`lib/domain/repositories/notification_repository.dart`)
- Wrapper layer cho RemoteDataSource
- Handle errors và exceptions

### 3. Business Logic

#### NotificationCubit (`lib/blocs/notification/notification_cubit.dart`)
State management cho notifications:
- State: notifications list, unreadCount, totalCount, hasMore, isLoadingMore
- Actions:
  - `getNotifications()`: Load notifications với pagination
  - `refreshNotifications()`: Refresh danh sách
  - `markAsRead()`: Đánh dấu một thông báo đã đọc
  - `markAsUnread()`: Đánh dấu một thông báo chưa đọc
  - `markAllAsRead()`: Đánh dấu tất cả đã đọc
  - `deleteNotification()`: Xóa một thông báo
  - `deleteAllNotifications()`: Xóa tất cả
  - `updateUnreadCount()`: Cập nhật số lượng chưa đọc

### 4. UI Layer

#### NotificationScreen (`lib/ui/screen/settings/page/notification_screen.dart`)
Màn hình danh sách thông báo với các tính năng:
- Hiển thị danh sách thông báo
- Pull to refresh
- Load more (pagination)
- Filter (Tất cả, Chưa đọc, Đã đọc)
- Đánh dấu đã đọc/chưa đọc
- Xóa thông báo (swipe to delete)
- Đánh dấu tất cả đã đọc
- Xóa tất cả thông báo
- Empty state
- Badge hiển thị số lượng chưa đọc

## API Endpoints

Các endpoint được định nghĩa trong `ApiConstant`:

```dart
static final getNotifications = "notifications";
static final markNotificationRead = "notifications/mark-read";
static final markAllNotificationsRead = "notifications/mark-all-read";
static final deleteNotification = "notifications";
static final deleteAllNotifications = "notifications/delete-all";
static final getNotificationUnreadCount = "notifications/unread-count";
```

### Backend API Format

#### GET /notifications
Query params:
- `page`: Số trang (default: 1)
- `limit`: Số lượng per page (default: 20)
- `isRead`: Filter theo trạng thái (true/false/null)

Response:
```json
{
  "data": [
    {
      "id": "1",
      "title": "Thông báo mới",
      "body": "Nội dung thông báo",
      "type": "book",
      "isRead": false,
      "createdAt": "2026-01-13T10:00:00.000Z",
      "userId": "user123"
    }
  ],
  "total": 100,
  "unreadCount": 15
}
```

#### PATCH /notifications/mark-read/:id
Body:
```json
{
  "isRead": true
}
```

#### PATCH /notifications/mark-all-read
Body: `{}`

#### DELETE /notifications/:id
No body required

#### DELETE /notifications/delete-all
No body required

#### GET /notifications/unread-count
Response:
```json
{
  "count": 15
}
```

## Sử dụng

### 1. Navigation đến NotificationScreen
```dart
Navigator.pushNamed(context, Routes.notificationScreen);
```

### 2. Sử dụng NotificationCubit
```dart
final cubit = context.read<NotificationCubit>();

// Load notifications
cubit.getNotifications(page: 1, limit: 20);

// Mark as read
cubit.markAsRead(notificationId);

// Delete notification
cubit.deleteNotification(notificationId);

// Get unread count
final unreadCount = cubit.unreadCount;
```

### 3. Dependency Injection
Đã được đăng ký trong `injection_container.dart`:
```dart
// Data Source
getIt.registerLazySingleton(() => NotificationRemoteDataSource(network: getIt.get()));

// Repository
getIt.registerLazySingleton(() => NotificationRepository(remoteDataSource: getIt.get<NotificationRemoteDataSource>()));

// Cubit
getIt.registerFactory(() => NotificationCubit(notificationRepository: getIt.get<NotificationRepository>()));
```

## Tính năng nổi bật

1. **Pull to Refresh**: Kéo xuống để refresh danh sách
2. **Pagination**: Tự động load more khi scroll đến cuối
3. **Filter**: Lọc theo trạng thái đã đọc/chưa đọc
4. **Swipe to Delete**: Vuốt sang trái để xóa thông báo
5. **Mark as Read**: Tự động đánh dấu đã đọc khi tap vào thông báo
6. **Empty State**: Hiển thị trạng thái rỗng khi không có thông báo
7. **Badge Count**: Hiển thị số lượng thông báo chưa đọc
8. **Notification Icons**: Icon màu sắc theo loại thông báo
9. **Formatted Date**: Hiển thị thời gian theo định dạng thân thiện (Hôm nay, Hôm qua, etc.)

## TODO / Future Improvements

- [ ] Thêm notification navigation (tap vào thông báo để navigate đến màn hình tương ứng)
- [ ] Local notification storage (cache offline)
- [ ] Real-time notification updates (WebSocket)
- [ ] Notification categories/tabs
- [ ] Search notifications
- [ ] Export notifications
- [ ] Notification preferences per category
- [ ] Rich notification (images, actions)
- [ ] Notification scheduling
- [ ] Notification analytics

## Testing

Để test chức năng này, backend cần implement các API endpoints ở trên với format đúng.

Test cases cơ bản:
1. Load danh sách thông báo
2. Filter thông báo theo trạng thái
3. Đánh dấu đã đọc/chưa đọc
4. Xóa thông báo
5. Pull to refresh
6. Load more pagination
7. Empty state
8. Error handling

## Notes

- Đã thêm `patch()` và `delete()` methods vào `Network` class trong `network_impl.dart`
- UI sử dụng `SmartRefresher` từ package `pull_to_refresh`
- Colors và icons được handle bởi `NotificationHandler`
- Tất cả các string đã được Việt hóa
