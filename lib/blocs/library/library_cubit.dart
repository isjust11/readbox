import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/usecases/add_book_usecase.dart';
import 'package:readbox/domain/usecases/get_book_list_usecase.dart';
import 'package:readbox/domain/usecases/delete_book_usecase.dart';
import 'package:readbox/domain/usecases/search_books_usecase.dart';
import 'package:readbox/res/res.dart';

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
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> getBooks({
    FilterType? filterType,
    String? searchQuery,
    int? page,
    int? limit,
    String? categoryId,
    bool isLoadMore = false,
    bool isDiscover = false,
  }) async {
    try {
      
      if (!isLoadMore) {
        emit(LoadingState());
        _books = [];
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }

      final newBooks = await getBookListUseCase(
        filterType: filterType,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
        categoryId: categoryId,
        isDiscover: isDiscover,
      );


      if (isLoadMore) {
        _books.addAll(newBooks);
        _hasMore = newBooks.length >= (limit ?? 10);
        _isLoadingMore = false;
      } else {
        _books = newBooks;
        _hasMore = newBooks.length >= (limit ?? 10);
      }

      // Emit với list mới để trigger rebuild
      emit(LoadedState(List.from(_books)));
    } catch (e) {
      _isLoadingMore = false;
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> searchBooks({
    FilterType? filterType,
    String? searchQuery,
    int? page,
    int? limit,
    String? categoryId,
    bool isLoadMore = false,
  }) async {
    try {
      if (!isLoadMore) {
        emit(LoadingState());
        _books = [];
        _hasMore = true;
      } else {
        _isLoadingMore = true;
      }

      final newBooks = await searchBooksUseCase(
        filterType: filterType,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );

      if (isLoadMore) {
        _books.addAll(newBooks);
        _hasMore = newBooks.length >= (limit ?? 10);
        _isLoadingMore = false;
      } else {
        _books = newBooks;
        _hasMore = newBooks.length >= (limit ?? 10);
      }

      // Emit với list mới để trigger rebuild
      emit(LoadedState(List.from(_books)));
    } catch (e) {
      _isLoadingMore = false;
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

  Future<void> refreshBooks({
    FilterType? filterType,
    String? searchQuery,
    int? page,
    int? limit,
    String? categoryId,
  }) async {
    await getBooks(
      filterType: filterType,
      searchQuery: searchQuery,
      page: page ?? 1,
      limit: limit,
      categoryId: categoryId,
      isLoadMore: false,
      isDiscover: false,
    );
  }
}

