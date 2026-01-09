import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:readbox/res/resources.dart';

class HtmlStyleHelper {
  static Map<String, Style> getNewsContentStyle() {
    return {
      "body": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textDark,
        textAlign: TextAlign.justify,
        lineHeight: LineHeight(1.5),
      ),
      "p": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textDark,
        textAlign: TextAlign.justify,
        margin: Margins.only(bottom: AppDimens.SIZE_12),
        lineHeight: LineHeight(1.6),
      ),
      "h1": Style(
        fontSize: FontSize(AppDimens.SIZE_22),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_16, bottom: AppDimens.SIZE_12),
      ),
      "h2": Style(
        fontSize: FontSize(AppDimens.SIZE_20),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_14, bottom: AppDimens.SIZE_10),
      ),
      "h3": Style(
        fontSize: FontSize(AppDimens.SIZE_18),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_12, bottom: AppDimens.SIZE_8),
      ),
      "h4": Style(
        fontSize: FontSize(AppDimens.SIZE_16),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_10, bottom: AppDimens.SIZE_6),
      ),
      "h5": Style(
        fontSize: FontSize(AppDimens.SIZE_15),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_8, bottom: AppDimens.SIZE_4),
      ),
      "h6": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        margin: Margins.only(top: AppDimens.SIZE_6, bottom: AppDimens.SIZE_4),
      ),
      "img": Style(
        margin: Margins.only(top: AppDimens.SIZE_12, bottom: AppDimens.SIZE_12),
        alignment: Alignment.center,
      ),
      "ul": Style(
        margin: Margins.only(
          left: AppDimens.SIZE_16,
          bottom: AppDimens.SIZE_12,
        ),
      ),
      "ol": Style(
        margin: Margins.only(
          left: AppDimens.SIZE_16,
          bottom: AppDimens.SIZE_12,
        ),
      ),
      "li": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textDark,
        margin: Margins.only(bottom: AppDimens.SIZE_4),
      ),
      "blockquote": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textMediumGrey,
        fontStyle: FontStyle.italic,
        margin: Margins.only(
          left: AppDimens.SIZE_16,
          top: AppDimens.SIZE_12,
          bottom: AppDimens.SIZE_12,
        ),
        border: Border(
          left: BorderSide(color: AppColors.secondaryBrand, width: 4),
        ),
      ),
      "strong": Style(fontWeight: FontWeight.bold, color: AppColors.textDark),
      "b": Style(fontWeight: FontWeight.bold, color: AppColors.textDark),
      "em": Style(fontStyle: FontStyle.italic, color: AppColors.textDark),
      "i": Style(fontStyle: FontStyle.italic, color: AppColors.textDark),
      "u": Style(
        textDecoration: TextDecoration.underline,
        color: AppColors.textDark,
      ),
      "a": Style(
        color: AppColors.secondaryBrand,
        textDecoration: TextDecoration.underline,
      ),
      "code": Style(
        backgroundColor: AppColors.lightGreyBackground,
        fontFamily: 'monospace',
      ),
      "pre": Style(
        backgroundColor: AppColors.lightGreyBackground,
        margin: Margins.only(bottom: AppDimens.SIZE_12),
        fontFamily: 'monospace',
        fontSize: FontSize(AppDimens.SIZE_13),
      ),
      "table": Style(
        margin: Margins.only(bottom: AppDimens.SIZE_12),
        border: Border.all(color: AppColors.dividerGrey, width: 1),
      ),
      "th": Style(
        backgroundColor: AppColors.lightGreyBackground,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
        textAlign: TextAlign.center,
      ),
      "td": Style(
        color: AppColors.textDark,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerGrey, width: 1),
          right: BorderSide(color: AppColors.dividerGrey, width: 1),
        ),
      ),
    };
  }

  static Map<String, Style> getSimpleContentStyle() {
    return {
      "body": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textDark,
        textAlign: TextAlign.justify,
        lineHeight: LineHeight(1.5),
      ),
      "p": Style(
        fontSize: FontSize(AppDimens.SIZE_14),
        color: AppColors.textDark,
        textAlign: TextAlign.justify,
        margin: Margins.only(bottom: AppDimens.SIZE_8),
      ),
      "img": Style(
        margin: Margins.only(top: AppDimens.SIZE_8, bottom: AppDimens.SIZE_8),
        alignment: Alignment.center,
      ),
    };
  }
}
