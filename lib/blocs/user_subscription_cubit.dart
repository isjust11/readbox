import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class UserSubscriptionCubit extends Cubit<BaseState> {
  final UserSubscriptionRepository repository;

  UserSubscriptionCubit({required this.repository}) : super(InitState());
  UserSubscriptionModel? userSubscription;
  bool isProUser() {
    if (userSubscription == null) return false;
    final now = DateTime.now();
    return userSubscription?.expiresAt != null &&
        now.isBefore(userSubscription!.expiresAt);
  }

  bool isFreeUser() {
    return userSubscription?.plan?.code.contains('FREE') ?? false;
  }

  Future<void> loadMe() async {
    try {
      emit(LoadingState());
      final me = await repository.getMe();
      if (me == null) {
        emit(EmptyState());
      } else {
        userSubscription = me;
        emit(LoadedState<UserSubscriptionModel>(me));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void clear() {
    userSubscription = null;
    emit(InitState());
  }
}
