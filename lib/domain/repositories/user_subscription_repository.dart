import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class UserSubscriptionRepository {
  final UserSubscriptionRemoteDataSource remoteDataSource;

  UserSubscriptionRepository({required this.remoteDataSource});

  Future<UserSubscriptionModel> getMe() async {
    try {
      return await remoteDataSource.getMe();
    } catch (e) {
      throw Exception('Failed to get user subscription me: $e');
    }
  }
}
