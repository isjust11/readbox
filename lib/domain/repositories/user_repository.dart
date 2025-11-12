import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class UserRepository {
  final UserLocalDataSource userLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  UserRepository({required this.userLocalDataSource, required this.userRemoteDataSource});

  Future<UserModel> getUserInfo() async {
    UserModel? userModel;
    try {
      userModel = await userRemoteDataSource.getUserInfo();
    } catch (e) {
      userModel = await userLocalDataSource.getUserInfo();
    }
    if (userModel == null) {
      return Future.error(NotFoundException());
    }
    return userModel;
  }
}
