import 'package:readbox/domain/data/datasources/remote/user_interaction_data_source.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';

class UserInteractionRepository {
  final UserInteractionRemoteDataSource remoteDataSource;

  UserInteractionRepository({required this.remoteDataSource});

  Future<UserInteractionModel> updateInteractionAction({
    required InteractionTarget targetType,
    required dynamic targetId,
    required InteractionType actionType,
  }) => remoteDataSource.updateInteractionAction(targetType: targetType, targetId: targetId, actionType: actionType);

  Future<UserInteractionModel> toggleFavorite({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.toggleFavorite(targetType: targetType, targetId: targetId);

  Future<UserInteractionModel> toggleArchive({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.toggleArchive(targetType: targetType, targetId: targetId);
  
  Future<UserInteractionModel> view({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.view(targetType: targetType, targetId: targetId);

  Future<dynamic> unlike({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.unlike(targetType: targetType, targetId: targetId);

  Future<dynamic> bookmark({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.bookmark(targetType: targetType, targetId: targetId);

  Future<void> unbookmark({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.unbookmark(targetType: targetType, targetId: targetId);

  Future<dynamic> share({
    required String targetType,
    required dynamic targetId,
    String? sharePlatform,
  }) => remoteDataSource.share(
    targetType: targetType,
    targetId: targetId,
    sharePlatform: sharePlatform,
  );

  Future<dynamic> rate({
    required String targetType,
    required dynamic targetId,
    required int rating,
  }) => remoteDataSource.rate(
    targetType: targetType,
    targetId: targetId,
    rating: rating,
  );

  Future<UserInteractionModel> rateAndComment({
    required String targetType,
    required dynamic targetId,
    required double rating,
    String? comment,
  }) => remoteDataSource.rateAndComment(
    targetType: targetType,
    targetId: targetId,
    rating: rating,
    comment: comment,
  );

  Future<List<UserInteractionModel>> loadInteractions({
    required InteractionTarget targetType,
    required dynamic targetId,
    Map<String, dynamic>? query,
  }) =>
    remoteDataSource.loadInteractions(
      targetType: targetType,
      targetId: targetId,
      query: query,
    );

  Future<dynamic> follow({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.follow(targetType: targetType, targetId: targetId);

  Future<void> unfollow({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.unfollow(targetType: targetType, targetId: targetId);

  Future<dynamic> getStatus({
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.getStatus(targetType: targetType, targetId: targetId);

  Future<InteractionStatsModel> getStats({
    required InteractionTarget targetType,
    required dynamic targetId,
  }) => remoteDataSource.getStats(targetType: targetType, targetId: targetId);

  // save reading progress
  Future<UserInteractionModel> saveReadingProgress({required InteractionTarget targetType, required InteractionType actionType, required dynamic targetId, required ReadingProgressModel readingProgress}) 
  => remoteDataSource.saveReadingProgress(targetType: targetType, actionType: actionType, targetId: targetId, readingProgress: readingProgress);

    Future<List<UserInteractionModel>> getMyInteractions({Map<String, dynamic>? query}) =>
      remoteDataSource.getMyInteractions(query: query);

  Future<Map<String, dynamic>> getUserInteractionStatus({required InteractionTarget targetType, required dynamic targetId}) =>
    remoteDataSource.getUserInteractionStatus(targetType: targetType, targetId: targetId);

  Future<UserInteractionModel> getInteractionAction({required InteractionTarget targetType, required InteractionType actionType, required dynamic targetId}) =>
    remoteDataSource.getInteractionAction(targetType: targetType, actionType: actionType, targetId: targetId);

  Future<Map<String, int>> getMyInteractionCounts() =>
    remoteDataSource.getMyInteractionCounts();
}
