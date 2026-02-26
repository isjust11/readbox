import 'package:intl/intl.dart';
import 'package:readbox/domain/data/models/models.dart';

/// Model cho gói đăng ký (subscription plan) từ API.
/// Khớp với entity SubscriptionPlan ở backend.
class UserSubscriptionModel {
  final String? id;
  final SubscriptionPlanModel? plan;
  final DateTime startedAt;
  final DateTime expiresAt;
  final int storageUsedBytes;
  final int ttsUsedInPeriod;
  final int convertUsedInPeriod;
  final String currentPeriodKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSubscriptionModel({
    required this.id,
    required this.plan,
    required this.startedAt,
    required this.expiresAt,
    required this.storageUsedBytes,
    required this.ttsUsedInPeriod,
    required this.convertUsedInPeriod,
    required this.currentPeriodKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'],
      plan: json['plan'] != null ? SubscriptionPlanModel.fromJson(json['plan']) : null,
      startedAt: DateTime.parse(json['startedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      storageUsedBytes: _parseBigInt(json['storageUsedBytes']),
      ttsUsedInPeriod: _parseBigInt(json['ttsUsedInPeriod']),
      convertUsedInPeriod: _parseBigInt(json['convertUsedInPeriod']),
      currentPeriodKey: json['currentPeriodKey'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static int _parseBigInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  /// Dung lượng lưu trữ hiển thị (VD: "1 GB", "500 MB")
  String get storageDisplay {
    const int mb = 1024 * 1024;
    const int gb = 1024 * mb;
    if (storageUsedBytes >= gb) {
      return '${(storageUsedBytes / gb).toStringAsFixed(1)} GB';
    }
    if (storageUsedBytes >= mb) {
      return '${(storageUsedBytes / mb).round()} MB';
    }
    return '$storageUsedBytes B';
  }

  /// Giá hiển thị (VD: "99.000đ/tháng")
  String get priceDisplay {
    if (plan?.price == null || plan?.price == 0) return '';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final period = plan?.periodType == 'year' ? '/năm' : '/tháng';
    return '${formatter.format(plan?.price)}$period';
  }

  bool get isFree => plan?.price == null || plan?.price == 0;
}
