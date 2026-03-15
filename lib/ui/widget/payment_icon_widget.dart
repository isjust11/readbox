import 'package:flutter/material.dart';
import 'package:readbox/domain/enums/payment_method.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/res/resources.dart';

class PaymentIconWidget extends StatelessWidget {
  final PaymentMethod? paymentMethod;
  const PaymentIconWidget({super.key, this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    switch (paymentMethod) {
      case PaymentMethod.payos:
        return Image.asset(
          Assets.images.payos.path,
          width: AppDimens.SIZE_32,
          height: AppDimens.SIZE_32,
        );
      case PaymentMethod.momo:
        return Image.asset(
          Assets.images.momo.path,
          width: AppDimens.SIZE_32,
          height: AppDimens.SIZE_32,
        );
      case PaymentMethod.vnpay:
        return Image.asset(
          Assets.images.vnpay.path,
          width: AppDimens.SIZE_32,
          height: AppDimens.SIZE_32,
        );
      default:
        return Image.asset(
          Assets.images.payos.path,
          width: AppDimens.SIZE_32,
          height: AppDimens.SIZE_32,
        );
    }
  }
}
