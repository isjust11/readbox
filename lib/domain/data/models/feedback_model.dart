enum FeedbackType {
  general,
  bug,
  feature,
  improvement,
  other;

  String get displayName {
    switch (this) {
      case FeedbackType.general:
        return 'Chung';
      case FeedbackType.bug:
        return 'Lỗi';
      case FeedbackType.feature:
        return 'Tính năng mới';
      case FeedbackType.improvement:
        return 'Cải thiện';
      case FeedbackType.other:
        return 'Khác';
    }
  }
}

enum FeedbackPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case FeedbackPriority.low:
        return 'Thấp';
      case FeedbackPriority.medium:
        return 'Trung bình';
      case FeedbackPriority.high:
        return 'Cao';
      case FeedbackPriority.urgent:
        return 'Khẩn cấp';
    }
  }
}

class FeedbackModel {
  final String title;
  final String content;
  final FeedbackType type;
  final FeedbackPriority priority;
  final String? email;
  final String? phone;
  final String? name;
  final String? deviceInfo;
  final String? appVersion;
  final String? osVersion;
  final bool isAnonymous;

  FeedbackModel({
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    this.email,
    this.phone,
    this.name,
    this.deviceInfo,
    this.appVersion,
    this.osVersion,
    this.isAnonymous = false,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json){
    return FeedbackModel(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: FeedbackType.values.byName(json['type'] ?? ''),
      priority: FeedbackPriority.values.byName(json['priority'] ?? ''),
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      deviceInfo: json['deviceInfo'] ?? '',
      appVersion: json['appVersion'] ?? '',
      osVersion: json['osVersion'] ?? '',
      isAnonymous: json['isAnonymous'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'type': type.name,
      'priority': priority.name,
      'email': email,
      'phone': phone,
      'name': name,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'osVersion': osVersion,
      'isAnonymous': isAnonymous,
    };
  }
}
