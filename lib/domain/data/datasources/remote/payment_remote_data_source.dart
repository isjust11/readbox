import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class PaymentRemoteDataSource {
  final Network network;

  PaymentRemoteDataSource({required this.network});

  /// Tạo payment và lấy payment URL
  Future<PaymentModel> createPayment({
    required String planId,
    required String paymentMethod, // 'vnpay', 'momo', 'zalopay'
    String? bankCode,
    int? periodMonths,
    int? discountPercentage,
  }) async {
    final url = '${ApiConstant.apiHost}payment/create';
    final body = {
      'planId': planId,
      if (periodMonths != null) 'periodMonths': periodMonths,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
      'paymentMethod': paymentMethod,
      if (bankCode != null) 'bankCode': bankCode,
    };

    final ApiResponse apiResponse = await network.post(url: url, body: body);

    if (apiResponse.isSuccess && apiResponse.data != null) {
      return PaymentModel.fromJson(
        Map<String, dynamic>.from(apiResponse.data as Map),
      );
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Kiểm tra trạng thái payment
  Future<PaymentStatusModel> getPaymentStatus(String transactionId) async {
    final url = '${ApiConstant.apiHost}payment/$transactionId/status';
    final ApiResponse apiResponse = await network.get(url: url);

    if (apiResponse.isSuccess && apiResponse.data != null) {
      return PaymentStatusModel.fromJson(
        Map<String, dynamic>.from(apiResponse.data as Map),
      );
    }
    return Future.error(apiResponse.errMessage);
  }

  /// Lấy danh sách lịch sử thanh toán
  Future<List<PaymentHistoryModel>> getPaymentHistory() async {
    final url = '${ApiConstant.apiHost}payment/history';
    final ApiResponse apiResponse = await network.get(url: url);

    if (apiResponse.isSuccess && apiResponse.data != null) {
      return (apiResponse.data as List)
          .map(
            (e) => PaymentHistoryModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    return Future.error(apiResponse.errMessage);
  }
}
