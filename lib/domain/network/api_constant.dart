import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstant {
  // Tự động detect địa chỉ IP dựa trên platform
  // Android emulator: 10.0.2.2 trỏ về localhost của máy host
  // iOS simulator: localhost hoạt động bình thường
  // Web: localhost hoạt động bình thường
  // Thiết bị thật: Cần thay bằng IP của máy chạy server (ví dụ: 192.168.1.100)
  static String get _baseHost {
    if (kIsWeb) {
      // Web platform
      return 'localhost';
    } else if (Platform.isAndroid) {
      // Android emulator: dùng 10.0.2.2 để trỏ về localhost của máy host
      // Nếu là thiết bị thật, cần thay bằng IP của máy host
      return '10.59.91.142';
    } else if (Platform.isIOS) {
      // iOS simulator: localhost hoạt động bình thường
      return 'localhost';
    } else {
      // Desktop platforms
      return 'localhost';
    }
  }

  // Port của API server 
  // Server mặc định chạy port 4000 (theo main.ts: process.env.PORT ?? 4200)
  // Nếu server chạy port khác, sửa giá trị này hoặc set biến môi trường PORT
  static const int apiPort = 4000;
  static const int storagePort = 3005;

  static String get apiHost => "http://$_baseHost:$apiPort/";
  static String get apiHostStorage => "http://$_baseHost:$storagePort";
  static String get storageServiceUrl => "http://$_baseHost:$storagePort";
  static final login = "auth/login";
  static final register = "auth/register";
  static final verifyPin = "auth/verify-pin";
  static final resendPin = "auth/resend-pin";
  static final getUserInfo = "";
  
  // Book endpoints
  static final getBooksPublic =  "books/public";
  static final getBooks =  "books/search";
  static final addBook = "books";
  static final updateBook = "books";
  static final deleteBook = "books";
  static final toggleFavorite = "books/favorite";
  
  // Chapter endpoints
  static final getChapters = "books";
  
  // Bookmark endpoints
  static final getBookmarks = "bookmarks";
  static final addBookmark = "bookmarks";
  static final deleteBookmark = "bookmarks";
  
  // Reading progress endpoints
  static final saveReadingProgress = "reading-progress";
  static final getReadingProgress = "reading-progress";

  // Admin endpoints
  static final uploadEbook = "upload/ebook";
  static final uploadCover = "upload/image";
  static final getCategories = "categories";
  //upload medial
  static final uploadMedia = "media/upload";
}
