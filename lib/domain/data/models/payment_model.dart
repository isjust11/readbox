/// Model cho payment response từ API
class PaymentModel {
  final int paymentId;
  final String transactionId;
  final String paymentUrl;
  final double amount;
  final String? status;

  PaymentModel({
    required this.paymentId,
    required this.transactionId,
    required this.paymentUrl,
    required this.amount,
    this.status,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      paymentId: (json['paymentId'] as num?)?.toInt() ?? 0,
      transactionId: json['transactionId'] as String? ?? '',
      paymentUrl: json['paymentUrl'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'transactionId': transactionId,
      'paymentUrl': paymentUrl,
      'amount': amount,
      'status': status,
    };
  }
}

/// Model cho payment status
class PaymentStatusModel {
  final String transactionId;
  final String status; // pending, completed, failed
  final double amount;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentStatusModel({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.paidAt,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      transactionId: json['transactionId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'] as String) : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
