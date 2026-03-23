import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

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
    final id = data['id'] as String?;
    final type = data['type'] as String?;

    debugPrint('   ID: $id');
    debugPrint('   Type: $type');

    await _navigateToScreen(id, type, data);
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
    final data = jsonDecode(payload);
    final id = data['id'] as String?;
    final type = data['type'] as String?;
    await _navigateToScreen(id, type, data);
  }

  /// Navigate to specific screen based on notification data
  Future<void> _navigateToScreen(
    String? id,
    String? type,
    Map<String, dynamic> data,
  ) async {
    if (_context == null) {
      debugPrint('❌ Navigation context not set');
      return;
    }

    if (id == null) {
      debugPrint('⚠️ No screen specified in notification');
      return;
    }

    try {
      switch (type) {
        case 'ebook':
          // Navigate to book detail screen
          debugPrint('📖 Navigating to book detail: $id');
          Navigator.of(
            _context!,
          ).pushNamed(Routes.bookDetailScreen, arguments: id);
          break;

        case 'feedback':
          debugPrint('📚 Navigating to library');
          Navigator.of(_context!).pushNamed(Routes.feedbackScreen);
          break;

        case 'new_article':
          debugPrint('⚙️ Navigating to settings');
          Navigator.of(_context!).pushNamed(Routes.settingsScreen);
          break;

        case 'system':
          debugPrint('👤 Navigating to profile');
          Navigator.of(_context!).pushNamed(Routes.profileScreen);
          break;

        default:
          debugPrint('⚠️ Unknown type: $type');
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
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      action:
          onTap != null
              ? SnackBarAction(
                label: AppLocalizations.current.view,
                textColor: Colors.white,
                onPressed: onTap,
              )
              : null,
      backgroundColor: Theme.of(context).primaryColor,
    );

    AppSnackBar.show(context, message: body, snackBarType: SnackBarType.info);
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
      case 'payment':
        return Icons.payment;
      case 'interaction':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  /// Parse notification type and return appropriate color
  Color getNotificationColor(String? type) {
    switch (type) {
      case 'ebook':
        return Colors.blue;
      case 'feedback':
        return Colors.purple;
      case 'new_article':
        return Colors.orange;
      case 'system':
        return Colors.green;
      case 'announcement':
        return Colors.red;
      case 'payment':
        return Colors.amber;
      case 'interaction':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
