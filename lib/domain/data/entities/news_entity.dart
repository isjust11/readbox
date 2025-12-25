import 'base_entity.dart';

class NewsEntity extends BaseEntity {
  int? id;
  String? title;
  String? content;
  String? summary;
  String? imageUrl;
  String? author;
  String? category;
  List<String>? tags;
  DateTime? publishedDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? viewCount;
  bool? isPublished;
  bool? isFeatured;
  String? source;
  String? sourceUrl;

  NewsEntity({
    this.id,
    this.title,
    this.content,
    this.summary,
    this.imageUrl,
    this.author,
    this.category,
    this.tags,
    this.publishedDate,
    this.createdAt,
    this.updatedAt,
    this.viewCount,
    this.isPublished,
    this.isFeatured,
    this.source,
    this.sourceUrl,
  });

  NewsEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null);
    title = json['title'];
    content = json['content'];
    summary = json['summary'];
    imageUrl = json['imageUrl'];
    author = json['author'];
    category = json['category'];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];
    try {
      publishedDate = json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'].toString())
          : null;
    } catch (e) {
      publishedDate = null;
    }
    try {
      createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null;
    } catch (e) {
      createdAt = null;
    }
    try {
      updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null;
    } catch (e) {
      updatedAt = null;
    }
    viewCount = json['viewCount'] is int 
        ? json['viewCount'] 
        : (json['viewCount'] != null ? int.tryParse(json['viewCount'].toString()) : null);
    isPublished = json['isPublished'] is bool 
        ? json['isPublished'] 
        : (json['isPublished'] == true || json['isPublished'] == 'true');
    isFeatured = json['isFeatured'] is bool 
        ? json['isFeatured'] 
        : (json['isFeatured'] == true || json['isFeatured'] == 'true');
    source = json['source'];
    sourceUrl = json['sourceUrl'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['content'] = content;
    data['summary'] = summary;
    data['imageUrl'] = imageUrl;
    data['author'] = author;
    data['category'] = category;
    data['tags'] = tags;
    data['publishedDate'] = publishedDate?.toIso8601String();
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['viewCount'] = viewCount;
    data['isPublished'] = isPublished;
    data['isFeatured'] = isFeatured;
    data['source'] = source;
    data['sourceUrl'] = sourceUrl;
    return data;
  }
}

