import 'dart:io';
import 'package:dio/dio.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/network.dart';

class AdminRemoteDataSource {
  final Network network;

  AdminRemoteDataSource({required this.network});

  /// Upload ebook file (PDF, EPUB, MOBI)
  Future<ApiResponse<dynamic>> uploadEbook(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await network.postWithFormData(
      url: '${ApiConstant.apiHost}${ApiConstant.uploadMedia}',
      formData: formData,
      options: Options(
        responseType: ResponseType.json,
        contentType: 'multipart/form-data',
      ),
    );

    if (response.isSuccess) {
      return response;
    }
    return Future.error(response.errMessage);
  }

  /// Upload cover image
  Future<ApiResponse<dynamic>> uploadCoverImage(File file) async {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await network.postWithFormData(
        url: '${ApiConstant.apiHost}${ApiConstant.uploadMedia}',
        formData: formData,
        options: Options(
          responseType: ResponseType.json,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.isSuccess) {
        return response;
      }
      return ApiResponse.error(response.errMessage);
  }

  /// Create book with uploaded file URLs
  Future<BookModel> createBook(Map<String, dynamic> bookData) async {
    ApiResponse response = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.books}',
      body: bookData,
    );

    if (response.isSuccess) {
      return BookModel.fromJson(response.data);
    }
    return Future.error(response.errMessage);
  }

  /// Update book with uploaded file URLs
  Future<BookModel> updateBook(
    String bookId,
    Map<String, dynamic> bookData,
  ) async {
    ApiResponse response = await network.put(
      url: '${ApiConstant.apiHost}${ApiConstant.books}/$bookId',
      body: bookData,
    );

    if (response.isSuccess) {
      return BookModel.fromJson(response.data);
    }
    return Future.error(response.errMessage);
  }

  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      ApiResponse response = await network.get(
        url: '${ApiConstant.apiHost}${ApiConstant.getCategories}',
      );

      if (response.isSuccess) {
        return (response.data as List).map((item) => CategoryModel.fromJson(item)).toList();
      }
      return Future.error(response.errMessage);
    } catch (e) {
      return Future.error(BlocUtils.getMessageError(e));
    }
  }
}
