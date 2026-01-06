import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/widget.dart';

enum LoadingType {
  waveDots,
  inkDrop,
  twistingDots,
  threeRotatingDots,
  staggeredDotsWave,
  fourRotatingDots,
  fallingDot,
  discreteCircle,
  threeArchedCircle,
  bouncingBall,
  flickr,
  hexagonDots,
  beat,
  twoRotatingArc,
  horizontalRotatingDots,
  newtonCradle,
  stretchedDots,
  halfTriangleDot,
  dotsTriangle,
}

class LoadingTemplate extends StatelessWidget {
  final String? message;
  final LoadingType loadingType;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? size;

  const LoadingTemplate({
    super.key,
    this.message,
    this.loadingType = LoadingType.threeArchedCircle,
    this.backgroundColor,
    this.indicatorColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {}, // Prevent interaction
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
          ),
          child: Center(child: _buildLoadingContent(context)),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_18),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: AppDimens.SIZE_16,
            offset: const Offset(0, AppDimens.SIZE_4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppDimens.SIZE_16),
            _buildMessage(context),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    switch (loadingType) {
      case LoadingType.waveDots:
        return LoadingAnimationWidget.waveDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.inkDrop:
        return LoadingAnimationWidget.inkDrop(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.twistingDots:
        return LoadingAnimationWidget.twistingDots(
          leftDotColor: indicatorColor ?? AppColors.baseColor,
          rightDotColor: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.threeRotatingDots:
        return LoadingAnimationWidget.threeRotatingDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.staggeredDotsWave:
        return LoadingAnimationWidget.staggeredDotsWave(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.fourRotatingDots:
        return LoadingAnimationWidget.fourRotatingDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.fallingDot:
        return LoadingAnimationWidget.fallingDot(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.discreteCircle:
        return LoadingAnimationWidget.discreteCircle(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.threeArchedCircle:
        return LoadingAnimationWidget.threeArchedCircle(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.bouncingBall:
        return LoadingAnimationWidget.bouncingBall(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.flickr:
        return LoadingAnimationWidget.flickr(
          leftDotColor: indicatorColor ?? AppColors.baseColor,
          rightDotColor: indicatorColor ?? AppColors.focusBorder,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.hexagonDots:
        return LoadingAnimationWidget.hexagonDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.beat:
        return LoadingAnimationWidget.beat(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.twoRotatingArc:
        return LoadingAnimationWidget.twoRotatingArc(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.horizontalRotatingDots:
        return LoadingAnimationWidget.horizontalRotatingDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.newtonCradle:
        return LoadingAnimationWidget.newtonCradle(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.stretchedDots:
        return LoadingAnimationWidget.stretchedDots(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.halfTriangleDot:
        return LoadingAnimationWidget.halfTriangleDot(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
      case LoadingType.dotsTriangle:
        return LoadingAnimationWidget.dotsTriangle(
          color: indicatorColor ?? AppColors.baseColor,
          size: size ?? AppDimens.SIZE_32,
        );
    }
  }

  Widget _buildMessage(BuildContext context) {
    final displayMessage = message ?? AppLocalizations.current.loading;
    return CustomTextLabel(
      displayMessage,
      fontSize: AppDimens.SIZE_14,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
      textAlign: TextAlign.center,
    );
  }
}
