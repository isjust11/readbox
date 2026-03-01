enum InteractionType {
  favorite('favorite'),
  bookmark('bookmark'),
  save('save'),
  reading('reading'),
  download('download'),
  rating('rating'),
  archived('archived'),
  share('share'),
  tts('tts');


  const InteractionType(this.value);
  final String value;

  static InteractionType fromString(String value) {
    return InteractionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => InteractionType.reading,
    );
  }
}
