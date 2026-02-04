import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/domain/data/datasources/remote/admin_remote_data_source.dart';

class LibraryCubit extends Cubit<BaseState> {
  final AdminRemoteDataSource adminRemoteDataSource;
    String? _errorUploadEbook;
  String? _errorUploadCoverImage; 
  String? _ebookFileUrl;
  String? _coverImageUrl;
  bool _uploadEbookSuccess = false;
  List<dynamic> _categories = [];

  String? get ebookFileUrl => _ebookFileUrl;
  String? get coverImageUrl => _coverImageUrl;
  List<dynamic> get categories => _categories;
  String? get errorUploadEbook => _errorUploadEbook;
  String? get errorUploadCoverImage => _errorUploadCoverImage;
  bool get uploadEbookSuccess => _uploadEbookSuccess;
  final BookRepository repository;

  LibraryCubit({
    required this.repository,
    required this.adminRemoteDataSource,
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

      final newBooks = await repository.getPublicBooks(
        filterType: filterType,
        searchQuery: searchQuery,
        page: page ?? 1,
        limit: limit ?? 10,
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

      final newBooks = await repository.getPublicBooks(
        filterType: filterType ?? FilterType.all,
        searchQuery: searchQuery,
        page: page ?? 1,
        limit: limit ?? 10,
        categoryId: categoryId ?? '',
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

  void resetErrorUpload() {
    _errorUploadEbook = null;
    _errorUploadCoverImage = null;
  }

    Future<void> loadCategories() async {
    try {
      emit(LoadingState());
      _categories = await adminRemoteDataSource.getCategories();
      emit(LoadedState(_categories));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e),));
    }
  }


  void resetCoverImage() {
    _coverImageUrl = null;
    _errorUploadCoverImage = null;
    emit(LoadedState(_categories));
  }

  Future<void> _uploadEbookInternal(File file) async {
    final response = await adminRemoteDataSource.uploadEbook(file);
    if (response.isSuccess) {
      _ebookFileUrl = response.data['publicRelativePath'];
      return;
    }
    throw Exception(BlocUtils.getMessageError(response.errMessage));
  }

  Future<void> _uploadCoverImageInternal(File file) async {
    final response = await adminRemoteDataSource.uploadCoverImage(file);
    if (response.isSuccess) {
      _coverImageUrl = response.data['publicRelativePath'];
      return;
    }
    throw Exception(BlocUtils.getMessageError(response.errMessage));
  }

  /// Thực hiện từng bước: upload file → upload ảnh bìa (nếu có) → tạo sách.
  /// Không tạo file rác vì chỉ upload khi người dùng bấm Tạo.
  Future<void> createBookWithUpload({
    required File ebookFile,
    File? coverImageFile,
    required String title,
    required String author,
    String? description,
    String? publisher,
    String? isbn,
    int? totalPages,
    String language = 'vi',
    bool isPublic = true,
    String? categoryId,
  }) async {
    emit(LoadingState());
    try {
      await _uploadEbookInternal(ebookFile);
      if (coverImageFile != null) {
        await _uploadCoverImageInternal(coverImageFile);
      }
      await createBook(
        title: title,
        author: author,
        description: description,
        publisher: publisher,
        isbn: isbn,
        totalPages: totalPages,
        language: language,
        isPublic: isPublic,
        categoryId: categoryId,
      );
    } catch (e) {
      _ebookFileUrl = null;
      _coverImageUrl = null;
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Create book with all information
  Future<void> createBook({
    required String title,
    required String author,
    String? description,
    String? publisher,
    String? isbn,
    int? totalPages,
    String language = 'vi',
    bool isPublic = true,
    String? categoryId,
  }) async {
    try {
      if (_ebookFileUrl == null) {
        emit(ErrorState(BlocUtils.getMessageError('Please upload ebook file first'),));
        return;
      }

      emit(LoadingState());

      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'fileUrl': _ebookFileUrl,
        'coverImageUrl': _coverImageUrl,
        'publisher': publisher,
        'isbn': isbn,
        'totalPages': totalPages,
        'language': language,
        'isPublic': isPublic,
        if (categoryId != null) 'category': categoryId,
      };

      final response = await adminRemoteDataSource.createBook(bookData);
      _books.add(response);
      // Reset uploaded files
      _ebookFileUrl = null;
      _coverImageUrl = null;
      _uploadEbookSuccess = true;
      emit(LoadedState(
        response,
        message: 'Book created successfully',
      ));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e),));
    }
  }

  /// Update book with all information
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    String? description,
    String? publisher,
    String? isbn,
    int? totalPages,
    String language = 'vi',
    bool isPublic = true,
    String? categoryId,
    String? existingFileUrl, // File URL từ server (nếu không upload file mới)
    String? existingCoverImageUrl, // Cover URL từ server (nếu không upload cover mới)
  }) async {
    try {
      emit(LoadingState());

      final bookData = {
        'title': title,
        'author': author,
        'description': description,
        'fileUrl': _ebookFileUrl ?? existingFileUrl, // Dùng file mới nếu có, không thì dùng file cũ
        'coverImageUrl': _coverImageUrl ?? existingCoverImageUrl, // Dùng cover mới nếu có, không thì dùng cover cũ
        'publisher': publisher,
        'isbn': isbn,
        'totalPages': totalPages,
        'language': language,
        'isPublic': isPublic,
        if (categoryId != null) 'category': categoryId,
      };

      final response = await adminRemoteDataSource.updateBook(bookId, bookData);
      if(_books.isNotEmpty) {
        _books.removeWhere((book) => book.id == bookId);
        _books.add(response);
      }
      // Reset uploaded files
      _ebookFileUrl = null;
      _coverImageUrl = null;
      _uploadEbookSuccess = true;
      emit(LoadedState(
        response,
        message: 'Book updated successfully',
      ));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e),));
    }
  }

  /// Reset state
  void reset() {
    _ebookFileUrl = null;
    _coverImageUrl = null;
    _uploadEbookSuccess = false;
    emit(InitState());
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      final result = await repository.deleteBook(bookId);
      if (result) {
        // Remove from local list
        _books.removeWhere((book) => book.id == bookId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
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
