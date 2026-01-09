import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class PageCubit extends Cubit<BaseState> {
  final PageRepository repository;
  PageCubit({required this.repository}) : super(InitState());

  void getPageBySlug(String slug) async {
    try {
      emit(LoadingState());
      final page = await repository.getPageBySlug(slug);
      emit(LoadedState(page));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
