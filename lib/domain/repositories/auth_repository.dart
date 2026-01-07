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

  Future<dynamic> forgotPassword(Map<String, dynamic> param) async {
    return await remoteDataSource.forgotPassword(param);
  }

   Future<UserModel?> getProfile() async {
    return await localDataSource.getUserInfo();
  }


  Future<AuthenModel> mobileSocialLogin(Map<String, dynamic> param) async {
    AuthenModel authModel = await remoteDataSource.mobileSocialLogin(param);
    await localDataSource.saveToken(authModel.accessToken ?? '');
    await localDataSource.saveUserInfo(authModel.user!);
    return authModel;
  }

  Future<UserModel> updateProfile(UserModel updatedUserModel) async {
    Map<String, dynamic> param = <String, dynamic>{};
    param['fullName'] = updatedUserModel.fullName;
    param['email'] = updatedUserModel.email;
    param['picture'] = updatedUserModel.picture;
    param['phoneNumber'] = updatedUserModel.phoneNumber;
    param['address'] = updatedUserModel.address;
    param['birthDate'] = updatedUserModel.birthDate;
    param['facebookLink'] = updatedUserModel.facebookLink;
    param['instagramLink'] = updatedUserModel.instagramLink;
    param['twitterLink'] = updatedUserModel.twitterLink;
    param['linkedinLink'] = updatedUserModel.linkedinLink;
    UserModel userModel = await remoteDataSource.updateProfile(param);
    await localDataSource.saveUserInfo(userModel);
    return userModel;
  }
}
