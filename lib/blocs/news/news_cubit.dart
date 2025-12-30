import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/usecases/add_news_usecase.dart';
import 'package:readbox/domain/usecases/get_news_list_usecase.dart';
import 'package:readbox/domain/usecases/update_news_usecase.dart';
import 'package:readbox/domain/usecases/delete_news_usecase.dart';
import 'package:readbox/domain/usecases/search_news_usecase.dart';
import 'package:readbox/domain/usecases/upload_image_usecase.dart';

class NewsCubit extends Cubit<BaseState> {
  final GetNewsListUseCase getNewsListUseCase;
  final AddNewsUseCase addNewsUseCase;
  final UpdateNewsUseCase updateNewsUseCase;
  final DeleteNewsUseCase deleteNewsUseCase;
  final SearchNewsUseCase searchNewsUseCase;
  final UploadImageUseCase uploadImageUseCase;

  NewsCubit({
    required this.getNewsListUseCase,
    required this.addNewsUseCase,
    required this.updateNewsUseCase,
    required this.deleteNewsUseCase,
    required this.searchNewsUseCase,
    required this.uploadImageUseCase,
  }) : super(InitState());

  List<NewsModel> _newsList = [];
  List<NewsModel> get newsList => _newsList;

  void getNews({
    String? category,
    bool? isPublished,
    bool? isFeatured,
  }) async {
    try {
      emit(LoadingState());
      _newsList = await getNewsListUseCase(
        category: category,
        isPublished: isPublished,
        isFeatured: isFeatured,
      );
      emit(LoadedState(_newsList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void searchNews(String query) async {
    try {
      if (query.isEmpty) {
        getNews();
        return;
      }
      emit(LoadingState());
      _newsList = await searchNewsUseCase(query);
      emit(LoadedState(_newsList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void addNews(NewsModel news) async {
    try {
      emit(LoadingState());
      await addNewsUseCase(news);
      // Refresh list after adding
      getNews();
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
  
  Future<dynamic> uploadImage(File file) async {
    try {
      return await uploadImageUseCase(file);
    } catch (e) {
      throw Exception(BlocUtils.getMessageError(e));
    }
  }

  void updateNews(NewsModel news) async {
    try {
      emit(LoadingState());
      await updateNewsUseCase(news);
      // Refresh list after updating
      getNews();
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void deleteNews(String newsId) async {
    try {
      emit(LoadingState());
      await deleteNewsUseCase(newsId);
      // Remove from local list
      final id = int.tryParse(newsId);
      if (id != null) {
        _newsList.removeWhere((news) => news.id == id);
      }
      emit(LoadedState(_newsList));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void refreshNews() {
    getNews();
  }
}

