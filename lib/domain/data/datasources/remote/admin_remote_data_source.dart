import 'dart:io';
import 'package:dio/dio.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/domain/network/network.dart';

class AdminRemoteDataSource {
    final Network network;

  AdminRemoteDataSource({required this.network});

  /// Upload ebook file (PDF, EPUB, MOBI)
  Future<Map<String, dynamic>> uploadEbook(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await network.postWithFormData(
        url: '${ApiConstant.apiHost}${ApiConstant.uploadEbook}',
        formData: formData,
        contentType: 'multipart/form-data',
      );

      if (response.isSuccess) {
        return response.data;
      }
      return Future.error(BlocUtils.getMessageError(response.errMessage));
    } catch (e) {
      return Future.error(BlocUtils.getMessageError(e));
    }
  }

  /// Upload cover image
  Future<Map<String, dynamic>> uploadCoverImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await network.postWithFormData(
        url: '${ApiConstant.apiHost}${ApiConstant.uploadCover}',
        formData: formData,
      );

      return response.data;
    } catch (e) {
      return Future.error(BlocUtils.getMessageError(e));
    }
  }

  /// Create book with uploaded file URLs
  Future<Map<String, dynamic>> createBook(Map<String, dynamic> bookData) async {
    try {
      final response = await network.post(
        url: '${ApiConstant.apiHost}${ApiConstant.addBook}',
        body: bookData,
      );

      return response.data;
    } catch (e) {
      return Future.error(BlocUtils.getMessageError(e));
    }
  }

  /// Get all categories
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await network.get(
        url: '${ApiConstant.apiHost}${ApiConstant.getCategories}',
      );

      return response.data;
    } catch (e) {
      return Future.error(BlocUtils.getMessageError(e));
    }
  }
}
