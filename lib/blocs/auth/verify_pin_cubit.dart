import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class VerifyPinCubit extends Cubit<BaseState> {
  final AuthRepository repository;

  VerifyPinCubit({required this.repository}) : super(InitState());

  verifyPin({String? email, String? pin}) async {
    try {
      emit(LoadingState());
      UserModel userModel = await repository.verifyPin({
        "email": email,
        "pin": pin,
      });
      emit(LoadedState(userModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
