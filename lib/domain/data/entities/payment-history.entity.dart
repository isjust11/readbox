import 'package:readbox/domain/enums/payment_method.dart';
import 'package:readbox/domain/enums/payment_status.dart';
import 'base_entity.dart';

class PaymentHistoryEntity extends BaseEntity {
  String? id;

  String? userId;

  String? planId;

  double? amount;

  String? currency;

  PaymentMethod? paymentMethod;

  PaymentStatus? status;

  String? transactionId;

  String? paymentIntentId;

  String? gatewayTransactionId;

  String? paymentUrl;

  String? ipAddress;

  String? gatewayResponse;

  DateTime? paidAt;

  String? description;

  String? metadata;

  String? failureReason;

  String? userSubscriptionId;

  DateTime? createdAt;

  DateTime? updatedAt;

  DateTime? completedAt;

  PaymentHistoryEntity({
    this.id,
    this.userId,
    this.planId,
    this.amount,
    this.currency,
    this.paymentMethod,
    this.status,
    this.transactionId,
    this.paymentIntentId,
    this.gatewayTransactionId,
    this.paymentUrl,
    this.ipAddress,
    this.gatewayResponse,
    this.paidAt,
    this.description,
    this.metadata,
    this.failureReason,
    this.userSubscriptionId,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  PaymentHistoryEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    planId = json['planId'];
    amount = double.parse(json['amount']);
    currency = json['currency'];
    paymentMethod =
        json['paymentMethod'] != null
            ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethod.vnpay,
            )
            : null;
    status =
        json['status'] != null
            ? PaymentStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => PaymentStatus.pending,
            )
            : null;
    transactionId = json['transactionId'];
    paymentIntentId = json['paymentIntentId'];
    gatewayTransactionId = json['gatewayTransactionId'];
    paymentUrl = json['paymentUrl'];
    ipAddress = json['ipAddress'];
    gatewayResponse = json['gatewayResponse'];
    paidAt = json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null;
    description = json['description'];
    metadata = json['metadata'];
    failureReason = json['failureReason'];
    userSubscriptionId = json['userSubscriptionId'];
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt =
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    completedAt =
        json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planId': planId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'paymentIntentId': paymentIntentId,
      'gatewayTransactionId': gatewayTransactionId,
      'paymentUrl': paymentUrl,
      'ipAddress': ipAddress,
      'gatewayResponse': gatewayResponse,
      'paidAt': paidAt,
      'description': description,
      'metadata': metadata,
      'failureReason': failureReason,
      'userSubscriptionId': userSubscriptionId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'completedAt': completedAt,
    };
  }
}
