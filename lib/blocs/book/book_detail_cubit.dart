import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class BookDetailCubit extends Cubit<BaseState> {
  final BookRepository repository;

  BookDetailCubit({required this.repository}) : super(InitState());

  BookModel? _book;
  BookModel? get book => _book;

  void getBookById(String id) async {
    try {
      emit(LoadingState());
      _book = await repository.getBookById(id);
      emit(LoadedState(_book));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void toggleFavorite(String id, bool isFavorite) async {
    try {
      emit(LoadingState());
      await repository.toggleFavorite(id, isFavorite);
      if (_book != null) {
        _book!.isFavorite = isFavorite;
        emit(LoadedState(_book));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void updateBook(BookModel book) async {
    try {
      emit(LoadingState());
      await repository.updateBook(book);
      _book = book;
      emit(LoadedState(_book));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}

