import 'package:readbox/domain/data/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  // Helper methods
  String get displayTitle => title ?? 'Thông báo';
  String get displayBody => message ?? body ?? 'Không có nội dung';

  String get formattedDate {
    if (createdAt == null) return '';
    
    final now = DateTime.now();
    // Tính từ 0h của mỗi ngày
    final todayStart = DateTime(now.year, now.month, now.day);
    final createdAtStart = DateTime(createdAt!.year, createdAt!.month, createdAt!.day);
    final difference = todayStart.difference(createdAtStart).inDays;
    
    if (difference == 0) {
      // Today
      final hour = createdAt!.hour.toString().padLeft(2, '0');
      final minute = createdAt!.minute.toString().padLeft(2, '0');
      return 'Hôm nay, $hour:$minute';
    } else if (difference == 1) {
      // Yesterday
      final hour = createdAt!.hour.toString().padLeft(2, '0');
      final minute = createdAt!.minute.toString().padLeft(2, '0');
      return 'Hôm qua, $hour:$minute';
    } else if (difference < 7) {
      // Within a week
      final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
      final weekday = weekdays[createdAt!.weekday % 7];
      final hour = createdAt!.hour.toString().padLeft(2, '0');
      final minute = createdAt!.minute.toString().padLeft(2, '0');
      return '$weekday, $hour:$minute';
    } else {
      // Older
      final day = createdAt!.day.toString().padLeft(2, '0');
      final month = createdAt!.month.toString().padLeft(2, '0');
      final year = createdAt!.year;
      return '$day/$month/$year';
    }
  }

  bool get isUnread => status == NotificationStatus.UNREAD;

  String get typeDisplay {
    switch (type) {
      case NotificationType.ebook:
        return 'Ebook';
      case NotificationType.feedback:
        return 'Phản hồi';
      case NotificationType.new_article:
        return 'Bài viết mới';
      case NotificationType.system:
        return 'Hệ thống';
      default:
        return 'Khác';
    }
  }
}
