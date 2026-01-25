import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/res/res.dart';

class BookRemoteDataSource {
  final Network network;

  BookRemoteDataSource({required this.network});

  Future<List<BookModel>> getPublicBooks({
    int? page,
    int? limit,
    FilterType? filterType,
    String? categoryId,
    String? searchQuery,
    bool isDiscover = false,
  }) async {
    Map<String, dynamic> params = {};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (categoryId != null) params['categoryId'] = categoryId;
    if (filterType != null) params['filterType'] = filterType.name;
    if (isDiscover) params['fromMe'] = !isDiscover;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['search'] = searchQuery;
    }

    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getBooksPublic}',
      params: params,
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data != null && apiResponse.data.isNotEmpty) {
        return (apiResponse.data['data'] as List)
            .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<BookModel> getBookById(String id) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.books}/$id',
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data == null) {
        return Future.error('Book not found');
      }
      return BookModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<BookModel> addBook(BookModel book) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.books}',
      body: book.toJson(),
    );

    if (apiResponse.isSuccess) {
      return BookModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<BookModel> updateBook(BookModel book) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.books}/${book.id}',
      body: book.toJson(),
    );

    if (apiResponse.isSuccess) {
      return BookModel.fromJson(apiResponse.data['data'] as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<bool> deleteBook(String id) async {
    ApiResponse apiResponse = await network.delete(
      url: '${ApiConstant.apiHost}${ApiConstant.books}/$id',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<bool> toggleFavorite(String id, bool isFavorite) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.toggleFavorite}',
      body: {'bookId': id, 'isFavorite': isFavorite},
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  // Chapter methods
  Future<List<ChapterModel>> getChaptersByBookId(String bookId) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getChapters}/$bookId',
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data is List) {
        return (apiResponse.data as List)
            .map((item) => ChapterModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    return Future.error(apiResponse.errMessage);
  }

  // Bookmark methods
  Future<List<BookmarkModel>> getBookmarksByBookId(String bookId) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getBookmarks}/$bookId',
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data is List) {
        return (apiResponse.data as List)
            .map((item) => BookmarkModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<BookmarkModel> addBookmark(BookmarkModel bookmark) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.addBookmark}',
      body: bookmark.toJson(),
    );

    if (apiResponse.isSuccess) {
      return BookmarkModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<bool> deleteBookmark(String id) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.deleteBookmark}/$id',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }

  // Reading progress methods
  Future<ReadingProgressModel> saveReadingProgress(ReadingProgressModel progress) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.saveReadingProgress}',
      body: progress.toJson(),
    );

    if (apiResponse.isSuccess) {
      return ReadingProgressModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<ReadingProgressModel?> getReadingProgressByBookId(String bookId) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getReadingProgress}/$bookId',
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data != null) {
        return ReadingProgressModel.fromJson(apiResponse.data as Map<String, dynamic>);
      }
      return null;
    }
    return Future.error(apiResponse.errMessage);
  }
}

