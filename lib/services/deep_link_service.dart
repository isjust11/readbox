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
    
    // Luôn lưu lại deepLinkId để các màn hình chính (Discover/AllEbooks) bắt được nếu đang cold start
    await SharedPreferenceUtil.saveDeepLinkId(bookId);

    final navigator = NavigationService.instance.navigatorKey.currentState;
    if (navigator == null) return;

    // Kiểm tra xem app có đang ở SplashScreen không
    bool isSplash = false;
    navigator.popUntil((route) {
      if (route.settings.name == Routes.splashScreen || route.settings.name == '/') {
        isSplash = true;
      }
      return true; // Trả về true để không thực sự pop bất kỳ màn hình nào
    });

    if (!isSplash) {
      // Hot/Warm Start: App đã chạy qua Splash.
      // Chúng ta navigate thẳng tới màn hình sách (hoặc login nếu chưa có token).
      await SharedPreferenceUtil.removeDeepLinkId(); // Xóa ID để mainScreen không đẩy thêm lần nữa
      
      if (token == null || token.isEmpty) {
        // Cần lưu lại để sau khi login xong, màn hình main sẽ push
        await SharedPreferenceUtil.saveDeepLinkId(bookId);
        navigator.pushNamed(Routes.loginScreen);
      } else {
        // Push thẳng BookDetailScreen đè lên màn hình hiện tại
        navigator.pushNamed(Routes.bookDetailScreen, arguments: bookId);
      }
    }
  }
}
