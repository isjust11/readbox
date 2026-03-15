enum PaymentStatus {
  pending('pending'),
  completed('completed'),
  failed('failed'),
  refunded('refunded'),
  cancelled('cancelled');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}
