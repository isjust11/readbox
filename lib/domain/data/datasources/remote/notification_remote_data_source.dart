import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class NotificationRemoteDataSource {
  final Network network;

  NotificationRemoteDataSource({required this.network});

  /// Get list of notifications with pagination
  Future<Map<String, dynamic>> getNotifications({
    int? page,
    int? limit,
    int? isRead,
  }) async {
    Map<String, dynamic> params = {};
    if (page != null) params['page'] = page;
    if (limit != null) params['size'] = limit;
    if (isRead != null) params['isRead'] = isRead;

    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getNotifications}',
      params: params,
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data != null) {
        final data = apiResponse.data;
        final notifications = (data['items'] as List?)
                ?.map((item) =>
                    NotificationModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        
        final total = data['total'] ?? 0;
        final unreadCount = data['unreadCount'] ?? 0;
        
        return {
          'notifications': notifications,
          'total': total,
          'unreadCount': unreadCount,
        };
      } else {
        return {
          'notifications': <NotificationModel>[],
          'total': 0,
          'unreadCount': 0,
        };
      }
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Get notification by ID
  Future<NotificationModel> getNotificationById(String id) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getNotifications}/$id',
    );

    if (apiResponse.isSuccess) {
      return NotificationModel.fromJson(
          apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Mark notification as read
  Future<NotificationModel> markAsRead(String id) async {
    ApiResponse apiResponse = await network.put(
      url: '${ApiConstant.apiHost}${ApiConstant.markNotificationRead}/$id',
      body: {'isRead': true},
    );

    if (apiResponse.isSuccess) {
      return NotificationModel.fromJson(
          apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Mark notification as unread
  Future<NotificationModel> markAsUnread(String id) async {
    ApiResponse apiResponse = await network.patch(
      url: '${ApiConstant.apiHost}${ApiConstant.markNotificationRead}/$id',
      body: {'isRead': false},
    );

    if (apiResponse.isSuccess) {
      return NotificationModel.fromJson(
          apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.markAllNotificationsRead}',
      body: {},
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Delete notification
  Future<bool> deleteNotification(String id) async {
    ApiResponse apiResponse = await network.delete(
      url: '${ApiConstant.apiHost}${ApiConstant.deleteNotification}/$id',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.deleteAllNotifications}',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getNotificationUnreadCount}',
    );

    if (apiResponse.isSuccess) {
      return apiResponse.data ?? 0;
    }
    return Future.error(apiResponse.errMessage);
  }
}
