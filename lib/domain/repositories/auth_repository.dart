import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class AuthRepository {
  AuthRemoteDataSource remoteDataSource;
  UserLocalDataSource localDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<UserModel> login(Map<String, dynamic> param) async {
    UserModel userModel = await remoteDataSource.login(param);
    await localDataSource.saveToken(userModel.token ?? '');
    await localDataSource.saveUserInfo(userModel);
    return userModel;
  }

  Future<UserModel> register(Map<String, dynamic> param) async {
    UserModel userModel = await remoteDataSource.register(param);
    await localDataSource.saveUserInfo(userModel);
    return userModel;
  }

  Future<UserModel> verifyPin(Map<String, dynamic> param) async {
    UserModel userModel = await remoteDataSource.verifyPin(param);
    await localDataSource.saveToken(userModel.token ?? '');
    await localDataSource.saveUserInfo(userModel);
    return userModel;
  }
}
