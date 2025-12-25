import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/utils/shared_preference.dart';

class UserLocalDataSource {
  Future<UserModel?> getUserInfo() {
    return SharedPreferenceUtil.getUserInfo();
  }

  Future<bool> saveUserInfo(UserModel userModel) async {
    try {
      return await SharedPreferenceUtil.saveUserInfo(userModel);
    } catch (e) {}
    return false;
  }

  Future<bool> saveToken(String token) async {
    try {
      return await SharedPreferenceUtil.saveToken(token);
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      return await SharedPreferenceUtil.getToken();
    } catch (e) {
      return '';
    }
  }
}
