import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/usecases/add_book_usecase.dart';
import 'package:readbox/domain/usecases/get_book_list_usecase.dart';
import 'package:readbox/domain/usecases/delete_book_usecase.dart';
import 'package:readbox/domain/usecases/search_books_usecase.dart';

class LibraryCubit extends Cubit<BaseState> {
  final GetBookListUseCase getBookListUseCase;
  final AddBookUseCase addBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;
  final SearchBooksUseCase searchBooksUseCase;

  LibraryCubit({
    required this.getBookListUseCase,
    required this.addBookUseCase,
    required this.deleteBookUseCase,
    required this.searchBooksUseCase,
  }) : super(InitState());

  List<BookModel> _books = [];
  List<BookModel> get books => _books;

  void getBooks({
    bool? isFavorite,
    bool? isArchived,
  }) async {
    try {
      emit(LoadingState());
      _books = await getBookListUseCase(
        isFavorite: isFavorite,
        isArchived: isArchived,
      );
      emit(LoadedState(_books));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void searchBooks(String query) async {
    try {
      if (query.isEmpty) {
        getBooks();
        return;
      }
      emit(LoadingState());
      _books = await searchBooksUseCase(query);
      emit(LoadedState(_books));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void addBook(BookModel book) async {
    try {
      emit(LoadingState());
      await addBookUseCase(book);
      // Refresh list after adding
      getBooks();
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void deleteBook(String bookId) async {
    try {
      emit(LoadingState());
      await deleteBookUseCase(bookId);
      // Remove from local list
      _books.removeWhere((book) => book.id == bookId);
      emit(LoadedState(_books));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void refreshBooks() {
    getBooks();
  }
}

