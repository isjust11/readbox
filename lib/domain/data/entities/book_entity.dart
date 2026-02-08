import 'package:readbox/domain/data/models/models.dart';

import 'base_entity.dart';

enum BookType { epub, pdf }

class BookEntity extends BaseEntity {
  String? id;
  String? title;
  String? author;
  String? description;
  String? coverImageUrl;
  String? fileUrl;
  BookType? fileType;
  int? fileSize; // in bytes
  List<String>? categories;
  List<String>? tags;
  double? rating;
  DateTime? dateAdded;
  DateTime? lastRead;
  int? totalPages;
  bool? isFavorite;
  bool? isArchived;
  String? publisher;
  String? isbn;
  String? language;
  String? createById;
  DateTime? createAt;
  DateTime? updatedAt;
  String? categoryId;
  bool? isLocalBook;
  CategoryModel? category;
  BookEntity({
    this.id,
    this.title,
    this.author,
    this.description,
    this.coverImageUrl,
    this.fileUrl,
    this.fileType,
    this.fileSize,
    this.categories,
    this.tags,
    this.rating,
    this.dateAdded,
    this.lastRead,
    this.totalPages,
    this.isFavorite,
    this.isArchived,
    this.publisher,
    this.isbn,
    this.language,
    this.createById,
    this.createAt,
    this.updatedAt,
    this.categoryId,
  });

  BookEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    author = json['author'];
    description = json['description'];
    coverImageUrl = json['coverImageUrl'];
    fileUrl = json['fileUrl'];
    fileType = json['fileType'] != null
        ? BookType.values.firstWhere(
            (e) => e.toString() == 'BookType.${json['fileType']}',
            orElse: () => BookType.epub,
          )
        : BookType.epub;
    fileSize = json['fileSize'];
    categories = json['categories'] != null
        ? List<String>.from(json['categories'])
        : [];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];
    rating = json['rating']?.toDouble();
    dateAdded = json['dateAdded'] != null
        ? DateTime.parse(json['dateAdded'])
        : null;
    lastRead =
        json['lastRead'] != null ? DateTime.parse(json['lastRead']) : null;
    totalPages = json['totalPages'];
    isFavorite = json['isFavorite'] ?? false;
    isArchived = json['isArchived'] ?? false;
    publisher = json['publisher'];
    isbn = json['isbn'];
    language = json['language'];
    createById = json['createById'];
    createAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    categoryId = json['categoryId'];
    isLocalBook = json['isLocalBook'] ?? false;
    category = json['category'] != null ? CategoryModel.fromJson(json['category']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['author'] = author;
    data['description'] = description;
    data['coverImageUrl'] = coverImageUrl;
    data['fileUrl'] = fileUrl;
    data['fileType'] = fileType?.toString().split('.').last;
    data['fileSize'] = fileSize;
    data['categories'] = categories;
    data['tags'] = tags;
    data['rating'] = rating;
    data['dateAdded'] = dateAdded?.toIso8601String();
    data['lastRead'] = lastRead?.toIso8601String();
    data['totalPages'] = totalPages;
    data['isFavorite'] = isFavorite;
    data['isArchived'] = isArchived;
    data['publisher'] = publisher;
    data['isbn'] = isbn;
    data['language'] = language;
    data['createById'] = createById;
    data['createdAt'] = createAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['category'] = category?.toJson();
    return data;
  }
}

