import 'package:readbox/domain/data/entities/book_file_entity.dart';
import 'package:readbox/domain/data/entities/user_entity.dart';
import 'package:readbox/domain/data/models/models.dart';

import 'base_entity.dart';

enum BookType { epub, azw3, pdf }

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

  // --- Các trường mới đồng bộ từ backend ---
  String? countryCode;
  String? region;
  bool? isPublic;
  String? parentCategoryId;
  CategoryModel? parentCategory;
  String? statusId;
  CategoryModel? status;
  UserEntity? createBy;
  String? matchKey;
  List<BookFileEntity>? files;
  DateTime? publishedDate;
  bool isInvalid = false;
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
    this.countryCode,
    this.region,
    this.isPublic,
    this.parentCategoryId,
    this.parentCategory,
    this.statusId,
    this.status,
    this.createBy,
    this.matchKey,
    this.files,
    this.publishedDate,
  });

  BookEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    author = json['author'];
    description = json['description'];
    coverImageUrl = json['coverImageUrl'];
    fileUrl = json['fileUrl'];
    fileType =
        json['fileType'] != null
            ? BookType.values.firstWhere(
              (e) => e.toString() == 'BookType.${json['fileType']}',
              orElse: () => BookType.epub,
            )
            : BookType.epub;
    fileSize =
        json['fileSize'] != null
            ? int.parse(json['fileSize'].toString())
            : null;
    categories =
        json['categories'] != null ? List<String>.from(json['categories']) : [];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : [];
    rating = json['rating']?.toDouble();
    dateAdded =
        json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : null;
    lastRead =
        json['lastRead'] != null ? DateTime.parse(json['lastRead']) : null;
    totalPages =
        json['totalPages'] != null
            ? int.parse(json['totalPages'].toString())
            : null;
    // isFavorite = json['isFavorite'] ?? false;
    // isArchived = json['isArchived'] ?? false;
    publisher = json['publisher'];
    isbn = json['isbn'];
    language = json['language'];
    createById = json['createById'];
    createAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    categoryId = json['categoryId'];
    isLocalBook = json['isLocalBook'] ?? false;
    category =
        json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null;

    // --- Các trường mới ---
    countryCode = json['countryCode'];
    region = json['region'];
    isPublic = json['isPublic'];
    parentCategoryId = json['parentCategoryId']?.toString();
    parentCategory =
        json['parentCategory'] != null
            ? CategoryModel.fromJson(json['parentCategory'])
            : null;
    statusId = json['statusId']?.toString();
    status =
        json['status'] != null ? CategoryModel.fromJson(json['status']) : null;
    createBy =
        json['createBy'] != null ? UserEntity.fromJson(json['createBy']) : null;
    matchKey = json['matchKey'];
    files =
        json['files'] != null
            ? (json['files'] as List)
                .map((f) => BookFileEntity.fromJson(f as Map<String, dynamic>))
                .toList()
            : null;
    // lấy thể loại ebook type theo danh sách file ưu tiên epub => pdf
    if (files != null && files!.any((f) => f.ebookFormat == EbookFormat.epub)) {
      fileType = BookType.epub;
    } else if (files != null &&
        files!.any((f) => f.ebookFormat == EbookFormat.pdf)) {
      fileType = BookType.pdf;
    }
    publishedDate =
        json['publishedDate'] != null
            ? DateTime.tryParse(json['publishedDate'])
            : null;
    isInvalid = files?.isEmpty ?? false;
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

    // --- Các trường mới ---
    data['countryCode'] = countryCode;
    data['region'] = region;
    data['isPublic'] = isPublic;
    data['parentCategoryId'] = parentCategoryId;
    data['parentCategory'] = parentCategory?.toJson();
    data['statusId'] = statusId;
    data['status'] = status?.toJson();
    data['createBy'] = createBy?.toJson();
    data['matchKey'] = matchKey;
    data['files'] = files?.map((f) => f.toJson()).toList();
    data['publishedDate'] = publishedDate?.toIso8601String();
    return data;
  }
}
