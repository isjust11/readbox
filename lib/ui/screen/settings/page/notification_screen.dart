import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/entities/entities.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/notification_handler.dart';
import 'package:readbox/ui/widget/base_html.dart';
import 'package:readbox/ui/widget/widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationBodyScreen();
  }
}

class NotificationBodyScreen extends StatefulWidget {
  const NotificationBodyScreen({super.key});

  @override
  State<NotificationBodyScreen> createState() => _NotificationBodyScreenState();
}

class _NotificationBodyScreenState extends State<NotificationBodyScreen> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  int _currentPage = 1;
  final int _pageSize = 20;
  final ValueNotifier<int> _filterReadNotifier = ValueNotifier<int>(2);
  late NotificationCubit _notificationCubit;
  @override
  void dispose() {
    _refreshController.dispose();
    _filterReadNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _notificationCubit = context.read<NotificationCubit>();
    _notificationCubit.getNotifications(
      page: 1,
      limit: _pageSize,
      isRead: _filterReadNotifier.value,
    );
  }

  void _onRefresh() async {
    _currentPage = 1;
    await _notificationCubit.refreshNotifications(
      page: _currentPage,
      limit: _pageSize,
      isRead: _filterReadNotifier.value,
    );
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    if (_notificationCubit.hasMore && !_notificationCubit.isLoadingMore) {
      _currentPage++;
      await _notificationCubit.getNotifications(
        page: _currentPage,
        limit: _pageSize,
        isRead: _filterReadNotifier.value,
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
          title: Center(
            child: Text(
              AppLocalizations.current.filter,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterItem(context, AppLocalizations.current.all, 2),
              _buildFilterItem(context, AppLocalizations.current.unread, 0),
              _buildFilterItem(context, AppLocalizations.current.read, 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterItem(BuildContext context, String title, int filterValue) {
    return ValueListenableBuilder<int?>(
      valueListenable: _filterReadNotifier,
      builder: (context, selectedValue, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Radio<int>(
              value: filterValue,
              groupValue: selectedValue,
              onChanged: (newValue) {
                _filterReadNotifier.value = newValue ?? 2;
                // Reload notifications with new filter
                _notificationCubit.refreshNotifications(
                  page: 1,
                  limit: _pageSize,
                  isRead: newValue,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseScreen(
      colorTitle: theme.colorScheme.surfaceContainerHighest,
      body: _buildBody(context),
      colorBg: Theme.of(context).colorScheme.surface,
      customAppBar: BaseAppBar(
        title: AppLocalizations.current.notifications,
        centerTitle: true,
        actions: _buildActions(context),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    return [
      IconButton(
        icon: Icon(Icons.filter_list, color: theme.colorScheme.onPrimary),
        onPressed: _showFilterDialog,
        tooltip: AppLocalizations.current.filter,
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, color: theme.colorScheme.onPrimary),
        onSelected: (value) {
          if (_notificationCubit.notifications.isEmpty) {
            return;
          }
          if (value == 'mark_all_read' && _notificationCubit.unreadCount > 0) {
            _notificationCubit.markAllAsRead();
          } else if (value == 'delete_all') {
            _notificationCubit.deleteAllNotifications();
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Text(AppLocalizations.current.markAllAsRead),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Text(AppLocalizations.current.deleteAll),
              ),
            ],
      ),
    ];
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<NotificationCubit, BaseState>(
      bloc: _notificationCubit,
      buildWhen: (previous, current) {
        // Rebuild when state type changes OR when state data changes
        return previous.runtimeType != current.runtimeType ||
            previous != current;
      },
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.data),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _onRefresh,
                  child: Text(AppLocalizations.current.try_again),
                ),
              ],
            ),
          );
        }

        final notifications = _notificationCubit.notifications;

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            if (_notificationCubit.unreadCount > 0)
              Container(
                padding: EdgeInsets.all(AppDimens.SIZE_12),
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${AppLocalizations.current.youHave} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      _notificationCubit.unreadCount.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.current.unreadNotifications,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: _notificationCubit.hasMore,
                onRefresh: _onRefresh,
                onLoading: _onLoadMore,
                child: ListView.separated(
                  itemCount: _notificationCubit.notifications.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = _notificationCubit.notifications[index];
                    return _buildNotificationItem(context, notification);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.current.noNotifications,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.current.youWillReceiveNotificationsHere,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
  ) {
    final notificationHandler = NotificationHandler();
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(notification.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                AppLocalizations.current.confirm,
                style: TextStyle(color: theme.colorScheme.onError),
              ),
              content: Text(
                AppLocalizations.current.areYouSureYouWantToDeleteNotification,
                style: TextStyle(color: theme.colorScheme.onError),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    AppLocalizations.current.cancel,
                    style: TextStyle(color: theme.colorScheme.onError),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    AppLocalizations.current.delete,
                    style: TextStyle(color: theme.colorScheme.onError),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<NotificationCubit>().deleteNotification(notification.id!);
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.notificationDeletedSuccessfully,
          snackBarType: SnackBarType.success,
        );
      },
      child: InkWell(
        onTap: () {
          // Mark as read
          if (notification.isUnread) {
            context.read<NotificationCubit>().markAsRead(notification.id!);
          }
          switch (notification.type) {
            case NotificationType.ebook:
              Navigator.pushNamed(
                context,
                Routes.bookDetailScreen,
                arguments: notification.metadata?['id'],
              );
              break;
            case NotificationType.feedback:
              Navigator.pushNamed(
                context,
                Routes.notificationDetailScreen,
                arguments: notification,
              );
              break;
            case NotificationType.new_article:
              break;
            case NotificationType.system:
              break;
            default:
              break;
          }
          // Handle navigation if needed
          // notificationHandler.handleNotificationTap(...);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: AppDimens.SIZE_16,
            horizontal: AppDimens.SIZE_12,
          ),
          decoration: BoxDecoration(
            color:
                notification.isUnread
                    ? theme.primaryColor.withValues(alpha: 0.05)
                    : theme.colorScheme.surfaceContainer,
            border: Border(
              bottom: BorderSide(color: theme.secondaryHeaderColor, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notificationHandler
                      .getNotificationColor(
                        notification.type?.toString().split('.').last,
                      )
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  notificationHandler.getNotificationIcon(
                    notification.type?.toString().split('.').last,
                  ),
                  color: notificationHandler.getNotificationColor(
                    notification.type?.toString().split('.').last,
                  ),
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
                          child: BaseHtml(html: notification.displayTitle),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: notificationHandler
                                .getNotificationColor(
                                  notification.type?.toString().split('.').last,
                                )
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            notification.typeDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              color: notificationHandler.getNotificationColor(
                                notification.type?.toString().split('.').last,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    BaseHtml(html: notification.displayBody),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
