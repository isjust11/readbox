import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

/// T is the bloc that will be used to show the snack bar
/// If T is null, the snack bar will be shown without a bloc
class CustomSnackBar<T extends Cubit<BaseState>> extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;

  const CustomSnackBar({super.key, this.fontSize, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BlocListener<T, BaseState>(
      child: Container(),
      listener: (context, state) {
        String? mess;
        if (state is LoadedState) {
          mess = state.message;
        } else if (state is ErrorState) {
          mess = state.message ?? state.data?.toString() ?? 'Error';
        } else if (state is LoadingState) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_buildSnackBar(context, state, mess ?? ''));
      },
    );
  }

  SnackBar _buildSnackBar(BuildContext context, BaseState state, String mess) {
    final SnackBarType snackBarType =
        state is LoadedState
            ? SnackBarType.success
            : state is ErrorState
            ? SnackBarType.error
            : SnackBarType.info;

    return SnackBar(
      content: _AnimatedSnackBarContent(
        message: mess,
        snackBarType: snackBarType,
        fontSize: fontSize,
        textColor: textColor,
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppDimens.SIZE_20),
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(milliseconds: 3000),
    );
  }
}

class AppSnackBar {
  /// Show snackbar không cần Bloc
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType snackBarType = SnackBarType.success,
    double? fontSize,
    Color? textColor,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _AnimatedSnackBarContent(
          message: message,
          snackBarType: SnackBarType.success,
          fontSize: fontSize,
          textColor: textColor,
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppDimens.SIZE_20),
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration,
      ),
    );
  }
}

class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final SnackBarType snackBarType;
  final double? fontSize;
  final Color? textColor;

  const _AnimatedSnackBarContent({
    required this.message,
    required this.snackBarType,
    this.fontSize,
    this.textColor,
  });

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accentColor =
        widget.snackBarType == SnackBarType.success
            ? theme.primaryColor
            : widget.snackBarType == SnackBarType.error
            ? theme.colorScheme.error
            : widget.snackBarType == SnackBarType.warning
            ? Colors.orange
            : widget.snackBarType == SnackBarType.info
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 24 * _slideAnimation.value),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimens.SIZE_8,
                horizontal: AppDimens.SIZE_12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    accentColor.withValues(alpha: 0.85),
                    accentColor.withValues(alpha: 0.65),
                    accentColor.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.12, 1.0],
                ),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.SIZE_4),
                      decoration: ShapeDecoration(
                        shape: CircleBorder(),
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      child: Icon(
                        widget.snackBarType == SnackBarType.success
                            ? Icons.check_rounded
                            : widget.snackBarType == SnackBarType.error
                            ? Icons.close_rounded
                            : widget.snackBarType == SnackBarType.warning
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded,
                        color:
                            widget.snackBarType == SnackBarType.success
                                ? theme.primaryColor
                                : widget.snackBarType == SnackBarType.error
                                ? theme.colorScheme.error
                                : widget.snackBarType == SnackBarType.warning
                                ? Colors.orange
                                : Colors.blue,
                        size:
                            widget.snackBarType == SnackBarType.success
                                ? 22
                                : widget.snackBarType == SnackBarType.error
                                ? 22
                                : widget.snackBarType == SnackBarType.warning
                                ? 22
                                : 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.SIZE_14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextLabel(
                          ' ${widget.snackBarType == SnackBarType.success
                              ? AppLocalizations.current.success
                              : widget.snackBarType == SnackBarType.error
                              ? AppLocalizations.current.error
                              : widget.snackBarType == SnackBarType.warning
                              ? AppLocalizations.current.warning
                              : AppLocalizations.current.info}',
                          fontSize: widget.fontSize ?? AppSize.fontSizeMedium,
                          color:
                              widget.textColor ??
                              Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: AppDimens.SIZE_4),
                        CustomTextLabel(
                          widget.message,
                          fontSize: widget.fontSize ?? AppSize.fontSizeSmall,
                          color:
                              widget.textColor ??
                              Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
