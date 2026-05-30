import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý lịch sử tìm kiếm
class SearchHistoryService {
  static const String _keySearchHistory = 'search_history';
  static const int _maxHistoryItems = 10; // Giới hạn 10 item gần nhất

  // Singleton pattern
  static final SearchHistoryService _instance = SearchHistoryService._internal();
  factory SearchHistoryService() => _instance;
  SearchHistoryService._internal();

  /// Lấy danh sách lịch sử tìm kiếm
  Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keySearchHistory);
      
      if (historyJson == null) return [];
      
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Thêm từ khóa tìm kiếm vào lịch sử
  Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = await getSearchHistory();
      
      // Xóa term cũ nếu có (để đưa lên đầu)
      history.remove(term.trim());
      
      // Thêm vào đầu danh sách
      history.insert(0, term.trim());
      
      // Giới hạn số lượng
      if (history.length > _maxHistoryItems) {
        history = history.take(_maxHistoryItems).toList();
      }
      
      // Lưu lại
      await prefs.setString(_keySearchHistory, json.encode(history));
    } catch (e) {
      // Ignore errors
    }
  }

  /// Xóa một item khỏi lịch sử
  Future<void> removeSearchTerm(String term) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = await getSearchHistory();
      
      history.remove(term);
      
      await prefs.setString(_keySearchHistory, json.encode(history));
    } catch (e) {
      // Ignore errors
    }
  }

  /// Xóa toàn bộ lịch sử
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySearchHistory);
    } catch (e) {
      // Ignore errors
    }
  }
}