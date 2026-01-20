class FilterModel {
  final String? categoryId;
  final bool isMyUpload;
  final String? format;

  FilterModel({
    this.categoryId,
    this.isMyUpload = false,
    this.format,
  });
}