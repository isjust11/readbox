enum InteractionTarget {
  book('book'),
  author('author'),
  none('none');

  const InteractionTarget(this.value);
  final String value;

  static InteractionTarget fromString(String value) {
    return InteractionTarget.values.firstWhere(
      (target) => target.value == value,
      orElse: () => InteractionTarget.none,
    );
  }
}
