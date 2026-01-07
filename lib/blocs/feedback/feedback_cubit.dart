import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/domain/data/models/models.dart';

class FeedbackCubit extends Cubit<BaseState> {
  FeedbackCubit() : super(InitState());

  Future<void> createFeedback(FeedbackModel feedback) async {
    try {
      emit(LoadingState());
      
      // TODO: Implement API call to submit feedback
      // final repository = getIt.get<FeedbackRepository>();
      // await repository.createFeedback(feedback);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      emit(LoadedState(feedback));
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }
}
