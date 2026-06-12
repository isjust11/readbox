import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/utils/html_content_processor.dart';
import 'package:readbox/utils/navigator.dart';

/// Key for flag: app nhận thông báo khi ở background (dùng để refresh khi resume)
const String _keyNewNotificationInBackground = 'fcm_new_notification_in_background';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Received background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  // Ghi cờ để khi app resume sẽ load lại danh sách thông báo
  await GetStorage().write(_keyNewNotificationInBackground, true);
  // Note: Do not show notifications here as it's handled by the system
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final GetStorage _storage = GetStorage();
  final HtmlUnescape _htmlUnescape = HtmlUnescape();
  /// Stream để báo có thông báo mới (foreground/background/tap) -> load lại danh sách
  static final _newNotificationController = StreamController<void>.broadcast();
  static Stream<void> get onNewNotification => _newNotificationController.stream;

  /// Gọi khi nhận thông báo foreground, tap notification, hoặc mở app từ notification
  void _notifyNewNotificationReceived() {
    _newNotificationController.add(null);
  }

  /// Gọi khi app resume: nếu có thông báo mới lúc background thì báo để refresh
  void checkAndNotifyIfReceivedInBackground() {
    if (_storage.read(_keyNewNotificationInBackground) == true) {
      _storage.remove(_keyNewNotificationInBackground);
      _notifyNewNotificationReceived();
    }
  }

  // Notification channels
  static const String _channelId = 'readbox_channel';
  static const String _channelName = 'ReadBox Notifications';
  static const String _channelDescription =
      'Notifications from ReadBox app';

  // Storage keys
  static const String _fcmTokenKey = 'fcm_token';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  String? _fcmToken;
  bool _notificationsEnabled = true;
  String? _deviceId;
  String? _appVersion;
  String? get fcmToken => _fcmToken;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Initialize FCM service
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission
      await _requestPermission();

      // For iOS, ensure APNS token is ready before getting FCM token
      if (Platform.isIOS) {
        await _ensureAPNSTokenReady();
      }

      // Get FCM token (chỉ lấy, không gửi lên server)
      await _getFCMToken();

      // Nếu user đã login rồi, gửi token với userId
      // await sendTokenToServerIfLoggedIn();

      // Setup message handlers
      _setupMessageHandlers();

      // Load notification settings
      await _loadNotificationSettings();

      // Get device id and app version
      _deviceId = await _getDeviceId();
      _appVersion = await _getAppVersion();

      debugPrint('FCM Service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM Service: $e');
    }
  }

  String get platform => Platform.isIOS ? 'ios' : 'android';
  String? get deviceId =>  _deviceId;
  String? get appVersion => _appVersion;

  /// Ensure APNS token is ready for iOS
  Future<void> _ensureAPNSTokenReady() async {
    int retryCount = 0;
    const maxRetries = 5;

    while (retryCount < maxRetries) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('APNS Token ready: $apnsToken');
        return;
      }

      retryCount++;
      debugPrint('APNS Token not ready, retry $retryCount/$maxRetries...');
      await Future.delayed(Duration(seconds: retryCount));
    }

    debugPrint(
      'APNS Token not available after $maxRetries retries, proceeding...',
    );
  }

  Future<String?> _getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // ID duy nhất cho iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.id; // Trên Android, 'id' thường là Android ID
  }
  
  return null;
}

   Future<String?> _getAppVersion() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.systemVersion;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.version.sdkInt.toString();
    }
    return '1.0.0';
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    debugPrint('📱 Requesting notification permission...');

    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final status = settings.authorizationStatus;
    debugPrint('🔔 Notification permission status: $status');

    // Check and log permission status
    switch (status) {
      case AuthorizationStatus.authorized:
        debugPrint('✅ User granted notification permission');
      case AuthorizationStatus.provisional:
        debugPrint('⚠️ User granted provisional permission');
      case AuthorizationStatus.denied:
        debugPrint('❌ User denied notification permission');
        debugPrint('⚠️ User needs to enable notifications in Settings');
      case AuthorizationStatus.notDetermined:
        debugPrint('❓ Permission not determined yet');
    }

    // For iOS, ensure APNS token is available
    if (Platform.isIOS) {
      await _setupAPNSToken();
    }

    return settings;
  }

  /// Setup APNS token for iOS
  Future<void> _setupAPNSToken() async {
    try {
      // Request APNS token
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null) {
        debugPrint('APNS Token: $apnsToken');
      } else {
        debugPrint('APNS Token not available yet, will retry...');
        // Retry after a short delay
        Future.delayed(const Duration(seconds: 2), () async {
          final retryToken = await _messaging.getAPNSToken();
          if (retryToken != null) {
            debugPrint('APNS Token (retry): $retryToken');
          }
        });
      }
    } catch (e) {
      debugPrint('Error getting APNS token: $e');
    }
  }

  /// Get FCM token (chỉ lấy token, không gửi lên server)
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _storage.write(_fcmTokenKey, _fcmToken);
        debugPrint('FCM Token: $_fcmToken');
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }


  /// Kiểm tra và gửi FCM token nếu user đã login (dùng khi app khởi động lại)
  // Future<void> sendTokenToServerIfLoggedIn() async {
  //   try {
  //     // Kiểm tra xem có access token không (user đã login)
  //     final secureStorage = SecureStorageService();
  //     final hasToken = await secureStorage.hasToken();
      
  //     if (hasToken && _fcmToken != null) {
  //       debugPrint('User already logged in, sending FCM token with userId');
  //       await sendTokenToServer();
  //     }
  //   } catch (e) {
  //     debugPrint('Error checking login status: $e');
  //   }
  // }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (registered separately in main.dart)
    // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    _handleInitialMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 Received foreground message: ${message.messageId}');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    if (!_notificationsEnabled) {
      debugPrint('⚠️ Notifications are disabled in app settings');
      return;
    }

    // Show local notification
    await _showLocalNotification(message);
    // Báo để load lại danh sách thông báo
    _notifyNewNotificationReceived();
  }

  /// Handle notification tap
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    debugPrint('Notification tapped: ${message.messageId}');
    _notifyNewNotificationReceived();
    // Handle navigation based on message data
    _navigateToScreen(message.data);
  }

  /// Handle initial message (when app is terminated)
  Future<void> _handleInitialMessage() async {
    final RemoteMessage? message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('App opened from notification: ${message.messageId}');
      _notifyNewNotificationReceived();
      _navigateToScreen(message.data);
    }
  }

 

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      debugPrint('⚠️ No notification payload in message');
      return;
    }

    debugPrint('🔔 Showing local notification...');
    debugPrint('   Title: ${notification.title}');
    debugPrint('   Body: ${notification.body}');

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      // Convert data map to JSON string for payload
      final payload = message.data.isNotEmpty 
          ? jsonEncode(message.data) 
          : null;

      // Decode HTML entities (&amp;, &lt;, &quot;, ...) và strip HTML tags
      final decodedTitle = HtmlContentProcessor.stripHtmlTags(notification.title ?? '');
      final decodedBody = HtmlContentProcessor.stripHtmlTags(notification.body ?? '');
      debugPrint('   Title decoded: $decodedTitle');
      debugPrint('   Body decoded: $decodedBody');
      await _localNotifications.show(
        message.hashCode,
        decodedTitle,
        decodedBody,
        details,
        payload: payload,
      );
      debugPrint('✅ Local notification shown successfully');
      debugPrint('   Payload: $payload');
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  /// Handle notification tap (local notification - khi user tap thông báo hiển thị lúc foreground)
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    _notifyNewNotificationReceived();
    // Navigate dựa trên payload JSON
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateToScreen(data);
      } catch (e) {
        debugPrint('❌ Error parsing local notification payload: $e');
      }
    }
  }

  /// Navigate to specific screen based on message data.
  /// Backend gửi [type] dạng UPPERCASE (e.g. 'CONTINUE_READING', 'EBOOK').
  /// Các key quan trọng trong [data]:
  ///   - type: loại thông báo
  ///   - bookId: ID của sách (dạng String)
  ///   - bookIds: danh sách IDs cách nhau bởi dấu phẩy (hot books)
  void _navigateToScreen(Map<String, dynamic> data) {
    final navigator = NavigationService.instance.navigatorKey.currentState;
    if (navigator == null) {
      debugPrint('❌ Navigator not ready');
      return;
    }

    final type = (data['type'] as String?)?.toUpperCase();
    final bookId = data['bookId'] as String?;

    debugPrint('🔔 Navigate from notification — type=$type, bookId=$bookId');

    switch (type) {
      // Nhắc tiếp tục đọc → mở thẳng BookDetail của cuốn sách đó
      case 'CONTINUE_READING':
        if (bookId != null) {
          navigator.pushNamed(Routes.bookDetailScreen, arguments: bookId);
        } else {
          navigator.pushNamed(Routes.notificationScreen);
        }
        break;

      // Ebook hot / gợi ý → mở màn hình thông báo để user xem danh sách
      case 'HOT_BOOKS':
        navigator.pushNamed(Routes.notificationScreen);
        break;

      // Thông báo về ebook cụ thể → BookDetail
      case 'EBOOK':
        if (bookId != null) {
          navigator.pushNamed(Routes.bookDetailScreen, arguments: bookId);
        } else {
          navigator.pushNamed(Routes.notificationScreen);
        }
        break;

      // Tương tác (like, rate, comment...) → BookDetail nếu có bookId
      case 'INTERACTION':
        if (bookId != null) {
          navigator.pushNamed(Routes.bookDetailScreen, arguments: bookId);
        } else {
          navigator.pushNamed(Routes.notificationScreen);
        }
        break;

      // Thanh toán → màn hình lịch sử thanh toán
      case 'PAYMENT':
        navigator.pushNamed(Routes.paymentHistoryScreen);
        break;

      // Feedback → màn hình feedback
      case 'FEEDBACK':
        navigator.pushNamed(Routes.feedbackScreen);
        break;

      // Bài viết mới / System → màn hình thông báo
      case 'NEW_ARTICLE':
      case 'SYSTEM':
        navigator.pushNamed(Routes.notificationScreen);
        break;

      default:
        debugPrint('⚠️ Unknown notification type: $type, navigating to notifications');
        navigator.pushNamed(Routes.notificationScreen);
        break;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      // For iOS, ensure APNS token is available before subscribing
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS token not available, waiting...');
          // Wait a bit and retry
          await Future.delayed(const Duration(seconds: 3));
          final retryToken = await _messaging.getAPNSToken();
          if (retryToken == null) {
            debugPrint('APNS token still not available, proceeding anyway...');
          }
        }
      }

      await _messaging.subscribeToTopic(topic);

      // Also notify server
      // final apiService = ApiService();
      // apiService.initialize();
      // await apiService.subscribeToTopic(topic);

      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');

      // If it's an APNS error, try to get the token and retry
      if (e.toString().contains('apns-token-not-set') && Platform.isIOS) {
        debugPrint('Retrying subscription after APNS token setup...');
        await Future.delayed(const Duration(seconds: 2));
        try {
          await _messaging.subscribeToTopic(topic);
          debugPrint('Successfully subscribed to topic: $topic (retry)');
        } catch (retryError) {
          debugPrint('Retry failed: $retryError');
        }
      }
    }
  }

  /// Toggle notifications
  Future<bool> toggleNotifications(bool enabled) async {
    if (enabled) {
      // Khi BẬT: Kiểm tra và request permission
      final settings = await _requestPermission();
      final isGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                       settings.authorizationStatus == AuthorizationStatus.provisional;
      
      if (!isGranted) {
        debugPrint('❌ System notification permission not granted');
        // Không cho phép bật nếu system permission bị denied
        return false;
      }
      
      _notificationsEnabled = true;
      await _storage.write(_notificationsEnabledKey, true);
      debugPrint('✅ Notifications enabled');
      return true;
    } else {
      // Khi TẮT: Chỉ tắt in-app notification
      _notificationsEnabled = false;
      await _storage.write(_notificationsEnabledKey, false);
      debugPrint('⚠️ Notifications disabled in app');
      return true;
    }
  }

  /// Load notification settings
  Future<void> _loadNotificationSettings() async {
    _notificationsEnabled = _storage.read(_notificationsEnabledKey) ?? true;
  }

  /// Refresh FCM token
  Future<void> refreshToken() async {
    await _getFCMToken();
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check APNS token status (iOS only)
  Future<bool> isAPNSTokenReady() async {
    if (!Platform.isIOS) return true;

    try {
      final apnsToken = await _messaging.getAPNSToken();
      return apnsToken != null;
    } catch (e) {
      debugPrint('Error checking APNS token: $e');
      return false;
    }
  }

  /// Get APNS token (iOS only)
  Future<String?> getAPNSToken() async {
    if (!Platform.isIOS) return null;

    try {
      return await _messaging.getAPNSToken();
    } catch (e) {
      debugPrint('Error getting APNS token: $e');
      return null;
    }
  }

  /// Check if notification permission is granted
  Future<bool> isPermissionGranted() async {
    final settings = await _messaging.getNotificationSettings();
    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint(
      '🔍 Permission check: ${settings.authorizationStatus} (granted: $isGranted)',
    );
    return isGranted;
  }

  /// Get detailed permission status
  Future<Map<String, dynamic>> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();

    return {
      'authorizationStatus': settings.authorizationStatus.toString(),
      'isGranted':
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional,
      'alert': settings.alert.toString(),
      'badge': settings.badge.toString(),
      'sound': settings.sound.toString(),
      'announcement': settings.announcement.toString(),
      'carPlay': settings.carPlay.toString(),
      'criticalAlert': settings.criticalAlert.toString(),
      'lockScreen': settings.lockScreen.toString(),
      'notificationCenter': settings.notificationCenter.toString(),
    };
  }

  /// Request permission again (useful if user denied initially)
  Future<bool> requestPermissionAgain() async {
    debugPrint('🔄 Requesting notification permission again...');
    final settings = await _requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
