import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class VerifyPinCubit extends Cubit<BaseState> {
  final AuthRepository repository;

  VerifyPinCubit({required this.repository}) : super(InitState());

  verifyPin({String? email, String? pin}) async {
    try {
      emit(LoadingState());
      bool isSuccess = await repository.verifyPin({
        "email": email,
        "pin": pin,
      });
      if (isSuccess) {
        emit(LoadedState(true));
      } else {
        emit(ErrorState(BlocUtils.getMessageError('Mã PIN không hợp lệ')));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  resendPin({String? email}) async {
    try {
      emit(LoadingState());
      bool isSuccess = await repository.resendPin({
        "email": email,
      });
      if (isSuccess) {
        emit(LoadedState(true));
      } else {
        emit(ErrorState(BlocUtils.getMessageError('Mã PIN không hợp lệ')));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
