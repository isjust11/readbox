import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readbox/res/resources.dart';
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
  final Color? hintTextColor;
  final double? hintTextFontSize;
  final FontWeight? hintTextFontWeight;
  final BorderRadius? borderRadius;

  const CustomTextInput({
    super.key,
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
    this.hintTextFontSize,
    this.hintTextColor,
    this.hintTextFontWeight,
    this.borderRadius,
  });

  @override
  State<StatefulWidget> createState() {
    return TextFieldState();
  }
}

class TextFieldState extends State<CustomTextInput> with SingleTickerProviderStateMixin {
  bool _showText = true;
  late List<TextInputFormatter> inputFormatters;
  String errorText = '';
  late TextEditingController textController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );
    
    textController = widget.textController ?? TextEditingController();
    if (widget.initData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        textController.text =
            widget.formatCurrency
                ? Common.formatPrice(widget.initData, showPrefix: false)
                : widget.initData.toString();
      });
    }
    if (widget.formatNumber || widget.formatCurrency || widget.formatPercent) {
      inputFormatters = [
        NumericTextFormatter(widget.formatCurrency, widget.formatPercent),
      ];
    } else if (widget.formatDecimal) {
      inputFormatters = [DecimalTextInputFormatter(decimalRange: 5)];
    } else {
      inputFormatters = [];
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    if (widget.textController == null) {
      textController.dispose();
    }
    super.dispose();
  }

  /// Trigger shake animation
  void _triggerShake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Calculate shake offset
        final sineValue = math.sin(_shakeAnimation.value * math.pi * 3);
        final offset = sineValue * 5.0; // Max 5px offset
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: Container(
        // height: widget.height ?? double.infinity,
        width: widget.width ?? double.infinity,
        margin: widget.margin ?? EdgeInsets.zero,
        child: Wrap(
        children: [
          Stack(
            children: [
              TextFormField(
                inputFormatters: inputFormatters,
                maxLength: widget.maxLength,
                cursorColor: Theme.of(context).primaryColor,
                autofocus: widget.autoFocus,
                enabled: widget.enabled,
                textAlign: widget.align ?? TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  fontSize: widget.fontSize ?? AppDimens.SIZE_14,
                  fontWeight: widget.fontWeight ?? FontWeight.w500,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  // labelText: widget.title + (widget.isRequired ? ' *' : ''),
                  // labelStyle: TextStyle(
                  //   color: widget.titleStyle?.color ?? theme.colorScheme.secondary.withValues(alpha: 0.6),
                  //   fontSize: widget.titleStyle?.fontSize ?? 16,
                  //   fontWeight: widget.titleStyle?.fontWeight ?? FontWeight.w400,
                  // ),
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: errorText.isNotEmpty ? theme.colorScheme.error : widget.hintTextColor ?? theme.colorScheme.secondary.withValues(alpha: 0.6),
                    fontWeight: widget.hintTextFontWeight ?? FontWeight.w400,
                    fontSize: widget.hintTextFontSize ?? 14,
                  ),
                  suffixIcon:
                      (widget.isPasswordTF == true)
                          ? IconButton(
                            icon: Icon(
                              !_showText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _showText = !_showText;
                              });
                            },
                          )
                          : widget.suffixIcon,
                  prefixIcon: widget.prefixIcon != null ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.SIZE_12,
                    ),
                    child: widget.prefixIcon,
                  ) : null,
                  focusColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  suffixIconConstraints: BoxConstraints(
                    maxHeight: AppDimens.SIZE_35,
                  ),
                  prefixIconConstraints: BoxConstraints(
                    maxHeight: AppDimens.SIZE_35,
                    minWidth: AppDimens.SIZE_35,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.SIZE_8),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.SIZE_12),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.SIZE_12),
                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.SIZE_12),
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(AppDimens.SIZE_12),
                    borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                  ),
                  errorStyle: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  isDense: true,
                  contentPadding:
                      widget.padding ??
                      EdgeInsets.symmetric(horizontal: AppDimens.SIZE_10, vertical: AppDimens.SIZE_12),
                ),
                controller: textController,
                obscureText:
                    widget.isPasswordTF == true
                        ? (_showText)
                        : widget.obscureText,
                keyboardType:
                    widget.formatCurrency
                        ? TextInputType.number
                        : widget.keyboardType,
                textInputAction: widget.textInputAction,
                onFieldSubmitted: (String value) {
                  widget.onSubmitted?.call(value);
                },
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                
                // Validator for Form.validate()
                validator: widget.validator != null 
                    ? (value) {
                        final result = widget.validator!(value?.trim() ?? '');
                        if (result != null && result.isNotEmpty) {
                          _triggerShake();
                        }
                        return result;
                      }
                    : null,
                
                // Auto validate mode
                autovalidateMode: AutovalidateMode.onUserInteraction,

                onChanged: (String text) {
                  String currentText = text.trim();
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
                        if (widget.enabled) widget.onTapTextField?.call();
                      },
                      child: Container(),
                    ),
                  )
                  : Container(),
            ],
          ),
          // Note: Error text is now displayed by TextFormField's validator
          // ErrorTextWidget is kept for backward compatibility
        ],
      ),
    ),  // Container - child of AnimatedBuilder
    );  // AnimatedBuilder
  }

  String getText(DateTime dateTime) {
    return Common.datetimeToSting(dateTime);
  }

  bool get isValid => _validate();

  String get value => textController.text.trim();

  bool _validate() {
    if (widget.validator != null) {
      String text = textController.text.trim();
      String? validate = widget.validator!.call(text);
      setState(() {
        errorText = validate ?? "";
      });
      
      // Trigger shake animation when validation fails
      if (errorText.isNotEmpty) {
        _triggerShake();
      }
      
      return errorText.isEmpty;
    }
    return true;
  }
}

