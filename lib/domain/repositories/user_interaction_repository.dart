import 'package:readbox/domain/data/datasources/remote/user_interaction_data_source.dart';
import 'package:readbox/domain/data/models/models.dart';

class UserInteractionRepository {
  final UserInteractionRemoteDataSource remoteDataSource;

  UserInteractionRepository({required this.remoteDataSource});

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
    required String targetType,
    required dynamic targetId,
  }) => remoteDataSource.getStats(targetType: targetType, targetId: targetId);

  // Future<dynamic> getMyInteractions({Map<String, dynamic>? query}) =>
  //     remoteDataSource.getMyInteractions(query: query);
}
