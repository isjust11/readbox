import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _storedCredentialsKey = 'stored_credentials';
  static const String _storedSocialLoginKey = 'stored_social_login';

  // Cấu hình Flutter Secure Storage với bảo mật cao
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    lOptions: LinuxOptions(),
    wOptions: WindowsOptions(),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  /// Kiểm tra xem thiết bị có hỗ trợ sinh trắc học không
  static Future<bool> isBiometricSupported() async {
    try {
      final bool isAvailable = await _localAuth.isDeviceSupported();
      return isAvailable;
    } on PlatformException catch (e) {
      // Log error in development mode
      assert(() {
        print('Error checking biometric support: $e');
        return true;
      }());
      return false;
    }
  }

  /// Kiểm tra xem có sinh trắc học nào được đăng ký không
  static Future<bool> isBiometricEnrolled() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } on PlatformException catch (e) {
      // Log error in development mode
      assert(() {
        print('Error checking biometric enrollment: $e');
        return true;
      }());
      return false;
    }
  }

  /// Lấy danh sách các loại sinh trắc học khả dụng
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await _localAuth
          .getAvailableBiometrics();
      return availableBiometrics;
    } on PlatformException catch (e) {
      // Log error in development mode
      assert(() {
        print('Error getting available biometrics: $e');
        return true;
      }());
      return [];
    }
  }

  /// Xác thực sinh trắc học
  static Future<BiometricAuthResult> authenticateWithBiometrics({
    String localizedReason = 'Vui lòng xác thực để đăng nhập',
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failure('Xác thực thất bại');
      }
    } on PlatformException catch (e) {
      String message;
      switch (e.code) {
        case auth_error.notAvailable:
          message = 'Sinh trắc học không khả dụng trên thiết bị này';
          break;
        case auth_error.notEnrolled:
          message =
              'Chưa thiết lập sinh trắc học. Vui lòng thiết lập trong Cài đặt';
          break;
        case auth_error.lockedOut:
          message = 'Quá nhiều lần thử. Vui lòng thử lại sau';
          break;
        case auth_error.permanentlyLockedOut:
          message =
              'Sinh trắc học bị khóa vĩnh viễn. Vui lòng sử dụng mật khẩu';
          break;
        default:
          message = 'Lỗi xác thực: ${e.message}';
      }
      return BiometricAuthResult.failure(message);
    }
  }

  /// Kiểm tra trạng thái bật/tắt sinh trắc học trong ứng dụng
  static Future<bool> isBiometricEnabledInApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Bật/tắt sinh trắc học trong ứng dụng
  static Future<void> setBiometricEnabledInApp(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  /// Lưu thông tin đăng nhập (được mã hóa an toàn)
  static Future<void> storeCredentials(String username, String password) async {
    try {
      // Lưu username và password riêng biệt để bảo mật tốt hơn
      await _secureStorage.write(
        key: '${_storedCredentialsKey}_username',
        value: username,
      );
      await _secureStorage.write(
        key: '${_storedCredentialsKey}_password',
        value: password,
      );
    } catch (e) {
      // Fallback to SharedPreferences nếu secure storage thất bại
      assert(() {
        print(
          'Error writing to secure storage, falling back to SharedPreferences: $e',
        );
        return true;
      }());

      final prefs = await SharedPreferences.getInstance();
      final credentials = '$username:$password';
      await prefs.setString(_storedCredentialsKey, credentials);
    }
  }

  /// Lấy thông tin đăng nhập đã lưu
  static Future<Map<String, String>?> getStoredCredentials() async {
    try {
      // Thử lấy từ Secure Storage trước
      final username = await _secureStorage.read(
        key: '${_storedCredentialsKey}_username',
      );
      final password = await _secureStorage.read(
        key: '${_storedCredentialsKey}_password',
      );

      if (username != null && password != null) {
        return {'username': username, 'password': password};
      }
    } catch (e) {
      // Nếu lỗi, thử fallback to SharedPreferences
      assert(() {
        print(
          'Error reading from secure storage, falling back to SharedPreferences: $e',
        );
        return true;
      }());
    }

    // Fallback to SharedPreferences (cho các thiết bị cũ hoặc khi có lỗi)
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString(_storedCredentialsKey);

      if (credentials != null && credentials.contains(':')) {
        final parts = credentials.split(':');
        if (parts.length == 2) {
          // Migration: chuyển từ SharedPreferences sang Secure Storage
          await _migrateToSecureStorage(parts[0], parts[1]);
          return {'username': parts[0], 'password': parts[1]};
        }
      }
    } catch (e) {
      assert(() {
        print('Error reading from SharedPreferences: $e');
        return true;
      }());
    }

    return null;
  }

  /// Xóa thông tin đăng nhập đã lưu
  static Future<void> clearStoredCredentials() async {
    try {
      // Xóa từ Secure Storage
      await _secureStorage.delete(key: '${_storedCredentialsKey}_username');
      await _secureStorage.delete(key: '${_storedCredentialsKey}_password');
    } catch (e) {
      assert(() {
        print('Error clearing secure storage: $e');
        return true;
      }());
    }

    // Cũng xóa từ SharedPreferences để đảm bảo
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storedCredentialsKey);
    } catch (e) {
      assert(() {
        print('Error clearing SharedPreferences: $e');
        return true;
      }());
    }
  }

  /// Lưu thông tin đăng nhập social (Google/Facebook)
  static Future<void> storeSocialLoginInfo(
    Map<String, dynamic> socialData,
  ) async {
    try {
      await _secureStorage.write(
        key: _storedSocialLoginKey,
        value: jsonEncode(socialData),
      );
    } catch (e) {
      // Fallback to SharedPreferences nếu secure storage thất bại
      assert(() {
        print(
          'Error writing social login to secure storage, falling back to SharedPreferences: $e',
        );
        return true;
      }());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storedSocialLoginKey, jsonEncode(socialData));
    }
  }

  /// Lấy thông tin đăng nhập social đã lưu
  static Future<Map<String, dynamic>?> getStoredSocialLoginInfo() async {
    try {
      // Thử lấy từ Secure Storage trước
      final socialData = await _secureStorage.read(key: _storedSocialLoginKey);
      if (socialData != null) {
        return jsonDecode(socialData);
      }
    } catch (e) {
      // Nếu lỗi, thử fallback to SharedPreferences
      assert(() {
        print(
          'Error reading social login from secure storage, falling back to SharedPreferences: $e',
        );
        return true;
      }());
    }

    // Fallback to SharedPreferences (cho các thiết bị cũ hoặc khi có lỗi)
    try {
      final prefs = await SharedPreferences.getInstance();
      final socialData = prefs.getString(_storedSocialLoginKey);

      if (socialData != null) {
        return jsonDecode(socialData);
      }
    } catch (e) {
      assert(() {
        print('Error reading social login from SharedPreferences: $e');
        return true;
      }());
    }

    return null;
  }

  /// Xóa thông tin đăng nhập social đã lưu
  static Future<void> clearStoredSocialLoginInfo() async {
    try {
      // Xóa từ Secure Storage
      await _secureStorage.delete(key: _storedSocialLoginKey);
    } catch (e) {
      assert(() {
        print('Error clearing social login from secure storage: $e');
        return true;
      }());
    }

    // Cũng xóa từ SharedPreferences để đảm bảo
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storedSocialLoginKey);
    } catch (e) {
      assert(() {
        print('Error clearing social login from SharedPreferences: $e');
        return true;
      }());
    }
  }

  /// Xóa tất cả thông tin đăng nhập (cả traditional và social)
  static Future<void> clearAllStoredLoginInfo() async {
    await Future.wait([clearStoredCredentials(), clearStoredSocialLoginInfo()]);
  }

  /// Migration helper: chuyển dữ liệu từ SharedPreferences sang Secure Storage
  static Future<void> _migrateToSecureStorage(
    String username,
    String password,
  ) async {
    try {
      // Lưu vào Secure Storage
      await storeCredentials(username, password);

      // Xóa khỏi SharedPreferences sau khi migration thành công
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storedCredentialsKey);

      assert(() {
        print('Successfully migrated credentials to secure storage');
        return true;
      }());
    } catch (e) {
      assert(() {
        print('Failed to migrate credentials to secure storage: $e');
        return true;
      }());
    }
  }

  /// Kiểm tra toàn diện khả năng sử dụng sinh trắc học
  static Future<BiometricCapability> checkBiometricCapability() async {
    final bool isSupported = await isBiometricSupported();
    if (!isSupported) {
      return BiometricCapability.notSupported;
    }

    final bool isEnrolled = await isBiometricEnrolled();
    if (!isEnrolled) {
      return BiometricCapability.notEnrolled;
    }

    final List<BiometricType> availableBiometrics =
        await getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      return BiometricCapability.notAvailable;
    }

    return BiometricCapability.available;
  }

  /// Đăng nhập bằng sinh trắc học
  static Future<BiometricAuthResult> loginWithBiometrics() async {
    try {
      // Kiểm tra xem có bật sinh trắc học không
      final bool isEnabled = await isBiometricEnabledInApp();
      if (!isEnabled) {
        return BiometricAuthResult.failure(
          'Đăng nhập bằng sinh trắc học chưa được bật',
        );
      }

      // Kiểm tra khả năng sinh trắc học
      final capability = await checkBiometricCapability();
      if (capability != BiometricCapability.available) {
        return BiometricAuthResult.failure(_getCapabilityMessage(capability));
      }

      // Thực hiện xác thực sinh trắc học
      final authResult = await authenticateWithBiometrics(
        localizedReason: 'Xác thực để đăng nhập vào ứng dụng',
      );

      if (!authResult.isSuccess) {
        return authResult;
      }

      // Kiểm tra social login info trước
      final socialInfo = await getStoredSocialLoginInfo();
      if (socialInfo != null) {
        return BiometricAuthResult.success(
          data: socialInfo,
          isSocialLogin: true,
        );
      }

      // Fallback to traditional credentials
      final credentials = await getStoredCredentials();
      if (credentials != null) {
        return BiometricAuthResult.success(
          data: credentials,
          isSocialLogin: false,
        );
      }

      return BiometricAuthResult.failure(
        'Chưa có thông tin đăng nhập được lưu',
      );
    } catch (e) {
      return BiometricAuthResult.failure('Lỗi đăng nhập: $e');
    }
  }

  static String _getCapabilityMessage(BiometricCapability capability) {
    switch (capability) {
      case BiometricCapability.notSupported:
        return 'Thiết bị không hỗ trợ sinh trắc học';
      case BiometricCapability.notEnrolled:
        return 'Chưa thiết lập sinh trắc học. Vui lòng thiết lập trong Cài đặt';
      case BiometricCapability.notAvailable:
        return 'Sinh trắc học không khả dụng';
      case BiometricCapability.available:
        return 'Sinh trắc học khả dụng';
    }
  }
}

/// Enum cho khả năng sinh trắc học
enum BiometricCapability { available, notSupported, notEnrolled, notAvailable }

/// Kết quả xác thực sinh trắc học
class BiometricAuthResult {
  final bool isSuccess;
  final String? message;
  final Map<String, dynamic>? data;
  final bool isSocialLogin;

  BiometricAuthResult._({
    required this.isSuccess,
    this.message,
    this.data,
    this.isSocialLogin = false,
  });

  factory BiometricAuthResult.success({
    Map<String, dynamic>? data,
    bool isSocialLogin = false,
  }) {
    return BiometricAuthResult._(
      isSuccess: true,
      data: data,
      isSocialLogin: isSocialLogin,
    );
  }

  factory BiometricAuthResult.failure(String message) {
    return BiometricAuthResult._(isSuccess: false, message: message);
  }
}
