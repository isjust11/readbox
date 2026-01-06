import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readbox/ui/widget/base_progress_indicator.dart';

class BaseNetworkImage extends StatelessWidget {
  final String? url;
  final double borderRadius;
  final double? width;
  final double? height;
  final String? errorAssetImage;
  final double? loadingSize;
  final BoxFit fit;
  final Color? backgroundColor;
  final bool showShimmer;

  const BaseNetworkImage({
    super.key,
    this.url,
    this.borderRadius = 0,
    this.width,
    this.height,
    this.errorAssetImage,
    this.loadingSize,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget errorWidget = _buildErrorWidget(context, isDark);

    return url == null
        ? errorWidget
        : ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              fit: fit,
              imageUrl: url!,
              placeholder: (context, url) =>
                  _buildLoadingWidget(context, isDark),
              errorWidget: (context, url, error) =>
                  _buildErrorWidget(context, isDark),
            ),
          );
  }

  Widget _buildLoadingWidget(BuildContext context, bool isDark) {
    if (!showShimmer) {
      return Center(child: BaseProgressIndicator(size: loadingSize ?? 20));
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? (isDark ? Colors.grey[900] : Colors.grey[100]),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _ShimmerEffect(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        highlightColor: isDark ? Colors.grey[600]! : Colors.grey[50]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[100]!, Colors.grey[200]!]
                : [Colors.grey[100]!, Colors.grey[50]!],
          ),
        ),
        child: errorAssetImage?.isNotEmpty ?? false
            ? Image.asset(
                errorAssetImage!,
                width: width,
                height: height,
                fit: fit,
              )
            : Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[200] : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: isDark ? Colors.grey[300] : Colors.grey[400],
                    size: 28,
                  ),
                ),
              ),
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerEffect({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
