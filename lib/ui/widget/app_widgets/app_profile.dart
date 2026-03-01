import 'package:flutter/material.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/user_subscription_cubit.dart';
import 'package:readbox/ui/widget/base_network_image.dart';

class AppProfile extends StatelessWidget {
  final UserModel? user;
  const AppProfile({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // context.watch<UserSubscriptionCubit>().loadMe();
    final userSubscription =
        context.watch<UserSubscriptionCubit>().userSubscription;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.profileBackground.path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter
          .mode(Theme.of(context).colorScheme.onInverseSurface, BlendMode.darken),
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withValues(alpha: 0.9),
              theme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.profileScreen,
                      arguments: user,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.onInverseSurface.withValues(alpha: 0.6), width: 3),
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
                ),
                SizedBox(width: 16),

                // User Name
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? user?.username ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),

                        // User Email
                        if (user?.email != null && user!.email!.isNotEmpty)
                          Text(
                            user!.email!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              Routes.subscriptionPlanScreen,
                            );
                          },
                          child: _buildSubscriptionBadge(userSubscription),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build avatar widget dựa trên thông tin user
  Widget _buildSubscriptionBadge(UserSubscriptionModel? userSubscription) {
    final plan = userSubscription?.plan;
    final isFree = plan == null || plan.isFree;

    final Color bgColor =
        isFree ? Colors.white.withValues(alpha: 0.12) : const Color(0x33FFD700);
    final Color borderColor =
        isFree ? Colors.white.withValues(alpha: 0.2) : const Color(0x66FFD700);
    final Color iconColor = isFree ? Colors.white70 : const Color(0xFFFFD700);
    final IconData icon =
        isFree ? Icons.workspace_premium_outlined : Icons.star_rounded;
    final String label = plan?.name ?? 'Free';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isFree ? Colors.white70 : const Color(0xFFFFD700),
              fontSize: 12,
              fontWeight: isFree ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
          if (isFree) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    if (user == null) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: theme.colorScheme.onInverseSurface,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.primaryColor,
            ),
          ),
        ),
      );
    }

    // Nếu có ảnh avatar
    if (user?.picture != null && user!.picture!.isNotEmpty) {
      final avatarUrl = _getAvatarUrl();
     
      return BaseNetworkImage(
        width: 80,
        height: 80,
        borderRadius: 40,
        backgroundColor: theme.colorScheme.onInverseSurface,
        showShimmer: true,
        url: avatarUrl,
      );
    }

    // Nếu có tên, hiển thị chữ cái đầu
    if (user?.fullName != null && user!.fullName!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: theme.colorScheme.onInverseSurface,
        child: Text(
          _getInitials(user!.fullName!),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
      );
    }

    // Default: icon person
    return CircleAvatar(
      radius: 40,
      backgroundColor: theme.primaryColor.withValues(alpha: 0.5),
      child: Icon(
        Icons.person,
        size: 48,
        color: theme.primaryColor,
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
