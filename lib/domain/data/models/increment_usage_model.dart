class IncrementUsageModel {
  final int? storageUsedBytes;
  final int? ttsCount;
  final int? convertCount;
  final int? downloadCount;
  final int? readCount;
  final int? shareCount;

  IncrementUsageModel({this.storageUsedBytes, this.ttsCount, this.convertCount, this.downloadCount, this.readCount, this.shareCount});

  factory IncrementUsageModel.fromJson(Map<String, dynamic> json) {
    return IncrementUsageModel(storageUsedBytes: json['storageUsedBytes'], ttsCount: json['ttsCount'], convertCount: json['convertCount'], downloadCount: json['downloadCount'], readCount: json['readCount'], shareCount: json['shareCount']);
  }

  Map<String, dynamic> toJson() {
    return {
      'storageUsedBytes': storageUsedBytes,
      'ttsCount': ttsCount,
      'convertCount': convertCount,
      'downloadCount': downloadCount,
      'readCount': readCount,
      'shareCount': shareCount,
    };
  }
}