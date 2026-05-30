import 'base_entity.dart';

/// Định dạng file ebook chuẩn hóa.
enum EbookFormat {
  pdf,
  epub,
  mobi,
  azw,
  azw3,
  fb2,
  other;

  static EbookFormat fromString(String? value) {
    if (value == null) return EbookFormat.other;
    return EbookFormat.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => EbookFormat.other,
    );
  }
}

/// Một bản ebook có thể có nhiều file định dạng khác nhau (pdf, epub, mobi…).
/// Mỗi định dạng = 1 BookFile riêng, gắn vào cùng một Book.
class BookFileEntity extends BaseEntity {
  String? id;
  String? bookId;
  String? format; // 'pdf' | 'epub' | 'mobi' | ...
  String? mimeType;
  String? fileUrl;
  int? fileSize;
  String? fileHash;
  String? source; // 'upload' | 'drive' | 'external_url' | 'admin_seed'
  String? googleDriveFileId;
  String? mediaId;
  bool? isPrimary;
  int? totalPages;
  DateTime? createdAt;
  DateTime? updatedAt;

  BookFileEntity({
    this.id,
    this.bookId,
    this.format,
    this.mimeType,
    this.fileUrl,
    this.fileSize,
    this.fileHash,
    this.source,
    this.googleDriveFileId,
    this.mediaId,
    this.isPrimary,
    this.totalPages,
    this.createdAt,
    this.updatedAt,
  });

  BookFileEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id']?.toString();
    bookId = json['bookId']?.toString();
    format = json['format'];
    mimeType = json['mimeType'];
    fileUrl = json['fileUrl'];
    fileSize = json['fileSize'] != null
        ? int.tryParse(json['fileSize'].toString())
        : null;
    fileHash = json['fileHash'];
    source = json['source'];
    googleDriveFileId = json['googleDriveFileId'];
    mediaId = json['mediaId']?.toString();
    isPrimary = json['isPrimary'];
    totalPages = json['totalPages'] != null
        ? int.tryParse(json['totalPages'].toString())
        : null;
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bookId'] = bookId;
    data['format'] = format;
    data['mimeType'] = mimeType;
    data['fileUrl'] = fileUrl;
    data['fileSize'] = fileSize;
    data['fileHash'] = fileHash;
    data['source'] = source;
    data['googleDriveFileId'] = googleDriveFileId;
    data['mediaId'] = mediaId;
    data['isPrimary'] = isPrimary;
    data['totalPages'] = totalPages;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }

  /// Lấy EbookFormat enum từ format string.
  EbookFormat get ebookFormat => EbookFormat.fromString(format);

  /// Kích thước file đã format.
  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    }
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
