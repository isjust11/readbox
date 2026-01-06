import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/widget.dart';

class CustomDialogUtil {
  static Future<T?> showDialogSuccess<T>(BuildContext context,
      {onSubmit, String? title, bool barrierDismissible = true, String? image, String? content, String? titleSubmit}) {
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) => CustomDialog(
          title: title,
          image: image ?? "Assets.images.icDialogSuccess",
          content: content,
          onSubmit: onSubmit,
          titleSubmit: titleSubmit ?? AppLocalizations.of(context).agree),
    );
  }

  static Future<T?> showDialogConfirm<T>(BuildContext context,
      {onCancel,
      onSubmit,
      String? title,
      bool barrierDismissible = true,
      bool autoPopWhenPressSubmit = true,
      String? content,
      String? titleCancel,
      String? image,
      bool hideCancel = false,
      String? titleSubmit}) {
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) => CustomDialog(
          content: content,
          autoPopWhenPressSubmit: autoPopWhenPressSubmit,
          image: image ?? "Assets.images.icDialogConfirm",
          titleSubmit: titleSubmit ?? AppLocalizations.of(context).agree,
          onSubmit: onSubmit,
          onCancel: onCancel,
          titleCancel: hideCancel ? null : (titleCancel ?? AppLocalizations.current.close)),
    );
  }

  static Future<T?> showDialogError<T>(BuildContext context,
      {onCancel, String? title, bool barrierDismissible = true, String? image, String? content, String? titleCancel}) {
    return showDialog<T>(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (BuildContext context) => CustomDialog(
          content: content,
          image: image ?? "Assets.images.icDialogFail",
          onCancel: onCancel,
          titleCancel: titleCancel ?? AppLocalizations.current.close),
    );
  }

  static showDatePicker(
    context, {
    onDateTimeChanged,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    CupertinoDatePickerMode? mode,
  }) {
    var valueSelect = initialDate;
    firstDate = firstDate ?? DateTime(1900);
    lastDate = lastDate ?? DateTime(2100);
    initialDate = initialDate ?? DateTime.now();

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
              height: 500,
              child: Column(
                children: [
                  Container(
                    height: 400,
                    color: AppColors.white,
                    child: CupertinoDatePicker(
                        mode: mode ?? CupertinoDatePickerMode.date,
                        minimumDate: firstDate,
                        maximumDate: lastDate,
                        initialDateTime: initialDate,
                        onDateTimeChanged: (value) {
                          valueSelect = value;
                        }),
                  ),
                  CupertinoButton(
                    child: CustomTextLabel(
                      AppLocalizations.current.done,
                      fontSize: 16,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDateTimeChanged(valueSelect);
                    },
                  )
                ],
              ),
            ));
  }

  static Future showInfoDialog(context, {Widget? titleWidget, Widget? contentWidget}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Wrap(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleWidget ?? Container(),
                    SizedBox(
                      height: 20,
                    ),
                    contentWidget ?? Container(),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: BaseButton(
                        decoration: BoxDecoration(
                            color: AppColors.baseColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x40000000),
                                offset: Offset(0, 3),
                                blurRadius: 1,
                              )
                            ]),
                        wrapChild: true,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        alignment: Alignment.center,
                        onTap: () => Navigator.of(context).pop(),
                        child: CustomTextLabel("OK", fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ]),
            ));
  }
}

class OptionItem extends StatelessWidget {
  final double? width, height;
  final double? imageSize;
  final String? imageKey;
  final String? textKey;
  final Function? onTap;

  const OptionItem({super.key, this.width, this.height, this.imageSize, this.imageKey, this.textKey, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        width: width ?? 300.0,
        height: height ?? 60.0,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).round()),
            blurRadius: 12,
            offset: Offset(0.0, 2.0),
          ),
        ]),
        child: Row(
          children: [
            imageKey == null
                ? Container()
                : Container(
                    width: height ?? 60.0,
                    height: height ?? 60.0,
                    decoration: BoxDecoration(color: AppColors.gray, borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: Image.asset(
                      imageKey!,
                      width: imageSize ?? 24,
                      height: imageSize ?? 24,
                    ),
                  ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 18),
              height: 21,
              child: textKey == null
                  ? Container()
                  : CustomTextLabel(
                      textKey,
                      fontSize: 16,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
            )),
            Container(
              margin: EdgeInsets.only(left: 12, right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final Function? onSubmit;
  final Function? onCancel;
  final String? titleSubmit;
  final String? image;
  final Widget? contentWidget;
  final String? content;
  final String? titleCancel;
  final String? title;
  final Key? keyInputValue;
  final bool autoPopWhenPressSubmit;

  const CustomDialog(
      {super.key,
      this.onSubmit,
      this.titleSubmit,
      this.image,
      this.content,
      this.titleCancel,
      this.title,
      this.contentWidget,
      this.keyInputValue,
      this.onCancel,
      this.autoPopWhenPressSubmit = true,
      });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.only(left: 25, right: 25),
      child: Stack(
        children: [
          Wrap(children: [
            Column(
              children: [
                if (image?.isNotEmpty ?? false)
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Image.asset(
                      image!,
                      height: 100,
                    ),
                  ),
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: contentWidget ??
                              CustomTextLabel(
                                content,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                textAlign: TextAlign.center,
                                // shadows: [
                                //   Shadow(
                                //       color: Color(0x40000000),
                                //       offset: Offset(0,3),
                                //       blurRadius: 3
                                //   )
                                // ],
                              ),
                        ),
                        Column(
                          children: [
                            if (titleSubmit?.isNotEmpty ?? false)
                              BaseButton(
                                title: titleSubmit,
                                wrapChild: true,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                margin: EdgeInsets.only(bottom: 10),
                                onTap: () {
                                  if (keyInputValue is GlobalKey<TextFieldState>) {
                                    if (((keyInputValue as GlobalKey<TextFieldState>).currentState?.isValid ?? false)) {
                                      Navigator.of(context).pop();
                                      onSubmit?.call();
                                    }
                                  } else {
                                    if (autoPopWhenPressSubmit) {
                                      Navigator.of(context).pop();
                                    }
                                    onSubmit?.call();
                                  }
                                },
                              ),
                            if (titleCancel?.isNotEmpty ?? false)
                              // Expanded(
                              //   child:
                              BaseButton(
                                wrapChild: true,
                                backgroundColor: Colors.transparent,
                                borderRadius: 10,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                // title: titleCancel,
                                child: CustomTextLabel(
                                  titleCancel,
                                  color: AppColors.baseColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                // titleColor: Colors.black,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onCancel?.call();
                                },
                              ),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          ])
        ],
      ),
    );
  }
}
