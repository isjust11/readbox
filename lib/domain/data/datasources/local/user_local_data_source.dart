import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/services/secure_storage_service.dart';

/// Local data source cho user data
/// Sử dụng SecureStorage cho dữ liệu nhạy cảm (token, user info)
class UserLocalDataSource {
  final SecureStorageService _secureStorage = SecureStorageService();

  /// Lấy thông tin user từ secure storage
  Future<UserModel?> getUserInfo() async {
    try {
      return await _secureStorage.getUserInfo();
    } catch (e) {
      print('❌ Error getting user info: $e');
      return null;
    }
  }

  /// Lưu thông tin user vào secure storage
  Future<bool> saveUserInfo(UserModel userModel) async {
    try {
      await _secureStorage.saveUserInfo(userModel);
      return true;
    } catch (e) {
      print('❌ Error saving user info: $e');
      return false;
    }
  }

  /// Lưu token vào secure storage
  Future<bool> saveToken(String token) async {
    try {
      await _secureStorage.saveToken(token);
      return true;
    } catch (e) {
      print('❌ Error saving token: $e');
      return false;
    }
  }

  /// Lấy token từ secure storage
  Future<String?> getToken() async {
    try {
      return await _secureStorage.getToken();
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  /// Xóa tất cả dữ liệu user (logout)
  Future<void> clearAllData() async {
    try {
      await _secureStorage.clearAllSecureData();
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }
  }
}
