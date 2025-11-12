import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

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

  Future<List<BookModel>> getAllBooks({
    bool? isFavorite,
    bool? isArchived,
    String? searchQuery,
  }) async {
    try {
      return await remoteDataSource.getAllBooks(
        isFavorite: isFavorite,
        isArchived: isArchived,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw Exception('Failed to get books: $e');
    }
  }

  Future<BookModel> getBookById(String id) async {
    try {
      return await remoteDataSource.getBookById(id);
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  Future<BookModel> updateBook(BookModel book) async {
    try {
      return await remoteDataSource.updateBook(book);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<bool> deleteBook(String id) async {
    try {
      return await remoteDataSource.deleteBook(id);
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  Future<bool> toggleFavorite(String id, bool isFavorite) async {
    try {
      return await remoteDataSource.toggleFavorite(id, isFavorite);
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  // Chapter methods
  Future<List<ChapterModel>> getChaptersByBookId(String bookId) async {
    try {
      return await remoteDataSource.getChaptersByBookId(bookId);
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }

  // Bookmark methods
  Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
    try {
      return await remoteDataSource.addBookmark(bookmark);
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId) async {
    try {
      return await remoteDataSource.getBookmarksByBookId(bookId);
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  Future<bool> deleteBookmark(String id) async {
    try {
      return await remoteDataSource.deleteBookmark(id);
    } catch (e) {
      throw Exception('Failed to delete bookmark: $e');
    }
  }

  // Reading progress methods
  Future<ReadingProgressModel> saveReadingProgress(ReadingProgressModel progress) async {
    try {
      return await remoteDataSource.saveReadingProgress(progress);
    } catch (e) {
      throw Exception('Failed to save reading progress: $e');
    }
  }

  Future<ReadingProgressModel?> getReadingProgressByBookId(String bookId) async {
    try {
      return await remoteDataSource.getReadingProgressByBookId(bookId);
    } catch (e) {
      throw Exception('Failed to get reading progress: $e');
    }
  }
}

