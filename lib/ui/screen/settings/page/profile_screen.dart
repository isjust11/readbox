import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
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
      backgroundColor: theme.primaryColor.withValues(alpha: 0.6),
      child: Icon(
        Icons.arrow_back_ios_new_outlined,
        color: theme.primaryColor,
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
                        width: AppDimens.SIZE_100,
                        height: AppDimens.SIZE_100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child:
                              userModel?.picture != null
                                  ? BaseNetworkImage(
                                    url:
                                        userModel?.isSocialPlatform ?? false
                                            ? userModel?.picture
                                            : ApiConstant.storageHost +
                                                (userModel?.picture ?? ''),
                                    fit: BoxFit.cover,
                                    showShimmer: false,
                                  )
                                  : Container(
                                    color: AppColors.border.withValues(
                                      alpha: 0.3,
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: AppDimens.SIZE_60,
                                      color: AppColors.white,
                                    ),
                                  ),
                        ),
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
}
