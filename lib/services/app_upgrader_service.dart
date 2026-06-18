import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:upgrader/upgrader.dart';

/// Cấu hình kiểm tra bản cập nhật từ App Store / Google Play.
class AppUpgraderService {
  AppUpgraderService._();

  static Upgrader? _upgrader;
  static String? _localeKey;

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static bool get debugDisplayAlways {
    return dotenv.env['UPGRADER_DEBUG']?.toLowerCase() == 'true';
  }

  /// Giữ một instance [Upgrader] — tránh tạo mới mỗi lần `MaterialApp.builder`
  /// rebuild (instance mới không được `initialize()` → dialog không bao giờ hiện).
  static Upgrader upgraderFor(Locale locale) {
    final languageCode = locale.languageCode == 'vi' ? 'vi' : 'en';
    final key = '${languageCode}_${locale.countryCode ?? ''}';
    if (_upgrader == null || _localeKey != key) {
      _localeKey = key;
      _upgrader?.dispose();
      _upgrader = Upgrader(
        debugLogging: kDebugMode || debugDisplayAlways,
        debugDisplayAlways: debugDisplayAlways,
        durationUntilAlertAgain: const Duration(days: 1),
        languageCode: languageCode,
        messages: _ReadboxUpgraderMessages(languageCode),
        minAppVersion: null,
        countryCode: locale.countryCode ?? (languageCode == 'vi' ? 'vn' : 'us'),
        storeController: UpgraderStoreController(
          onAndroid: () => UpgraderPlayStore(),
          oniOS: () => UpgraderAppStore(),
        ),
      );
    }
    return _upgrader!;
  }

  static Widget wrapIfSupported({
    required BuildContext context,
    required Widget child,
  }) {
    if (!isSupported) return child;

    final locale = Localizations.localeOf(context);

    // `MaterialApp.builder` nằm trên Navigator — cần navigatorKey để showDialog.
    return UpgradeAlert(
      key: const ValueKey('readbox_upgrade_alert'),
      upgrader: upgraderFor(locale),
      navigatorKey: NavigationService.instance.navigatorKey,
      showIgnore: !debugDisplayAlways,
      showLater: !debugDisplayAlways,
      child: child,
    );
  }
}

class _ReadboxUpgraderMessages extends UpgraderMessages {
  _ReadboxUpgraderMessages(this._languageCode);

  final String _languageCode;

  @override
  String get body {
    if (_languageCode == 'vi') {
      return 'Đã có phiên bản mới của Readbox trên cửa hàng.';
    }
    return 'A new version of Readbox is available on the store.';
  }

  @override
  String get buttonTitleIgnore => _languageCode == 'vi' ? 'Bỏ qua' : 'Ignore';

  @override
  String get buttonTitleLater => _languageCode == 'vi' ? 'Để sau' : 'Later';

  @override
  String get buttonTitleUpdate => _languageCode == 'vi' ? 'Cập nhật' : 'Update';

  @override
  String get prompt => _languageCode == 'vi' ? 'Bạn có muốn cập nhật không?' : 'Would you like to update?';

  @override
  String get releaseNotes => _languageCode == 'vi' ? 'Ghi chú phiên bản' : 'Release Notes';

  @override
  String get title => _languageCode == 'vi' ? 'Cập nhật ứng dụng' : 'Update App';
}
