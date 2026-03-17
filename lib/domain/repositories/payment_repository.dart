import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepository({required this.remoteDataSource});

  Future<PaymentModel> createPayment({
    required String planId,
    required String paymentMethod,
    String? bankCode,
    int? periodMonths,
    int? discountPercentage,
  }) async {
    try {
      return await remoteDataSource.createPayment(
        planId: planId,
        paymentMethod: paymentMethod,
        bankCode: bankCode,
        periodMonths: periodMonths,
        discountPercentage: discountPercentage,
      );
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<PaymentStatusModel> getPaymentStatus(String transactionId) async {
    try {
      return await remoteDataSource.getPaymentStatus(transactionId);
    } catch (e) {
      throw Exception('Failed to get payment status: $e');
    }
  }

  Future<List<PaymentHistoryModel>> getPaymentHistory() async {
    try {
      return await remoteDataSource.getPaymentHistory();
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }
}
