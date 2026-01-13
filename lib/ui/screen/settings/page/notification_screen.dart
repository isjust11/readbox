import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/services/notification_handler.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.get<NotificationCubit>()..getNotifications(page: 1, limit: 20),
      child: const NotificationBodyScreen(),
    );
  }
}

class NotificationBodyScreen extends StatefulWidget {
  const NotificationBodyScreen({super.key});

  @override
  State<NotificationBodyScreen> createState() => _NotificationBodyScreenState();
}

class _NotificationBodyScreenState extends State<NotificationBodyScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  int _currentPage = 1;
  final int _pageSize = 20;
  bool? _filterRead; // null = all, true = read, false = unread

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    _currentPage = 1;
    await context.read<NotificationCubit>().refreshNotifications(
      page: _currentPage,
      limit: _pageSize,
      isRead: _filterRead,
    );
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    final cubit = context.read<NotificationCubit>();
    if (cubit.hasMore && !cubit.isLoadingMore) {
      _currentPage++;
      await cubit.getNotifications(
        page: _currentPage,
        limit: _pageSize,
        isRead: _filterRead,
        isLoadMore: true,
      );
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Lọc thông báo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Tất cả'),
                leading: Radio<bool?>(
                  value: null,
                  groupValue: _filterRead,
                  onChanged: (value) {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _filterRead = value;
                      _currentPage = 1;
                    });
                    context.read<NotificationCubit>().getNotifications(
                      page: _currentPage,
                      limit: _pageSize,
                      isRead: _filterRead,
                    );
                  },
                ),
              ),
              ListTile(
                title: const Text('Chưa đọc'),
                leading: Radio<bool?>(
                  value: false,
                  groupValue: _filterRead,
                  onChanged: (value) {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _filterRead = value;
                      _currentPage = 1;
                    });
                    context.read<NotificationCubit>().getNotifications(
                      page: _currentPage,
                      limit: _pageSize,
                      isRead: _filterRead,
                    );
                  },
                ),
              ),
              ListTile(
                title: const Text('Đã đọc'),
                leading: Radio<bool?>(
                  value: true,
                  groupValue: _filterRead,
                  onChanged: (value) {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _filterRead = value;
                      _currentPage = 1;
                    });
                    context.read<NotificationCubit>().getNotifications(
                      page: _currentPage,
                      limit: _pageSize,
                      isRead: _filterRead,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tất cả thông báo'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotificationCubit>().deleteAllNotifications();
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đánh dấu tất cả đã đọc'),
          content: const Text('Bạn có muốn đánh dấu tất cả thông báo là đã đọc?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotificationCubit>().markAllAsRead();
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Lọc',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _showMarkAllReadDialog();
              } else if (value == 'delete_all') {
                _showDeleteAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Đánh dấu tất cả đã đọc'),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Xóa tất cả'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, BaseState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.data),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final cubit = context.read<NotificationCubit>();
          final notifications = cubit.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              if (cubit.unreadCount > 0)
                Container(
                  padding: EdgeInsets.all(AppDimens.SIZE_12),
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bạn có ${cubit.unreadCount} thông báo chưa đọc',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  enablePullUp: cubit.hasMore,
                  onRefresh: _onRefresh,
                  onLoading: _onLoadMore,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.SIZE_8),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(context, notification);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn sẽ nhận được thông báo ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    final notificationHandler = NotificationHandler();
    
    return Dismissible(
      key: Key(notification.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Bạn có muốn xóa thông báo này?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<NotificationCubit>().deleteNotification(notification.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thông báo')),
        );
      },
      child: InkWell(
        onTap: () {
          // Mark as read
          if (notification.isUnread) {
            context.read<NotificationCubit>().markAsRead(notification.id!);
          }
          
          // Handle navigation if needed
          // notificationHandler.handleNotificationTap(...);
        },
        child: Container(
          color: notification.isUnread 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) 
              : Colors.transparent,
          padding: EdgeInsets.all(AppDimens.SIZE_16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notificationHandler.getNotificationColor(notification.type?.toString().split('.').last).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  notificationHandler.getNotificationIcon(notification.type?.toString().split('.').last),
                  color: notificationHandler.getNotificationColor(notification.type?.toString().split('.').last),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.displayTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.displayBody,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: notificationHandler.getNotificationColor(notification.type?.toString().split('.').last).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.typeDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              color: notificationHandler.getNotificationColor(notification.type?.toString().split('.').last),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // More options
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'mark_read') {
                    if (notification.isUnread) {
                      context.read<NotificationCubit>().markAsRead(notification.id!);
                    } else {
                      context.read<NotificationCubit>().markAsUnread(notification.id!);
                    }
                  } else if (value == 'delete') {
                    context.read<NotificationCubit>().deleteNotification(notification.id!);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Text(notification.isUnread ? 'Đánh dấu đã đọc' : 'Đánh dấu chưa đọc'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
