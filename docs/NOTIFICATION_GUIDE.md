# Hướng dẫn Triển khai và Sử dụng Notification

## 📱 Tổng quan

Ứng dụng ReadBox đã được tích hợp đầy đủ hệ thống thông báo bao gồm:
- **Push Notifications** (FCM - Firebase Cloud Messaging)
- **Local Notifications** (Scheduled, Reminders)
- **Notification Handler** (Navigation và Actions)

## 🎯 Các Tính Năng

### 1. Push Notifications (FCM)
- Nhận thông báo từ server (background, foreground, terminated)
- Tự động xử lý APNS token cho iOS
- Channel configuration cho Android
- Permission management

### 2. Local Notifications
- Scheduled notifications (lên lịch thông báo)
- Daily reminders (nhắc nhở đọc sách hàng ngày)
- Instant notifications
- Notification channels (Default, Reminder, Update)

### 3. Notification Handler
- Tự động điều hướng đến màn hình tương ứng
- Parse notification data
- Handle foreground/background/terminated states
- In-app notification banner

### 4. Notification Settings UI
- Quản lý toàn bộ notification preferences
- Toggle push/local notifications
- Set reading reminders
- Test notifications
- View & copy FCM token

## 📦 Cài đặt

### 1. Dependencies đã có sẵn

```yaml
dependencies:
  firebase_core: ^4.3.0
  firebase_messaging: ^16.1.0
  flutter_local_notifications: ^19.5.0
  permission_handler: ^11.0.0
  timezone: ^0.9.0
```

### 2. Android Configuration

#### AndroidManifest.xml
```xml
<!-- Permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Default notification channel -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel"/>

<!-- Intent filter for notification click -->
<intent-filter>
    <action android:name="FLUTTER_NOTIFICATION_CLICK"/>
    <category android:name="android.intent.category.DEFAULT"/>
</intent-filter>
```

### 3. iOS Configuration

#### AppDelegate.swift
- Đã cấu hình đầy đủ APNS token handling
- UNUserNotificationCenter delegate
- Firebase messaging integration
- Notification presentation options

#### Info.plist
Thêm quyền notification (nếu chưa có):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 🚀 Sử dụng

### 1. Khởi tạo trong App

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

// app.dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FCMService _fcmService = FCMService();
  final LocalNotificationService _localNotificationService = 
      LocalNotificationService();
  final NotificationHandler _notificationHandler = NotificationHandler();
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // Initialize notification services
    await _fcmService.initialize();
    await _localNotificationService.initialize();
  }
  
  @override
  Widget build(BuildContext context) {
    // Set navigation context for notification handler
    _notificationHandler.setContext(context);
    
    return MaterialApp(
      // ... your app config
    );
  }
}
```

### 2. Gửi Push Notification từ Server

#### Payload Format
```json
{
  "notification": {
    "title": "Sách mới đã được thêm",
    "body": "Khám phá cuốn sách mới trong thư viện"
  },
  "data": {
    "screen": "book_detail",
    "id": "book_123",
    "type": "book"
  }
}
```

#### Các Screen Types hỗ trợ:
- `book_detail` - Chi tiết sách (cần `id`)
- `library` - Thư viện
- `settings` - Cài đặt
- `profile` - Hồ sơ
- `main` - Màn hình chính
- `pdf_viewer` - PDF viewer (cần `fileUrl` và `title`)
- `notification_settings` - Cài đặt thông báo

### 3. Sử dụng Local Notifications

#### Hiển thị Notification ngay lập tức
```dart
final localNotificationService = LocalNotificationService();

await localNotificationService.showNotification(
  id: 1,
  title: 'Thông báo',
  body: 'Nội dung thông báo',
  payload: 'custom_data',
  channel: NotificationChannel.defaultChannel,
);
```

#### Schedule Notification
```dart
await localNotificationService.scheduleNotification(
  id: 2,
  title: 'Nhắc nhở',
  body: 'Đã đến giờ đọc sách',
  scheduledDate: DateTime.now().add(Duration(hours: 1)),
  payload: 'reminder',
  channel: NotificationChannel.reminder,
);
```

#### Daily Reading Reminder
```dart
await localNotificationService.scheduleDailyReadingReminder(
  id: 3,
  title: 'Giờ đọc sách',
  body: 'Hãy dành thời gian đọc sách hôm nay!',
  hour: 20, // 8:00 PM
  minute: 0,
  payload: 'daily_reminder',
);
```

#### Pre-built Notifications
```dart
// Book reading reminder
await localNotificationService.showReadingReminder('Tên sách');

// Book completion
await localNotificationService.showBookCompletionNotification('Tên sách');