class NumericTextFormatter extends TextInputFormatter {
  final bool isFormatCurrency;
  final bool isFormatPercent;

  NumericTextFormatter(this.isFormatCurrency, this.isFormatPercent);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      if (oldValue.text == '0' && newValue.text == '00') {
        return oldValue;
      }

      if (oldValue.text.length < newValue.text.length) {
        String s = newValue.text.substring(
          newValue.selection.baseOffset - 1,
          newValue.selection.baseOffset,
        );
        if (!RegExp("^[0-9]").hasMatch(s)) return oldValue;
      }

      if (isFormatPercent) {
        if ((oldValue.text == "100" && newValue.text.length > 3) ||
            '.'.allMatches(newValue.text).length > 1 ||
            double.parse(newValue.text) > 100 ||
            newValue.text[0] == "." ||
            (newValue.text.length > 1 &&
                newValue.text[0] == "0" &&
                newValue.text[1] != ".") ||
            newValue.text.split(".").length > 1 &&
                newValue.text.split(".")[1].length > 2) {
          return oldValue;
        } else {
          return newValue;
        }
      }

      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final f = isFormatCurrency ? NumberFormat("#,###") : NumberFormat('#');
      final number = int.parse(
        newValue.text.replaceAll(f.symbols.GROUP_SEP, ''),
      );
      final newString = f.format(number);
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndexFromTheRight,
        ),
      );
    } else {
      return oldValue;
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
    : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (newValue.text.contains(' ')) {
      return TextEditingValue(
        text: oldValue.text,
        selection: oldValue.selection,
        composing: TextRange.empty,
      );
    }

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

    if (truncated.length > oldValue.text.length &&
        newValue.text.substring(0, 1) == '0' &&
        oldValue.text.length > 1) {
      if (!(newValue.text.length > 2 &&
          newValue.text.substring(0, 2) == '0.')) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
        return TextEditingValue(
          text: truncated,
          selection: newSelection,
          composing: TextRange.empty,
        );
      }
    }

    String value = newValue.text;
    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
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
}
