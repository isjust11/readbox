import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
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
  // icon for state
  final String? emptyIcon;
  final String? emptyMessage;
  final String? emptyDescription;
  final String? errorIcon;
  final String? errorMessage;
  final String? errorDescription;
  final Gradient? gradientBg;

  // Tùy chọn nâng cấp an toàn cho màn hình
  final bool useSafeAreaTop;
  final bool useSafeAreaBottom;
  final bool extendBodyBehindAppBar;
  final bool implementErrorWidget;

  // Xử lý auto loading, error, success
  final bool autoHandleState;
  final void Function(BuildContext context, BaseState state)? onStateChanged;
  final void Function()? onRetry;
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
    this.onRetry,
    this.emptyIcon,
    this.emptyMessage,
    this.emptyDescription,
    this.errorIcon,
    this.errorMessage,
    this.errorDescription,
    this.implementErrorWidget = false,
    this.gradientBg,
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
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Assets.images.mainBg.path),
                          fit: BoxFit.fill,
                        ),
                        color: colorBg,
                        gradient: gradientBg,
                      ),
                    ),
                    //  build error state

                    // 4. Bỏ fallback Container() sang SizedBox.shrink
                    SafeArea(
                      top: useSafeAreaTop && hideAppBar,
                      bottom: useSafeAreaBottom,
                      child: _bodyContent(context),
                    ),

                    // Lớp phủ (Overlay) tự động catch LoadingState
                    if (_shouldListen)
                      Positioned.fill(
                        child: BlocBuilder<T, BaseState>(
                          builder: (context, state) {
                            if (state is LoadingState) {
                              return IgnorePointer(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child:
                                      LoadingAnimationWidget.threeArchedCircle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        size: AppDimens.SIZE_32,
                                      ),
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

  // loading widget
  Widget _bodyContent(BuildContext context) {
    return _shouldListen
        ? BlocBuilder<T, BaseState>(
          builder: (context, state) {
            if (state is ErrorState && implementErrorWidget) {
              return _errorWidget(context, state);
            }
            // no data
            if (state is EmptyState) {
              return _emptyWidget(context);
            }
            return body ?? const SizedBox.shrink();
          },
        )
        : body ?? const SizedBox.shrink();
  }

  // empty widget
  Widget _emptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            emptyIcon ?? Assets.icons.folderEmpty,
            width: 120,
            height: 120,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.outline,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? AppLocalizations.current.empty,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            emptyDescription ?? AppLocalizations.current.no_data_description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // error widget
  Widget _errorWidget(BuildContext context, BaseState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            errorIcon ?? Assets.icons.dataEmpty,
            width: 120,
            height: 120,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.outline,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? AppLocalizations.current.error_occurred,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorDescription ??
                state.message ??
                AppLocalizations.current.error_common,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.current.retry),
          ),
        ],
      ),
    );
  }
}
