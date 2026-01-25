import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/res/res.dart';

class BookRepository {
  final BookRemoteDataSource remoteDataSource;

  BookRepository({required this.remoteDataSource});

  Future<BookModel> addBook(BookModel book) async {
    try {
      return await remoteDataSource.addBook(book);
    } catch (e) {
      throw Exception('Failed to add book: $e');
    }
  }

  Future<List<BookModel>> getPublicBooks({
    FilterType? filterType,
    String? searchQuery,
    int? page,
    int? limit,
    String? categoryId,
    bool isDiscover = false,
  }) async {
    return await remoteDataSource.getPublicBooks(
      filterType: filterType,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
      categoryId: categoryId,
      isDiscover: isDiscover,
    );
  }

  Future<BookModel> getBookById(String id) async {
    return await remoteDataSource.getBookById(id);
  }

  Future<BookModel> updateBook(BookModel book) async {
    return await remoteDataSource.updateBook(book);
  }

  Future<bool> deleteBook(String id) async {
    return await remoteDataSource.deleteBook(id);
  }

  Future<bool> toggleFavorite(String id, bool isFavorite) async {
    return await remoteDataSource.toggleFavorite(id, isFavorite);
  }

  // Chapter methods
  Future<List<ChapterModel>> getChaptersByBookId(String bookId) async {
    return await remoteDataSource.getChaptersByBookId(bookId);
  }

  // Bookmark methods
  Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
    return await remoteDataSource.addBookmark(bookmark);
  }

  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId) async {
    return await remoteDataSource.getBookmarksByBookId(bookId);
  }

  Future<bool> deleteBookmark(String id) async {
    return await remoteDataSource.deleteBookmark(id);
  }

  // Reading progress methods
  Future<ReadingProgressModel> saveReadingProgress(
    ReadingProgressModel progress,
  ) async {
    return await remoteDataSource.saveReadingProgress(progress);
  }

  Future<ReadingProgressModel?> getReadingProgressByBookId(
    String bookId,
  ) async {
    return await remoteDataSource.getReadingProgressByBookId(bookId);
  }
}
