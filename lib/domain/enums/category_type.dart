enum CategoryType {
  folkMedicine('FolkMedicine'),
  discovery('Discovery'),
  tips('Tips');

  const CategoryType(this.value);
  final String value;

  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere((type) => type.value == value);
  }
}
