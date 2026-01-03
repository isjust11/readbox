import 'package:readbox/domain/data/models/models.dart';    
import 'package:readbox/domain/network/network.dart';

class AuthRemoteDataSource {
  final Network network;

  AuthRemoteDataSource({required this.network});

  Future<AuthenModel> login(Map<String, dynamic> param) async {
    ApiResponse apiResponse = await network.post(url: '${ApiConstant.apiHost}${ApiConstant.login}', body: param);
    if (apiResponse.isSuccess) {
      return AuthenModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<UserModel> register(Map<String, dynamic> param) async {
    ApiResponse apiResponse = await network.post(url: '${ApiConstant.apiHost}${ApiConstant.register}', body: param);
    if (apiResponse.isSuccess) {
      
      
      final registerResult = UserRegisterModel.fromJson(apiResponse.data ?? {});
      if (registerResult.code == 'ok') {
        return registerResult.data ?? UserModel.fromJson({});
      }
      return Future.error(registerResult.message ?? '');
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<AuthenModel> verifyPin(Map<String, dynamic> param) async {
    ApiResponse apiResponse = await network.post(url: '${ApiConstant.apiHost}${ApiConstant.verifyPin}', body: param);
    if (apiResponse.isSuccess) {
      return AuthenModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<Map<String, dynamic>> resendPin(Map<String, dynamic> param) async {
    ApiResponse apiResponse = await network.post(url: '${ApiConstant.apiHost}${ApiConstant.resendPin}', body: param);
    if (apiResponse.isSuccess) {
      return apiResponse.data ?? {'message': 'PIN đã được gửi lại'};
    }
    return Future.error(apiResponse.errMessage);
  }
}
