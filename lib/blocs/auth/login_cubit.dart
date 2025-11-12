import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class LoginCubit extends Cubit<BaseState> {
  final AuthRepository repository;

  LoginCubit({required this.repository}) : super(InitState());

  doLogin({String? userName, String? password}) async {
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
