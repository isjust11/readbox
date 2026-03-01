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

          // Card thông tin chi tiết
          Container(
            margin: const EdgeInsets.all(AppDimens.SIZE_8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.SIZE_12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin cơ bản
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.username,
                    userModel?.username ?? '',
                    Icons.person_outline,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.roles,
                    userModel?.roles.map((e) => e.name).join(', ') ?? '',
                    Icons.admin_panel_settings_outlined,
                  ),
                  // _buildInfoCard(
                  //   context,
                  //   AppLocalizations.current.permissions,
                  //   userModel?.permissions.map((e) => e).join(', ') ?? '',
                  //   Icons.security_outlined,
                  // ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.birth_date,
                    userModel?.birthDate ?? '',
                    Icons.calendar_today_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.address,
                    userModel?.address ?? '',
                    Icons.location_on_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.facebook_link,
                    userModel?.facebookLink ?? '',
                    Icons.facebook_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.instagram_link,
                    userModel?.instagramLink ?? '',
                    Icons.link_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.twitter_link,
                    userModel?.twitterLink ?? '',
                    Icons.link_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.linkedin_link,
                    userModel?.linkedinLink ?? '',
                    Icons.link_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.phone_number,
                    userModel?.phoneNumber ?? '',
                    Icons.phone_outlined,
                  ),

                  const SizedBox(height: AppDimens.SIZE_20),

                  _buildInfoCard(
                    context,
                    AppLocalizations.current.created_at,
                    userModel?.createdAt ?? '',
                    Icons.calendar_today_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.updated_at,
                    userModel?.updatedAt ?? '',
                    Icons.update_outlined,
                  ),
                  _buildInfoCard(
                    context,
                    AppLocalizations.current.last_login,
                    userModel?.lastLogin != null
                        ? DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(DateTime.parse(userModel?.lastLogin ?? ''))
                        : AppLocalizations.current.no_info,
                    Icons.login_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.SIZE_12),
      padding: const EdgeInsets.all(AppDimens.SIZE_8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.05,
        ),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
          width: 1,
        ),
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
          const SizedBox(width: AppDimens.SIZE_12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  title,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  fontSize: AppDimens.SIZE_12,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: AppDimens.SIZE_4),
                CustomTextLabel(
                  value.isEmpty ? AppLocalizations.current.no_info : value,
                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                  fontSize: AppDimens.SIZE_14,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
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
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
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
