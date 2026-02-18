import 'base_entity.dart';

enum NotificationType {
  ebook,
  feedback,
  new_article,
  system,
}

enum NotificationStatus {
  READ,
  UNREAD,
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
  String? metadata;

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
            orElse: () => NotificationStatus.UNREAD,
          )
        : NotificationStatus.UNREAD;
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
    metadata = json['metadata'];
  }

  NotificationType _parseNotificationType(dynamic typeValue) {
    if (typeValue == null) return NotificationType.system;
    
    final typeString = typeValue.toString().toLowerCase();
    
    switch (typeString) {
      case 'ebook':
        return NotificationType.ebook;
      case 'feedback':
        return NotificationType.feedback;
      case 'reminder':
        return NotificationType.new_article;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
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
