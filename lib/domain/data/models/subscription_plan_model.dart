import 'package:intl/intl.dart';

/// Model cho gói đăng ký (subscription plan) từ API.
/// Khớp với entity SubscriptionPlan ở backend.
class SubscriptionPlanModel {
  final String? id;
  final String code;
  final String name;
  final String? description;
  final int storageLimitBytes;
  final int ttsLimitPerPeriod;
  final int convertLimitPerPeriod;
  final String periodType;
  final double? price;
  final int sortOrder;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.storageLimitBytes = 0,
    this.ttsLimitPerPeriod = 0,
    this.convertLimitPerPeriod = 0,
    this.periodType = 'month',
    this.price,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      storageLimitBytes: _parseBigInt(json['storageLimitBytes']),
      ttsLimitPerPeriod: json['ttsLimitPerPeriod'],
      convertLimitPerPeriod: json['convertLimitPerPeriod'],
      periodType: json['periodType'],
      price: _parsePrice(json['price']),
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
    );
  }

  static int _parseBigInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  static double? _parsePrice(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Dung lượng lưu trữ hiển thị (VD: "1 GB", "500 MB")
  String get storageDisplay {
    const int mb = 1024 * 1024;
    const int gb = 1024 * mb;
    if (storageLimitBytes >= gb) {
      return '${(storageLimitBytes / gb).toStringAsFixed(1)} GB';
    }
    if (storageLimitBytes >= mb) {
      return '${(storageLimitBytes / mb).round()} MB';
    }
    return '$storageLimitBytes B';
  }

  /// Giá hiển thị (VD: "99.000đ/tháng")
  String get priceDisplay {
    if (price == null || price! <= 0) return '';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final period = periodType == 'year' ? '/năm' : '/tháng';
    return '${formatter.format(price)}$period';
  }

  bool get isFree => price == null || price! <= 0;
}
