import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:readbox/utils/shared_preference.dart';

/// Service nhận và xử lý Universal Links / App Links
/// URL pattern: https://readbox.pro.vn/book/{bookId}
///
/// Phân biệt rõ 2 trường hợp:
/// - Cold Start (getInitialLink): chỉ lưu bookId, KHÔNG navigate.
///   SplashScreen → MainScreen → DiscoverScreen sẽ đọc và xử lý.
/// - Warm/Hot Start (uriLinkStream): navigate ngay lập tức.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  Future<void> initialize() async {
    // ── Cold Start ──────────────────────────────────────────────────────────
    // App được khởi động lần đầu bởi deeplink (user nhấn link khi app đang tắt)
    // Chỉ lưu bookId vào SharedPreferences, KHÔNG navigate.
    // SplashScreen sẽ chạy _prepareNavigation → mainScreen → DiscoverScreen
    // → navigateToBookFromDeeplink() sẽ bắt bookId và push bookDetail.
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        final bookId = _extractBookId(initialLink);
        if (bookId != null) {
          await SharedPreferenceUtil.saveDeepLinkId(bookId);
          // Không gọi _navigateToBook ở đây để tránh double-navigation
          // với luồng Splash → DiscoverScreen
        }
      }
    } catch (_) {}

    // ── Warm / Hot Start ────────────────────────────────────────────────────
    // App đang chạy (foreground hoặc background) → deeplink đến
    // Thực hiện navigate ngay lập tức
    _appLinks.uriLinkStream.listen(
      (uri) {
        final bookId = _extractBookId(uri);
        if (bookId != null) {
          _navigateToBook(bookId);
        }
      },
      onError: (_) {},
    );
  }

  /// Trích xuất bookId từ URI.
  /// Trả về null nếu URI không khớp với bất kỳ pattern nào.
  String? _extractBookId(Uri uri) {
    // Universal/App link: https://readbox.pro.vn/book/{bookId}
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == 'readbox.pro.vn' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'book') {
      final id = uri.pathSegments[1];
      return id.isNotEmpty ? id : null;
    }
    // Custom scheme: readbox://book/{bookId}
    if (uri.scheme == 'readbox' &&
        uri.host == 'book' &&
        uri.pathSegments.isNotEmpty) {
      final id = uri.pathSegments[0];
      return id.isNotEmpty ? id : null;
    }
    return null;
  }

  /// Xử lý deeplink trong Warm/Hot Start: navigate ngay lập tức.
  void _navigateToBook(String bookId) async {
    // Lưu bookId — "nguồn sự thật" duy nhất
    await SharedPreferenceUtil.saveDeepLinkId(bookId);

    // Dùng addPostFrameCallback để đảm bảo frame hiện tại đã render xong
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final navigator = NavigationService.instance.navigatorKey.currentState;
      if (navigator == null) return;

      // Kiểm tra token
      final token = await SecureStorageService().getToken();

      if (token == null || token.isEmpty) {
        // ── Chưa đăng nhập ────────────────────────────────────────────────
        // deepLinkId đã lưu; navigate về LoginScreen.
        // Sau khi login, LoginScreen navigate tới mainScreen,
        // DiscoverScreen.navigateToBookFromDeeplink() sẽ bắt deepLinkId.
        navigator.pushNamedAndRemoveUntil(
          Routes.loginScreen,
          (route) => false,
        );
        return;
      }

      // ── Đã đăng nhập ──────────────────────────────────────────────────────
      // deepLinkId đã được lưu ở trên; navigate về mainScreen.
      // DiscoverScreen.navigateToBookFromDeeplink() trong initState sẽ
      // đọc deepLinkId và push bookDetailScreen.
      navigator.pushNamedAndRemoveUntil(
        Routes.mainScreen,
        (route) => false,
      );
    });
  }
}
