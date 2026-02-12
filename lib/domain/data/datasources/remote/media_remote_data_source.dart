import 'dart:io';

import 'package:dio/dio.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/domain/data/models/models.dart';

class MediaRemoteDataSource {
  final Network network;

  MediaRemoteDataSource({required this.network});

  // GET /media - Lấy danh sách media với phân trang
  Future<Map<String, dynamic>> getAllMedia({
    int page = 1,
    int size = 100,
    String? search,
    String? mimeType,
  }) async {
    Map<String, dynamic> params = {'page': page, 'size': size};

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    if (mimeType != null && mimeType.isNotEmpty) {
      params['mimeType'] = mimeType;
    }

    ApiResponse apiResponse = await network.get(
      url: ApiConstant.getMedia,
      params: params,
    );

    if (apiResponse.isSuccess) {
      return apiResponse.data;
    }

    return Future.error(apiResponse.errMessage);
  }

  // GET /media/:id - Lấy chi tiết media theo ID
  Future<MediaModel> getMediaById(String id) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.getMedia}/$id',
    );

    if (apiResponse.isSuccess) {
      return MediaModel.fromJson(apiResponse.data);
    }

    return Future.error(apiResponse.errMessage);
  }

  // POST /media/upload - Upload file
  Future<MediaModel> uploadMedia(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    ApiResponse apiResponse = await network.postWithFormData(
      url: '${ApiConstant.apiHost}${ApiConstant.uploadMedia}',
      formData: formData,
      options: Options(
        responseType: ResponseType.json,
        contentType: 'multipart/form-data',
      ),
    );

    if (apiResponse.isSuccess) {
      return MediaModel.fromJson(apiResponse.data);
    }

    return Future.error(apiResponse.errMessage);
  }

  // PUT /media/:id - Cập nhật thông tin media
  Future<MediaModel> updateMedia(
    String id,
    Map<String, dynamic> updateData,
  ) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.getMedia}/$id',
      body: updateData,
    );

    if (apiResponse.isSuccess) {
      return MediaModel.fromJson(apiResponse.data);
    }

    return Future.error(apiResponse.errMessage);
  }

  // DELETE /media/:id - Xóa media theo filename
  Future<Map<String, dynamic>> deleteMedia(String filename) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.getMedia}/$filename',
    );

    if (apiResponse.isSuccess) {
      return apiResponse.data;
    }

    return Future.error(apiResponse.errMessage);
  }

  // DELETE /media - Xóa nhiều media
  Future<Map<String, dynamic>> deleteMultipleMedia(
    List<String> filenames,
  ) async {
    ApiResponse apiResponse = await network.post(
      url: ApiConstant.getMedia,
      body: {'filenames': filenames},
    );

    if (apiResponse.isSuccess) {
      return apiResponse.data;
    }

    return Future.error(apiResponse.errMessage);
  }
}
