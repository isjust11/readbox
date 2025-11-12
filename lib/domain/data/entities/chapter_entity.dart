import 'base_entity.dart';

class ChapterEntity extends BaseEntity {
  String? id;
  String? bookId;
  String? title;
  int? order;
  String? content; // HTML content for EPUB
  int? startPage; // For PDF
  int? endPage; // For PDF
  String? href; // For EPUB navigation

  ChapterEntity({
    this.id,
    this.bookId,
    this.title,
    this.order,
    this.content,
    this.startPage,
    this.endPage,
    this.href,
  });

  ChapterEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookId = json['bookId'];
    title = json['title'];
    order = json['order'];
    content = json['content'];
    startPage = json['startPage'];
    endPage = json['endPage'];
    href = json['href'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookId'] = bookId;
    data['title'] = title;
    data['order'] = order;
    data['content'] = content;
    data['startPage'] = startPage;
    data['endPage'] = endPage;
    data['href'] = href;
    return data;
  }
}

