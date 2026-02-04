import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/datasources/remote/admin_remote_data_source.dart';

class AdminCubit extends Cubit<BaseState> {
  final AdminRemoteDataSource _adminRemoteDataSource;

  AdminCubit(this._adminRemoteDataSource) : super(InitState());
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
  /// Load categories
  Future<void> loadCategories() async {
    try {
      emit(LoadingState());
      _categories = await _adminRemoteDataSource.getCategories();
      emit(LoadedState(_categories));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e),));
    }
  }

  void resetErrorUpload() {
    _errorUploadEbook = null;
    _errorUploadCoverImage = null;
  }

  void resetCoverImage() {
    _coverImageUrl = null;
    _errorUploadCoverImage = null;
    emit(LoadedState(_categories));
  }

  Future<void> _uploadEbookInternal(File file) async {
    final response = await _adminRemoteDataSource.uploadEbook(file);
    if (response.isSuccess) {
      _ebookFileUrl = response.data['publicRelativePath'];
      return;
    }
    throw Exception(BlocUtils.getMessageError(response.errMessage));
  }

  Future<void> _uploadCoverImageInternal(File file) async {
    final response = await _adminRemoteDataSource.uploadCoverImage(file);
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

      final response = await _adminRemoteDataSource.createBook(bookData);
      
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

      final response = await _adminRemoteDataSource.updateBook(bookId, bookData);
      
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
}
