import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class PaymentCubit extends Cubit<BaseState> {
  final PaymentRepository repository;

  PaymentCubit({required this.repository}) : super(InitState());

  /// Tạo payment cho gói dịch vụ
  Future<void> createPayment({
    required String planId,
    required String paymentMethod,
    String? bankCode,
  }) async {
    try {
      emit(LoadingState());
      final payment = await repository.createPayment(
        planId: planId,
        paymentMethod: paymentMethod,
        bankCode: bankCode,
      );
      emit(LoadedState<PaymentModel>(payment));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Kiểm tra trạng thái payment
  Future<void> checkPaymentStatus(String transactionId) async {
    try {
      emit(LoadingState());
      final status = await repository.getPaymentStatus(transactionId);
      emit(LoadedState<PaymentStatusModel>(status));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}

