import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readbox/constants.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:readbox/utils/common.dart';
import 'package:intl/intl.dart';

typedef CustomTextFieldValidator<T> = String? Function(String value);

class CustomTextInput extends StatefulWidget {
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final String title;
  final TextStyle? titleStyle;
  final int maxLines;
  final TextInputAction? textInputAction;
  final Function? getTextFieldValue;
  final int minLines;
  final bool obscureText;
  final String hintText;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final initData;
  final double? width;
  final double? heightTextInput;
  final double? fontSize;
  final TextEditingController? textController;

  final FontWeight? fontWeight;
  final TextAlign? align;
  final bool enabled;
  final Color colorBgTextField;
  final Color colorBgTextFieldDisable;
  final bool formatNumber;
  final Color colorText;
  final int maxLength;
  final bool formatPercent;
  final bool formatDecimal;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isPasswordTF;
  final bool isRequired;
  final bool formatCurrency;
  final CustomTextFieldValidator? validator;
  final Function? onTapTextField;
  final bool autoFocus;

  CustomTextInput({
    Key? key,
    this.getTextFieldValue,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.title = "",
    this.maxLines = 1,
    this.textInputAction,
    this.minLines = 1,
    this.obscureText = false,
    this.hintText = "",
    this.margin,
    this.padding,
    this.initData,
    this.titleStyle,
    this.width,
    this.heightTextInput,
    this.textController,
    this.fontWeight,
    this.align,
    this.enabled = true,
    this.colorText = Colors.black,
    this.maxLength = TextField.noMaxLength,
    this.formatPercent = false,
    this.formatDecimal = false,
    this.suffixIcon,
    this.prefixIcon,
    this.isPasswordTF = false,
    this.isRequired = false,
    this.colorBgTextField = AppColors.white,
    this.colorBgTextFieldDisable = AppColors.disable,
    this.formatCurrency = false,
    this.formatNumber = false,
    this.validator,
    this.onTapTextField,
    this.autoFocus = false,
    this.fontSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TextFieldState();
  }
}

class TextFieldState extends State<CustomTextInput> {
  bool _showText = true;
  late List<TextInputFormatter> inputFormatters;
  String errorText = '';
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = widget.textController ?? TextEditingController();
    if (widget.initData != null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        textController.text =
            widget.formatCurrency ? Common.formatPrice(widget.initData, showPrefix: false) : widget.initData.toString();
      });
    }
    if (widget.formatNumber || widget.formatCurrency || widget.formatPercent) {
      inputFormatters = [NumericTextFormatter(widget.formatCurrency, widget.formatPercent)];
    } else if (widget.formatDecimal) {
      inputFormatters = [DecimalTextInputFormatter(decimalRange: 5)];
    } else {
      inputFormatters = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.height ?? double.infinity,
      width: widget.width ?? double.infinity,
      margin: widget.margin ?? EdgeInsets.zero,
      child: Wrap(
        children: [
          if (widget.title.isNotEmpty)
            Container(
              padding: EdgeInsets.only(bottom: 5),
              child: CustomTextLabel(
                widget.title,
                color: AppColors.ff828282,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          Container(
            height: widget.heightTextInput,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: widget.enabled ? widget.colorBgTextField : widget.colorBgTextFieldDisable,
                borderRadius: BorderRadius.circular(widget.enabled ? 5 : 0)),
            child: Stack(
              children: [
                TextField(
                  inputFormatters: inputFormatters,
                  maxLength: widget.maxLength,
                  cursorColor: AppColors.baseColor,
                  autofocus: widget.autoFocus,
                  enabled: widget.enabled,
                  textAlign: widget.align ?? TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                      color: widget.colorText,
                      fontSize: widget.fontSize ?? 14,
                      fontWeight: widget.fontWeight ?? FontWeight.w400),
                  decoration: InputDecoration(
                      counterText: "",
                      suffixIcon: (widget.isPasswordTF == true)
                          ? IconButton(
                              icon: Icon(!_showText ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _showText = !_showText;
                                });
                              },
                            )
                          : widget.suffixIcon,
                      prefixIcon: widget.prefixIcon,
                      focusColor: Colors.white,
                      border: InputBorder.none,
                      suffixIconConstraints: BoxConstraints(maxHeight: 35),
                      prefixIconConstraints: BoxConstraints(maxHeight: 35),
                      disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.focusBorder)),
                      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                      hintStyle: TextStyle(color: AppColors.hintTextColor, fontWeight: FontWeight.w400, fontSize: 14),
                      hintText: widget.hintText,
                      isDense: true,
                      contentPadding: widget.padding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
                  controller: textController,
                  obscureText: widget.isPasswordTF == true ? (_showText) : widget.obscureText,
                  keyboardType: widget.formatCurrency ? TextInputType.number : widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  onChanged: (String _text) {
                    _validate();
                    String currentText = _text.trim();
                    widget.getTextFieldValue?.call(currentText);
                  },
                ),
                widget.onTapTextField != null
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          onTap: () {
                            if (this.widget.enabled) widget.onTapTextField?.call();
                          },
                          child: Container(),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          errorText.isNotEmpty ? ErrorTextWidget(errorText: errorText) : Container()
        ],
      ),
    );
  }

  String getText(DateTime dateTime) {
    return Common.datetimeToSting(dateTime);
  }

  bool get isValid => _validate();

  String get value => textController.text.trim();

  bool _validate() {
    if (widget.validator != null) {
      String _text = textController.text.trim();
      String? validate = widget.validator!.call(_text);
      setState(() {
        this.errorText = validate ?? "";
      });
      return this.errorText.isEmpty;
    }
    return true;
  }
}

