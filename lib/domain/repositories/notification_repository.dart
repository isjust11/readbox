import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class NotificationRepository{
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    int? isRead,
  }) async {
    try {
      return await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
        isRead: isRead ?? 2,
      );
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<NotificationModel> getNotificationById(String id) async {
    try {
      return await remoteDataSource.getNotificationById(id);
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  Future<NotificationModel> markAsRead(String id) async {
    try {
      return await remoteDataSource.markAsRead(id);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<NotificationModel> markAsUnread(String id) async {
    try {
      return await remoteDataSource.markAsUnread(id);
    } catch (e) {
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      return await remoteDataSource.markAllAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<bool> deleteNotification(String id) async {
    try {
      return await remoteDataSource.deleteNotification(id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<bool> deleteAllNotifications() async {
    try {
      return await remoteDataSource.deleteAllNotifications();
    } catch (e) {
      throw Exception('Failed to delete all notifications: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      return await remoteDataSource.getUnreadCount();
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }
}
