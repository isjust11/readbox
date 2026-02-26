import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstant {
  /// Giá trị mặc định theo platform khi không cấu hình trong .env
  static String get _platformDefaultHost {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator → host
    if (Platform.isIOS) return 'localhost';
    return 'localhost';
  }

  /// Host API: đọc từ .env (API_BASE_HOST), không có thì dùng _platformDefaultHost
  static String get _baseHost {
    return dotenv.get('API_BASE_HOST', fallback: _platformDefaultHost).trim();
  }

  /// Port API: đọc từ .env (API_PORT), mặc định 4000
  static int get apiPort {
    final v = dotenv.get('API_PORT', fallback: '4000').trim();
    return int.tryParse(v) ?? 4000;
  }

  /// Port Storage: đọc từ .env (STORAGE_PORT), mặc định 3005
  static int get storagePort {
    final v = dotenv.get('STORAGE_PORT', fallback: '3005').trim();
    return int.tryParse(v) ?? 3005;
  }

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
  static final books = "books";
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

  static final getMyInteractions = "user-interactions/my-interactions";
  static final interactionAction = "user-interactions/action";
  static final loadInteraction = "user-interactions/load-interaction";
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
  
  // Converter endpoints
  static final converterWordToPdf = "converter/word-to-pdf";
  static final converterWordToPdfPublic = "converter/word-to-pdf-public";
  
  //upload medial
  static final uploadMedia = "media/upload";
  static final createFeedback = "feedback";

  static final getCategoriesByCategoryTypeCode = "categories/get-by-category-type";
  
  // Notification endpoints
  static final getNotifications = "notifications";
  static final markNotificationRead = "notifications/mark-read";
  static final markAllNotificationsRead = "notifications/read-all";
  static final deleteNotification = "notifications";
  static final deleteAllNotifications = "notifications/delete-all";
  static final getNotificationUnreadCount = "notifications/unread-count";

  // Subscription / Payment
  static final subscriptionPlans = "subscription-plans";
  static final subscriptionMe = "subscription/me";
  static final subscriptionHistory = "subscription/history";
}
