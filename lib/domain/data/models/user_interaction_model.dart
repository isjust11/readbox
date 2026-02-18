import 'dart:convert';

import 'package:readbox/domain/data/entities/user_interaction_entity.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';

class UserInteractionModel extends UserInteractionEntity {
  UserInteractionModel.fromJson(super.json) : super.fromJson();
  

  bool get isReading => interactionType == InteractionType.reading;
  ReadingProgressModel? get readingProgress => metadata != null && isReading ? ReadingProgressModel.fromJson(jsonDecode(metadata!)) : null;
}
