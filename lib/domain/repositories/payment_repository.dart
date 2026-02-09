import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepository({required this.remoteDataSource});

  Future<PaymentModel> createPayment({
    required int planId,
    required String paymentMethod,
    String? bankCode,
  }) async {
    try {
      return await remoteDataSource.createPayment(
        planId: planId,
        paymentMethod: paymentMethod,
        bankCode: bankCode,
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
}
