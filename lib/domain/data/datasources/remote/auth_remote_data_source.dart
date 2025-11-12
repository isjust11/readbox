import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class AuthRemoteDataSource {
  final Network network;

  AuthRemoteDataSource({required this.network});

  Future<UserModel> login(Map<String, dynamic> param) async {
    ApiResponse apiResponse = await network.post(url: ApiConstant.login, params: param);
    if (apiResponse.isSuccess) {
      return UserModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.errMessage);
  }
}
