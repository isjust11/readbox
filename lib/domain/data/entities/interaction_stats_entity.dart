import 'package:readbox/domain/data/entities/entities.dart';
import 'package:readbox/domain/enums/enums.dart';

class InteractionStatsEntity extends BaseEntity {
  String? id;
  InteractionTarget? targetType;
  String? targetId;

  // Optional foreign key relationships based on target type

  // Related entities
  BookEntity? book;

  // Statistics counters
  int? likeCount;
  int? dislikeCount;
  int? bookmarkCount;
  int? shareCount;
  int? viewCount;
  int? commentCount;
  int? rateCount;
  int? followCount;
  bool? favoriteStatus;
  bool? archiveStatus;

  // Average rating (for rate interactions)
  double? averageRating;

  // Total rating sum (for calculating average)
  double? totalRating;

  String? createdAt;
  String? updatedAt;

  InteractionStatsEntity.fromJson(Map<String, dynamic> json)
    : super.fromJson(json) {
    id = json['id'];
    targetType = json['targetType'] != null
        ? InteractionTarget.fromString(json['targetType'])
        : null;
    targetId = json['targetId'];

    favoriteStatus = json['favoriteStatus'];
    archiveStatus = json['archiveStatus'];
    if (json['book'] != null) {
      book = BookEntity.fromJson(json['book']);
    }

    // Statistics counters
    likeCount = json['likeCount'];
    dislikeCount = json['dislikeCount'];
    bookmarkCount = json['bookmarkCount'];
    shareCount = json['shareCount'];
    viewCount = json['viewCount'];
    commentCount = json['commentCount'];
    rateCount = json['rateCount'];
    followCount = json['followCount'];

    // Rating data
    averageRating = json['averageRating'] != null
        ? double.parse(json['averageRating'])
        : 0.0;
    totalRating = json['totalRating'] != null
        ? double.parse(json['totalRating'])
        : 0.0;

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['targetType'] = targetType?.value;
    data['targetId'] = targetId;


    // Related entities
    data['book'] = book?.toJson();

    // Statistics counters
    data['likeCount'] = likeCount;
    data['dislikeCount'] = dislikeCount;
    data['bookmarkCount'] = bookmarkCount;
    data['shareCount'] = shareCount;
    data['viewCount'] = viewCount;
    data['commentCount'] = commentCount;
    data['rateCount'] = rateCount;
    data['followCount'] = followCount;

    // Rating data
    data['averageRating'] = averageRating;
    data['totalRating'] = totalRating;

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['favoriteStatus'] = favoriteStatus;
    data['archiveStatus'] = archiveStatus;
    return data;
  }
}
