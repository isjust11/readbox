import 'package:flutter/material.dart';
import 'package:readbox/res/colors.dart';

class BaseProgressIndicator extends StatelessWidget {
  final double? size;

  const BaseProgressIndicator({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loading = CircularProgressIndicator(
      strokeWidth: 3,
      backgroundColor: AppColors.baseColor,
      valueColor: new AlwaysStoppedAnimation<Color>(AppColors.baseColorBorderTextField),
    );
    return size == null
        ? loading
        : SizedBox(
            width: size,
            height: size,
            child: loading,
          );
  }
}
