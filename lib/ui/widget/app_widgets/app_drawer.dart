import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/user_subscription_cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/app_widgets/app_profile.dart';

class AppDrawer extends StatefulWidget {
  final UserModel? user;
  final Function(String, String) onSelected;
  const AppDrawer({super.key, required this.onSelected, this.user});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _currentFilter;

  void _filterBooks(String filter, String title) {
    setState(() {
      _currentFilter = filter;
    });

    switch (filter) {
      case 'all':
        widget.onSelected('all', title);
        break;
      case 'favorite':
        widget.onSelected('favorite', title);
        break;
      case 'archived':
        widget.onSelected('archived', title);
        break;
      case 'uploaded':
        widget.onSelected('uploaded', title);
        break;
    }
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppProfile(user: widget.user),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icGlobal,
                      width: AppDimens.SIZE_22,
                      height: AppDimens.SIZE_22,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.book_discover,
                    isSelected: _currentFilter == 'all',
                    onTap:
                        () => _filterBooks(
                          'all',
                          AppLocalizations.current.book_discover,
                        ),
                    iconColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icFavorite,
                      width: AppDimens.SIZE_22,
                      height: AppDimens.SIZE_22,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.error,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.favorite_books,
                    isSelected: _currentFilter == 'favorite',
                    onTap:
                        () => _filterBooks(
                          'favorite',
                          AppLocalizations.current.favorite_books,
                        ),
                    iconColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icStorage,
                      width: AppDimens.SIZE_24,
                      height: AppDimens.SIZE_24,
                      colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 228, 228, 228),
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.archived_books,
                    isSelected: _currentFilter == 'archived',
                    onTap:
                        () => _filterBooks(
                          'archived',
                          AppLocalizations.current.archived_books,
                        ),
                    iconColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icCloud,
                      width: AppDimens.SIZE_20,
                      height: AppDimens.SIZE_20,
                      colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 230, 252, 255),
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.my_uploaded_books,
                    isSelected: _currentFilter == 'uploaded',
                    onTap:
                        () => _filterBooks(
                          'uploaded',
                          AppLocalizations.current.my_uploaded_books,
                        ),
                    iconColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    icon: Icons.phone_android,
                    title: AppLocalizations.current.local_library,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.localLibraryScreen);
                    },
                    iconColor: Colors.green,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    icon: Icons.upload_file,
                    title: AppLocalizations.current.upload_book,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.adminUploadScreen);
                    },
                    iconColor: Theme.of(context).colorScheme.secondary,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icTools,
                      width: AppDimens.SIZE_22,
                      height: AppDimens.SIZE_22,
                      colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 228, 228, 228),
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.tools,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.toolsScreen);
                    },
                    iconColor:
                        Theme.of(context).colorScheme.onPrimaryFixedVariant,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback,
                    title: AppLocalizations.current.feedback,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.feedbackScreen);
                    },
                    iconColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  _buildDrawerItem(
                    svgIcon: SvgPicture.asset(
                      Assets.icons.icSetting,
                      width: AppDimens.SIZE_22,
                      height: AppDimens.SIZE_22,
                      colorFilter: ColorFilter.mode(
                        Colors.blueGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    title: AppLocalizations.current.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        Routes.settingsScreen,
                        arguments: widget.user,
                      );
                    },
                    iconColor: Colors.blueGrey,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: AppLocalizations.current.logout,
              onTap: _handleLogout,
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    await SecureStorageService().clearAllSecureData();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
    }
  }

  Widget _buildDrawerItem({
    Widget? svgIcon,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_8,
        vertical: AppDimens.SIZE_6,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                iconColor?.withValues(alpha: 0.15) ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                iconColor?.withValues(alpha: 0.55) ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 22,
            height: 22,
            child:
                svgIcon ??
                Icon(
                  icon ?? Icons.menu_outlined,
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : (iconColor ?? Colors.grey[700]),
                  size: 22,
                ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color:
                textColor ??
                (isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
