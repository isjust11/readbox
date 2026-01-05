import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class AuthRepository {
  AuthRemoteDataSource remoteDataSource;
  UserLocalDataSource localDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<AuthenModel> login(Map<String, dynamic> param) async {
    AuthenModel authenModel = await remoteDataSource.login(param);
    await localDataSource.saveToken(authenModel.accessToken ?? '');
    await localDataSource.saveUserInfo(authenModel.user ?? UserModel.fromJson({}));
    return authenModel;
  }

  Future<UserModel> register(Map<String, dynamic> param) async {
    UserModel userModel = await remoteDataSource.register(param);
    await localDataSource.saveUserInfo(userModel);
    return userModel;
  }

  Future<bool> verifyPin(Map<String, dynamic> param) async {
    bool isSuccess = await remoteDataSource.verifyPin(param);
    return isSuccess;
  }

  Future<bool> resendPin(Map<String, dynamic> param) async {
    return await remoteDataSource.resendPin(param);
  }
}
