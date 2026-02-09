import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class SubscriptionRemoteDataSource {
  final Network network;

  SubscriptionRemoteDataSource({required this.network});

  /// Lấy danh sách gói dịch vụ (chỉ gói đang bán khi activeOnly = true)
  Future<List<SubscriptionPlanModel>> getPlans({bool activeOnly = true}) async {
    final url = '${ApiConstant.apiHost}${ApiConstant.subscriptionPlans}';
    final ApiResponse apiResponse = await network.get(
      url: url,
      params: {'activeOnly': activeOnly.toString()},
    );
    if (apiResponse.isSuccess && apiResponse.data != null) {
      final raw = apiResponse.data;
      List list = [];
      if (raw is List) {
        list = raw;
      } else if (raw is Map && raw['data'] != null) {
        list = raw['data'] is List ? raw['data'] as List : [];
      }
      return list
          .map((e) => SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return Future.error(apiResponse.errMessage ?? 'Failed to load plans');
  }
}
