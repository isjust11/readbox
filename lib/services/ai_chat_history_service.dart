import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model một tin nhắn chat được lưu trữ
class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
  );
}

/// Service lưu/tải lịch sử hội thoại AI theo từng ebook
class AiChatHistoryService {
  static const String _keyPrefix = 'ai_chat_history_';
  static const int _maxMessages = 100; // Giới hạn 100 tin nhắn mỗi ebook

  // Singleton
  static final AiChatHistoryService _instance =
      AiChatHistoryService._internal();
  factory AiChatHistoryService() => _instance;
  AiChatHistoryService._internal();

  String _key(String ebookId) => '$_keyPrefix$ebookId';

  /// Tải lịch sử chat của một ebook
  Future<List<AiChatMessage>> loadHistory(String ebookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(ebookId));
      if (raw == null) return [];
      final List<dynamic> list = json.decode(raw);
      return list
          .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Lưu toàn bộ danh sách tin nhắn
  Future<void> saveHistory(String ebookId, List<AiChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Giữ tối đa _maxMessages tin nhắn gần nhất
      final limited =
          messages.length > _maxMessages
              ? messages.sublist(messages.length - _maxMessages)
              : messages;
      await prefs.setString(
        _key(ebookId),
        json.encode(limited.map((m) => m.toJson()).toList()),
      );
    } catch (_) {
      // Ignore
    }
  }

  /// Xoá lịch sử của một ebook
  Future<void> clearHistory(String ebookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(ebookId));
    } catch (_) {
      // Ignore
    }
  }
}
