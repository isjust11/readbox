import 'package:flutter/material.dart';
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
  final dynamic? title;

  // trường hợp có AppBar đặc biệt thì dùng customAppBar
  final Widget? customAppBar;

  // callBack của onBackPress với trường hợp  hiddenIconBack = false
  final Function? onBackPress;

  // custom widget bên phải của appBar
  final List<Widget>? rightWidgets;

  // loadingWidget để show loading toàn màn hình
  final Widget? loadingWidget;

  // show thông báo
  final Widget? messageNotify;
  final Widget? floatingButton;

  // nếu true => sẽ ẩn backIcon , mặc định là true
  final bool hiddenIconBack;

  final Color colorTitle;
  final bool hideAppBar;

  // base bg color
  final Color colorBg;

  const BaseScreen({
    Key? key,
    this.body,
    this.title = "",
    this.customAppBar,
    this.onBackPress,
    this.rightWidgets,
    this.hiddenIconBack = false,
    this.colorTitle = AppColors.colorTitle,
    this.loadingWidget,
    this.hideAppBar = false,
    this.messageNotify,
    this.floatingButton,
    this.colorBg = AppColors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
        appBar: hideAppBar ? null : (customAppBar == null ? baseAppBar(context) : customAppBar),
        backgroundColor: colorBg,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(
            children: [
              body ?? Container(),
              Positioned(
                top: AppDimens.SIZE_0,
                right: AppDimens.SIZE_0,
                left: AppDimens.SIZE_0,
                bottom: AppDimens.SIZE_0,
                child: loadingWidget ?? Container(),
              ),
              messageNotify ?? Container()
            ],
          ),
        ),
        floatingActionButton: floatingButton ?? null);
    return Stack(
      children: [
        // Positioned.fill(child: Container(color: backgroundColor,)),
        Container(
          child: Assets.images.appBarBackground.image(
            width: 1.width,
            height: toolbarHeight + 1.top,
            fit: BoxFit.fill,
          ),
        ),
        scaffold
      ],
    );
  }

  baseAppBar(BuildContext context) {
    var widgetTitle;
    if (title is Widget) {
      widgetTitle = title;
    } else {
      widgetTitle = CustomTextLabel(
        this.title?.toString(),
        maxLines: 2,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        textAlign: TextAlign.center,
        color: colorTitle,
      );
    }
    return AppBar(
      elevation: 0,
      toolbarHeight: toolbarHeight,
      title: widgetTitle,
      leading: hiddenIconBack
          ? Container()
          : InkWell(
              onTap: () {
                Navigator.pop(context);
                onBackPress?.call();
              },
              child: Container(
                width: 50,
                alignment: Alignment.center,
                child:
                    Assets.images.icBack.image(width: 22, height: 22, fit: BoxFit.contain, color: AppColors.colorTitle),
              ),
            ),
      centerTitle: true,
      actions: rightWidgets ?? [],
    );
  }
}
