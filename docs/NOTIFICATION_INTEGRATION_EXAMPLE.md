# Example: Tích hợp Notification vào App

## 1. Update App Widget (ui/app.dart)

```dart
import 'package:readbox/services/services.dart';

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
    _initializeNotifications();
  }
  
  Future<void> _initializeNotifications() async {
    try {
      // Initialize FCM
      await _fcmService.initialize();
      
      // Initialize Local Notifications
      await _localNotificationService.initialize();
      
      // Log status
      debugPrint('✅ Notifications initialized');
      debugPrint('FCM Token: ${_fcmService.fcmToken}');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ... your existing providers
      ],
      child: BlocBuilder<LanguageCubit, String>(
        builder: (context, lang) {
          return BlocBuilder<ThemeCubit, String>(
            builder: (context, theme) {
              // Set notification handler context
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _notificationHandler.setContext(context);
              });
              
              return MaterialApp(
                // ... your app config
                onGenerateRoute: Routes.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
```

## 2. Thêm vào Settings Screen

```dart
// In setting_screen.dart, thêm vào _buildSettingsSection()

_buildSettingItem(
  icon: Icons.notifications,
  title: AppLocalizations.current.notifications,
  subtitle: AppLocalizations.current.manageNotifications,
  trailing: IconButton(
    icon: Icon(
      Icons.arrow_forward_ios,
      size: AppDimens.SIZE_16,
      color: Theme.of(context).primaryColor,
    ),
    onPressed: () {
      Navigator.of(context).pushNamed(Routes.notificationSettingsScreen);
    },
  ),
),
```

## 3. Send Token sau khi Login

```dart
// In login_screen.dart hoặc authentication logic

Future<void> _onLoginSuccess() async {
  try {
    // ... your existing login logic
    
    // Send FCM token to server
    final fcmService = FCMService();
    await fcmService.sendTokenToServer();
    
    debugPrint('✅ FCM token sent to server');
  } catch (e) {
    debugPrint('❌ Error sending FCM token: $e');
    // Don't block login if token send fails
  }
}
```

## 4. Sử dụng Notifications trong Features

### A. Book Detail Screen - Nhắc nhở đọc sách

```dart
// In book_detail_screen.dart

import 'package:readbox/services/services.dart';

class BookDetailScreen extends StatelessWidget {
  final LocalNotificationService _localService = LocalNotificationService();
  
  Future<void> _setReadingReminder(BookModel book) async {
    // Schedule reminder for tomorrow at 8 PM
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final reminderTime = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      20, // 8 PM
      0,
    );
    
    await _localService.scheduleNotification(
      id: book.id.hashCode,
      title: 'Nhắc nhở đọc sách',
      body: 'Đừng quên đọc "${book.title}"',
      scheduledDate: reminderTime,
      payload: jsonEncode({
        'screen': 'book_detail',
        'id': book.id,
        'type': 'reminder',
      }),
      channel: NotificationChannel.reminder,
    );
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã đặt nhắc nhở đọc sách')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
      floatingActionButton: FloatingActionButton(
        onPressed: () => _setReadingReminder(book),
        child: Icon(Icons.alarm),
        tooltip: 'Đặt nhắc nhở',
      ),
    );
  }
}
```

### B. Library Screen - Thông báo sách mới

```dart
// In library_screen.dart

import 'package:readbox/services/services.dart';

class LibraryScreen extends StatefulWidget {
  // ...
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LocalNotificationService _localService = LocalNotificationService();
  
  Future<void> _loadBooks() async {
    // ... load books logic
    
    // Nếu có sách mới, hiển thị notification
    if (newBooks.isNotEmpty) {
      final firstNewBook = newBooks.first;
      await _localService.showNewBookNotification(
        firstNewBook.title,
        firstNewBook.author,
      );
    }
  }
}
```

### C. PDF Reader - Hoàn thành sách

```dart
// In pdf_viewer_screen.dart

import 'package:readbox/services/services.dart';

class PdfViewerScreen extends StatefulWidget {
  // ...
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final LocalNotificationService _localService = LocalNotificationService();
  
  void _onPageChanged(int page, int totalPages) {
    // Kiểm tra nếu đọc xong sách
    if (page == totalPages - 1) {
      _showCompletionNotification();
    }
  }
  
  Future<void> _showCompletionNotification() async {
    await _localService.showBookCompletionNotification(widget.title);
  }
}
```

