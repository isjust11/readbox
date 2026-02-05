import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as s_store ;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:readbox/domain/data/models/models.dart';

/// Service quản lý lưu trữ dữ liệu nhạy cảm (token, password, user info)
/// Sử dụng FlutterSecureStorage để mã hóa dữ liệu
class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Keys cho secure storage
  static const String _keyToken = 'secure_auth_token';
  static const String _keyRefreshToken = 'secure_refresh_token';
  static const String _keyUserInfo = 'secure_user_info';
  static const String _keyUsername = 'secure_username';
  static const String _keyPassword = 'secure_password';
  static const String _keySocialLoginInfo = 'secure_social_login_info';

  // Cấu hình Flutter Secure Storage với bảo mật cao
  static const s_store.FlutterSecureStorage _secureStorage = s_store.FlutterSecureStorage(
    aOptions: s_store.AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true, // Reset nếu có lỗi decrypt
    ),
    iOptions: s_store.IOSOptions(
      accessibility: s_store.KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    lOptions: s_store.LinuxOptions(),
    wOptions: s_store.WindowsOptions(),
    mOptions: s_store.MacOsOptions(
      accessibility: s_store.KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
  );

  // ==================== TOKEN MANAGEMENT ====================

  /// Lưu access token
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (e) {
      log('❌ Error saving token: $e');
      rethrow;
    }
  }

  /// Lấy access token
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } catch (e) {
      log('❌ Error reading token: $e');
      return null;
    }
  }

  /// Xóa token
  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (e) {
      log('❌ Error deleting token: $e');
    }
  }

  /// Lưu refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    } catch (e) {
      log('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Lấy refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      log('❌ Error reading refresh token: $e');
      return null;
    }
  }

  // ==================== USER INFO MANAGEMENT ====================

  /// Lưu thông tin user (bao gồm cả email, phone - dữ liệu nhạy cảm)
  Future<void> saveUserInfo(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await _secureStorage.write(key: _keyUserInfo, value: userJson);
    } catch (e) {
      log('❌ Error saving user info: $e');
      rethrow;
    }
  }

  /// Lấy thông tin user
  Future<UserModel?> getUserInfo() async {
    try {
      final userJson = await _secureStorage.read(key: _keyUserInfo);
      if (userJson == null) return null;
      return UserModel.fromJson(json.decode(userJson));
    } catch (e) {
      log('❌ Error reading user info: $e');
      return null;
    }
  }

  /// Xóa thông tin user
  Future<void> deleteUserInfo() async {
    try {
      await _secureStorage.delete(key: _keyUserInfo);
    } catch (e) {
      log('❌ Error deleting user info: $e');
    }
  }

  // ==================== CREDENTIALS MANAGEMENT (for biometric) ====================

  /// Lưu username và password cho biometric login
  Future<void> saveCredentials(String username, String password) async {
    try {
      await _secureStorage.write(key: _keyUsername, value: username);
      await _secureStorage.write(key: _keyPassword, value: password);
    } catch (e) {
      log('❌ Error saving credentials: $e');
      rethrow;
    }
  }

  /// Lấy credentials đã lưu
  Future<Map<String, String>?> getCredentials() async {
    try {
      final username = await _secureStorage.read(key: _keyUsername);
      final password = await _secureStorage.read(key: _keyPassword);
      
      if (username != null && password != null) {
        return {
          'username': username,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      log('❌ Error reading credentials: $e');
      return null;
    }
  }

  /// Xóa credentials
  Future<void> deleteCredentials() async {
    try {
      await _secureStorage.delete(key: _keyUsername);
      await _secureStorage.delete(key: _keyPassword);
    } catch (e) {
      log('❌ Error deleting credentials: $e');
    }
  }

  // ==================== SOCIAL LOGIN INFO ====================

  /// Lưu thông tin social login (Google, Facebook)
  Future<void> saveSocialLoginInfo(Map<String, dynamic> socialInfo) async {
    try {
      final socialJson = json.encode(socialInfo);
      await _secureStorage.write(key: _keySocialLoginInfo, value: socialJson);
    } catch (e) {
      log('❌ Error saving social login info: $e');
      rethrow;
    }
  }

  /// Lấy thông tin social login
  Future<Map<String, dynamic>?> getSocialLoginInfo() async {
    try {
      final socialJson = await _secureStorage.read(key: _keySocialLoginInfo);
      if (socialJson == null) return null;
      return json.decode(socialJson);
    } catch (e) {
      log('❌ Error reading social login info: $e');
      return null;
    }
  }

  /// Xóa thông tin social login
  Future<void> deleteSocialLoginInfo() async {
    try {
      await _secureStorage.delete(key: _keySocialLoginInfo);
    } catch (e) {
      log('❌ Error deleting social login info: $e');
    }
  }

  // ==================== CLEAR ALL DATA ====================

  /// Xóa tất cả dữ liệu nhạy cảm (logout)
  Future<void> clearAllSecureData() async {
    try {
      await Future.wait([
        deleteToken(),
        _secureStorage.delete(key: _keyRefreshToken),
        deleteUserInfo(),
        deleteCredentials(),
        deleteSocialLoginInfo(),
      ]);
      log('✅ All secure data cleared');
    } catch (e) {
      log('❌ Error clearing secure data: $e');
      // Fallback: xóa toàn bộ secure storage
      await _secureStorage.deleteAll();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Kiểm tra xem có token không (đã đăng nhập)
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Kiểm tra xem có credentials được lưu không
  Future<bool> hasStoredCredentials() async {
    final credentials = await getCredentials();
    return credentials != null;
  }

  /// Kiểm tra xem có social login info không
  Future<bool> hasSocialLoginInfo() async {
    final socialInfo = await getSocialLoginInfo();
    return socialInfo != null;
  }

  /// Debug: In tất cả keys trong secure storage
  Future<void> debugPrintAllKeys() async {
    try {
      final allData = await _secureStorage.readAll();
      log('🔐 Secure Storage Keys: ${allData.keys.toList()}');
    } catch (e) {
      log('❌ Error reading all keys: $e');
    }
  }

  // ==================== MIGRATION FROM SHARED PREFERENCES ====================
  
  /// Di chuyển dữ liệu cũ từ SharedPreferences sang SecureStorage
  /// Gọi method này khi app khởi động lần đầu sau khi update
  Future<bool> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Kiểm tra xem đã migration chưa
      final hasAlreadyMigrated = prefs.getBool('_has_migrated_to_secure_storage') ?? false;
      if (hasAlreadyMigrated) {
        log('ℹ️ Already migrated, skipping...');
        return false;
      }

      bool hasMigrated = false;

      // 1. Migrate token
      final oldToken = prefs.getString('auth_token');
      if (oldToken != null && oldToken.isNotEmpty) {
        await saveToken(oldToken);
        await prefs.remove('auth_token');
        hasMigrated = true;
        log('✅ Migrated token from SharedPreferences');
      }

      // 2. Migrate user info
      final oldUserInfo = prefs.getString('pref_key_user_info');
      if (oldUserInfo != null && oldUserInfo.isNotEmpty) {
        try {
          final userJson = json.decode(oldUserInfo);
          final user = UserModel.fromJson(userJson);
          await saveUserInfo(user);
          await prefs.remove('pref_key_user_info');
          hasMigrated = true;
          log('✅ Migrated user info from SharedPreferences');
        } catch (e) {
          log('⚠️ Failed to migrate user info: $e');
        }
      }

      // Đánh dấu đã migration (dù có migrate hay không để tránh check lại)
      await prefs.setBool('_has_migrated_to_secure_storage', true);
      
      if (hasMigrated) {
        log('✅ Migration completed successfully');
      } else {
        log('ℹ️ No old data to migrate');
      }

      return hasMigrated;
    } catch (e) {
      log('❌ Migration error: $e');
      return false;
    }
  }
}
