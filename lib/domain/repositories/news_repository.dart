import 'dart:io';

import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepository({required this.remoteDataSource});

  Future<NewsModel> createNews(NewsModel news) async {
    try {
      return await remoteDataSource.createNews(news);
    } catch (e) {
      throw Exception('Failed to create news: $e');
    }
  }

  Future<List<NewsModel>> getNewsList({
    String? category,
    bool? isPublished,
    bool? isFeatured,
    String? searchQuery,
  }) async {
    try {
      return await remoteDataSource.getNewsList(
        category: category,
        isPublished: isPublished,
        isFeatured: isFeatured,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw Exception('Failed to get news list: $e');
    }
  }

  Future<NewsModel> getNewsById(String id) async {
    try {
      return await remoteDataSource.getNewsById(id);
    } catch (e) {
      throw Exception('Failed to get news: $e');
    }
  }

  Future<NewsModel> updateNews(NewsModel news) async {
    try {
      return await remoteDataSource.updateNews(news);
    } catch (e) {
      throw Exception('Failed to update news: $e');
    }
  }

  Future<bool> deleteNews(String id) async {
    try {
      return await remoteDataSource.deleteNews(id);
    } catch (e) {
      throw Exception('Failed to delete news: $e');
    }
  }

  Future<dynamic> uploadImage(File file) async {
    try {
      final response = await remoteDataSource.uploadImage(file);
      if (response['success'] == true) {
        return response;
      } else {
        throw Exception(BlocUtils.getMessageError(response['message']));
      }
    } catch (e) {
      throw Exception(BlocUtils.getMessageError(e));
    }
  }
}

