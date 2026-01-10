# Notification Services

## Services Available

### 1. FCMService (`fcm_service.dart`)
Quản lý Firebase Cloud Messaging - Push notifications từ server.

**Tính năng:**
- Initialize FCM và request permissions
- Handle foreground, background, terminated messages
- APNS token management (iOS)
- Topic subscription
- Token refresh và send to server

**Usage:**
```dart
final fcmService = FCMService();
await fcmService.initialize();
await fcmService.sendTokenToServer();
await fcmService.subscribeToTopic('books');
```

### 2. LocalNotificationService (`local_notification_service.dart`)
Quản lý local notifications - Scheduled và instant notifications.

**Tính năng:**
- Show instant notifications
- Schedule notifications
- Daily reminders
- Multiple notification channels
- Pre-built notification templates

**Usage:**
```dart
final localService = LocalNotificationService();
await localService.initialize();

// Instant notification
await localService.showNotification(
  id: 1,
  title: 'Title',
  body: 'Body',
);

// Daily reminder
await localService.scheduleDailyReadingReminder(
  id: 2,
  title: 'Reading Time',
  body: 'Time to read!',
  hour: 20,
  minute: 0,
);

// Pre-built
await localService.showReadingReminder('Book Title');
```

### 3. NotificationHandler (`notification_handler.dart`)
Xử lý navigation và actions khi user tap vào notification.

**Tính năng:**
- Auto-navigation based on notification data
- Parse notification payload
- In-app notification banner
- Icon và color mapping theo notification type

**Usage:**
```dart
// Set context first (in main app widget)
final handler = NotificationHandler();
handler.setContext(context);

// Handle notification tap
await handler.handleNotificationTap(remoteMessage);

// Show in-app banner
handler.showInAppNotification(
  context,
  'Title',
  'Body',
  onTap: () {
    // Navigate somewhere
  },
);
```

## Notification Data Format

### Push Notification (FCM)
```json
{
  "notification": {
    "title": "Notification Title",
    "body": "Notification Body"
  },
  "data": {
    "screen": "book_detail|library|settings|profile|main|pdf_viewer",
    "id": "resource_id",
    "type": "book|library|reminder|update|message|announcement",
    "fileUrl": "url", // for pdf_viewer
    "title": "title" // for pdf_viewer
  }
}
```

### Local Notification Payload
```dart
// Simple string payload
payload: 'reminder:reading'

// For complex data, use JSON
payload: jsonEncode({
  'type': 'book',
  'id': 'book_123',
  'action': 'open',
})
```

## Notification Channels

### Android
- **Default Channel** (`readbox_default`) - General notifications
- **Reminder Channel** (`readbox_reminders`) - Reading reminders
- **Update Channel** (`readbox_updates`) - App updates

### Usage
```dart
await localService.showNotification(
  ...
  channel: NotificationChannel.reminder, // or .defaultChannel or .update
);
```

## Integration Checklist

- [x] FCM Service initialized
- [x] Local Notification Service initialized
- [x] NotificationHandler context set
- [x] Background message handler registered
- [x] Android permissions configured
- [x] iOS APNS configured
- [x] Notification channels created
- [x] Routes defined for navigation
- [ ] Server API endpoints implemented (TODO)
- [ ] FCM token sent to server after login
- [ ] Topic subscription implemented

## Quick Start

```dart
// 1. In main.dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

// 2. In app widget
class _MyAppState extends State<MyApp> {
  final FCMService _fcmService = FCMService();
  final LocalNotificationService _localService = LocalNotificationService();
  final NotificationHandler _handler = NotificationHandler();
  
  @override
  void initState() {
    super.initState();
    _init();
  }
  
  Future<void> _init() async {
    await _fcmService.initialize();
    await _localService.initialize();
    _handler.setContext(context);
  }
  
  // ... build method
}

// 3. Send notifications
await _localService.showNotification(...);
await _fcmService.sendTokenToServer();

// 4. Navigate to settings
Navigator.pushNamed(context, Routes.notificationSettingsScreen);
```

## Debug Tips

```dart
// Check FCM token
print('FCM: ${fcmService.fcmToken}');

// Check APNS token (iOS)
print('APNS: ${await fcmService.getAPNSToken()}');

// Check permissions
print('Granted: ${await fcmService.isPermissionGranted()}');

// Check pending notifications
final pending = await localService.getPendingNotifications();
print('Pending: ${pending.length}');
```

## Xem thêm

Chi tiết đầy đủ tại: `docs/NOTIFICATION_GUIDE.md`
