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
}
