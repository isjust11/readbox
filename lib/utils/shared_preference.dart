import 'dart:convert';

import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SPrefCache {
  // share preference key
  static const String KEY_TOKEN = "auth_token";
  static const String PREF_KEY_LANGUAGE = "pref_key_language";
  static const String PREF_KEY_USER_INFO = "pref_key_user_info";
  static const String PREF_KEY_IS_KEEP_LOGIN = "pref_key_is_keep_login";
  static const String PREF_KEY_LOCAL_BOOKS = "pref_key_local_books";
  static const String PREF_KEY_REMEMBER_PASSWORD = "pref_key_remember_password";
}

class SharedPreferenceUtil {
  static Future saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.KEY_TOKEN, token);
  }

  static Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.KEY_TOKEN) ?? '';
  }

  static Future saveKeepLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SPrefCache.PREF_KEY_IS_KEEP_LOGIN, value);
  }

  static Future<bool> isKeepLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPrefCache.PREF_KEY_IS_KEEP_LOGIN) ?? false;
  }

  static Future<bool> saveUserInfo(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(SPrefCache.PREF_KEY_USER_INFO, json.encode(user.toJson()));
  }

  static Future<UserModel?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(SPrefCache.PREF_KEY_USER_INFO);
    if (data == null) {
      return null;
    }
    return UserModel.fromJson(json.decode(data));
  }

  static Future setCurrentLanguage(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SPrefCache.PREF_KEY_LANGUAGE, token);
  }

  static Future<String> getCurrentLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(SPrefCache.PREF_KEY_LANGUAGE) ??
        AppLocalizationDelegate().supportedLocales.first.languageCode;
  }

  static Future clearData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Local Books - lưu danh sách file paths
  static Future<bool> saveLocalBooks(List<String> filePaths) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(SPrefCache.PREF_KEY_LOCAL_BOOKS, filePaths);
  }

  static Future<List<String>> getLocalBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SPrefCache.PREF_KEY_LOCAL_BOOKS) ?? [];
  }

  static Future<bool> addLocalBook(String filePath) async {
    final books = await getLocalBooks();
    if (!books.contains(filePath)) {
      books.add(filePath);
      return await saveLocalBooks(books);
    }
    return false; // Already exists
  }

  static Future<bool> removeLocalBook(String filePath) async {
    final books = await getLocalBooks();
    books.remove(filePath);
    return await saveLocalBooks(books);
  }

  static Future<bool> isBookAdded(String filePath) async {
    final books = await getLocalBooks();
    return books.contains(filePath);
  }
  
  static Future setRememberPassword(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SPrefCache.PREF_KEY_REMEMBER_PASSWORD, value);
  }

  static Future<bool> getRememberPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SPrefCache.PREF_KEY_REMEMBER_PASSWORD) ?? false;
  }
}
