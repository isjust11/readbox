import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/repositories/user_interaction_repository.dart';

class UserInteractionCubit extends Cubit<BaseState> {
  bool isFavorite = false;
  bool isArchived = false;
  bool isBookmarked = false;
  bool hasTrackedBookmark = false;
  int viewCount = 0;
  int likeCount = 0;
  bool hasTrackedView = false;
  List<UserInteractionModel> readingBooks = [];
  List<UserInteractionModel> reviews = [];
  bool _hasMore = true;
  bool get hasMore => _hasMore;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  final UserInteractionRepository repository;
  UserInteractionCubit({required this.repository}) : super(InitState());

  // toggle favorite
  Future<dynamic> toggleFavorite({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.toggleFavorite(
        targetType: targetType,
        targetId: targetId,
      );
      isFavorite = !isFavorite;
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // toggle favorite
  Future<dynamic> toggleArchive({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.toggleArchive(
        targetType: targetType,
        targetId: targetId,
      );
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // save reading progress
  Future<dynamic> saveReadingProgress({
    required InteractionTarget targetType,
    required InteractionType actionType,
    required dynamic targetId,
    required ReadingProgressModel readingProgress,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.saveReadingProgress(
        targetType: targetType,
        actionType: actionType,
        targetId: targetId,
        readingProgress: readingProgress,
      );
      return response;
    } catch (e) {
      throw Exception(BlocUtils.getMessageError(e));
    }
  }

  Future<dynamic> bookmark({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.bookmark(
        targetType: targetType,
        targetId: targetId,
      );
      isBookmarked = true;
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void unbookmark({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      await repository.unbookmark(targetType: targetType, targetId: targetId);
      isBookmarked = false;
      emit(LoadedState(null));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void share({
    required String targetType,
    required dynamic targetId,
    String? platform,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.share(
        targetType: targetType,
        targetId: targetId,
        sharePlatform: platform,
      );
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void view({required String targetType, required dynamic targetId}) async {
    // Avoid tracking view multiple times
    if (hasTrackedView) return;

    try {
      // emit(LoadingState());
      await repository.view(targetType: targetType, targetId: targetId);
      // Increment view count locally
      viewCount++;
      hasTrackedView = true;
      // emit(LoadedUserInteractionState(response));
    } catch (e) {
      // emit(ErrorUserInteractionState(BlocUtils.getMessageError(e)));
    }
  }

  void rate({
    required String targetType,
    required dynamic targetId,
    required int rating,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.rate(
        targetType: targetType,
        targetId: targetId,
        rating: rating,
      );
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> rateAndComment({
    required String targetType,
    required dynamic targetId,
    required double rating,
    String? comment,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.rateAndComment(
        targetType: targetType,
        targetId: targetId,
        rating: rating,
        comment: comment,
      );
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
      rethrow;
    }
  }

  Future<void> loadInteractions({
    required InteractionTarget targetType,
    required dynamic targetId,
    Map<String, dynamic>? query,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      emit(LoadingState());
      reviews = [];
      _hasMore = true;
    } else {
      _isLoadingMore = true;
    }
    final response = await repository.loadInteractions(
      targetType: targetType,
      targetId: targetId,
      query: query,
    );
    if (isLoadMore) {
      reviews.addAll(response);
      _hasMore = response.length >= (query?['limit'] ?? 10);
      _isLoadingMore = false;
    } else {
      reviews = response;
      _hasMore = response.length >= (query?['limit'] ?? 10);
    }
    emit(LoadedState(List.from(reviews)));
  }

  void follow({required String targetType, required dynamic targetId}) async {
    try {
      emit(LoadingState());
      final response = await repository.follow(
        targetType: targetType,
        targetId: targetId,
      );
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void unfollow({required String targetType, required dynamic targetId}) async {
    try {
      emit(LoadingState());
      await repository.unfollow(targetType: targetType, targetId: targetId);
      emit(LoadedState(null));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  void getStatus({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.getStatus(
        targetType: targetType,
        targetId: targetId,
      );
      isFavorite = response != null && response['like'] == true;
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> getStats({
    required String targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.getStats(
        targetType: targetType,
        targetId: targetId,
      );
      isFavorite = response.favoriteStatus == true;
      isArchived = response.archiveStatus == true;
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> getMyInteractions({Map<String, dynamic>? query}) async {
    try {
      emit(LoadingState());
      final response = await repository.getMyInteractions(query: query);
      readingBooks = response;
      emit(LoadedState(readingBooks));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future<void> getUserInteractionStatus({
    required InteractionTarget targetType,
    required dynamic targetId,
  }) async {
    try {
      emit(LoadingState());
      final response = await repository.getUserInteractionStatus(targetType: targetType, targetId: targetId);
      emit(LoadedState(response));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  // get interaction by target
  Future<UserInteractionModel> getInteractionAction({
    required InteractionTarget targetType,
    required InteractionType actionType,
    required dynamic targetId,
  }) async {
    try {
      final response = await repository.getInteractionAction(
        targetType: targetType,
        actionType: actionType,
        targetId: targetId,
      );
      return response;
    } catch (e) {
      throw Exception(BlocUtils.getMessageError(e));
    }
  }

  void initInteraction({
    required bool isView,
    required bool isFavorite,
    required bool isBookmarked,
  }) {
    this.isFavorite = isFavorite;
    this.isBookmarked = isBookmarked;
  }

  // Reset state when switching to different target
  void resetState() {
    isFavorite = false;
    isBookmarked = false;
    viewCount = 0;
    likeCount = 0;
    hasTrackedView = false;
    hasTrackedBookmark = false;
    emit(InitState());
  }
}
