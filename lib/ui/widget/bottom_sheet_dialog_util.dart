import 'package:flutter/material.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/ui/widget/widget.dart';

class BottomSheetDialogUtil {
  static Future showBaseBottomSheetDialog(
    context, {
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
    Widget? leftWidget,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet(
        barrierColor: barrierColor,
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        context: context,
        enableDrag: enableDrag,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        builder: (BuildContext context) => Padding(
              padding: EdgeInsets.only(
                  // top: 80,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              padding: EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 15),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                              )),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: leftWidget ?? Container(),
                        )),
                      ],
                    ),
                    builder.call(context)
                  ],
                ),
              ),
            ));
  }

  static Future showBottomSheetNotyDialog(
    context, {
    bool isDismissible = true,
    required Widget widgetContent,
    AssetGenImage? icon,
    Color? colorIcon,
  }) {
    return showBaseBottomSheetDialog(context, isDismissible: isDismissible, builder: (context) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            widgetContent,
            if (icon != null)
              Container(margin: EdgeInsets.only(top: 20), child: icon.image(width: 30, color: colorIcon)),
            SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  static Future showDialogSuccess(BuildContext context, {required String content}) {
    return showBaseBottomSheetDialog(context, builder: (context) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            CustomTextLabel(
              content,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w400,
              fontHeight: 1.4,
              fontSize: 14,
            ),
            SizedBox(height: 10),
          ],
        ),
      );
    });
  }
}
