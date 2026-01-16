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
  static String get storageHost => "http://$_baseHost:$storagePort";
  static final login = "auth/login";
  static final register = "auth/register";
  static final verifyPin = "auth/verify-pin";
  static final resendPin = "auth/resend-pin";
  static final getUserInfo = "";
  static final mobileSocialLogin = "auth/mobile/social-login";
  static final registerFcmToken = "fcm-tokens/register";
  static final updateProfile = "auth/update-profile";
  static final refreshToken = "auth/refresh-token";
  static final forgotPassword = "auth/forgot-password";
  static final getMedia = "media";
  static final getPage = "pages";
  // Book endpoints
  static final getBooksPublic =  "books/public";
  static final getBookById = "books";
  static final addBook = "books";
  static final updateBook = "books";
  static final deleteBook = "books";
  static final toggleFavorite = "user-interactions/toggle-favorite";
  static final getFavorite = "books/favorite";
  static final getUnfavorite = "books/unfavorite";
  static final getView = "books/view";
  static final getBookmark = "books/bookmark";
  static final getUnbookmark = "books/unbookmark";
  static final getRead = "books/read";
  static final getUnread = "books/unread";
  static final getSave = "books/save";
  static final getUnsave = "books/unsave";
  static final getInteractionStatus = "user-interactions/status";
  static final getInteractionStats = "user-interactions/stats";

  static final getMyInteractions = "books/my-interactions";
  static final interactionAction = "user-interactions/action/";
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
  static final createFeedback = "feedback";
  
  // Notification endpoints
  static final getNotifications = "notifications";
  static final markNotificationRead = "notifications/mark-read";
  static final markAllNotificationsRead = "notifications/read-all";
  static final deleteNotification = "notifications";
  static final deleteAllNotifications = "notifications/delete-all";
  static final getNotificationUnreadCount = "notifications/unread-count";
}
