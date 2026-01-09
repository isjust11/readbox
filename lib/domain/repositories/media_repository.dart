import 'dart:io';
import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/media_model.dart';

class MediaRepository {
  final MediaRemoteDataSource remoteDataSource;

  MediaRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> getAllMedia({
    int page = 1,
    int size = 100,
    String? search,
    String? mimeType,
  }) async {
    return await remoteDataSource.getAllMedia(
      page: page,
      size: size,
      search: search,
      mimeType: mimeType,
    );
  }

  Future<MediaModel> getMediaById(String id) async {
    return await remoteDataSource.getMediaById(id);
  }

  Future<MediaModel> uploadMedia(File file) async {
    return await remoteDataSource.uploadMedia(file);
  }

  Future<MediaModel> updateMedia(
    String id,
    Map<String, dynamic> updateData,
  ) async {
    return await remoteDataSource.updateMedia(id, updateData);
  }

  Future<Map<String, dynamic>> deleteMedia(String filename) async {
    return await remoteDataSource.deleteMedia(filename);
  }

  Future<Map<String, dynamic>> deleteMultipleMedia(
    List<String> filenames,
  ) async {
    return await remoteDataSource.deleteMultipleMedia(filenames);
  }
}
