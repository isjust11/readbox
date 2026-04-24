import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class UserSubscriptionRemoteDataSource {
  final Network network;

  UserSubscriptionRemoteDataSource({required this.network});

  /// Lấy thông tin gói dịch vụ hiện tại của user
  Future<UserSubscriptionModel?> getMe() async {
    final url = '${ApiConstant.apiHost}${ApiConstant.subscriptionMe}';
    final ApiResponse apiResponse = await network.get(url: url);
    if (apiResponse.isSuccess && apiResponse.data != null) {
      final raw = apiResponse.data['subscription'];
      if (raw == null) {
        return null;
      }
      return UserSubscriptionModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Lấy lịch sử gói dịch vụ của user
  Future<List<UserSubscriptionModel>> getHistory() async {
    final url = '${ApiConstant.apiHost}${ApiConstant.subscriptionHistory}';
    final ApiResponse apiResponse = await network.get(url: url);
    if (apiResponse.isSuccess && apiResponse.data != null) {
      final raw = apiResponse.data;
      return List<UserSubscriptionModel>.from(
        raw.map((e) => UserSubscriptionModel.fromJson(e)),
      );
    }
    return Future.error(apiResponse.errMessage);
  }
}
