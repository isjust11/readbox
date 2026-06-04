import 'package:app_links/app_links.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/utils/navigator.dart';

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
    _appLinks.uriLinkStream.listen(
      _handleLink,
      onError: (_) {},
    );
  }

  void _handleLink(Uri uri) {
    // https://readbox.pro.vn/book/{bookId}
    if (uri.host == 'readbox.pro.vn' && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments[0] == 'book' && uri.pathSegments.length >= 2) {
        final bookId = uri.pathSegments[1];
        if (bookId.isNotEmpty) {
          _navigateToBook(bookId);
        }
      }
    }
  }

  void _navigateToBook(String bookId) {
    final navigator = NavigationService.instance.navigatorKey.currentState;
    if (navigator == null) return;

    // Nếu đang ở màn hình chi tiết sách khác → replace để tránh stack chồng
    navigator.pushNamed(Routes.bookDetailScreen, arguments: bookId);
  }
}
