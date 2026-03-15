enum PaymentMethod {
  stripe('stripe'),
  vnpay('vnpay'),
  momo('momo'),
  zalopay('zalopay'),
  payos('payos'),
  cash('cash');

  const PaymentMethod(this.value);
  final String value;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PaymentMethod.stripe,
    );
  }
}
