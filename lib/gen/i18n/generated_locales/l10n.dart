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
  String get input_username {
    return Intl.message(
      'Nhập tên đăng nhập',
      name: 'input_username',
      desc: '',
      args: [],
    );
  }

  /// `Tên đăng nhập`
  String get username {
    return Intl.message('Tên đăng nhập', name: 'username', desc: '', args: []);
  }

  /// `Vui lòng nhập tên đăng nhập`
  String get pls_input_username {
    return Intl.message(
      'Vui lòng nhập tên đăng nhập',
      name: 'pls_input_username',
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
  String get forgot_password {
    return Intl.message(
      'Quên mật khẩu',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Đặt lại mật khẩu`
  String get reset_password {
    return Intl.message(
      'Đặt lại mật khẩu',
      name: 'reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Xác thực email`
  String get verify_email {
    return Intl.message(
      'Xác thực email',
      name: 'verify_email',
      desc: '',
      args: [],
    );
  }

  /// `Xác thực mã`
  String get verify_code {
    return Intl.message('Xác thực mã', name: 'verify_code', desc: '', args: []);
  }

  /// `Không có dữ liệu`
  String get empty {
    return Intl.message('Không có dữ liệu', name: 'empty', desc: '', args: []);
  }

  /// `Kéo xuống để làm mới`
  String get pull_to_refresh {
    return Intl.message(
      'Kéo xuống để làm mới',
      name: 'pull_to_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Thử lại`
  String get try_again {
    return Intl.message('Thử lại', name: 'try_again', desc: '', args: []);
  }

  /// `Đã xảy ra lỗi, vui lòng thử lại sau`
  String get error_common {
    return Intl.message(
      'Đã xảy ra lỗi, vui lòng thử lại sau',
      name: 'error_common',
      desc: '',
      args: [],
    );
  }

  /// `Đồng ý`
  String get agree {
    return Intl.message('Đồng ý', name: 'agree', desc: '', args: []);
  }

  /// `Không đồng ý`
  String get disagree {
    return Intl.message('Không đồng ý', name: 'disagree', desc: '', args: []);
  }

  /// `Hoàn thành`
  String get done {
    return Intl.message('Hoàn thành', name: 'done', desc: '', args: []);
  }

  /// `Trang chủ`
  String get home {
    return Intl.message('Trang chủ', name: 'home', desc: '', args: []);
  }

  /// `Tin tức`
  String get news {
    return Intl.message('Tin tức', name: 'news', desc: '', args: []);
  }

  /// `Hồ sơ`
  String get profile {
    return Intl.message('Hồ sơ', name: 'profile', desc: '', args: []);
  }

  /// `Cài đặt`
  String get settings {
    return Intl.message('Cài đặt', name: 'settings', desc: '', args: []);
  }

  /// `Không có kết nối internet`
  String get error_connection {
    return Intl.message(
      'Không có kết nối internet',
      name: 'error_connection',
      desc: '',
      args: [],
    );
  }

  /// `Thư viện của tôi`
  String get my_library {
    return Intl.message(
      'Thư viện của tôi',
      name: 'my_library',
      desc: '',
      args: [],
    );
  }

  /// `Tìm kiếm sách...`
  String get search_books {
    return Intl.message(
      'Tìm kiếm sách...',
      name: 'search_books',
      desc: '',
      args: [],
    );
  }

  /// `Sách yêu thích`
  String get favorite_books {
    return Intl.message(
      'Sách yêu thích',
      name: 'favorite_books',
      desc: '',
      args: [],
    );
  }

  /// `Sách đã lưu`
  String get archived_books {
    return Intl.message(
      'Sách đã lưu',
      name: 'archived_books',
      desc: '',
      args: [],
    );
  }

  /// `Tất cả sách`
  String get all_books {
    return Intl.message('Tất cả sách', name: 'all_books', desc: '', args: []);
  }

  /// `Sách công khai`
  String get public_books {
    return Intl.message(
      'Sách công khai',
      name: 'public_books',
      desc: '',
      args: [],
    );
  }

  /// `Sách riêng tư`
  String get private_books {
    return Intl.message(
      'Sách riêng tư',
      name: 'private_books',
      desc: '',
      args: [],
    );
  }

  /// `Sách của tôi`
  String get my_books {
    return Intl.message('Sách của tôi', name: 'my_books', desc: '', args: []);
  }

  /// `Thêm sách`
  String get add_book {
    return Intl.message('Thêm sách', name: 'add_book', desc: '', args: []);
  }

  /// `Sửa sách`
  String get edit_book {
    return Intl.message('Sửa sách', name: 'edit_book', desc: '', args: []);
  }

  /// `Xóa sách`
  String get delete_book {
    return Intl.message('Xóa sách', name: 'delete_book', desc: '', args: []);
  }

  /// `Đã tải hết dữ liệu`
  String get all_data_loaded {
    return Intl.message(
      'Đã tải hết dữ liệu',
      name: 'all_data_loaded',
      desc: '',
      args: [],
    );
  }

  /// `Thêm sách để bắt đầu đọc`
  String get add_book_to_start_reading {
    return Intl.message(
      'Thêm sách để bắt đầu đọc',
      name: 'add_book_to_start_reading',
      desc: '',
      args: [],
    );
  }

  /// `Chưa có sách nào`
  String get no_books {
    return Intl.message(
      'Chưa có sách nào',
      name: 'no_books',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi tải sách`
  String get error_loading_books {
    return Intl.message(
      'Lỗi tải sách',
      name: 'error_loading_books',
      desc: '',
      args: [],
    );
  }

  /// `Thử lại tải sách`
  String get retry_loading_books {
    return Intl.message(
      'Thử lại tải sách',
      name: 'retry_loading_books',
      desc: '',
      args: [],
    );
  }

  /// `Đang tải sách`
  String get loading_books {
    return Intl.message(
      'Đang tải sách',
      name: 'loading_books',
      desc: '',
      args: [],
    );
  }

  /// `Đang tải thêm sách`
  String get loading_more_books {
    return Intl.message(
      'Đang tải thêm sách',
      name: 'loading_more_books',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi tải thêm sách`
  String get loading_more_books_failed {
    return Intl.message(
      'Lỗi tải thêm sách',
      name: 'loading_more_books_failed',
      desc: '',
      args: [],
    );
  }

  /// `Đã tải thêm sách`
  String get loading_more_books_completed {
    return Intl.message(
      'Đã tải thêm sách',
      name: 'loading_more_books_completed',
      desc: '',
      args: [],
    );
  }

  /// `Không có dữ liệu để tải thêm`
  String get loading_more_books_no_data {
    return Intl.message(
      'Không có dữ liệu để tải thêm',
      name: 'loading_more_books_no_data',
      desc: '',
      args: [],
    );
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
