import 'package:readbox/domain/data/entities/base_entity.dart';
import 'package:readbox/domain/data/entities/book_entity.dart';
import 'package:readbox/domain/data/entities/user_entity.dart';
import 'package:readbox/domain/enums/enums.dart';

class UserInteractionEntity extends BaseEntity {
  String? id;
  String? userId;
  UserEntity? user;
  InteractionType? interactionType;
  InteractionTarget? targetType;
  String? targetId;

  // Optional foreign key relationships based on target type
  String? bookId;

  // Related entities
  BookEntity? book;

  // Additional data for specific interaction types
  Map<String, dynamic>? metadata;

  // For rating interactions
  double? rating;

  // For comment interactions
  String? comment;

  // For share interactions
  String? sharePlatform;

  String? createdAt;
  String? updatedAt;

  UserInteractionEntity.fromJson(Map<String, dynamic> json)
    : super.fromJson(json) {
    id = json['id'];
    userId = json['userId'];
    interactionType = json['interactionType'] != null
        ? InteractionType.fromString(json['interactionType'])
        : null;
    targetType = json['targetType'] != null
        ? InteractionTarget.fromString(json['targetType'])
        : null;
    targetId = json['targetId'];

    // Optional foreign keys
    bookId = json['bookId'];

    // Related entities
    if (json['user'] != null) {
      user = UserEntity.fromJson(json['user']);
    }
    if (json['book'] != null) {
      book = BookEntity.fromJson(json['book']);
    }

    // Additional data
    metadata = json['metadata'];
    rating = json['rating']?.toDouble();
    comment = json['comment'];
    sharePlatform = json['sharePlatform'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['interactionType'] = interactionType?.value;
    data['targetType'] = targetType?.value;
    data['targetId'] = targetId;

    // Optional foreign keys
    data['bookId'] = bookId;

    // Related entities
    data['user'] = user?.toJson();
    data['book'] = book?.toJson();

    // Additional data
    data['metadata'] = metadata;
    data['rating'] = rating;
    data['comment'] = comment;
    data['sharePlatform'] = sharePlatform;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    return data;
  }
}
