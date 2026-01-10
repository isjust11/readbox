import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/routes.dart';

/// Handles notification navigation and actions
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();
  factory NotificationHandler() => _instance;
  NotificationHandler._internal();

  BuildContext? _context;
  
  /// Set the navigation context
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Handle notification tap when app is opened
  Future<void> handleNotificationTap(RemoteMessage message) async {
    debugPrint('🔔 Handling notification tap...');
    debugPrint('   Message ID: ${message.messageId}');
    debugPrint('   Data: ${message.data}');

    final data = message.data;
    if (data.isEmpty) {
      debugPrint('⚠️ No data in notification');
      return;
    }

    // Extract navigation info from data
    final screen = data['screen'] as String?;
    final id = data['id'] as String?;
    final type = data['type'] as String?;

    debugPrint('   Screen: $screen');
    debugPrint('   ID: $id');
    debugPrint('   Type: $type');

    await _navigateToScreen(screen, id, type, data);
  }

  /// Handle foreground notification tap
  Future<void> handleForegroundNotificationTap(String? payload) async {
    if (payload == null || payload.isEmpty) {
      debugPrint('⚠️ No payload in foreground notification');
      return;
    }

    debugPrint('🔔 Handling foreground notification tap: $payload');
    
    // Parse payload if it's JSON
    // For now, just log it
  }

  /// Navigate to specific screen based on notification data
  Future<void> _navigateToScreen(
    String? screen,
    String? id,
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (_context == null) {
      debugPrint('❌ Navigation context not set');
      return;
    }

    if (screen == null) {
      debugPrint('⚠️ No screen specified in notification');
      return;
    }

    debugPrint('🚀 Navigating to screen: $screen');

    try {
      switch (screen) {
        case 'book_detail':
          if (id != null) {
            // Navigate to book detail screen
            // Need to fetch book data first
            debugPrint('📖 Navigating to book detail: $id');
            // Navigator.of(_context!).pushNamed(
            //   Routes.bookDetailScreen,
            //   arguments: bookModel,
            // );
          }
          break;

        case 'library':
          debugPrint('📚 Navigating to library');
          Navigator.of(_context!).pushNamed(Routes.libraryScreen);
          break;

        case 'settings':
          debugPrint('⚙️ Navigating to settings');
          Navigator.of(_context!).pushNamed(Routes.settingsScreen);
          break;

        case 'profile':
          debugPrint('👤 Navigating to profile');
          Navigator.of(_context!).pushNamed(Routes.profileScreen);
          break;

        case 'main':
          debugPrint('🏠 Navigating to main screen');
          Navigator.of(_context!).pushNamedAndRemoveUntil(
            Routes.mainScreen,
            (route) => false,
          );
          break;

        case 'pdf_viewer':
          if (data.containsKey('fileUrl') && data.containsKey('title')) {
            debugPrint('📄 Navigating to PDF viewer');
            Navigator.of(_context!).pushNamed(
              Routes.pdfViewerScreen,
              arguments: {
                'fileUrl': data['fileUrl'],
                'title': data['title'],
              },
            );
          }
          break;

        case 'notification_settings':
          debugPrint('🔔 Navigating to notification settings');
          Navigator.of(_context!).pushNamed(Routes.notificationSettingsScreen);
          break;

        default:
          debugPrint('⚠️ Unknown screen: $screen');
          // Navigate to main screen as fallback
          Navigator.of(_context!).pushNamedAndRemoveUntil(
            Routes.mainScreen,
            (route) => false,
          );
      }
    } catch (e) {
      debugPrint('❌ Error navigating to screen: $e');
    }
  }

  /// Show in-app notification banner (for foreground notifications)
  void showInAppNotification(
    BuildContext context,
    String title,
    String body, {
    VoidCallback? onTap,
  }) {
    final snackBar = SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      action: onTap != null
          ? SnackBarAction(
              label: 'Xem',
              textColor: Colors.white,
              onPressed: onTap,
            )
          : null,
      backgroundColor: Theme.of(context).primaryColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Parse notification type and return appropriate icon
  IconData getNotificationIcon(String? type) {
    switch (type) {
      case 'book':
        return Icons.book;
      case 'library':
        return Icons.library_books;
      case 'reminder':
        return Icons.alarm;
      case 'update':
        return Icons.system_update;
      case 'message':
        return Icons.message;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  /// Parse notification type and return appropriate color
  Color getNotificationColor(String? type) {
    switch (type) {
      case 'book':
        return Colors.blue;
      case 'library':
        return Colors.purple;
      case 'reminder':
        return Colors.orange;
      case 'update':
        return Colors.green;
      case 'message':
        return Colors.teal;
      case 'announcement':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
