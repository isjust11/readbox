import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepository({required this.remoteDataSource});

  Future<List<SubscriptionPlanModel>> getPlans({bool activeOnly = true}) async 
    => await remoteDataSource.getPlans(activeOnly: activeOnly);

  Future<UserSubscriptionModel> createSubscriptionPlan(String planId) async 
    => await remoteDataSource.createSubscriptionPlan(planId);
  

  Future<Map<String, bool>> checkUsage() async 
    => await remoteDataSource.checkUsage();
}
