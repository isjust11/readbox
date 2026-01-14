import 'base_entity.dart';

enum NotificationType {
  book,
  library,
  reminder,
  update,
  message,
  announcement,
  system,
  other
}

enum NotificationStatus {
  read,
  unread,
}

class NotificationEntity extends BaseEntity {
  String? id;
  String? title;
  String? body;
  String? message;
  NotificationType? type;
  Map<String, dynamic>? data;
  NotificationStatus? status;
  DateTime? sentAt;
  DateTime? createdAt;
  DateTime? readAt;
  String? userId;
  String? imageUrl;
  String? actionUrl;
  Map<String, dynamic>? metadata;

  NotificationEntity({
    this.id,
    this.title,
    this.body,
    this.message,
    this.type,
    this.data,
    this.status,
    this.sentAt,
    this.createdAt,
    this.readAt,
    this.userId,
    this.imageUrl,
    this.actionUrl,
    this.metadata,
  });

  NotificationEntity.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title'];
    body = json['content'];
    message = json['message'] ?? json['content'];
    type = _parseNotificationType(json['type']);
    data = json['data'] != null
        ? Map<String, dynamic>.from(json['data'])
        : null;
    status = json['status'] != null
        ? NotificationStatus.values.firstWhere(
            (e) => e.toString() == 'NotificationStatus.${json['status']}',
            orElse: () => NotificationStatus.unread,
          )
        : NotificationStatus.unread;
    sentAt = json['sentAt'] != null
        ? DateTime.parse(json['sentAt'])
        : null;
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    readAt = json['readAt'] != null 
        ? DateTime.parse(json['readAt']) 
        : null;
    userId = json['userId']?.toString();
    imageUrl = json['imageUrl'];
    actionUrl = json['actionUrl'];
    metadata = json['metadata'] != null
        ? Map<String, dynamic>.from(json['metadata'])
        : null;
  }

  NotificationType _parseNotificationType(dynamic typeValue) {
    if (typeValue == null) return NotificationType.other;
    
    final typeString = typeValue.toString().toLowerCase();
    
    switch (typeString) {
      case 'book':
        return NotificationType.book;
      case 'library':
        return NotificationType.library;
      case 'reminder':
        return NotificationType.reminder;
      case 'update':
        return NotificationType.update;
      case 'message':
        return NotificationType.message;
      case 'announcement':
        return NotificationType.announcement;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.other;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['id'] = id;
    jsonData['title'] = title;
    jsonData['body'] = body;
    jsonData['message'] = message;
    jsonData['type'] = type?.toString().split('.').last;
    jsonData['data'] = data;
    jsonData['status'] = status?.toString().split('.').last;
    jsonData['createdAt'] = createdAt?.toIso8601String();
    jsonData['readAt'] = readAt?.toIso8601String();
    jsonData['userId'] = userId;
    jsonData['imageUrl'] = imageUrl;
    jsonData['actionUrl'] = actionUrl;
    jsonData['metadata'] = metadata;
    return jsonData;
  }
}
