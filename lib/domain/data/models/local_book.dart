class LocalBook {
  final String filePath;
  final String fileName;
  final String fileType; // pdf, epub, mobi
  final int fileSize;
  final DateTime addedDate;
  final int totalPages;

  LocalBook({
    required this.filePath,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.totalPages,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'addedDate': addedDate.toIso8601String(),
      'totalPages': totalPages,
    };
  }

  factory LocalBook.fromJson(Map<String, dynamic> json) {
    return LocalBook(
      filePath: json['filePath'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      addedDate: DateTime.parse(json['addedDate'] as String),
      totalPages: json['totalPages'] as int,
    );
  }

  // Extract title from filename (remove extension)
  String get title {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast(); // Remove extension
      return parts.join('.');
    }
    return fileName;
  }

  // Extract author if filename format is "Title - Author.pdf"
  String get author {
    if (title.contains(' - ')) {
      final parts = title.split(' - ');
      return parts.length > 1 ? parts[1].trim() : 'Unknown';
    }
    return 'Unknown';
  }

  // Get clean title without author
  String get cleanTitle {
    if (title.contains(' - ')) {
      return title.split(' - ')[0].trim();
    }
    return title;
  }

  // Format file size
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

