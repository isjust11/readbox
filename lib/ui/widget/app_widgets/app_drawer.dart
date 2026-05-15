import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/app_widgets/app_profile.dart';

class AppDrawer extends StatefulWidget {
  final UserModel? user;
  final bool settingScreen;
  final Function(String, String) onSelected;
  final String currentFilter;
  const AppDrawer({
    super.key,
    required this.onSelected,
    this.user,
    this.settingScreen = false,
    this.currentFilter = 'all',
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late String _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.currentFilter;
  }

  @override
  void didUpdateWidget(AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilter != widget.currentFilter) {
      _currentFilter = widget.currentFilter;
    }
  }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Drawer(
      width: 318,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.16),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppProfile(user: widget.user, settingScreen: widget.settingScreen),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icGlobal,
                        width: AppDimens.SIZE_22,
                        height: AppDimens.SIZE_22,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
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
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icFavorite,
                        width: AppDimens.SIZE_22,
                        height: AppDimens.SIZE_22,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
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
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icStorage,
                        width: AppDimens.SIZE_24,
                        height: AppDimens.SIZE_24,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
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
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icCloud,
                        width: AppDimens.SIZE_20,
                        height: AppDimens.SIZE_20,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
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
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildSectionDivider(),
                    _buildDrawerItem(
                      icon: Icons.phone_android_rounded,
                      title: AppLocalizations.current.local_library,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.localLibraryScreen);
                      },
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      icon: Icons.upload_file_rounded,
                      title: AppLocalizations.current.upload_book,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.adminUploadScreen);
                      },
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icTools,
                        width: AppDimens.SIZE_22,
                        height: AppDimens.SIZE_22,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: AppLocalizations.current.tools,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, Routes.toolsScreen);
                      },
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                    _buildDrawerItem(
                      svgIcon: SvgPicture.asset(
                        Assets.icons.icSetting,
                        width: AppDimens.SIZE_22,
                        height: AppDimens.SIZE_22,
                        colorFilter: ColorFilter.mode(
                          colorScheme.primary,
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
                      iconColor: colorScheme.primary,
                      textColor: colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: AppLocalizations.current.logout,
                onTap: _handleLogout,
                iconColor: colorScheme.error,
                textColor: colorScheme.error,
                isDestructive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    // 1. Perform central logout (RevenueCat, secure storage, etc.)
    await context.read<AuthCubit>().doLogout();

    // 2. Clear subscription data
    context.read<UserSubscriptionCubit>().clear();
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
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color effectiveIconColor =
        iconColor ?? (isDestructive ? colorScheme.error : colorScheme.primary);
    final Color effectiveTextColor =
        textColor ??
        (isDestructive ? colorScheme.error : colorScheme.onSurface);
    final Color iconBackground = effectiveIconColor.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Row(
            children: [
              // Thanh gạch bên trái khi active
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: isSelected ? 36 : 0,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: effectiveIconColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 58),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                svgIcon ??
                                Icon(
                                  icon ?? Icons.menu_outlined,
                                  color: effectiveIconColor,
                                  size: 22,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.45),
      ),
    );
  }
}
