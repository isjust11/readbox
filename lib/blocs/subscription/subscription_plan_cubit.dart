import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

class SubscriptionPlanCubit extends Cubit<BaseState> {
  final SubscriptionRepository repository;

  SubscriptionPlanCubit({required this.repository}) : super(InitState());

  Future<void> loadPlans({bool activeOnly = true}) async {
    try {
      emit(LoadingState());
      final plans = await repository.getPlans(activeOnly: activeOnly);
      emit(LoadedState<List<SubscriptionPlanModel>>(plans));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> createSubscriptionPlan(String planId) async {
    try {
      emit(LoadingState());
      final subscriptionPlan = await repository.createSubscriptionPlan(planId);
      emit(LoadedState<UserSubscriptionModel>(subscriptionPlan));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> checkUsage() async {
    try {
      emit(LoadingState());
      final usage = await repository.checkUsage();
      emit(LoadedState<Map<String, bool>>(usage));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> restorePurchases() async {
    try {
      emit(LoadingState());
      await repository.restorePurchases();
      emit(LoadedState<String>(AppLocalizations.current.restore_purchases_success));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}

