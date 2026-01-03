import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class ResendPinCubit extends Cubit<BaseState> {
  final AuthRepository repository;

  ResendPinCubit({required this.repository}) : super(InitState());

  Future<void> resendPin({required String email}) async {
    try {
      emit(LoadingState());
      final result = await repository.resendPin({"email": email});
      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}

