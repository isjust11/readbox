import 'package:flutter/material.dart';
import 'package:readbox/res/colors.dart';

class BaseProgressIndicator extends StatefulWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const BaseProgressIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  @override
  State<BaseProgressIndicator> createState() => _BaseProgressIndicatorState();
}

class _BaseProgressIndicatorState extends State<BaseProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.baseColor;
    final backgroundColor =
        widget.color?.withValues(alpha: 0.2) ??
        AppColors.baseColorBorderTextField;

    final loading = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CircularProgressIndicator(
          value: _controller.value,
          strokeWidth: widget.strokeWidth,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        );
      },
    );

    return widget.size == null
        ? loading
        : SizedBox(width: widget.size, height: widget.size, child: loading);
  }
}
