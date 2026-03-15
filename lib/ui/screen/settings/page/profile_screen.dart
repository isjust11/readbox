import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/widget.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseScreen(
      hideAppBar: true,
      body: _buildUserInfo(context, user),
      colorBg: theme.colorScheme.surface,
      colorTitle: theme.colorScheme.surfaceContainerHighest,
      floatingButton: _buildFloatingButton(context),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      onPressed: () {
        Navigator.pop(context);
      },
      backgroundColor: theme.primaryColor.withValues(alpha: 1),
      child: Icon(
        Icons.arrow_back_ios_new,
        color: theme.colorScheme.onPrimary,
        size: AppDimens.SIZE_18,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserModel? userModel) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header với gradient background
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: theme.primaryColor),
            child: Stack(
              children: [
                // SVG background
                Positioned.fill(
                  child: SvgPicture.asset(
                    Assets.images.checkeredPattern,
                    fit: BoxFit.cover,
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppDimens.SIZE_24),
                  child: Row(
                    children: [
                      // Avatar với border và shadow
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildAvatar(context),
                      ),
                      const SizedBox(width: AppDimens.SIZE_16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextLabel(
                            userModel?.fullName ?? '',
                            color: theme.colorScheme.onPrimary,
                            fontSize: AppDimens.SIZE_20,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: AppDimens.SIZE_4),
                          // Email
                          CustomTextLabel(
                            userModel?.email ?? '',
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.9,
                            ),
                            fontSize: AppDimens.SIZE_14,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),

                      // Tên user
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.SIZE_16,
              vertical: AppDimens.SIZE_8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  context,
                  title: AppLocalizations.current.user_info,
                  children: [
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.username,
                      value: userModel?.username ?? '',
                      icon: Icons.person_outline,
                      isFirst: true,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.roles,
                      value:
                          userModel?.roles.map((e) => e.name).join(', ') ?? '',
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.birth_date,
                      value: userModel?.birthDate ?? '',
                      icon: Icons.calendar_today_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.address,
                      value: userModel?.address ?? '',
                      icon: Icons.location_on_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.phone_number,
                      value: userModel?.phoneNumber ?? '',
                      icon: Icons.phone_outlined,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.SIZE_24),
                _buildSection(
                  context,
                  title: AppLocalizations.current.social_networks,
                  children: [
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.facebook_link,
                      value: userModel?.facebookLink ?? '',
                      icon: Icons.facebook_outlined,
                      isFirst: true,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.instagram_link,
                      value: userModel?.instagramLink ?? '',
                      icon: Icons.link_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.twitter_link,
                      value: userModel?.twitterLink ?? '',
                      icon: Icons.link_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.linkedin_link,
                      value: userModel?.linkedinLink ?? '',
                      icon: Icons.link_outlined,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.SIZE_24),
                _buildSection(
                  context,
                  title: AppLocalizations.current.system_info,
                  children: [
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.created_at,
                      value: userModel?.createdAt ?? '',
                      icon: Icons.calendar_today_outlined,
                      isFirst: true,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.updated_at,
                      value: userModel?.updatedAt ?? '',
                      icon: Icons.update_outlined,
                    ),
                    _buildSectionItem(
                      context,
                      title: AppLocalizations.current.last_login,
                      value:
                          userModel?.lastLogin != null
                              ? DateFormat('dd/MM/yyyy HH:mm').format(
                                DateTime.parse(userModel?.lastLogin ?? ''),
                              )
                              : AppLocalizations.current.no_info,
                      icon: Icons.login_outlined,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.SIZE_32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
            // border: Border.all(
            //   color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            // ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSectionItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final displayValue =
        value.isEmpty ? AppLocalizations.current.no_info : value;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.SIZE_16,
            vertical: AppDimens.SIZE_12,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: AppDimens.SIZE_20,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppDimens.SIZE_2),
                    Text(
                      displayValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 56.0,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  /// Build avatar widget dựa trên thông tin user
  Widget _buildAvatar(BuildContext context) {
    if (user == null) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Nếu có ảnh avatar
    if (user?.picture != null && user!.picture!.isNotEmpty) {
      final avatarUrl = _getAvatarUrl();
      return CircleAvatar(
        radius: 40,
        backgroundImage:
            Platform.isAndroid
                ? AssetImage(avatarUrl)
                : CachedNetworkImageProvider(avatarUrl),
        backgroundColor: Colors.white,
        onBackgroundImageError: (_, __) {
          debugPrint('❌ Failed to load avatar: $avatarUrl');
        },
      );
    }

    // Nếu có tên, hiển thị chữ cái đầu
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Text(
          _getInitials(user!.fullName!),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    // Default: icon person
    return CircleAvatar(
      radius: 40,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Lấy chữ cái đầu của tên để hiển thị trong avatar
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    // Lấy chữ cái đầu của tên và họ
    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }

  String _getAvatarUrl() {
    if (user?.picture == null || user!.picture!.isEmpty) {
      return '';
    }

    final picture = user!.picture!;

    // Check if already a full URL (from social platforms)
    if (picture.startsWith('http://') || picture.startsWith('https://')) {
      return picture;
    }

    // If it's a relative path, prepend storage host
    return '${ApiConstant.storageHost}$picture';
  }
}
