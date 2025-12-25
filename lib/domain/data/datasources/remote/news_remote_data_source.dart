import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/domain/network/network.dart';

class NewsRemoteDataSource {
  final Network network;

  NewsRemoteDataSource({required this.network});

  Future<List<NewsModel>> getNewsList({
    String? category,
    bool? isPublished,
    bool? isFeatured,
    String? searchQuery,
  }) async {
    Map<String, dynamic> params = {};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (isPublished != null) params['isPublished'] = isPublished;
    if (isFeatured != null) params['isFeatured'] = isFeatured;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['keyword'] = searchQuery;
    }

    // Sử dụng endpoint /api/news/search nếu có params, ngược lại dùng /api/news/published
    String endpoint = (searchQuery != null && searchQuery.isNotEmpty) || 
                      category != null || 
                      isPublished != null || 
                      isFeatured != null
        ? 'news/search'
        : ApiConstant.getNewsList;

    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}$endpoint',
      params: params,
    );

    if (apiResponse.isSuccess) {
      if (apiResponse.data is List) {
        return (apiResponse.data as List)
            .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<NewsModel> getNewsById(String id) async {
    // Sử dụng endpoint published để không cần auth
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}news/published/$id',
    );

    if (apiResponse.isSuccess) {
      return NewsModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<NewsModel> createNews(NewsModel news) async {
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.createNews}',
      body: news.toJson(),
    );

    if (apiResponse.isSuccess) {
      return NewsModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<NewsModel> updateNews(NewsModel news) async {
    // Sử dụng POST endpoint để tương thích với Network class
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.updateNews}/${news.id}/update',
      body: news.toJson(),
    );

    if (apiResponse.isSuccess) {
      return NewsModel.fromJson(apiResponse.data as Map<String, dynamic>);
    }
    return Future.error(apiResponse.errMessage);
  }

  Future<bool> deleteNews(String id) async {
    // Sử dụng POST endpoint để tương thích với Network class
    ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.apiHost}${ApiConstant.deleteNews}/$id/delete',
    );

    if (apiResponse.isSuccess) {
      return true;
    }
    return Future.error(apiResponse.errMessage);
  }
}

