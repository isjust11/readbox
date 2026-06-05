import 'package:app_links/app_links.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:readbox/utils/shared_preference.dart';

/// Service nhận và xử lý Universal Links / App Links
/// URL pattern: https://readbox.pro.vn/book/{encodedBookId}
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();

  Future<void> initialize() async {
    // Cold start: app được mở lần đầu bởi link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (_) {}

    // Hot/warm start: app đang chạy hoặc ở background
    _appLinks.uriLinkStream.listen(_handleLink, onError: (_) {});
  }

  void _handleLink(Uri uri) {
    // Universal/App link: https://readbox.pro.vn/book/{bookId}
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host == 'readbox.pro.vn' &&
        uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments[0] == 'book' && uri.pathSegments.length >= 2) {
        final bookId = uri.pathSegments[1];
        if (bookId.isNotEmpty) {
          _navigateToBook(bookId);
        }
      }
    }
    // Custom scheme: readbox://book/{bookId}
    else if (uri.scheme == 'readbox' && uri.host == 'book') {
      if (uri.pathSegments.isNotEmpty) {
        final bookId = uri.pathSegments[0];
        if (bookId.isNotEmpty) {
          _navigateToBook(bookId);
        }
      }
    }
  }

  void _navigateToBook(String bookId) async {
    final token = await SecureStorageService().getToken();
    if (token == null || token.isEmpty) {
      final navigator = NavigationService.instance.navigatorKey.currentState;
      if (navigator == null) return;
      // Nếu đang ở màn hình chi tiết sách khác → replace để tránh stack chồng
      // save deeplink id
      await SharedPreferenceUtil.saveDeepLinkId(bookId);
      navigator.pushNamed(Routes.loginScreen);
    } else {
      final navigator = NavigationService.instance.navigatorKey.currentState;
      if (navigator == null) return;
      // đi từ main để push back không bị lỗi đen màn hình
      await SharedPreferenceUtil.saveDeepLinkId(bookId);
      navigator.pushNamed(Routes.mainScreen);
    }
  }
}