## 5. Handle Deep Links từ Notifications

```dart
// In notification_handler.dart - Đã implement sẵn

// Example payload từ server:
{
  "notification": {
    "title": "Sách mới",
    "body": "Khám phá sách mới trong thư viện"
  },
  "data": {
    "screen": "book_detail",
    "id": "book_123",
    "type": "book"
  }
}

// NotificationHandler sẽ tự động navigate đến BookDetailScreen
// và pass bookId = "book_123"
```

## 6. Subscribe to Topics

```dart
// In onboarding hoặc sau khi login

final fcmService = FCMService();

// Subscribe to topics dựa trên user preferences
if (user.interestedInFiction) {
  await fcmService.subscribeToTopic('fiction');
}

if (user.interestedInSciFi) {
  await fcmService.subscribeToTopic('scifi');
}

// General topics
await fcmService.subscribeToTopic('all_users');
await fcmService.subscribeToTopic('app_updates');
```

## 7. Test Notifications trong Development

```dart
// Tạo một debug screen hoặc add vào settings (chỉ debug mode)

if (kDebugMode) {
  ElevatedButton(
    onPressed: () async {
      final localService = LocalNotificationService();
      
      // Test instant notification
      await localService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Test Notification',
        body: 'This is a test notification',
        payload: 'test',
      );
    },
    child: Text('Test Local Notification'),
  ),
  
  ElevatedButton(
    onPressed: () async {
      final localService = LocalNotificationService();
      
      // Test scheduled notification (5 seconds)
      await localService.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch % 100000,
        title: 'Scheduled Test',
        body: 'This notification was scheduled',
        scheduledDate: DateTime.now().add(Duration(seconds: 5)),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification scheduled for 5 seconds')),
      );
    },
    child: Text('Test Scheduled Notification'),
  ),
}
```

## 8. Server API Implementation (Backend)

### A. Register FCM Token Endpoint

```javascript
// Node.js Express example
app.post('/api/fcm-tokens', async (req, res) => {
  const { token, platform, deviceId, appVersion, userId } = req.body;
  
  try {
    // Save to database
    await db.fcmTokens.upsert({
      where: { token },
      update: { userId, platform, deviceId, appVersion, lastUsed: new Date() },
      create: { token, userId, platform, deviceId, appVersion },
    });
    
    res.json({ success: true, message: 'Token registered' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### B. Send Notification Endpoint

```javascript
const admin = require('firebase-admin');

app.post('/api/notifications/send', async (req, res) => {
  const { userId, title, body, data } = req.body;
  
  try {
    // Get user's FCM token from database
    const userToken = await db.fcmTokens.findOne({ where: { userId } });
    
    if (!userToken) {
      return res.status(404).json({ error: 'User token not found' });
    }
    
    // Send notification via FCM
    const message = {
      notification: { title, body },
      data: data || {},
      token: userToken.token,
    };
    
    const response = await admin.messaging().send(message);
    
    res.json({ success: true, messageId: response });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### C. Send to Topic

```javascript
app.post('/api/notifications/send-topic', async (req, res) => {
  const { topic, title, body, data } = req.body;
  
  try {
    const message = {
      notification: { title, body },
      data: data || {},
      topic: topic,
    };
    
    const response = await admin.messaging().send(message);
    
    res.json({ success: true, messageId: response });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

## 9. Production Checklist

- [ ] Test notifications trên cả iOS và Android
- [ ] Test foreground, background, và terminated states
- [ ] Verify notification permissions
- [ ] Test deep links và navigation
- [ ] Test scheduled notifications
- [ ] Verify APNS certificates (iOS)
- [ ] Configure FCM server key (Backend)
- [ ] Setup notification topics
- [ ] Implement analytics tracking
- [ ] Handle notification errors gracefully
- [ ] Test với real users

## 10. Analytics Tracking

```dart
// Track notification events
void _trackNotificationEvent(String event, Map<String, dynamic> data) {
  // Your analytics service
  // FirebaseAnalytics.instance.logEvent(
  //   name: 'notification_$event',
  //   parameters: data,
  // );
}

// Examples:
_trackNotificationEvent('received', {'type': 'book', 'screen': 'book_detail'});
_trackNotificationEvent('opened', {'source': 'push', 'screen': 'library'});
_trackNotificationEvent('dismissed', {'type': 'reminder'});
```

## Xong! 🎉

Notification system đã sẵn sàng để sử dụng trong production!