class NumericTextFormatter extends TextInputFormatter {
  final bool isFormatCurrency;
  final bool isFormatPercent;

  NumericTextFormatter(this.isFormatCurrency, this.isFormatPercent);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      if (oldValue.text == '0' && newValue.text == '00') {
        return oldValue;
      }

      if (oldValue.text.length < newValue.text.length) {
        String s = newValue.text.substring(newValue.selection.baseOffset - 1, newValue.selection.baseOffset);
        if (!RegExp("^[0-9]").hasMatch(s)) return oldValue;
      }

      if (isFormatPercent) {
        if ((oldValue.text == "100" && newValue.text.length > 3) ||
            '.'.allMatches(newValue.text).length > 1 ||
            double.parse(newValue.text) > 100 ||
            newValue.text[0] == "." ||
            (newValue.text.length > 1 && newValue.text[0] == "0" && newValue.text[1] != ".") ||
            newValue.text.split(".").length > 1 && newValue.text.split(".")[1].length > 2) {
          return oldValue;
        } else {
          return newValue;
        }
      }

      final int selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;
      final f = isFormatCurrency ? NumberFormat("#,###") : NumberFormat('#');
      final number = int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final newString = f.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return oldValue;
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange}) : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (newValue.text.contains(' '))
      return TextEditingValue(
        text: oldValue.text,
        selection: oldValue.selection,
        composing: TextRange.empty,
      );

    if (oldValue.text == '0') {
      truncated = newValue.text.replaceFirst('0', '');
      if (!RegExp("^[0-9]").hasMatch(truncated)) {
        truncated = newValue.text;
      } else {
        newSelection = newValue.selection.copyWith(
          baseOffset: 1,
          extentOffset: 1,
        );
      }
      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }

    if (truncated.length > oldValue.text.length && newValue.text.substring(0, 1) == '0' && oldValue.text.length > 1) {
      if (!(newValue.text.length > 2 && newValue.text.substring(0, 2) == '0.')) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
        return TextEditingValue(
          text: truncated,
          selection: newSelection,
          composing: TextRange.empty,
        );
      }
    }

    if (decimalRange != null) {
      String value = newValue.text;
      if (value.contains(".") && value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
