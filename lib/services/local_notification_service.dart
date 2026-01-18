import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:readbox/ui/widget/base_html.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:readbox/services/notification_handler.dart';

/// Service for handling local notifications (scheduled, reminders, etc.)
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification channels
  static const String _defaultChannelId = 'readbox_default';
  static const String _defaultChannelName = 'ReadBox Notifications';
  static const String _defaultChannelDescription =
      'General notifications from ReadBox app';

  static const String _reminderChannelId = 'readbox_reminders';
  static const String _reminderChannelName = 'Reading Reminders';
  static const String _reminderChannelDescription =
      'Reminders to read your books';

  static const String _updateChannelId = 'readbox_updates';
  static const String _updateChannelName = 'App Updates';
  static const String _updateChannelDescription =
      'Updates and new features notifications';

  bool get isInitialized => _isInitialized;

  /// Initialize local notifications
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ Local notifications already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

      // Initialize settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      _isInitialized = true;
      debugPrint('✅ Local notifications initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing local notifications: $e');
      _isInitialized = false;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    // Default channel
    const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
      _defaultChannelId,
      _defaultChannelName,
      description: _defaultChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Reminder channel
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      _reminderChannelName,
      description: _reminderChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    // Update channel
    const AndroidNotificationChannel updateChannel = AndroidNotificationChannel(
      _updateChannelId,
      _updateChannelName,
      description: _updateChannelDescription,
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await androidImplementation.createNotificationChannel(defaultChannel);
    await androidImplementation.createNotificationChannel(reminderChannel);
    await androidImplementation.createNotificationChannel(updateChannel);

    debugPrint('✅ Android notification channels created');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Local notification tapped');
    debugPrint('   ID: ${response.id}');
    debugPrint('   Payload: ${response.payload}');

    if (response.payload != null) {
      NotificationHandler().handleForegroundNotificationTap(response.payload);
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.defaultChannel,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
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
      final unescapedTitle = BaseHtml(html: title );
      final unescapedBody = BaseHtml(html: body);
      await _notifications.show(id, unescapedTitle.toString(), unescapedBody.toString(), details, payload: payload);
      debugPrint('✅ Notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  /// Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationChannel channel = NotificationChannel.reminder,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final channelId = _getChannelId(channel);
    final channelName = _getChannelName(channel);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('✅ Notification scheduled: $title at $scheduledDate');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  /// Schedule daily reading reminder
  Future<void> scheduleDailyReadingReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time is in the past, schedule for next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
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
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
      debugPrint(
        '✅ Daily reminder scheduled: $title at $hour:${minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling daily reminder: $e');
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('✅ Notification cancelled: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('✅ All notifications cancelled');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Get channel ID based on channel type
  String _getChannelId(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.defaultChannel:
        return _defaultChannelId;
      case NotificationChannel.reminder:
        return _reminderChannelId;
      case NotificationChannel.update:
        return _updateChannelId;
    }
  }

  /// Get channel name based on channel type
  String _getChannelName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.defaultChannel:
        return _defaultChannelName;
      case NotificationChannel.reminder:
        return _reminderChannelName;
      case NotificationChannel.update:
        return _updateChannelName;
    }
  }

  /// Show book reading reminder
  Future<void> showReadingReminder(String bookTitle) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '📖 Đã đến giờ đọc sách!',
      body: 'Đã đến lúc tiếp tục đọc "$bookTitle"',
      payload: 'reminder:reading',
      channel: NotificationChannel.reminder,
    );
  }

  /// Show book completion notification
  Future<void> showBookCompletionNotification(String bookTitle) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '🎉 Chúc mừng!',
      body: 'Bạn đã hoàn thành "$bookTitle"',
      payload: 'completion:$bookTitle',
    );
  }

  /// Show new book notification
  Future<void> showNewBookNotification(String bookTitle, String author) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '📚 Sách mới đã được thêm!',
      body: '"$bookTitle" của $author đã có trong thư viện',
      payload: 'new_book:$bookTitle',
    );
  }
}

/// Notification channel types
enum NotificationChannel {
  defaultChannel,
  reminder,
  update,
}
