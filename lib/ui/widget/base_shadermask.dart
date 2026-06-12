import 'package:flutter/material.dart';

class BaseShaderMask extends StatelessWidget {
  const BaseShaderMask({
    super.key,
    required this.child,
    required this.colors,
    required this.begin,
    required this.end,
  });

  final Widget child;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => LinearGradient(
            colors: colors,
            begin: begin,
            end: end,
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: child,
    );
  }
}
