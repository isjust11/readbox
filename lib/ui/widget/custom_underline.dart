import 'package:flutter/material.dart';
import 'package:readbox/res/resources.dart';

class CustomUnderLine extends StatelessWidget {
  final Color color;

  const CustomUnderLine({super.key, this.color = AppColors.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color,
    );
  }
}
