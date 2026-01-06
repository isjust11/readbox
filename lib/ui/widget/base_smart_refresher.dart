import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readbox/res/resources.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CustomSmartRefresher extends StatelessWidget {
  final List listData;
  final RefreshController? refreshController;
  final bool enablePullUp;
  final bool enablePullDown;
  final VoidCallback? onRefresh;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback? onLoadMore;
  final double heightSeparator;
  final Color colorSeparator;
  final EdgeInsets padding;
  final EdgeInsets marginSeparator;

  const CustomSmartRefresher({
    super.key,
    this.refreshController,
    this.onRefresh,
    this.onLoadMore,
    this.enablePullUp = false,
    this.enablePullDown = true,
    required this.listData,
    required this.itemBuilder,
    this.heightSeparator = AppDimens.SIZE_0,
    this.colorSeparator = Colors.transparent,
    this.padding = const EdgeInsets.all(0),
    this.marginSeparator = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullUp: enablePullUp,
      enablePullDown: enablePullDown,
      controller: refreshController!,
      onRefresh: onRefresh,
      onLoading: onLoadMore,
      header: WaterDropMaterialHeader(),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body = Container(height: AppDimens.SIZE_0);
          if (mode == LoadStatus.loading) {
            body = SizedBox(
              height: AppDimens.SIZE_55,
              child: Center(child: CupertinoActivityIndicator()),
            );
          } else if (mode == LoadStatus.idle) {
            body = SizedBox(height: AppDimens.SIZE_0, child: Center());
          }
          return body;
        },
      ),
      child: ListView.separated(
        primary: false,
        shrinkWrap: true,
        padding: padding,
        itemCount: listData.length,
        separatorBuilder: (context, index) => Container(
          margin: marginSeparator,
          child: Divider(height: heightSeparator, color: colorSeparator),
        ),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
