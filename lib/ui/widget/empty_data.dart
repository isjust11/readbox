import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class EmptyData extends StatelessWidget {
  final EmptyDataEnum emptyDataEnum;
  final String? title;
  final String? description;
  const EmptyData({
    super.key,
    this.emptyDataEnum = EmptyDataEnum.no_data,
    this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          emptyDataEnum == EmptyDataEnum.no_data
              ? _buildEmptyData(context)
              : _buildEmptyFilter(context),
    );
  }

  Widget _buildEmptyData(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          width: AppDimens.SIZE_128,
          height: AppDimens.SIZE_128,
          Assets.icons.icNoDocument,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppDimens.SIZE_4),
        CustomTextLabel(
          title ?? AppLocalizations.current.empty,
          fontSize: AppSize.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.SIZE_8),
        description != null
            ? CustomTextLabel(
              description ?? AppLocalizations.current.empty,
              fontSize: AppSize.fontSizeLarge,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              textAlign: TextAlign.center,
            )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEmptyFilter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          width: AppDimens.SIZE_128,
          height: AppDimens.SIZE_128,
          Assets.icons.icSearchEmpty,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppDimens.SIZE_4),
        CustomTextLabel(
          title ?? AppLocalizations.current.empty,
          fontSize: AppSize.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.SIZE_8),
        description != null
            ? CustomTextLabel(
              description ?? AppLocalizations.current.empty,
              fontSize: AppSize.fontSizeLarge,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              textAlign: TextAlign.center,
            )
            : const SizedBox.shrink(),
      ],
    );
  }
}
