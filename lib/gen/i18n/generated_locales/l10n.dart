// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Đang tải...`
  String get loading {
    return Intl.message('Đang tải...', name: 'loading', desc: '', args: []);
  }

  /// `Lỗi`
  String get error {
    return Intl.message('Lỗi', name: 'error', desc: '', args: []);
  }

  /// `Thành công`
  String get success {
    return Intl.message('Thành công', name: 'success', desc: '', args: []);
  }

  /// `Cảnh báo`
  String get warning {
    return Intl.message('Cảnh báo', name: 'warning', desc: '', args: []);
  }

  /// `Thông tin`
  String get info {
    return Intl.message('Thông tin', name: 'info', desc: '', args: []);
  }

  /// `Xác nhận`
  String get confirm {
    return Intl.message('Xác nhận', name: 'confirm', desc: '', args: []);
  }

  /// `Hủy`
  String get cancel {
    return Intl.message('Hủy', name: 'cancel', desc: '', args: []);
  }

  /// `Đóng`
  String get close {
    return Intl.message('Đóng', name: 'close', desc: '', args: []);
  }

  /// `Thử lại`
  String get retry {
    return Intl.message('Thử lại', name: 'retry', desc: '', args: []);
  }

  /// `Làm mới`
  String get refresh {
    return Intl.message('Làm mới', name: 'refresh', desc: '', args: []);
  }

  /// `Tìm kiếm`
  String get search {
    return Intl.message('Tìm kiếm', name: 'search', desc: '', args: []);
  }

  /// `Nhập tên đăng nhập`
  String get inputUserName {
    return Intl.message(
      'Nhập tên đăng nhập',
      name: 'inputUserName',
      desc: '',
      args: [],
    );
  }

  /// `Tên đăng nhập`
  String get userName {
    return Intl.message('Tên đăng nhập', name: 'userName', desc: '', args: []);
  }

  /// `Vui lòng nhập tên đăng nhập`
  String get plsInputUserName {
    return Intl.message(
      'Vui lòng nhập tên đăng nhập',
      name: 'plsInputUserName',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập`
  String get login {
    return Intl.message('Đăng nhập', name: 'login', desc: '', args: []);
  }

  /// `Đăng xuất`
  String get logout {
    return Intl.message('Đăng xuất', name: 'logout', desc: '', args: []);
  }

  /// `Đăng ký`
  String get register {
    return Intl.message('Đăng ký', name: 'register', desc: '', args: []);
  }

  /// `Quên mật khẩu`
  String get forgotPassword {
    return Intl.message(
      'Quên mật khẩu',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Đặt lại mật khẩu`
  String get resetPassword {
    return Intl.message(
      'Đặt lại mật khẩu',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Xác thực email`
  String get verifyEmail {
    return Intl.message(
      'Xác thực email',
      name: 'verifyEmail',
      desc: '',
      args: [],
    );
  }

  /// `Xác thực mã`
  String get verifyCode {
    return Intl.message('Xác thực mã', name: 'verifyCode', desc: '', args: []);
  }

  /// `Không có dữ liệu`
  String get empty {
    return Intl.message('Không có dữ liệu', name: 'empty', desc: '', args: []);
  }

  /// `Kéo xuống để làm mới`
  String get pullToRefresh {
    return Intl.message(
      'Kéo xuống để làm mới',
      name: 'pullToRefresh',
      desc: '',
      args: [],
    );
  }

  /// `Thử lại`
  String get tryAgain {
    return Intl.message('Thử lại', name: 'tryAgain', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'vi'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
