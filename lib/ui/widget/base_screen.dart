import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:readbox/blocs/user_interaction_cubit.dart';
// import 'package:readbox/domain/data/enums/enums.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:scale_size/scale_size.dart';

class BaseScreen extends StatelessWidget {
  static double toolbarHeight = 50;

  // body của màn hình
  final Widget? body;

  // title của appbar có 2 kiểu String và Widget
  // title là kiểu Widget thì sẽ render widget
  // title là String
  final dynamic title;

  // trường hợp có AppBar đặc biệt thì dùng customAppBar
  final Widget? customAppBar;

  // callBack của onBackPress với trường hợp  hiddenIconBack = false
  final Function? onBackPress;

  // custom widget bên phải của appBar
  final List<Widget>? rightWidgets;

  // loadingWidget để show loading toàn màn hình
  final Widget? stateWidget;

  // show thông báo
  final Widget? messageNotify;
  final Widget? floatingButton;
  final Widget? bottomNavigationBar;

  // phần liên quan tới action
  // final InteractionTarget? interactionTarget;
  final String? interactionId;

  // nếu true => sẽ ẩn backIcon , mặc định là true
  final bool hiddenIconBack;

  final Color colorTitle;
  final bool hideAppBar;

  final SystemUiOverlayStyle systemUiOverlayStyle;

  // base bg color
  final Color colorBg;

  final Widget? drawer;

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
    // this.interactionTarget,
    this.interactionId,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    // _handleInteraction(context, interactionTarget, interactionId);

    final scaffold = Scaffold(
      appBar: hideAppBar ? null : (customAppBar ?? baseAppBar(context)),
      backgroundColor: colorBg,
      drawer: drawer,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            body ?? Container(), // luôn hiển thị stateWidget (overlay) nếu có
            Positioned(
              top: AppDimens.SIZE_0,
              right: AppDimens.SIZE_0,
              left: AppDimens.SIZE_0,
              bottom: AppDimens.SIZE_0,
              child: stateWidget ?? Container(),
            ),
            messageNotify ?? Container(),
          ],
        ),
      ),
      floatingActionButton: floatingButton,
      bottomNavigationBar: bottomNavigationBar,
    );
    return AnnotatedRegion(
      value: systemUiOverlayStyle,
      child: Stack(
        children: [
          // Positioned.fill(child: Container(color: backgroundColor,)),
          Container(
            child: Assets.images.appBarBackground.image(
              width: 1.width,
              height: toolbarHeight + 1.top,
              fit: BoxFit.fill,
            ),
          ),
          scaffold,
        ],
      ),
    );
  }

  baseAppBar(BuildContext context) {
    var widgetTitle;
    if (title is Widget) {
      widgetTitle = title;
    } else {
      widgetTitle = CustomTextLabel(
        title?.toString(),
        maxLines: 2,
        fontWeight: FontWeight.w700,
        fontSize: AppDimens.SIZE_14,
        textAlign: TextAlign.center,
        color: AppColors.white,
      );
    }
    return AppBar(
      elevation: 0,
      toolbarHeight: toolbarHeight,
      title: widgetTitle,
      backgroundColor: AppColors.secondaryBrand,
      leading: hiddenIconBack
          ? Container()
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
                  color: AppColors.white,
                  size: AppDimens.SIZE_16,
                ),
              ),
            ),
      centerTitle: true,
      actions: rightWidgets ?? [],
    );
  }

  // handle interaction
  // void _handleInteraction(
  //   BuildContext context,
  //   InteractionTarget? interactionTarget,
  //   String? interactionId,
  // ) {
  //   if (interactionTarget == InteractionTarget.article ||
  //       interactionTarget == InteractionTarget.herbal ||
  //       interactionTarget == InteractionTarget.folkMedicine ||
  //       interactionTarget == InteractionTarget.author) {
  //     _processGetStatsInteraction(context, interactionTarget!, interactionId);
  //     _processAutoIncrementView(context, interactionTarget, interactionId);
  //     _processGetStatusInteraction(context, interactionTarget, interactionId);
  //     return;
  //   }
  // }

  // void _processGetStatusInteraction(
  //   BuildContext context,
  //   InteractionTarget interactionTarget,
  //   String? interactionId,
  // ) {
  //   context.read<UserInteractionCubit>().getStatus(
  //     targetType: interactionTarget.value,
  //     targetId: interactionId,
  //   );
  // }

  // void _processGetStatsInteraction(
  //   BuildContext context,
  //   InteractionTarget interactionTarget,
  //   String? interactionId,
  // ) {
  //   context.read<UserInteractionCubit>().getStats(
  //     targetType: interactionTarget.value,
  //     targetId: interactionId,
  //   );
  // }

  // void _processAutoIncrementView(
  //   BuildContext context,
  //   InteractionTarget interactionTarget,
  //   String? interactionId,
  // ) {
  //   context.read<UserInteractionCubit>().view(
  //     targetType: interactionTarget.value,
  //     targetId: interactionId,
  //   );
  // }
}
