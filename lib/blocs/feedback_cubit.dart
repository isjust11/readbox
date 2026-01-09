import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class FeedbackCubit extends Cubit<BaseState> {
  final FeedbackRepository repository;
  FeedbackCubit({required this.repository}) : super(InitState());

  Future<void> createFeedback(FeedbackModel feedbackModel) async {
    try {
      emit(LoadingState());
      final feedback = await repository.createFeedback(feedbackModel);
      
      emit(LoadedState(feedback));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
