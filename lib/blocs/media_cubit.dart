import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class MediaCubit extends Cubit<BaseState> {
  final MediaRepository repository;
  MediaCubit({required this.repository}) : super(InitState());

  // Lấy danh sách media với phân trang
  Future<void> getAllMedia({
    int page = 1,
    int size = 100,
    String? search,
    String? mimeType,
  }) async {
    try {
      emit(LoadingState());
      final result = await repository.getAllMedia(
        page: page,
        size: size,
        search: search,
        mimeType: mimeType,
      );
      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // Lấy chi tiết media theo ID
  Future<void> getMediaById(String id) async {
    try {
      emit(LoadingState());
      final media = await repository.getMediaById(id);
      emit(LoadedState(media));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // Upload file
  Future<MediaModel> uploadMedia(File file) async {
    try {
      final media = await repository.uploadMedia(file);
      return media;
    } catch (e) {
      return Future.error(e);
    }
  }

  // Cập nhật thông tin media
  Future<void> updateMedia(String id, Map<String, dynamic> updateData) async {
    try {
      emit(LoadingState());
      final media = await repository.updateMedia(id, updateData);
      emit(LoadedState(media));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // Xóa media theo filename
  Future<void> deleteMedia(String filename) async {
    try {
      emit(LoadingState());
      final result = await repository.deleteMedia(filename);
      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // Xóa nhiều media
  Future<void> deleteMultipleMedia(List<String> filenames) async {
    try {
      emit(LoadingState());
      final result = await repository.deleteMultipleMedia(filenames);
      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
