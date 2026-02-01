import 'dart:convert';

import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class để quản lý SharedPreferences
/// CHỈ LƯU DỮ LIỆU KHÔNG NHẠY CẢM (non-sensitive data)
/// 
/// Dữ liệu nhạy cảm (token, password, user info) được lưu trong SecureStorageService
class SPrefCache {
  // SharedPreferences keys - CHỈ cho dữ liệu không nhạy cảm
  static const String PREF_KEY_LANGUAGE = "pref_key_language";
  static const String PREF_KEY_IS_KEEP_LOGIN = "pref_key_is_keep_login";
  static const String PREF_KEY_LOCAL_BOOKS = "pref_key_local_books";
  static const String PREF_KEY_REMEMBER_PASSWORD = "pref_key_remember_password";
  static const String PREF_KEY_THEME = "pref_key_theme";
  // DEPRECATED - Đã chuyển sang SecureStorage
  @Deprecated('Use SecureStorageService.saveToken() instead')
  static const String KEY_TOKEN = "auth_token";
  @Deprecated('Use SecureStorageService.saveUserInfo() instead')
  static const String PREF_KEY_USER_INFO = "pref_key_user_info";
    static const String PREF_KEY_HIDE_NAVIGATION_BAR = "pref_key_hide_navigation_bar";
  static const String PREF_KEY_PDF_READING_POSITIONS = "pref_key_pdf_reading_positions";
  static const String PREF_KEY_PDF_DRAWINGS = "pref_key_pdf_drawings";
  static const String PREF_KEY_PDF_NOTES = "pref_key_pdf_notes";
}

class SharedPreferenceUtil {
  // ==================== APP PREFERENCES ====================
  
  /// Lưu trạng thái "Keep me logged in"
  static Future saveKeepLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SPrefCache.PREF_KEY_IS_KEEP_LOGIN, value);
  }

  /// Kiểm tra trạng thái "Keep me logged in"
  static Future<bool> isKeepLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPrefCache.PREF_KEY_IS_KEEP_LOGIN) ?? false;
  }

  // ==================== LANGUAGE SETTINGS ====================
  
  /// Lưu ngôn ngữ hiện tại
  static Future setCurrentLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.PREF_KEY_LANGUAGE, languageCode);
  }

  /// Lấy ngôn ngữ hiện tại
  static Future<String> getCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.PREF_KEY_LANGUAGE) ??
        AppLocalizationDelegate().supportedLocales.first.languageCode;
  }

  // ==================== PASSWORD SETTINGS ====================
  
  /// Lưu trạng thái "Remember password"
  static Future setRememberPassword(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SPrefCache.PREF_KEY_REMEMBER_PASSWORD, value);
  }

  /// Lấy trạng thái "Remember password"
  static Future<bool> getRememberPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPrefCache.PREF_KEY_REMEMBER_PASSWORD) ?? false;
  }

  // ==================== LOCAL BOOKS MANAGEMENT ====================
  
  /// Lưu danh sách file paths của sách local
  static Future<bool> saveLocalBooks(List<String> filePaths) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(SPrefCache.PREF_KEY_LOCAL_BOOKS, filePaths);
  }

  /// Lấy danh sách sách local
  static Future<List<String>> getLocalBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SPrefCache.PREF_KEY_LOCAL_BOOKS) ?? [];
  }

  /// Thêm một sách local
  static Future<bool> addLocalBook(String filePath) async {
    final books = await getLocalBooks();
    if (!books.contains(filePath)) {
      books.add(filePath);
      return await saveLocalBooks(books);
    }
    return false; // Already exists
  }

  static Future<bool> saveHideNavigationBar(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(SPrefCache.PREF_KEY_HIDE_NAVIGATION_BAR, value);
  }

  /// Lấy trạng thái "Hide navigation bar"
  static Future<bool> getHideNavigationBar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPrefCache.PREF_KEY_HIDE_NAVIGATION_BAR) ?? true;
  }

  // ==================== PDF READING POSITION ====================

  /// Lưu trang đang đọc của PDF (key thường là fileUrl hoặc đường dẫn file)
  static Future<bool> savePdfReadingPosition(String key, int page) async {
    if (key.isEmpty || page < 1) return false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_READING_POSITIONS);
    final Map<String, dynamic> map = json != null
        ? Map<String, dynamic>.from(jsonDecode(json) as Map)
        : {};
    map[key] = page;
    return prefs.setString(SPrefCache.PREF_KEY_PDF_READING_POSITIONS, jsonEncode(map));
  }

  /// Lưu nét vẽ trên PDF (key: fileUrl, value: Map<page, List<List<{x,y}>>>)
  static Future<bool> savePdfDrawings(
    String key,
    Map<String, dynamic> drawings,
  ) async {
    if (key.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_DRAWINGS);
    final map = json != null
        ? Map<String, dynamic>.from(jsonDecode(json) as Map)
        : <String, dynamic>{};
    map[key] = drawings;
    return prefs.setString(
      SPrefCache.PREF_KEY_PDF_DRAWINGS,
      jsonEncode(map),
    );
  }

  /// Lấy nét vẽ đã lưu
  static Future<Map<String, dynamic>?> getPdfDrawings(String key) async {
    if (key.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_DRAWINGS);
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>?;
    return map?[key] as Map<String, dynamic>?;
  }

  /// Lưu ghi chú PDF (key: fileUrl, value: List<{page, text, timestamp}>)
  static Future<bool> savePdfNotes(String key, List<Map<String, dynamic>> notes) async {
    if (key.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_NOTES);
    final map = json != null
        ? Map<String, dynamic>.from(jsonDecode(json) as Map)
        : <String, dynamic>{};
    map[key] = notes;
    return prefs.setString(
      SPrefCache.PREF_KEY_PDF_NOTES,
      jsonEncode(map),
    );
  }

  /// Lấy ghi chú đã lưu
  static Future<List<Map<String, dynamic>>> getPdfNotes(String key) async {
    if (key.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_NOTES);
    if (json == null) return [];
    final map = jsonDecode(json) as Map<String, dynamic>?;
    final list = map?[key];
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  /// Lấy trang đã lưu của PDF, trả về null nếu chưa có
  static Future<int?> getPdfReadingPosition(String key) async {
    if (key.isEmpty) return null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(SPrefCache.PREF_KEY_PDF_READING_POSITIONS);
    if (json == null) return null;
    final map = jsonDecode(json) as Map<String, dynamic>?;
    final v = map?[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  /// Xóa một sách local
  static Future<bool> removeLocalBook(String filePath) async {
    final books = await getLocalBooks();
    books.remove(filePath);
    return await saveLocalBooks(books);
  }

  /// Kiểm tra sách đã được thêm chưa
  static Future<bool> isBookAdded(String filePath) async {
    final books = await getLocalBooks();
    return books.contains(filePath);
  }

  // ==================== THEME SETTINGS ====================
  static Future<String> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.PREF_KEY_THEME) ?? 'light';
  }
  static Future<void> setTheme(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.PREF_KEY_THEME, theme);
  }

  // ==================== CLEAR DATA ====================
  
  /// Xóa tất cả dữ liệu trong SharedPreferences
  /// 
  /// LƯU Ý: Method này CHỈ xóa dữ liệu không nhạy cảm trong SharedPreferences
  /// Để xóa dữ liệu nhạy cảm (token, password, user info), sử dụng:
  /// ```dart
  /// await SecureStorageService().clearAllSecureData();
  /// ```
  static Future clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
