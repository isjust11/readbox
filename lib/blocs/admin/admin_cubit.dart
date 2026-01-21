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

  /// Upload ebook file
  void resetErrorUpload() {
    _errorUploadEbook = null;
    _errorUploadCoverImage = null;
  }

  /// Reset cover image (URL và lỗi) khi đổi ảnh bìa hoặc xóa ebook.
  void resetCoverImage() {
    _coverImageUrl = null;
    _errorUploadCoverImage = null;
    emit(LoadedState(_categories));
  }

  Future<void> uploadEbook(File file) async {
    try {
      emit(LoadingState());
      final response = await _adminRemoteDataSource.uploadEbook(file);
      
      if (response.isSuccess) {
        _ebookFileUrl = response.data['publicRelativePath'];
        emit(LoadedState(
          response,
          msgError: 'Ebook uploaded successfully',
        ));
      } else {
        _errorUploadEbook = BlocUtils.getMessageError(response.errMessage);
        emit(ErrorState(_errorUploadEbook,));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e),));
    }
  }

  /// Upload cover image
  Future<void> uploadCoverImage(File file) async {
    try {
      emit(LoadingState());
      final response = await _adminRemoteDataSource.uploadCoverImage(file);
      
      if (response.isSuccess) {
        _coverImageUrl = response.data['publicRelativePath'];
        emit(LoadedState(
          response,
          msgError: 'Cover image uploaded successfully',
        ));
      } else {
        _errorUploadCoverImage = BlocUtils.getMessageError(response.errMessage);
        emit(ErrorState(_errorUploadCoverImage,));
      }
    } catch (e) {
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
    int? categoryId,
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
        if (categoryId != null) 'category': {'id': categoryId},
      };

      final response = await _adminRemoteDataSource.createBook(bookData);
      
      // Reset uploaded files
      _ebookFileUrl = null;
      _coverImageUrl = null;
      _uploadEbookSuccess = true;
      emit(LoadedState(
        response,
        msgError: 'Book created successfully',
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
