import 'base_entity.dart';

class BookmarkEntity extends BaseEntity {
  String? id;
  String? bookId;
  String? chapterId;
  String? title; // User-defined bookmark title
  String? note; // User note
  int? pageNumber; // For PDF
  String? position; // For EPUB (scroll position or element ID)
  DateTime? createdAt;
  String? highlightedText; // Selected text when bookmarking

  BookmarkEntity({
    this.id,
    this.bookId,
    this.chapterId,
    this.title,
    this.note,
    this.pageNumber,
    this.position,
    this.createdAt,
    this.highlightedText,
  });

  BookmarkEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookId = json['bookId'];
    chapterId = json['chapterId'];
    title = json['title'];
    note = json['note'];
    pageNumber = json['pageNumber'];
    position = json['position'];
    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    highlightedText = json['highlightedText'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookId'] = bookId;
    data['chapterId'] = chapterId;
    data['title'] = title;
    data['note'] = note;
    data['pageNumber'] = pageNumber;
    data['position'] = position;
    data['createdAt'] = createdAt?.toIso8601String();
    data['highlightedText'] = highlightedText;
    return data;
  }
}

