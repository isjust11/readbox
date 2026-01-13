enum InteractionType {
  favorite('favorite'),
  bookmark('bookmark'),
  save('save'),
  read('read'),
  download('download');

  const InteractionType(this.value);
  final String value;

  static InteractionType fromString(String value) {
    return InteractionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InteractionType.read,
    );
  }
}
