import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepository({required this.remoteDataSource});

  Future<List<SubscriptionPlanModel>> getPlans({bool activeOnly = true}) async {
    try {
      return await remoteDataSource.getPlans(activeOnly: activeOnly);
    } catch (e) {
      throw Exception('Failed to get subscription plans: $e');
    }
  }

  Future<UserSubscriptionModel> createSubscriptionPlan(String planId) async {
    try {
      return await remoteDataSource.createSubscriptionPlan(planId);
    } catch (e) {
      throw Exception('Failed to create subscription plan: $e');
    }
  }
}
