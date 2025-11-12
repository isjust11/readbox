import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class RegisterCubit extends Cubit<BaseState> {
  final AuthRepository repository;

  RegisterCubit({required this.repository}) : super(InitState());

  doRegister({String? userName, String? password}) async {
    try {
      emit(LoadingState());
      UserModel userModel = await repository.login({
        "userName": userName,
        "password": password,
      });
      emit(LoadedState(userModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
