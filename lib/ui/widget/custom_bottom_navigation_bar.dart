import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/resources.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = AppColors.secondaryBrand;
    const unselectedColor = AppColors.hintTextColor;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.lightBackgroundAlt, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: selectedColor,
        selectedIconTheme: IconThemeData(color: selectedColor),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Assets.icons.icHome,
              color: unselectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            activeIcon: SvgPicture.asset(
              Assets.icons.icHome,
              color: selectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            label: AppLocalizations.current.home,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Assets.icons.icNews,
              color: unselectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            activeIcon: SvgPicture.asset(
              Assets.icons.icNews,
              color: selectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            label: AppLocalizations.current.news,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              Assets.icons.icSetting,
              color: unselectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            activeIcon: SvgPicture.asset(
              Assets.icons.icSetting,
              color: selectedColor,
              width: AppDimens.SIZE_24,
              height: AppDimens.SIZE_24,
            ),
            label: AppLocalizations.current.settings,
          ),
        ],
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
