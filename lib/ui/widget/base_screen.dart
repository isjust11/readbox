import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/custom_snack_bar.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class BaseScreen<T extends Cubit<BaseState>> extends StatelessWidget {
  static const double toolbarHeight = 50.0;

  // Khai báo giữ nguyên để tương thích 100% với code cũ
  final Widget? body;
  final dynamic title;
  final Widget? customAppBar;
  final Function? onBackPress;
  final List<Widget>? rightWidgets;
  final Widget? stateWidget;
  final Widget? messageNotify;
  final Widget? floatingButton;
  final Widget? bottomNavigationBar;
  final String? interactionId;
  final bool hiddenIconBack;
  final Color colorTitle;
  final bool hideAppBar;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final Color colorBg;
  final Widget? drawer;

  // Tùy chọn nâng cấp an toàn cho màn hình
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;
  final bool extendBodyBehindAppBar;

  // Xử lý auto loading, error, success
  final bool autoHandleState;
  final void Function(BuildContext context, BaseState state)? onStateChanged;

  const BaseScreen({
    super.key,
    this.body,
    this.title = "",
    this.customAppBar,
    this.onBackPress,
    this.rightWidgets,
    this.hiddenIconBack = false,
    this.colorTitle = AppColors.colorTitle,
    this.stateWidget,
    this.hideAppBar = false,
    this.messageNotify,
    this.floatingButton,
    this.colorBg = AppColors.white,
    this.systemUiOverlayStyle = SystemUiOverlayStyle.dark,
    this.bottomNavigationBar,
    this.interactionId,
    this.drawer,
    this.useSafeAreaTop = true,
    this.useSafeAreaBottom = true,
    this.extendBodyBehindAppBar = false,
    this.autoHandleState = true,
    this.onStateChanged,
  });

  Type _typeOf<X>() => X;
  bool get _shouldListen =>
      autoHandleState && T != dynamic && T != _typeOf<Cubit<BaseState>>();

  @override
  Widget build(BuildContext context) {
    Widget content = PopScope(
      canPop: onBackPress == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (onBackPress != null) {
          // Giữ đúng thứ tự xử lý cũ
          Navigator.of(context).pop();
          onBackPress?.call();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiOverlayStyle,
        child: Stack(
          children: [
            // 1. Tối ưu: Đặt background Appbar sau các node chung
            if (!hideAppBar)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Assets.images.appBarBackground.image(
                  width: double.infinity,
                  height: toolbarHeight + MediaQuery.of(context).padding.top,
                  fit: BoxFit.fill,
                ),
              ),

            // 2. Chuyển Scaffold sang cơ chế minh bạch
            Scaffold(
              backgroundColor: hideAppBar ? colorBg : Colors.transparent,
              appBar:
                  hideAppBar
                      ? null
                      : (customAppBar as PreferredSizeWidget? ??
                          _buildBaseAppBar(context)),
              drawer: drawer,
              extendBodyBehindAppBar: extendBodyBehindAppBar,
              floatingActionButton: floatingButton,
              bottomNavigationBar: bottomNavigationBar,
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                // 3. Tối ưu: Tránh leak memory bằng FocusManager thay vì sinh object rác rỗng
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Màu nền
                    Container(color: colorBg),

                    // 4. Bỏ fallback Container() sang SizedBox.shrink
                    SafeArea(
                      top: useSafeAreaTop && hideAppBar,
                      bottom: useSafeAreaBottom,
                      child: body ?? const SizedBox.shrink(),
                    ),

                    // Lớp phủ (Overlay) tự động catch LoadingState
                    if (_shouldListen)
                      Positioned.fill(
                        child: BlocBuilder<T, BaseState>(
                          builder: (context, state) {
                            if (state is LoadingState) {
                              return Container(
                                alignment: Alignment.center,
                                child: LoadingAnimationWidget.threeArchedCircle(
                                  color: AppColors.baseColor,
                                  size: AppDimens.SIZE_32,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                    if (stateWidget != null)
                      Positioned.fill(child: stateWidget!),
                    if (messageNotify != null)
                      Positioned.fill(child: messageNotify!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Lắng nghe State để tự động bung thông báo Error / Success
    if (_shouldListen) {
      content = BlocListener<T, BaseState>(
        listener: (context, state) {
          // Callback thoát ra cho screen
          onStateChanged?.call(context, state);

          // Tự động đẩy logic UI báo lỗi hoặc báo thành công
          if (state is LoadedState) {
            final mess = state.message;
            if (mess.isNotEmpty) {
              AppSnackBar.show(
                context,
                message: mess,
                snackBarType: SnackBarType.success,
              );
            }
          } else if (state is ErrorState) {
            final dynamic messData = state.message ?? state.data;
            final messString = messData?.toString() ?? 'Có lỗi xảy ra!';
            if (messString.isNotEmpty) {
              AppSnackBar.show(
                context,
                message: messString,
                snackBarType: SnackBarType.error,
              );
            }
          }
        },
        child: content,
      );
    }

    return content;
  }

  PreferredSizeWidget _buildBaseAppBar(BuildContext context) {
    final theme = Theme.of(context);
    Widget widgetTitle;

    // Giữ cơ chế xử lý String và Widget
    if (title is Widget) {
      widgetTitle = title;
    } else {
      widgetTitle = CustomTextLabel(
        title?.toString(),
        maxLines: 2,
        fontWeight: FontWeight.w600,
        fontSize: AppDimens.SIZE_14,
        textAlign: TextAlign.center,
        color: theme.colorScheme.onInverseSurface,
      );
    }
    return AppBar(
      elevation: 0,
      toolbarHeight: toolbarHeight,
      title: widgetTitle,
      backgroundColor: theme.primaryColor.withValues(alpha: 0.8),
      leading:
          hiddenIconBack
              ? const SizedBox.shrink()
              : InkWell(
                onTap: () {
                  Navigator.pop(context);
                  onBackPress?.call();
                },
                child: Container(
                  width: AppDimens.SIZE_60,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: theme.colorScheme.onSecondary,
                    size: AppDimens.SIZE_16,
                  ),
                ),
              ),
      centerTitle: true,
      actions: rightWidgets ?? [],
    );
  }
}
