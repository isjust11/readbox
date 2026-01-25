import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/network.dart';

class UserInteractionRemoteDataSource {
  final Network network;

  UserInteractionRemoteDataSource({required this.network});

  // like
  Future<UserInteractionModel> toggleFavorite({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url:
          '${ApiConstant.apiHost}${ApiConstant.interactionAction}/${InteractionType.favorite.value}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) {
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }

  // toggle read later
  Future<UserInteractionModel> toggleArchive({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url:
          '${ApiConstant.apiHost}${ApiConstant.interactionAction}/${InteractionType.archived.value}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) {
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }
  // view

  Future<UserInteractionModel> view({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url:
          '${ApiConstant.apiHost}/user-interactions/action/${InteractionType.download.value}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) {
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }

  // unlike
  Future<UserInteractionModel> unlike({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.toggleFavorite}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) return apiResponse.data;
    return Future.error(apiResponse.data);
  }

  // bookmark
  Future<void> bookmark({
    required String targetType,
    required dynamic targetId,
  }) async {
    await network.post(url: '${ApiConstant.getBookmark}/$targetType/$targetId');
  }

  // unbookmark
  Future<void> unbookmark({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.getUnbookmark}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) return;
    return Future.error(apiResponse.data);
  }

  // share
  Future<dynamic> share({
    required String targetType,
    required dynamic targetId,
    String? sharePlatform,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.getView}/$targetType/$targetId',
      body: sharePlatform == null ? null : {'sharePlatform': sharePlatform},
    );
    if (apiResponse.isSuccess) return apiResponse.data;
    return Future.error(apiResponse.data);
  }

  // rate
  Future<dynamic> rate({
    required String targetType,
    required dynamic targetId,
    required int rating,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.getRead}/$targetType/$targetId',
      body: {'rating': rating},
    );
    if (apiResponse.isSuccess) return apiResponse.data;
    return Future.error(apiResponse.data);
  }

  // follow
  Future<dynamic> follow({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url: '${ApiConstant.getSave}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) return apiResponse.data;
    return Future.error(apiResponse.data);
  }

  // unfollow
  Future<void> unfollow({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.delete(
      url: '${ApiConstant.getUnsave}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) return;
    return Future.error(apiResponse.data);
  }

  // get status
  Future<dynamic> getStatus({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.get(
      url:
          '${ApiConstant.apiHost}${ApiConstant.getInteractionStatus}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) {
      return apiResponse.data;
    }
    return Future.error(apiResponse.data);
  }

  // get stats
  Future<InteractionStatsModel> getStats({
    required String targetType,
    required dynamic targetId,
  }) async {
    final ApiResponse apiResponse = await network.get(
      url:
          '${ApiConstant.apiHost}${ApiConstant.getInteractionStats}/$targetType/$targetId',
    );
    if (apiResponse.isSuccess) {
      return InteractionStatsModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }

  // save reading progress
  Future<UserInteractionModel> saveReadingProgress({
    required InteractionTarget targetType,
    required InteractionType actionType,
    required dynamic targetId,
    required ReadingProgressModel readingProgress,
  }) async {
    final ApiResponse apiResponse = await network.post(
      url:
          '${ApiConstant.apiHost}${ApiConstant.interactionAction}/${actionType.value}/${targetType.value}/$targetId',
      body: {
        'metadata': readingProgress.toJson(),
      },
    );
    if (apiResponse.isSuccess) {
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }

  Future<UserInteractionModel> getMyInteractions({Map<String, dynamic>? query}) async {
    final ApiResponse apiResponse = await network.get(
      url:
          '${ApiConstant.apiHost}${ApiConstant.getMyInteractions}',
      params: query,
    );
    if (apiResponse.isSuccess) {
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }

  Future<UserInteractionModel> getInteractionAction
  ({required InteractionTarget targetType,required InteractionType actionType, required dynamic targetId}) async {
    final ApiResponse apiResponse = await network.get(
      url:
          '${ApiConstant.apiHost}${ApiConstant.interactionAction}/${actionType.value}/${targetType.value}/$targetId',
    );
    if (apiResponse.isSuccess) {
      if (apiResponse.data == null) {
        return UserInteractionModel.fromJson({});
      }
      return UserInteractionModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.data);
  }
}
