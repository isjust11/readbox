import 'base_entity.dart';

class ReadingProgressEntity extends BaseEntity {
  String? id;
  String? bookId;
  String? chapterId;
  int? currentPage; // For PDF
  String? currentPosition; // For EPUB
  double? progress; // 0.0 to 1.0
  DateTime? lastUpdated;
  int? totalReadingTime; // in seconds

  ReadingProgressEntity({
    this.id,
    this.bookId,
    this.chapterId,
    this.currentPage,
    this.currentPosition,
    this.progress,
    this.lastUpdated,
    this.totalReadingTime,
  });

  ReadingProgressEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookId = json['bookId'];
    chapterId = json['chapterId'];
    currentPage = json['currentPage'];
    currentPosition = json['currentPosition'];
    progress = json['progress']?.toDouble();
    lastUpdated = json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : null;
    totalReadingTime = json['totalReadingTime'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookId'] = bookId;
    data['chapterId'] = chapterId;
    data['currentPage'] = currentPage;
    data['currentPosition'] = currentPosition;
    data['progress'] = progress;
    data['lastUpdated'] = lastUpdated?.toIso8601String();
    data['totalReadingTime'] = totalReadingTime;
    return data;
  }
}

