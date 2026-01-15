import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/entities/notification_entity.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class NotificationCubit extends Cubit<BaseState> {
  final NotificationRepository notificationRepository;

  NotificationCubit({
    required this.notificationRepository,
  }) : super(InitState());

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  
  int _totalCount = 0;
  int get totalCount => _totalCount;
  
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  
  int? _currentFilter; // 2 = all, 1 = read, 0 = unread

  Future<void> getNotifications({
    int? page,
    int? limit,
    int? isRead,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(LoadingState());
        _notifications = [];
        _hasMore = true;
        _currentFilter = isRead ?? 2;
      } else {
        _isLoadingMore = true;
      }

      final result = await notificationRepository.getNotifications(
        page: page,
        limit: limit,
        isRead: isRead,
      );

      final newNotifications = result['notifications'] as List<NotificationModel>;
      _totalCount = result['total'] as int;
      _unreadCount = result['unreadCount'] as int;

      if (isLoadMore) {
        _notifications.addAll(newNotifications);
        _hasMore = newNotifications.length >= (limit ?? 10);
        _isLoadingMore = false;
      } else {
        _notifications = newNotifications;
        _hasMore = newNotifications.length >= (limit ?? 10);
      }

      emit(LoadedState(List.from(_notifications)));
    } catch (e) {
      _isLoadingMore = false;
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> refreshNotifications({
    int? page,
    int? limit,
    int? isRead,
  }) async {
    await getNotifications(
      page: page ?? 1,
      limit: limit,
      isRead: isRead ?? _currentFilter,
      isLoadMore: false,
    );
  }

  Future<void> markAsRead(String id) async {
    try {
      final updatedNotification = await notificationRepository.markAsRead(id);
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        emit(LoadedState(List.from(_notifications), timeEmit: DateTime.now().millisecondsSinceEpoch));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> markAsUnread(String id) async {
    try {
      final updatedNotification = await notificationRepository.markAsUnread(id);
      
      // Update local list
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updatedNotification;
        _unreadCount = _unreadCount + 1;
        emit(LoadedState(List.from(_notifications), timeEmit: DateTime.now().millisecondsSinceEpoch));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      emit(LoadingState());
      await notificationRepository.markAllAsRead();
      
      // Update all notifications in local list to read
      for (var notification in _notifications) {
        notification.status = NotificationStatus.READ;
      }
      _unreadCount = 0;
      
      emit(LoadedState(List.from(_notifications)));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await notificationRepository.deleteNotification(id);
      
      // Remove from local list
      final notification = _notifications.firstWhere((n) => n.id == id);
      _notifications.removeWhere((n) => n.id == id);
      
      // Update unread count if deleted notification was unread
      if (notification.isUnread) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
      
      emit(LoadedState(List.from(_notifications), timeEmit: DateTime.now().millisecondsSinceEpoch));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      emit(LoadingState());
      await notificationRepository.deleteAllNotifications();
      
      _notifications = [];
      _unreadCount = 0;
      _totalCount = 0;
      
      emit(LoadedState([]));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> updateUnreadCount() async {
    try {
      _unreadCount = await notificationRepository.getUnreadCount();
      // Don't emit state, just update the count
    } catch (e) {
      // Silently fail, not critical
    }
  }
}
