import 'dart:convert';

import 'package:readbox/domain/data/entities/user_interaction_entity.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';

class UserInteractionModel extends UserInteractionEntity {
  UserInteractionModel.fromJson(super.json) : super.fromJson();

  bool get isReading => interactionType == InteractionType.reading;

  ReadingProgressModel? getReadingProgressForFormat(String format) {
    if (metadata == null || !isReading) return null;
    try {
      final decoded = jsonDecode(metadata!);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey(format)) {
          return ReadingProgressModel.fromJson(Map<String, dynamic>.from(decoded[format]));
        }
        // Fallback for legacy flat metadata
        final String? storedFormat = decoded['format'];
        if (storedFormat == format || (storedFormat == null && format == 'pdf')) {
          return ReadingProgressModel.fromJson(decoded);
        }
      }
    } catch (_) {}
    return null;
  }

  ReadingProgressModel? get readingProgress {
    if (metadata == null || !isReading) return null;
    try {
      final decoded = jsonDecode(metadata!);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('epub') || decoded.containsKey('pdf')) {
          final epubJson = decoded['epub'];
          final pdfJson = decoded['pdf'];
          ReadingProgressModel? epubProgress = epubJson != null ? ReadingProgressModel.fromJson(Map<String, dynamic>.from(epubJson)) : null;
          ReadingProgressModel? pdfProgress = pdfJson != null ? ReadingProgressModel.fromJson(Map<String, dynamic>.from(pdfJson)) : null;
          if (epubProgress != null && pdfProgress != null) {
            if (epubProgress.lastUpdated == null) return pdfProgress;
            if (pdfProgress.lastUpdated == null) return epubProgress;
            return epubProgress.lastUpdated!.isAfter(pdfProgress.lastUpdated!) ? epubProgress : pdfProgress;
          }
          return epubProgress ?? pdfProgress;
        }
        return ReadingProgressModel.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}
