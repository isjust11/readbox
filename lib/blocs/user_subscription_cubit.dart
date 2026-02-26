import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class UserSubscriptionCubit extends Cubit<BaseState> {
  final UserSubscriptionRepository repository;

  UserSubscriptionCubit({required this.repository}) : super(InitState());

  Future<void> loadMe() async {
    try {
      emit(LoadingState());
      final me = await repository.getMe();
      emit(LoadedState<UserSubscriptionModel>(me));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}