// New book
await localNotificationService.showNewBookNotification('Tên sách', 'Tác giả');
```

### 4. Custom Navigation

Để thêm screen mới vào notification handler:

```dart
// lib/services/notification_handler.dart
Future<void> _navigateToScreen(...) async {
  switch (screen) {
    case 'custom_screen':
      Navigator.of(_context!).pushNamed(Routes.customScreen);
      break;
    // ... other cases
  }
}
```

### 5. Sử dụng Notification Settings UI

Người dùng có thể:
- Bật/tắt push notifications
- Bật/tắt local notifications
- Đặt reading reminders với thời gian tùy chỉnh
- Toggle sound, vibration, badge
- Test notifications
- Xem và copy FCM token
- Kiểm tra permission status

Navigate đến màn hình:
```dart
Navigator.of(context).pushNamed(Routes.notificationSettingsScreen);
```

## 📊 Permission Management

### Check Permission Status
```dart
final fcmService = FCMService();
final isGranted = await fcmService.isPermissionGranted();
final status = await fcmService.getPermissionStatus();
```

### Request Permission
```dart
final granted = await fcmService.requestPermissionAgain();
if (granted) {
  print('Permission granted');
} else {
  print('Permission denied');
}
```

### Open App Settings
```dart
import 'package:permission_handler/permission_handler.dart';

await openAppSettings();
```

## 🔧 API Server Integration

### 1. Gửi FCM Token lên Server

```dart
// Sau khi user login thành công
final fcmService = FCMService();
await fcmService.sendTokenToServer();
```

Hoặc tự động khi app khởi động (nếu đã login):
```dart
await fcmService.sendTokenToServerIfLoggedIn();
```

### 2. Subscribe to Topics

```dart
await fcmService.subscribeToTopic('books');
await fcmService.subscribeToTopic('updates');
```

### 3. Server API Endpoints (Cần implement)

```
POST /api/fcm-tokens
{
  "token": "fcm_token_string",
  "platform": "android|ios",
  "deviceId": "device_id",
  "appVersion": "1.0.0",
  "userId": "user_id" // optional
}

POST /api/notifications/send
{
  "token": "fcm_token_string", // or
  "userId": "user_id",
  "title": "Title",
  "body": "Body",
  "data": {
    "screen": "book_detail",
    "id": "book_123"
  }
}

POST /api/topics/subscribe
{
  "topic": "books",
  "userId": "user_id"
}
```

## 🐛 Debugging

### 1. Check FCM Token
```dart
final fcmService = FCMService();
print('FCM Token: ${fcmService.fcmToken}');
```

### 2. Check APNS Token (iOS)
```dart
final apnsToken = await fcmService.getAPNSToken();
print('APNS Token: $apnsToken');
```

### 3. Check Permission Status
```dart
final status = await fcmService.getPermissionStatus();
print('Permission Status: $status');
```

### 4. View Pending Notifications
```dart
final localService = LocalNotificationService();
final pending = await localService.getPendingNotifications();
print('Pending: ${pending.length}');
```

### 5. Enable Debug Logs
Tất cả services đã có debug logs với prefix:
- ✅ Success
- ❌ Error
- ⚠️ Warning
- 📱 Device/Platform info
- 🔔 Notification events
- 📩 Message received

## 📝 Testing

### 1. Test với Firebase Console
1. Mở Firebase Console
2. Cloud Messaging > Send test message
3. Nhập FCM token từ app
4. Gửi test message

### 2. Test Local Notifications
```dart
// In app
final localService = LocalNotificationService();
await localService.showNotification(
  id: DateTime.now().millisecondsSinceEpoch,
  title: 'Test',
  body: 'Test notification',
);
```

### 3. Test Navigation
```dart
// Test notification tap
final notificationHandler = NotificationHandler();
notificationHandler.setContext(context);

final testMessage = RemoteMessage(
  data: {
    'screen': 'library',
    'type': 'book',
  },
);

await notificationHandler.handleNotificationTap(testMessage);
```

## 🔒 Best Practices

1. **Always check permissions before sending notifications**
2. **Handle all notification states** (foreground, background, terminated)
3. **Use appropriate notification channels** for different types
4. **Keep notification payload small** (< 4KB)
5. **Test on both iOS and Android** thoroughly
6. **Handle errors gracefully** with try-catch
7. **Use meaningful notification IDs** for management
8. **Clean up scheduled notifications** when no longer needed
9. **Respect user preferences** from settings
10. **Log important events** for debugging

## 🚨 Common Issues & Solutions

### iOS: APNS token not available
```dart
// Wait and retry
if (Platform.isIOS) {
  await _fcmService.ensureAPNSTokenReady();
}
```

### Android: Notification not showing
- Check notification permissions
- Verify channel configuration
- Check Do Not Disturb mode

### Navigation not working
- Ensure NotificationHandler.setContext() is called
- Verify routes are defined in Routes class
- Check notification data format

### Token not being sent to server
- Verify user is logged in
- Check network connectivity
- Implement server API endpoints

## 📚 Tài liệu tham khảo

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Permission Handler](https://pub.dev/packages/permission_handler)
- [Timezone](https://pub.dev/packages/timezone)

## 🎉 Hoàn tất!

Hệ thống notification đã sẵn sàng sử dụng! Chỉ cần implement server API endpoints để có thể gửi push notifications từ backend.
