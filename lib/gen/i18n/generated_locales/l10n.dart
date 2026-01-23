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

  /// `Khám phá`
  String get book_discover {
    return Intl.message('Khám phá', name: 'book_discover', desc: '', args: []);
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

  /// `Thư viện Local`
  String get local_library {
    return Intl.message(
      'Thư viện Local',
      name: 'local_library',
      desc: '',
      args: [],
    );
  }

  /// `Tải sách lên`
  String get upload_book {
    return Intl.message(
      'Tải sách lên',
      name: 'upload_book',
      desc: '',
      args: [],
    );
  }

  /// `Phản hồi`
  String get feedback {
    return Intl.message('Phản hồi', name: 'feedback', desc: '', args: []);
  }

  /// `Google Play Services không khả dụng`
  String get google_play_services_not_available {
    return Intl.message(
      'Google Play Services không khả dụng',
      name: 'google_play_services_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập Google`
  String get user_cancelled_google_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập Google',
      name: 'user_cancelled_google_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập Facebook`
  String get user_cancelled_facebook_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập Facebook',
      name: 'user_cancelled_facebook_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập Apple`
  String get user_cancelled_apple_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập Apple',
      name: 'user_cancelled_apple_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập Twitter`
  String get user_cancelled_twitter_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập Twitter',
      name: 'user_cancelled_twitter_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập LinkedIn`
  String get user_cancelled_linkedin_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập LinkedIn',
      name: 'user_cancelled_linkedin_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập GitHub`
  String get user_cancelled_github_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập GitHub',
      name: 'user_cancelled_github_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập GitLab`
  String get user_cancelled_gitlab_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập GitLab',
      name: 'user_cancelled_gitlab_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập Bitbucket`
  String get user_cancelled_bitbucket_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập Bitbucket',
      name: 'user_cancelled_bitbucket_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Người dùng đã hủy đăng nhập`
  String get user_cancelled_sign_in {
    return Intl.message(
      'Người dùng đã hủy đăng nhập',
      name: 'user_cancelled_sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập Google thất bại`
  String get google_signin_failed {
    return Intl.message(
      'Đăng nhập Google thất bại',
      name: 'google_signin_failed',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi mạng Google`
  String get google_network_error {
    return Intl.message(
      'Lỗi mạng Google',
      name: 'google_network_error',
      desc: '',
      args: [],
    );
  }

  /// `Client Google không hợp lệ`
  String get google_invalid_client {
    return Intl.message(
      'Client Google không hợp lệ',
      name: 'google_invalid_client',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi phát triển Google`
  String get google_developer_error {
    return Intl.message(
      'Lỗi phát triển Google',
      name: 'google_developer_error',
      desc: '',
      args: [],
    );
  }

  /// `Thời gian đăng nhập Google hết hạn`
  String get google_timeout {
    return Intl.message(
      'Thời gian đăng nhập Google hết hạn',
      name: 'google_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Token Facebook là null`
  String get facebook_access_token_is_null {
    return Intl.message(
      'Token Facebook là null',
      name: 'facebook_access_token_is_null',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập Facebook thất bại`
  String get facebook_login_failed {
    return Intl.message(
      'Đăng nhập Facebook thất bại',
      name: 'facebook_login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi mạng Facebook`
  String get facebook_network_error {
    return Intl.message(
      'Lỗi mạng Facebook',
      name: 'facebook_network_error',
      desc: '',
      args: [],
    );
  }

  /// `Client Facebook không hợp lệ`
  String get facebook_invalid_client {
    return Intl.message(
      'Client Facebook không hợp lệ',
      name: 'facebook_invalid_client',
      desc: '',
      args: [],
    );
  }

  /// `Không có tên`
  String get noName {
    return Intl.message('Không có tên', name: 'noName', desc: '', args: []);
  }

  /// `Chỉnh sửa hồ sơ`
  String get editProfile {
    return Intl.message(
      'Chỉnh sửa hồ sơ',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật thông tin`
  String get updateYourInfo {
    return Intl.message(
      'Cập nhật thông tin',
      name: 'updateYourInfo',
      desc: '',
      args: [],
    );
  }

  /// `Bảo mật`
  String get security {
    return Intl.message('Bảo mật', name: 'security', desc: '', args: []);
  }

  /// `Cài đặt quyền riêng tư`
  String get privacySettings {
    return Intl.message(
      'Cài đặt quyền riêng tư',
      name: 'privacySettings',
      desc: '',
      args: [],
    );
  }

  /// `Ngôn ngữ`
  String get language {
    return Intl.message('Ngôn ngữ', name: 'language', desc: '', args: []);
  }

  /// `Thay đổi ngôn ngữ ứng dụng`
  String get changeAppLanguage {
    return Intl.message(
      'Thay đổi ngôn ngữ ứng dụng',
      name: 'changeAppLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Giao diện`
  String get theme {
    return Intl.message('Giao diện', name: 'theme', desc: '', args: []);
  }

  /// `Chọn giao diện ứng dụng`
  String get chooseAppAppearance {
    return Intl.message(
      'Chọn giao diện ứng dụng',
      name: 'chooseAppAppearance',
      desc: '',
      args: [],
    );
  }

  /// `Thông báo`
  String get notifications {
    return Intl.message('Thông báo', name: 'notifications', desc: '', args: []);
  }

  /// `Quản lý thông báo`
  String get manageNotifications {
    return Intl.message(
      'Quản lý thông báo',
      name: 'manageNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập sinh trắc học`
  String get biometricLogin {
    return Intl.message(
      'Đăng nhập sinh trắc học',
      name: 'biometricLogin',
      desc: '',
      args: [],
    );
  }

  /// `Sinh trắc học không khả dụng`
  String get biometricNotAvailable {
    return Intl.message(
      'Sinh trắc học không khả dụng',
      name: 'biometricNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Sử dụng vân tay hoặc Face ID`
  String get useFingerprintOrFaceID {
    return Intl.message(
      'Sử dụng vân tay hoặc Face ID',
      name: 'useFingerprintOrFaceID',
      desc: '',
      args: [],
    );
  }

  /// `Trung tâm trợ giúp`
  String get helpCenter {
    return Intl.message(
      'Trung tâm trợ giúp',
      name: 'helpCenter',
      desc: '',
      args: [],
    );
  }

  /// `Nhận trợ giúp và hỗ trợ`
  String get getHelpAndSupport {
    return Intl.message(
      'Nhận trợ giúp và hỗ trợ',
      name: 'getHelpAndSupport',
      desc: '',
      args: [],
    );
  }

  /// `Gửi phản hồi`
  String get sendFeedback {
    return Intl.message(
      'Gửi phản hồi',
      name: 'sendFeedback',
      desc: '',
      args: [],
    );
  }

  /// `Chia sẻ suy nghĩ của bạn`
  String get shareYourThoughts {
    return Intl.message(
      'Chia sẻ suy nghĩ của bạn',
      name: 'shareYourThoughts',
      desc: '',
      args: [],
    );
  }

  /// `Về ứng dụng`
  String get aboutApp {
    return Intl.message('Về ứng dụng', name: 'aboutApp', desc: '', args: []);
  }

  /// `Phiên bản`
  String get version {
    return Intl.message('Phiên bản', name: 'version', desc: '', args: []);
  }

  /// `Sáng`
  String get light {
    return Intl.message('Sáng', name: 'light', desc: '', args: []);
  }

  /// `Tối`
  String get dark {
    return Intl.message('Tối', name: 'dark', desc: '', args: []);
  }

  /// `Không có thông tin đăng nhập`
  String get noLoginInfo {
    return Intl.message(
      'Không có thông tin đăng nhập',
      name: 'noLoginInfo',
      desc: '',
      args: [],
    );
  }

  /// `Thiết lập sinh trắc học thành công`
  String get biometricSetupSuccess {
    return Intl.message(
      'Thiết lập sinh trắc học thành công',
      name: 'biometricSetupSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đã tắt sinh trắc học`
  String get biometricDisabled {
    return Intl.message(
      'Đã tắt sinh trắc học',
      name: 'biometricDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Gửi phản hồi thành công`
  String get feedbackSuccess {
    return Intl.message(
      'Gửi phản hồi thành công',
      name: 'feedbackSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin liên hệ`
  String get feedbackContact {
    return Intl.message(
      'Thông tin liên hệ',
      name: 'feedbackContact',
      desc: '',
      args: [],
    );
  }

  /// `Chúng tôi rất mong nhận được phản hồi từ bạn để cải thiện ứng dụng`
  String get feedbackDescription {
    return Intl.message(
      'Chúng tôi rất mong nhận được phản hồi từ bạn để cải thiện ứng dụng',
      name: 'feedbackDescription',
      desc: '',
      args: [],
    );
  }

  /// `Loại phản hồi`
  String get feedbackType {
    return Intl.message(
      'Loại phản hồi',
      name: 'feedbackType',
      desc: '',
      args: [],
    );
  }

  /// `Mức độ ưu tiên`
  String get feedbackPriority {
    return Intl.message(
      'Mức độ ưu tiên',
      name: 'feedbackPriority',
      desc: '',
      args: [],
    );
  }

  /// `Tiêu đề`
  String get feedbackTitle {
    return Intl.message('Tiêu đề', name: 'feedbackTitle', desc: '', args: []);
  }

  /// `Vui lòng nhập tiêu đề`
  String get feedbackTitleRequired {
    return Intl.message(
      'Vui lòng nhập tiêu đề',
      name: 'feedbackTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `Tiêu đề phải có ít nhất 5 ký tự`
  String get feedbackTitleMinLength {
    return Intl.message(
      'Tiêu đề phải có ít nhất 5 ký tự',
      name: 'feedbackTitleMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Nội dung`
  String get feedbackContent {
    return Intl.message(
      'Nội dung',
      name: 'feedbackContent',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập nội dung`
  String get feedbackContentRequired {
    return Intl.message(
      'Vui lòng nhập nội dung',
      name: 'feedbackContentRequired',
      desc: '',
      args: [],
    );
  }

  /// `Nội dung phải có ít nhất 10 ký tự`
  String get feedbackContentMinLength {
    return Intl.message(
      'Nội dung phải có ít nhất 10 ký tự',
      name: 'feedbackContentMinLength',
      desc: '',
      args: [],
    );
  }

  /// `Tên`
  String get feedbackName {
    return Intl.message('Tên', name: 'feedbackName', desc: '', args: []);
  }

  /// `Email không hợp lệ`
  String get feedbackEmailInvalid {
    return Intl.message(
      'Email không hợp lệ',
      name: 'feedbackEmailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại`
  String get feedbackPhone {
    return Intl.message(
      'Số điện thoại',
      name: 'feedbackPhone',
      desc: '',
      args: [],
    );
  }

  /// `Số điện thoại không hợp lệ`
  String get feedbackPhoneInvalid {
    return Intl.message(
      'Số điện thoại không hợp lệ',
      name: 'feedbackPhoneInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Tùy chọn`
  String get feedbackOptions {
    return Intl.message(
      'Tùy chọn',
      name: 'feedbackOptions',
      desc: '',
      args: [],
    );
  }

  /// `Gửi ẩn danh`
  String get feedbackAnonymous {
    return Intl.message(
      'Gửi ẩn danh',
      name: 'feedbackAnonymous',
      desc: '',
      args: [],
    );
  }

  /// `Gửi phản hồi mà không hiển thị thông tin cá nhân`
  String get feedbackAnonymousDescription {
    return Intl.message(
      'Gửi phản hồi mà không hiển thị thông tin cá nhân',
      name: 'feedbackAnonymousDescription',
      desc: '',
      args: [],
    );
  }

  /// `Gửi phản hồi`
  String get feedbackSend {
    return Intl.message(
      'Gửi phản hồi',
      name: 'feedbackSend',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập để tiếp tục`
  String get login_to_continue {
    return Intl.message(
      'Đăng nhập để tiếp tục',
      name: 'login_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Đăng ký để tiếp tục`
  String get register_to_continue {
    return Intl.message(
      'Đăng ký để tiếp tục',
      name: 'register_to_continue',
      desc: '',
      args: [],
    );
  }

  /// `Đăng ký ngay`
  String get register_now {
    return Intl.message(
      'Đăng ký ngay',
      name: 'register_now',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập ngay`
  String get login_now {
    return Intl.message(
      'Đăng nhập ngay',
      name: 'login_now',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Google`
  String get login_with_google {
    return Intl.message(
      'Đăng nhập với Google',
      name: 'login_with_google',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Facebook`
  String get login_with_facebook {
    return Intl.message(
      'Đăng nhập với Facebook',
      name: 'login_with_facebook',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Apple`
  String get login_with_apple {
    return Intl.message(
      'Đăng nhập với Apple',
      name: 'login_with_apple',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Twitter`
  String get login_with_twitter {
    return Intl.message(
      'Đăng nhập với Twitter',
      name: 'login_with_twitter',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với LinkedIn`
  String get login_with_linkedin {
    return Intl.message(
      'Đăng nhập với LinkedIn',
      name: 'login_with_linkedin',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với GitHub`
  String get login_with_github {
    return Intl.message(
      'Đăng nhập với GitHub',
      name: 'login_with_github',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với GitLab`
  String get login_with_gitlab {
    return Intl.message(
      'Đăng nhập với GitLab',
      name: 'login_with_gitlab',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Bitbucket`
  String get login_with_bitbucket {
    return Intl.message(
      'Đăng nhập với Bitbucket',
      name: 'login_with_bitbucket',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với email`
  String get login_with_email {
    return Intl.message(
      'Đăng nhập với email',
      name: 'login_with_email',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với số điện thoại`
  String get login_with_phone {
    return Intl.message(
      'Đăng nhập với số điện thoại',
      name: 'login_with_phone',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với tên đăng nhập`
  String get login_with_username {
    return Intl.message(
      'Đăng nhập với tên đăng nhập',
      name: 'login_with_username',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với mật khẩu`
  String get login_with_password {
    return Intl.message(
      'Đăng nhập với mật khẩu',
      name: 'login_with_password',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với mã OTP`
  String get login_with_otp {
    return Intl.message(
      'Đăng nhập với mã OTP',
      name: 'login_with_otp',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với mã PIN`
  String get login_with_pin {
    return Intl.message(
      'Đăng nhập với mã PIN',
      name: 'login_with_pin',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với Face ID`
  String get login_with_face_id {
    return Intl.message(
      'Đăng nhập với Face ID',
      name: 'login_with_face_id',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với vân tay`
  String get login_with_fingerprint {
    return Intl.message(
      'Đăng nhập với vân tay',
      name: 'login_with_fingerprint',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập với sinh trắc học`
  String get login_with_biometric {
    return Intl.message(
      'Đăng nhập với sinh trắc học',
      name: 'login_with_biometric',
      desc: '',
      args: [],
    );
  }

  /// `Chào mừng trở lại!`
  String get welcome_back {
    return Intl.message(
      'Chào mừng trở lại!',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Nhập tên đăng nhập`
  String get enter_username {
    return Intl.message(
      'Nhập tên đăng nhập',
      name: 'enter_username',
      desc: '',
      args: [],
    );
  }

  /// `Nhập mật khẩu`
  String get enter_password {
    return Intl.message(
      'Nhập mật khẩu',
      name: 'enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập tên đăng nhập`
  String get please_enter_username {
    return Intl.message(
      'Vui lòng nhập tên đăng nhập',
      name: 'please_enter_username',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập mật khẩu`
  String get please_enter_password {
    return Intl.message(
      'Vui lòng nhập mật khẩu',
      name: 'please_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Mật khẩu phải có ít nhất 6 ký tự`
  String get password_must_be_at_least_6_characters {
    return Intl.message(
      'Mật khẩu phải có ít nhất 6 ký tự',
      name: 'password_must_be_at_least_6_characters',
      desc: '',
      args: [],
    );
  }

  /// `Chưa có tài khoản? `
  String get no_account {
    return Intl.message(
      'Chưa có tài khoản? ',
      name: 'no_account',
      desc: '',
      args: [],
    );
  }

  /// `Đã có tài khoản? `
  String get have_account {
    return Intl.message(
      'Đã có tài khoản? ',
      name: 'have_account',
      desc: '',
      args: [],
    );
  }

  /// `Mật khẩu`
  String get password {
    return Intl.message('Mật khẩu', name: 'password', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Số điện thoại`
  String get phone {
    return Intl.message('Số điện thoại', name: 'phone', desc: '', args: []);
  }

  /// `Họ và tên`
  String get full_name {
    return Intl.message('Họ và tên', name: 'full_name', desc: '', args: []);
  }

  /// `Xác nhận mật khẩu`
  String get confirm_password {
    return Intl.message(
      'Xác nhận mật khẩu',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Nhập email`
  String get enter_email {
    return Intl.message('Nhập email', name: 'enter_email', desc: '', args: []);
  }

  /// `Nhập số điện thoại`
  String get enter_phone {
    return Intl.message(
      'Nhập số điện thoại',
      name: 'enter_phone',
      desc: '',
      args: [],
    );
  }

  /// `Nhập họ và tên`
  String get enter_full_name {
    return Intl.message(
      'Nhập họ và tên',
      name: 'enter_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Nhập lại mật khẩu`
  String get enter_confirm_password {
    return Intl.message(
      'Nhập lại mật khẩu',
      name: 'enter_confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập lại mật khẩu`
  String get please_enter_confirm_password {
    return Intl.message(
      'Vui lòng nhập lại mật khẩu',
      name: 'please_enter_confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Mật khẩu không khớp`
  String get passwords_do_not_match {
    return Intl.message(
      'Mật khẩu không khớp',
      name: 'passwords_do_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Đang tạo tài khoản...`
  String get creating_account {
    return Intl.message(
      'Đang tạo tài khoản...',
      name: 'creating_account',
      desc: '',
      args: [],
    );
  }

  /// `Tạo tài khoản mới`
  String get create_new_account {
    return Intl.message(
      'Tạo tài khoản mới',
      name: 'create_new_account',
      desc: '',
      args: [],
    );
  }

  /// `Điền thông tin để bắt đầu`
  String get enter_information_to_start {
    return Intl.message(
      'Điền thông tin để bắt đầu',
      name: 'enter_information_to_start',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập họ và tên`
  String get please_enter_full_name {
    return Intl.message(
      'Vui lòng nhập họ và tên',
      name: 'please_enter_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập email`
  String get please_enter_email {
    return Intl.message(
      'Vui lòng nhập email',
      name: 'please_enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Email không hợp lệ`
  String get invalid_email {
    return Intl.message(
      'Email không hợp lệ',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Nhớ tài khoản`
  String get remember_me {
    return Intl.message(
      'Nhớ tài khoản',
      name: 'remember_me',
      desc: '',
      args: [],
    );
  }

  /// `Đang đăng nhập...`
  String get logging_in {
    return Intl.message(
      'Đang đăng nhập...',
      name: 'logging_in',
      desc: '',
      args: [],
    );
  }

  /// `Gửi lại mã`
  String get resend_code {
    return Intl.message('Gửi lại mã', name: 'resend_code', desc: '', args: []);
  }

  /// `Quay lại đăng nhập`
  String get back_to_login {
    return Intl.message(
      'Quay lại đăng nhập',
      name: 'back_to_login',
      desc: '',
      args: [],
    );
  }

  /// `Email không hợp lệ`
  String get email_invalid {
    return Intl.message(
      'Email không hợp lệ',
      name: 'email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập số điện thoại`
  String get please_enter_phone {
    return Intl.message(
      'Vui lòng nhập số điện thoại',
      name: 'please_enter_phone',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập mã`
  String get please_enter_code {
    return Intl.message(
      'Vui lòng nhập mã',
      name: 'please_enter_code',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập mã xác nhận`
  String get please_enter_confirm_code {
    return Intl.message(
      'Vui lòng nhập mã xác nhận',
      name: 'please_enter_confirm_code',
      desc: '',
      args: [],
    );
  }

  /// `Ngày tạo`
  String get created_at {
    return Intl.message('Ngày tạo', name: 'created_at', desc: '', args: []);
  }

  /// `Ngày cập nhật`
  String get updated_at {
    return Intl.message(
      'Ngày cập nhật',
      name: 'updated_at',
      desc: '',
      args: [],
    );
  }

  /// `Đăng nhập gần nhất`
  String get last_login {
    return Intl.message(
      'Đăng nhập gần nhất',
      name: 'last_login',
      desc: '',
      args: [],
    );
  }

  /// `Không có thông tin`
  String get no_info {
    return Intl.message(
      'Không có thông tin',
      name: 'no_info',
      desc: '',
      args: [],
    );
  }

  /// `Vai trò`
  String get roles {
    return Intl.message('Vai trò', name: 'roles', desc: '', args: []);
  }

  /// `Quyền`
  String get permissions {
    return Intl.message('Quyền', name: 'permissions', desc: '', args: []);
  }

  /// `Ngày sinh`
  String get birth_date {
    return Intl.message('Ngày sinh', name: 'birth_date', desc: '', args: []);
  }

  /// `Địa chỉ`
  String get address {
    return Intl.message('Địa chỉ', name: 'address', desc: '', args: []);
  }

  /// `Số điện thoại`
  String get phone_number {
    return Intl.message(
      'Số điện thoại',
      name: 'phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết Facebook`
  String get facebook_link {
    return Intl.message(
      'Liên kết Facebook',
      name: 'facebook_link',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết Instagram`
  String get instagram_link {
    return Intl.message(
      'Liên kết Instagram',
      name: 'instagram_link',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết Twitter`
  String get twitter_link {
    return Intl.message(
      'Liên kết Twitter',
      name: 'twitter_link',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết LinkedIn`
  String get linkedin_link {
    return Intl.message(
      'Liên kết LinkedIn',
      name: 'linkedin_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập số điện thoại`
  String get please_enter_phone_number {
    return Intl.message(
      'Vui lòng nhập số điện thoại',
      name: 'please_enter_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Email không hợp lệ`
  String get please_enter_valid_email {
    return Intl.message(
      'Email không hợp lệ',
      name: 'please_enter_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Đang lưu...`
  String get saving {
    return Intl.message('Đang lưu...', name: 'saving', desc: '', args: []);
  }

  /// `Lưu`
  String get save {
    return Intl.message('Lưu', name: 'save', desc: '', args: []);
  }

  /// `Sửa`
  String get edit {
    return Intl.message('Sửa', name: 'edit', desc: '', args: []);
  }

  /// `Máy ảnh`
  String get camera {
    return Intl.message('Máy ảnh', name: 'camera', desc: '', args: []);
  }

  /// `Thư viện ảnh`
  String get gallery {
    return Intl.message('Thư viện ảnh', name: 'gallery', desc: '', args: []);
  }

  /// `Cập nhật`
  String get update {
    return Intl.message('Cập nhật', name: 'update', desc: '', args: []);
  }

  /// `Cập nhật hồ sơ`
  String get update_profile {
    return Intl.message(
      'Cập nhật hồ sơ',
      name: 'update_profile',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật hồ sơ thành công`
  String get update_profile_success {
    return Intl.message(
      'Cập nhật hồ sơ thành công',
      name: 'update_profile_success',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật hồ sơ thất bại`
  String get update_profile_failed {
    return Intl.message(
      'Cập nhật hồ sơ thất bại',
      name: 'update_profile_failed',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật thông tin của bạn`
  String get update_profile_description {
    return Intl.message(
      'Cập nhật thông tin của bạn',
      name: 'update_profile_description',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật thông tin thành công`
  String get update_profile_description_success {
    return Intl.message(
      'Cập nhật thông tin thành công',
      name: 'update_profile_description_success',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật thông tin thất bại`
  String get update_profile_description_failed {
    return Intl.message(
      'Cập nhật thông tin thất bại',
      name: 'update_profile_description_failed',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Instagram`
  String get please_enter_instagram_link {
    return Intl.message(
      'Vui lòng nhập liên kết Instagram',
      name: 'please_enter_instagram_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Twitter`
  String get please_enter_twitter_link {
    return Intl.message(
      'Vui lòng nhập liên kết Twitter',
      name: 'please_enter_twitter_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết LinkedIn`
  String get please_enter_linkedin_link {
    return Intl.message(
      'Vui lòng nhập liên kết LinkedIn',
      name: 'please_enter_linkedin_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết GitHub`
  String get please_enter_github_link {
    return Intl.message(
      'Vui lòng nhập liên kết GitHub',
      name: 'please_enter_github_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết GitLab`
  String get please_enter_gitlab_link {
    return Intl.message(
      'Vui lòng nhập liên kết GitLab',
      name: 'please_enter_gitlab_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Bitbucket`
  String get please_enter_bitbucket_link {
    return Intl.message(
      'Vui lòng nhập liên kết Bitbucket',
      name: 'please_enter_bitbucket_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Facebook`
  String get please_enter_facebook_link {
    return Intl.message(
      'Vui lòng nhập liên kết Facebook',
      name: 'please_enter_facebook_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập ngày sinh hợp lệ`
  String get please_enter_valid_birth_date {
    return Intl.message(
      'Vui lòng nhập ngày sinh hợp lệ',
      name: 'please_enter_valid_birth_date',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập số điện thoại hợp lệ`
  String get please_enter_valid_phone_number {
    return Intl.message(
      'Vui lòng nhập số điện thoại hợp lệ',
      name: 'please_enter_valid_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập địa chỉ hợp lệ`
  String get please_enter_valid_address {
    return Intl.message(
      'Vui lòng nhập địa chỉ hợp lệ',
      name: 'please_enter_valid_address',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết Facebook không hợp lệ`
  String get please_enter_valid_facebook_link {
    return Intl.message(
      'Liên kết Facebook không hợp lệ',
      name: 'please_enter_valid_facebook_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Instagram hợp lệ`
  String get please_enter_valid_instagram_link {
    return Intl.message(
      'Vui lòng nhập liên kết Instagram hợp lệ',
      name: 'please_enter_valid_instagram_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Twitter hợp lệ`
  String get please_enter_valid_twitter_link {
    return Intl.message(
      'Vui lòng nhập liên kết Twitter hợp lệ',
      name: 'please_enter_valid_twitter_link',
      desc: '',
      args: [],
    );
  }

  /// `Liên kết LinkedIn không hợp lệ`
  String get please_enter_valid_linkedin_link {
    return Intl.message(
      'Liên kết LinkedIn không hợp lệ',
      name: 'please_enter_valid_linkedin_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết GitHub hợp lệ`
  String get please_enter_valid_github_link {
    return Intl.message(
      'Vui lòng nhập liên kết GitHub hợp lệ',
      name: 'please_enter_valid_github_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết GitLab hợp lệ`
  String get please_enter_valid_gitlab_link {
    return Intl.message(
      'Vui lòng nhập liên kết GitLab hợp lệ',
      name: 'please_enter_valid_gitlab_link',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập liên kết Bitbucket hợp lệ`
  String get please_enter_valid_bitbucket_link {
    return Intl.message(
      'Vui lòng nhập liên kết Bitbucket hợp lệ',
      name: 'please_enter_valid_bitbucket_link',
      desc: '',
      args: [],
    );
  }

  /// `Không thể chọn ảnh`
  String get cannot_select_image_message {
    return Intl.message(
      'Không thể chọn ảnh',
      name: 'cannot_select_image_message',
      desc: '',
      args: [],
    );
  }

  /// `Không thể truy cập camera`
  String get cannot_access_camera {
    return Intl.message(
      'Không thể truy cập camera',
      name: 'cannot_access_camera',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng cấp quyền truy cập camera/thư viện ảnh trong cài đặt`
  String get please_grant_permission_to_access_camera_or_gallery_in_settings {
    return Intl.message(
      'Vui lòng cấp quyền truy cập camera/thư viện ảnh trong cài đặt',
      name: 'please_grant_permission_to_access_camera_or_gallery_in_settings',
      desc: '',
      args: [],
    );
  }

  /// `Không có camera khả dụng`
  String get no_available_camera {
    return Intl.message(
      'Không có camera khả dụng',
      name: 'no_available_camera',
      desc: '',
      args: [],
    );
  }

  /// `Không có nội dung để hiển thị`
  String get no_content_to_display {
    return Intl.message(
      'Không có nội dung để hiển thị',
      name: 'no_content_to_display',
      desc: '',
      args: [],
    );
  }

  /// `Quyền riêng tư và bảo mật`
  String get privacy_and_security {
    return Intl.message(
      'Quyền riêng tư và bảo mật',
      name: 'privacy_and_security',
      desc: '',
      args: [],
    );
  }

  /// `PDF, EPUB, MOBI`
  String get pdfEpubMobi {
    return Intl.message(
      'PDF, EPUB, MOBI',
      name: 'pdfEpubMobi',
      desc: '',
      args: [],
    );
  }

  /// `File Ebook`
  String get fileEbook {
    return Intl.message('File Ebook', name: 'fileEbook', desc: '', args: []);
  }

  /// `Bắt buộc`
  String get required_field {
    return Intl.message('Bắt buộc', name: 'required_field', desc: '', args: []);
  }

  /// `Chọn file`
  String get select_file {
    return Intl.message('Chọn file', name: 'select_file', desc: '', args: []);
  }

  /// `Từ file picker`
  String get from_file_picker {
    return Intl.message(
      'Từ file picker',
      name: 'from_file_picker',
      desc: '',
      args: [],
    );
  }

  /// `Trong bộ nhớ`
  String get in_memory {
    return Intl.message('Trong bộ nhớ', name: 'in_memory', desc: '', args: []);
  }

  /// `Sẵn sàng upload`
  String get ready_to_upload {
    return Intl.message(
      'Sẵn sàng upload',
      name: 'ready_to_upload',
      desc: '',
      args: [],
    );
  }

  /// `Đang upload...`
  String get uploading {
    return Intl.message(
      'Đang upload...',
      name: 'uploading',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get upload_file {
    return Intl.message('Upload File', name: 'upload_file', desc: '', args: []);
  }

  /// `Upload thành công`
  String get upload_success {
    return Intl.message(
      'Upload thành công',
      name: 'upload_success',
      desc: '',
      args: [],
    );
  }

  /// `Ảnh Bìa`
  String get cover_image {
    return Intl.message('Ảnh Bìa', name: 'cover_image', desc: '', args: []);
  }

  /// `JPG, PNG, WEBP`
  String get jpgPngWebp {
    return Intl.message(
      'JPG, PNG, WEBP',
      name: 'jpgPngWebp',
      desc: '',
      args: [],
    );
  }

  /// `Tùy chọn`
  String get optional {
    return Intl.message('Tùy chọn', name: 'optional', desc: '', args: []);
  }

  /// `Chọn ảnh bìa`
  String get select_cover_image {
    return Intl.message(
      'Chọn ảnh bìa',
      name: 'select_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Khuyến nghị: 600x900px`
  String get recommended_size {
    return Intl.message(
      'Khuyến nghị: 600x900px',
      name: 'recommended_size',
      desc: '',
      args: [],
    );
  }

  /// `Upload ảnh`
  String get upload_cover_image {
    return Intl.message(
      'Upload ảnh',
      name: 'upload_cover_image',
      desc: '',
      args: [],
    );
  }

  /// `Ảnh bìa đã upload thành công`
  String get cover_image_uploaded_successfully {
    return Intl.message(
      'Ảnh bìa đã upload thành công',
      name: 'cover_image_uploaded_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Thông tin sách`
  String get book_information {
    return Intl.message(
      'Thông tin sách',
      name: 'book_information',
      desc: '',
      args: [],
    );
  }

  /// `Tiêu đề`
  String get title {
    return Intl.message('Tiêu đề', name: 'title', desc: '', args: []);
  }

  /// `Tác giả`
  String get author {
    return Intl.message('Tác giả', name: 'author', desc: '', args: []);
  }

  /// `Mô tả`
  String get description {
    return Intl.message('Mô tả', name: 'description', desc: '', args: []);
  }

  /// `Nhà xuất bản`
  String get publisher {
    return Intl.message('Nhà xuất bản', name: 'publisher', desc: '', args: []);
  }

  /// `ISBN`
  String get isbn {
    return Intl.message('ISBN', name: 'isbn', desc: '', args: []);
  }

  /// `Số trang`
  String get total_pages {
    return Intl.message('Số trang', name: 'total_pages', desc: '', args: []);
  }

  /// `Thể loại`
  String get category {
    return Intl.message('Thể loại', name: 'category', desc: '', args: []);
  }

  /// `Công khai`
  String get public {
    return Intl.message('Công khai', name: 'public', desc: '', args: []);
  }

  /// `Riêng tư`
  String get private {
    return Intl.message('Riêng tư', name: 'private', desc: '', args: []);
  }

  /// `Sách sẽ hiển thị cho mọi người`
  String get book_will_be_displayed_for_everyone {
    return Intl.message(
      'Sách sẽ hiển thị cho mọi người',
      name: 'book_will_be_displayed_for_everyone',
      desc: '',
      args: [],
    );
  }

  /// `Sách chỉ hiển thị cho admin`
  String get book_will_be_displayed_for_admin {
    return Intl.message(
      'Sách chỉ hiển thị cho admin',
      name: 'book_will_be_displayed_for_admin',
      desc: '',
      args: [],
    );
  }

  /// `Đang tạo sách...`
  String get creating_book {
    return Intl.message(
      'Đang tạo sách...',
      name: 'creating_book',
      desc: '',
      args: [],
    );
  }

  /// `Tạo Sách Mới`
  String get create_new_book {
    return Intl.message(
      'Tạo Sách Mới',
      name: 'create_new_book',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập tác giả`
  String get please_enter_author {
    return Intl.message(
      'Vui lòng nhập tác giả',
      name: 'please_enter_author',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập mô tả`
  String get please_enter_description {
    return Intl.message(
      'Vui lòng nhập mô tả',
      name: 'please_enter_description',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập nhà xuất bản`
  String get please_enter_publisher {
    return Intl.message(
      'Vui lòng nhập nhà xuất bản',
      name: 'please_enter_publisher',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập ISBN`
  String get please_enter_isbn {
    return Intl.message(
      'Vui lòng nhập ISBN',
      name: 'please_enter_isbn',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập số trang`
  String get please_enter_total_pages {
    return Intl.message(
      'Vui lòng nhập số trang',
      name: 'please_enter_total_pages',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập ngôn ngữ`
  String get please_enter_language {
    return Intl.message(
      'Vui lòng nhập ngôn ngữ',
      name: 'please_enter_language',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập thể loại`
  String get please_enter_category {
    return Intl.message(
      'Vui lòng nhập thể loại',
      name: 'please_enter_category',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập tiêu đề`
  String get please_enter_title {
    return Intl.message(
      'Vui lòng nhập tiêu đề',
      name: 'please_enter_title',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng nhập ngôn ngữ`
  String get select_language {
    return Intl.message(
      'Vui lòng nhập ngôn ngữ',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `Ngôn ngữ dịch`
  String get translate {
    return Intl.message('Ngôn ngữ dịch', name: 'translate', desc: '', args: []);
  }

  /// `Text to speech`
  String get textToSpeech {
    return Intl.message(
      'Text to speech',
      name: 'textToSpeech',
      desc: '',
      args: [],
    );
  }

  /// `Chuyển đổi text to speech`
  String get convertTextToSpeech {
    return Intl.message(
      'Chuyển đổi text to speech',
      name: 'convertTextToSpeech',
      desc: '',
      args: [],
    );
  }

  /// `Thư viện Ebook`
  String get library {
    return Intl.message('Thư viện Ebook', name: 'library', desc: '', args: []);
  }

  /// `Cài đặt ngôn ngữ TTS`
  String get ttsLanguageSettings {
    return Intl.message(
      'Cài đặt ngôn ngữ TTS',
      name: 'ttsLanguageSettings',
      desc: '',
      args: [],
    );
  }

  /// `Chọn ngôn ngữ đọc`
  String get selectTTSLanguage {
    return Intl.message(
      'Chọn ngôn ngữ đọc',
      name: 'selectTTSLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Cài đặt TTS`
  String get ttsSettings {
    return Intl.message('Cài đặt TTS', name: 'ttsSettings', desc: '', args: []);
  }

  /// `Tốc độ đọc`
  String get ttsSpeed {
    return Intl.message('Tốc độ đọc', name: 'ttsSpeed', desc: '', args: []);
  }

  /// `Âm lượng`
  String get ttsVolume {
    return Intl.message('Âm lượng', name: 'ttsVolume', desc: '', args: []);
  }

  /// `Cao độ giọng nói`
  String get ttsPitch {
    return Intl.message(
      'Cao độ giọng nói',
      name: 'ttsPitch',
      desc: '',
      args: [],
    );
  }

  /// `Giọng đọc`
  String get ttsVoice {
    return Intl.message('Giọng đọc', name: 'ttsVoice', desc: '', args: []);
  }

  /// `Kiểm tra đọc`
  String get testTTS {
    return Intl.message('Kiểm tra đọc', name: 'testTTS', desc: '', args: []);
  }

  /// `Xin chào, đây là bài kiểm tra đọc văn bản.`
  String get ttsTestText {
    return Intl.message(
      'Xin chào, đây là bài kiểm tra đọc văn bản.',
      name: 'ttsTestText',
      desc: '',
      args: [],
    );
  }

  /// `Không có ngôn ngữ khả dụng`
  String get noLanguagesAvailable {
    return Intl.message(
      'Không có ngôn ngữ khả dụng',
      name: 'noLanguagesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Ngôn ngữ hiện tại`
  String get currentLanguage {
    return Intl.message(
      'Ngôn ngữ hiện tại',
      name: 'currentLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Ngôn ngữ khả dụng`
  String get availableLanguages {
    return Intl.message(
      'Ngôn ngữ khả dụng',
      name: 'availableLanguages',
      desc: '',
      args: [],
    );
  }

  /// `Chọn giọng đọc`
  String get selectVoice {
    return Intl.message(
      'Chọn giọng đọc',
      name: 'selectVoice',
      desc: '',
      args: [],
    );
  }

  /// `Giọng mặc định`
  String get defaultVoice {
    return Intl.message(
      'Giọng mặc định',
      name: 'defaultVoice',
      desc: '',
      args: [],
    );
  }

  /// `Tốc độ đọc`
  String get readingSpeed {
    return Intl.message('Tốc độ đọc', name: 'readingSpeed', desc: '', args: []);
  }

  /// `Chậm`
  String get slow {
    return Intl.message('Chậm', name: 'slow', desc: '', args: []);
  }

  /// `Bình thường`
  String get normal {
    return Intl.message('Bình thường', name: 'normal', desc: '', args: []);
  }

  /// `Nhanh`
  String get fast {
    return Intl.message('Nhanh', name: 'fast', desc: '', args: []);
  }

  /// `Rất nhanh`
  String get veryFast {
    return Intl.message('Rất nhanh', name: 'veryFast', desc: '', args: []);
  }

  /// `Cao độ giọng`
  String get voicePitch {
    return Intl.message('Cao độ giọng', name: 'voicePitch', desc: '', args: []);
  }

  /// `Thấp`
  String get low {
    return Intl.message('Thấp', name: 'low', desc: '', args: []);
  }

  /// `Trung bình`
  String get medium {
    return Intl.message('Trung bình', name: 'medium', desc: '', args: []);
  }

  /// `Cao`
  String get high {
    return Intl.message('Cao', name: 'high', desc: '', args: []);
  }

  /// `Phát thử`
  String get playTest {
    return Intl.message('Phát thử', name: 'playTest', desc: '', args: []);
  }

  /// `Dừng`
  String get stopTest {
    return Intl.message('Dừng', name: 'stopTest', desc: '', args: []);
  }

  /// `Đã thay đổi ngôn ngữ`
  String get languageChanged {
    return Intl.message(
      'Đã thay đổi ngôn ngữ',
      name: 'languageChanged',
      desc: '',
      args: [],
    );
  }

  /// `Đã lưu cài đặt`
  String get settingsSaved {
    return Intl.message(
      'Đã lưu cài đặt',
      name: 'settingsSaved',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi khi thay đổi ngôn ngữ`
  String get errorChangingLanguage {
    return Intl.message(
      'Lỗi khi thay đổi ngôn ngữ',
      name: 'errorChangingLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Lỗi khi lưu cài đặt`
  String get errorSavingSettings {
    return Intl.message(
      'Lỗi khi lưu cài đặt',
      name: 'errorSavingSettings',
      desc: '',
      args: [],
    );
  }

  /// `TTS chưa được khởi tạo`
  String get ttsNotInitialized {
    return Intl.message(
      'TTS chưa được khởi tạo',
      name: 'ttsNotInitialized',
      desc: '',
      args: [],
    );
  }

  /// `Đang khởi tạo TTS...`
  String get initializingTTS {
    return Intl.message(
      'Đang khởi tạo TTS...',
      name: 'initializingTTS',
      desc: '',
      args: [],
    );
  }

  /// `Cài đặt thông báo`
  String get notificationSettings {
    return Intl.message(
      'Cài đặt thông báo',
      name: 'notificationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Tùy chọn thông báo`
  String get notificationPreferences {
    return Intl.message(
      'Tùy chọn thông báo',
      name: 'notificationPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Bật thông báo`
  String get enableNotifications {
    return Intl.message(
      'Bật thông báo',
      name: 'enableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Tắt thông báo`
  String get disableNotifications {
    return Intl.message(
      'Tắt thông báo',
      name: 'disableNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Thông báo đẩy`
  String get pushNotifications {
    return Intl.message(
      'Thông báo đẩy',
      name: 'pushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Nhận thông báo đẩy từ server`
  String get receivePushNotifications {
    return Intl.message(
      'Nhận thông báo đẩy từ server',
      name: 'receivePushNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Thông báo cục bộ`
  String get localNotifications {
    return Intl.message(
      'Thông báo cục bộ',
      name: 'localNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Nhận nhắc nhở và thông báo cục bộ`
  String get receiveLocalNotifications {
    return Intl.message(
      'Nhận nhắc nhở và thông báo cục bộ',
      name: 'receiveLocalNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Nhắc nhở đọc sách`
  String get readingReminders {
    return Intl.message(
      'Nhắc nhở đọc sách',
      name: 'readingReminders',
      desc: '',
      args: [],
    );
  }

  /// `Đặt nhắc nhở đọc sách hàng ngày`
  String get setReadingReminders {
    return Intl.message(
      'Đặt nhắc nhở đọc sách hàng ngày',
      name: 'setReadingReminders',
      desc: '',
      args: [],
    );
  }

  /// `Thời gian nhắc nhở`
  String get reminderTime {
    return Intl.message(
      'Thời gian nhắc nhở',
      name: 'reminderTime',
      desc: '',
      args: [],
    );
  }

  /// `Chọn thời gian nhắc nhở`
  String get selectReminderTime {
    return Intl.message(
      'Chọn thời gian nhắc nhở',
      name: 'selectReminderTime',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật sách`
  String get bookUpdates {
    return Intl.message(
      'Cập nhật sách',
      name: 'bookUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Nhận thông báo khi có sách mới`
  String get receiveBookUpdates {
    return Intl.message(
      'Nhận thông báo khi có sách mới',
      name: 'receiveBookUpdates',
      desc: '',
      args: [],
    );
  }

  /// `Thông báo hệ thống`
  String get systemNotifications {
    return Intl.message(
      'Thông báo hệ thống',
      name: 'systemNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Nhận thông báo về cập nhật ứng dụng`
  String get receiveSystemNotifications {
    return Intl.message(
      'Nhận thông báo về cập nhật ứng dụng',
      name: 'receiveSystemNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Âm thanh thông báo`
  String get notificationSound {
    return Intl.message(
      'Âm thanh thông báo',
      name: 'notificationSound',
      desc: '',
      args: [],
    );
  }

  /// `Bật âm thanh`
  String get enableSound {
    return Intl.message(
      'Bật âm thanh',
      name: 'enableSound',
      desc: '',
      args: [],
    );
  }

  /// `Rung`
  String get notificationVibration {
    return Intl.message(
      'Rung',
      name: 'notificationVibration',
      desc: '',
      args: [],
    );
  }

  /// `Bật rung`
  String get enableVibration {
    return Intl.message(
      'Bật rung',
      name: 'enableVibration',
      desc: '',
      args: [],
    );
  }

  /// `Badge`
  String get notificationBadge {
    return Intl.message('Badge', name: 'notificationBadge', desc: '', args: []);
  }

  /// `Hiển thị badge trên icon`
  String get showBadge {
    return Intl.message(
      'Hiển thị badge trên icon',
      name: 'showBadge',
      desc: '',
      args: [],
    );
  }

  /// `Xem trước thông báo`
  String get notificationPreview {
    return Intl.message(
      'Xem trước thông báo',
      name: 'notificationPreview',
      desc: '',
      args: [],
    );
  }

  /// `Hiển thị nội dung trên màn hình khóa`
  String get showPreview {
    return Intl.message(
      'Hiển thị nội dung trên màn hình khóa',
      name: 'showPreview',
      desc: '',
      args: [],
    );
  }

  /// `Kiểm tra thông báo`
  String get testNotification {
    return Intl.message(
      'Kiểm tra thông báo',
      name: 'testNotification',
      desc: '',
      args: [],
    );
  }

  /// `Gửi thông báo thử nghiệm`
  String get sendTestNotification {
    return Intl.message(
      'Gửi thông báo thử nghiệm',
      name: 'sendTestNotification',
      desc: '',
      args: [],
    );
  }

  /// `Đã gửi thông báo thử nghiệm`
  String get testNotificationSent {
    return Intl.message(
      'Đã gửi thông báo thử nghiệm',
      name: 'testNotificationSent',
      desc: '',
      args: [],
    );
  }

  /// `Cần cấp quyền thông báo`
  String get notificationPermissionRequired {
    return Intl.message(
      'Cần cấp quyền thông báo',
      name: 'notificationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `Mở cài đặt`
  String get openSettings {
    return Intl.message('Mở cài đặt', name: 'openSettings', desc: '', args: []);
  }

  /// `Quyền bị từ chối`
  String get permissionDenied {
    return Intl.message(
      'Quyền bị từ chối',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Quyền đã được cấp`
  String get permissionGranted {
    return Intl.message(
      'Quyền đã được cấp',
      name: 'permissionGranted',
      desc: '',
      args: [],
    );
  }

  /// `Danh mục thông báo`
  String get notificationCategories {
    return Intl.message(
      'Danh mục thông báo',
      name: 'notificationCategories',
      desc: '',
      args: [],
    );
  }

  /// `Quản lý danh mục thông báo`
  String get manageNotificationCategories {
    return Intl.message(
      'Quản lý danh mục thông báo',
      name: 'manageNotificationCategories',
      desc: '',
      args: [],
    );
  }

  /// `Xóa tất cả thông báo`
  String get clearAllNotifications {
    return Intl.message(
      'Xóa tất cả thông báo',
      name: 'clearAllNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Đã xóa tất cả thông báo`
  String get notificationsCleared {
    return Intl.message(
      'Đã xóa tất cả thông báo',
      name: 'notificationsCleared',
      desc: '',
      args: [],
    );
  }

  /// `Không có thông báo`
  String get noNotifications {
    return Intl.message(
      'Không có thông báo',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Lịch sử thông báo`
  String get notificationHistory {
    return Intl.message(
      'Lịch sử thông báo',
      name: 'notificationHistory',
      desc: '',
      args: [],
    );
  }

  /// `Xem lịch sử thông báo`
  String get viewNotificationHistory {
    return Intl.message(
      'Xem lịch sử thông báo',
      name: 'viewNotificationHistory',
      desc: '',
      args: [],
    );
  }

  /// `FCM Token`
  String get fcmToken {
    return Intl.message('FCM Token', name: 'fcmToken', desc: '', args: []);
  }

  /// `Sao chép token`
  String get copyToken {
    return Intl.message(
      'Sao chép token',
      name: 'copyToken',
      desc: '',
      args: [],
    );
  }

  /// `Đã sao chép token`
  String get tokenCopied {
    return Intl.message(
      'Đã sao chép token',
      name: 'tokenCopied',
      desc: '',
      args: [],
    );
  }

  /// `Làm mới token`
  String get refreshToken {
    return Intl.message(
      'Làm mới token',
      name: 'refreshToken',
      desc: '',
      args: [],
    );
  }

  /// `Token đã được làm mới`
  String get tokenRefreshed {
    return Intl.message(
      'Token đã được làm mới',
      name: 'tokenRefreshed',
      desc: '',
      args: [],
    );
  }

  /// `Trạng thái thông báo`
  String get notificationStatus {
    return Intl.message(
      'Trạng thái thông báo',
      name: 'notificationStatus',
      desc: '',
      args: [],
    );
  }

  /// `Trạng thái quyền`
  String get permissionStatus {
    return Intl.message(
      'Trạng thái quyền',
      name: 'permissionStatus',
      desc: '',
      args: [],
    );
  }

  /// `Mới`
  String get new_book {
    return Intl.message('Mới', name: 'new_book', desc: '', args: []);
  }

  /// `Đọc sách`
  String get read_book {
    return Intl.message('Đọc sách', name: 'read_book', desc: '', args: []);
  }

  /// `Xem chi tiết`
  String get view_details {
    return Intl.message(
      'Xem chi tiết',
      name: 'view_details',
      desc: '',
      args: [],
    );
  }

  /// `Thêm yêu thích`
  String get add_favorite {
    return Intl.message(
      'Thêm yêu thích',
      name: 'add_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Bỏ yêu thích`
  String get remove_favorite {
    return Intl.message(
      'Bỏ yêu thích',
      name: 'remove_favorite',
      desc: '',
      args: [],
    );
  }

  /// `Thêm lưu vào thư viện`
  String get add_archive {
    return Intl.message(
      'Thêm lưu vào thư viện',
      name: 'add_archive',
      desc: '',
      args: [],
    );
  }

  /// `Bỏ lưu vào thư viện`
  String get remove_archive {
    return Intl.message(
      'Bỏ lưu vào thư viện',
      name: 'remove_archive',
      desc: '',
      args: [],
    );
  }

  /// `File ebook không tồn tại`
  String get file_ebook_not_found {
    return Intl.message(
      'File ebook không tồn tại',
      name: 'file_ebook_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Lọc`
  String get filter {
    return Intl.message('Lọc', name: 'filter', desc: '', args: []);
  }

  /// `Tất cả`
  String get all {
    return Intl.message('Tất cả', name: 'all', desc: '', args: []);
  }

  /// `Chưa đọc`
  String get unread {
    return Intl.message('Chưa đọc', name: 'unread', desc: '', args: []);
  }

  /// `Đã đọc`
  String get read {
    return Intl.message('Đã đọc', name: 'read', desc: '', args: []);
  }

  /// `Xóa tất cả`
  String get deleteAll {
    return Intl.message('Xóa tất cả', name: 'deleteAll', desc: '', args: []);
  }

  /// `Bạn có chắc chắn muốn xóa tất cả thông báo?`
  String get areYouSureYouWantToDeleteAllNotifications {
    return Intl.message(
      'Bạn có chắc chắn muốn xóa tất cả thông báo?',
      name: 'areYouSureYouWantToDeleteAllNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả đã đọc`
  String get markAllAsRead {
    return Intl.message(
      'Đánh dấu tất cả đã đọc',
      name: 'markAllAsRead',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả chưa đọc`
  String get markAllAsUnread {
    return Intl.message(
      'Đánh dấu tất cả chưa đọc',
      name: 'markAllAsUnread',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả đã đọc thành công`
  String get markAllAsReadSuccess {
    return Intl.message(
      'Đánh dấu tất cả đã đọc thành công',
      name: 'markAllAsReadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả chưa đọc thành công`
  String get markAllAsUnreadSuccess {
    return Intl.message(
      'Đánh dấu tất cả chưa đọc thành công',
      name: 'markAllAsUnreadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả đã đọc thất bại`
  String get markAllAsReadFailed {
    return Intl.message(
      'Đánh dấu tất cả đã đọc thất bại',
      name: 'markAllAsReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu tất cả chưa đọc thất bại`
  String get markAllAsUnreadFailed {
    return Intl.message(
      'Đánh dấu tất cả chưa đọc thất bại',
      name: 'markAllAsUnreadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Xóa tất cả thông báo thành công`
  String get deleteAllNotificationsSuccess {
    return Intl.message(
      'Xóa tất cả thông báo thành công',
      name: 'deleteAllNotificationsSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Xóa tất cả thông báo thất bại`
  String get deleteAllNotificationsFailed {
    return Intl.message(
      'Xóa tất cả thông báo thất bại',
      name: 'deleteAllNotificationsFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu đã đọc thành công`
  String get markReadSuccess {
    return Intl.message(
      'Đánh dấu đã đọc thành công',
      name: 'markReadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu đã đọc thất bại`
  String get markReadFailed {
    return Intl.message(
      'Đánh dấu đã đọc thất bại',
      name: 'markReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu chưa đọc thành công`
  String get markUnreadSuccess {
    return Intl.message(
      'Đánh dấu chưa đọc thành công',
      name: 'markUnreadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu chưa đọc thất bại`
  String get markUnreadFailed {
    return Intl.message(
      'Đánh dấu chưa đọc thất bại',
      name: 'markUnreadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Xóa thông báo thành công`
  String get deleteNotificationSuccess {
    return Intl.message(
      'Xóa thông báo thành công',
      name: 'deleteNotificationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Xóa thông báo thất bại`
  String get deleteNotificationFailed {
    return Intl.message(
      'Xóa thông báo thất bại',
      name: 'deleteNotificationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu đã đọc thành công`
  String get markAsReadSuccess {
    return Intl.message(
      'Đánh dấu đã đọc thành công',
      name: 'markAsReadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu đã đọc thất bại`
  String get markAsReadFailed {
    return Intl.message(
      'Đánh dấu đã đọc thất bại',
      name: 'markAsReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu chưa đọc thành công`
  String get markAsUnreadSuccess {
    return Intl.message(
      'Đánh dấu chưa đọc thành công',
      name: 'markAsUnreadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu chưa đọc thất bại`
  String get markAsUnreadFailed {
    return Intl.message(
      'Đánh dấu chưa đọc thất bại',
      name: 'markAsUnreadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Xóa thông báo`
  String get deleteNotification {
    return Intl.message(
      'Xóa thông báo',
      name: 'deleteNotification',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu đã đọc`
  String get markAsRead {
    return Intl.message(
      'Đánh dấu đã đọc',
      name: 'markAsRead',
      desc: '',
      args: [],
    );
  }

  /// `Đánh dấu chưa đọc`
  String get markAsUnread {
    return Intl.message(
      'Đánh dấu chưa đọc',
      name: 'markAsUnread',
      desc: '',
      args: [],
    );
  }

  /// `Bạn có`
  String get youHave {
    return Intl.message('Bạn có', name: 'youHave', desc: '', args: []);
  }

  /// `thông báo chưa đọc`
  String get unreadNotifications {
    return Intl.message(
      'thông báo chưa đọc',
      name: 'unreadNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Xóa`
  String get delete {
    return Intl.message('Xóa', name: 'delete', desc: '', args: []);
  }

  /// `Đã xóa thông báo thành công`
  String get notificationDeletedSuccessfully {
    return Intl.message(
      'Đã xóa thông báo thành công',
      name: 'notificationDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Đã xóa thông báo thất bại`
  String get notificationDeletedFailed {
    return Intl.message(
      'Đã xóa thông báo thất bại',
      name: 'notificationDeletedFailed',
      desc: '',
      args: [],
    );
  }

  /// `Đã đánh dấu đã đọc thành công`
  String get notificationMarkedAsReadSuccessfully {
    return Intl.message(
      'Đã đánh dấu đã đọc thành công',
      name: 'notificationMarkedAsReadSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Đã đánh dấu đã đọc thất bại`
  String get notificationMarkedAsReadFailed {
    return Intl.message(
      'Đã đánh dấu đã đọc thất bại',
      name: 'notificationMarkedAsReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Bạn có chắc chắn muốn xóa thông báo này?`
  String get areYouSureYouWantToDeleteNotification {
    return Intl.message(
      'Bạn có chắc chắn muốn xóa thông báo này?',
      name: 'areYouSureYouWantToDeleteNotification',
      desc: '',
      args: [],
    );
  }

  /// `Thêm sách mới vào thư viện`
  String get add_new_book_to_library {
    return Intl.message(
      'Thêm sách mới vào thư viện',
      name: 'add_new_book_to_library',
      desc: '',
      args: [],
    );
  }

  /// `Vui lòng upload file ebook trước`
  String get please_upload_ebook_file_first {
    return Intl.message(
      'Vui lòng upload file ebook trước',
      name: 'please_upload_ebook_file_first',
      desc: '',
      args: [],
    );
  }

  /// `Sách đã được thêm vào thư viện local`
  String get book_has_been_added_to_local_library {
    return Intl.message(
      'Sách đã được thêm vào thư viện local',
      name: 'book_has_been_added_to_local_library',
      desc: '',
      args: [],
    );
  }

  /// `Bạn sẽ nhận được thông báo ở đây`
  String get youWillReceiveNotificationsHere {
    return Intl.message(
      'Bạn sẽ nhận được thông báo ở đây',
      name: 'youWillReceiveNotificationsHere',
      desc: '',
      args: [],
    );
  }

  /// `Tiến độ đọc`
  String get reading_progress {
    return Intl.message(
      'Tiến độ đọc',
      name: 'reading_progress',
      desc: '',
      args: [],
    );
  }

  /// `Hoàn thành`
  String get completed {
    return Intl.message('Hoàn thành', name: 'completed', desc: '', args: []);
  }

  /// `Đọc tiếp`
  String get continue_reading {
    return Intl.message(
      'Đọc tiếp',
      name: 'continue_reading',
      desc: '',
      args: [],
    );
  }

  /// `Bắt đầu đọc`
  String get start_reading {
    return Intl.message(
      'Bắt đầu đọc',
      name: 'start_reading',
      desc: '',
      args: [],
    );
  }

  /// `Kích thước`
  String get size {
    return Intl.message('Kích thước', name: 'size', desc: '', args: []);
  }

  /// `Trang`
  String get pages {
    return Intl.message('Trang', name: 'pages', desc: '', args: []);
  }

  /// `Đọc lần cuối`
  String get last_read {
    return Intl.message('Đọc lần cuối', name: 'last_read', desc: '', args: []);
  }

  /// `Bộ lọc tìm kiếm`
  String get search_filter {
    return Intl.message(
      'Bộ lọc tìm kiếm',
      name: 'search_filter',
      desc: '',
      args: [],
    );
  }

  /// `Đặt lại`
  String get reset {
    return Intl.message('Đặt lại', name: 'reset', desc: '', args: []);
  }

  /// `Tôi đăng tải`
  String get i_uploaded {
    return Intl.message('Tôi đăng tải', name: 'i_uploaded', desc: '', args: []);
  }

  /// `Định dạng`
  String get format {
    return Intl.message('Định dạng', name: 'format', desc: '', args: []);
  }

  /// `EPUB`
  String get epub {
    return Intl.message('EPUB', name: 'epub', desc: '', args: []);
  }

  /// `PDF`
  String get pdf {
    return Intl.message('PDF', name: 'pdf', desc: '', args: []);
  }

  /// `Áp dụng bộ lọc`
  String get apply_filters {
    return Intl.message(
      'Áp dụng bộ lọc',
      name: 'apply_filters',
      desc: '',
      args: [],
    );
  }

  /// `Không tên`
  String get no_name {
    return Intl.message('Không tên', name: 'no_name', desc: '', args: []);
  }

  /// `Đã xóa sách khỏi thư viện`
  String get book_removed_from_library {
    return Intl.message(
      'Đã xóa sách khỏi thư viện',
      name: 'book_removed_from_library',
      desc: '',
      args: [],
    );
  }

  /// `Không tìm thấy sách`
  String get no_books_found {
    return Intl.message(
      'Không tìm thấy sách',
      name: 'no_books_found',
      desc: '',
      args: [],
    );
  }

  /// `Không tìm thấy sách`
  String get no_book_found {
    return Intl.message(
      'Không tìm thấy sách',
      name: 'no_book_found',
      desc: '',
      args: [],
    );
  }

  /// `Bỏ chọn tất cả`
  String get unselect_all {
    return Intl.message(
      'Bỏ chọn tất cả',
      name: 'unselect_all',
      desc: '',
      args: [],
    );
  }

  /// `Chọn tất cả`
  String get select_all {
    return Intl.message('Chọn tất cả', name: 'select_all', desc: '', args: []);
  }

  /// `Dùng 'Chọn file' để duyệt thư mục (ví dụ Download/Telegram)`
  String get use_select_file_to_browse_directory {
    return Intl.message(
      'Dùng \'Chọn file\' để duyệt thư mục (ví dụ Download/Telegram)',
      name: 'use_select_file_to_browse_directory',
      desc: '',
      args: [],
    );
  }

  /// `Không tìm thấy file PDF, EPUB, hoặc MOBI`
  String get no_pdf_epub_mobi_found {
    return Intl.message(
      'Không tìm thấy file PDF, EPUB, hoặc MOBI',
      name: 'no_pdf_epub_mobi_found',
      desc: '',
      args: [],
    );
  }

  /// `Tìm sách`
  String get find_book {
    return Intl.message('Tìm sách', name: 'find_book', desc: '', args: []);
  }

  /// `Tìm sách`
  String get search_book {
    return Intl.message('Tìm sách', name: 'search_book', desc: '', args: []);
  }

  /// `Chọn tất cả sách`
  String get select_all_books {
    return Intl.message(
      'Chọn tất cả sách',
      name: 'select_all_books',
      desc: '',
      args: [],
    );
  }

  /// `Bỏ chọn tất cả sách`
  String get unselect_all_books {
    return Intl.message(
      'Bỏ chọn tất cả sách',
      name: 'unselect_all_books',
      desc: '',
      args: [],
    );
  }

  /// `Quét lại`
  String get scan_again {
    return Intl.message('Quét lại', name: 'scan_again', desc: '', args: []);
  }

  /// `Bạn có chắc chắn muốn xóa sách này?`
  String get delete_book_confirmation_message {
    return Intl.message(
      'Bạn có chắc chắn muốn xóa sách này?',
      name: 'delete_book_confirmation_message',
      desc: '',
      args: [],
    );
  }

  /// `Đã xóa sách thành công`
  String get delete_book_success {
    return Intl.message(
      'Đã xóa sách thành công',
      name: 'delete_book_success',
      desc: '',
      args: [],
    );
  }

  /// `Đã xóa sách thất bại`
  String get delete_book_failed {
    return Intl.message(
      'Đã xóa sách thất bại',
      name: 'delete_book_failed',
      desc: '',
      args: [],
    );
  }

  /// `Đã sửa sách thành công`
  String get edit_book_success {
    return Intl.message(
      'Đã sửa sách thành công',
      name: 'edit_book_success',
      desc: '',
      args: [],
    );
  }

  /// `Đã sửa sách thất bại`
  String get edit_book_failed {
    return Intl.message(
      'Đã sửa sách thất bại',
      name: 'edit_book_failed',
      desc: '',
      args: [],
    );
  }

  /// `File ebook hiện tại không thể thay đổi từ màn hình này.`
  String get current_ebook_file_cannot_be_changed_from_this_screen {
    return Intl.message(
      'File ebook hiện tại không thể thay đổi từ màn hình này.',
      name: 'current_ebook_file_cannot_be_changed_from_this_screen',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật thông tin sách`
  String get update_book_info {
    return Intl.message(
      'Cập nhật thông tin sách',
      name: 'update_book_info',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật sách thành công!`
  String get update_book_success {
    return Intl.message(
      'Cập nhật sách thành công!',
      name: 'update_book_success',
      desc: '',
      args: [],
    );
  }

  /// `Tạo sách mới thành công!`
  String get create_book_success {
    return Intl.message(
      'Tạo sách mới thành công!',
      name: 'create_book_success',
      desc: '',
      args: [],
    );
  }

  /// `Có lỗi xảy ra`
  String get error_occurred {
    return Intl.message(
      'Có lỗi xảy ra',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Cập nhật sách`
  String get update_book {
    return Intl.message(
      'Cập nhật sách',
      name: 'update_book',
      desc: '',
      args: [],
    );
  }

  /// `Đang cập nhật...`
  String get updating_book {
    return Intl.message(
      'Đang cập nhật...',
      name: 'updating_book',
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
