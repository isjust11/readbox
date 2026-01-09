class MediaModel {
  final String id;
  final String filename;
  final String originalName;
  final String mimeType;
  final int size;
  final String url;
  final String? description;
  final String? altText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String publicRelativePath;

  MediaModel({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.mimeType,
    required this.size,
    required this.url,
    this.description,
    this.altText,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.publicRelativePath,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      url: json['url'] ?? '',
      description: json['description'],
      altText: json['altText'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['createdBy'] ?? '',
      publicRelativePath: json['publicRelativePath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'originalName': originalName,
      'mimeType': mimeType,
      'size': size,
      'url': url,
      'description': description,
      'altText': altText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'publicRelativePath': publicRelativePath,
    };
  }

  MediaModel copyWith({
    String? id,
    String? filename,
    String? originalName,
    String? mimeType,
    int? size,
    String? url,
    String? description,
    String? altText,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? publicRelativePath,
  }) {
    return MediaModel(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      originalName: originalName ?? this.originalName,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      url: url ?? this.url,
      description: description ?? this.description,
      altText: altText ?? this.altText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      publicRelativePath: publicRelativePath ?? this.publicRelativePath,
    );
  }
}
