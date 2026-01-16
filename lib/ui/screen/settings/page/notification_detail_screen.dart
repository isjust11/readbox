import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/services/notification_handler.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:readbox/utils/html_style_helper.dart';

// các thông báo hệ thống/feedback/new_article sẽ hiển thị ở đây
class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return NotificationDetailBody(notification: notification);
  }
}

class NotificationDetailBody extends StatelessWidget {
  final NotificationModel notification;
  const NotificationDetailBody({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: notification.displayTitle,
      colorTitle: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: _buildBody(context),
      colorBg: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          _buildTime(context),
          Html(
            data: notification.displayBody,
            style: HtmlStyleHelper.getNewsContentStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildTime(BuildContext context) {
    final notificationHandler = NotificationHandler();
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          notification.formattedDate,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.secondary),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }
}
