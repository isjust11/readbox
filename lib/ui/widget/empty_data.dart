import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            width: AppDimens.SIZE_48,
            height: AppDimens.SIZE_48,
            Assets.icons.boxEmpty,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.ff828282,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppDimens.SIZE_4),
          CustomTextLabel(
            AppLocalizations.current.noDataAvailable,
            fontSize: AppDimens.SIZE_12,
            fontWeight: FontWeight.w500,
            color: AppColors.colorTitle,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
