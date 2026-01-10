import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';

class AppProfile extends StatefulWidget {
  final UserModel? user;
  const AppProfile({super.key, this.user,});

  @override
  State<AppProfile> createState() => _AppProfileState();
}

class _AppProfileState extends State<AppProfile> {
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  final SecureStorageService _secureStorage = SecureStorageService();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      _currentUser = await _secureStorage.getUserInfo();
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.profileBackground.path),
          fit: BoxFit.cover,
        ),
      ),
      child: Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.9),
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
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
                      Navigator.pushNamed(context, Routes.profileScreen, arguments: _currentUser);
                    },
                    child: Container(
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
                      child: _buildAvatar(),
                    ),
                  ),
                  SizedBox(width: 16),

                  // User Name
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser?.fullName ??
                              _currentUser?.username ??
                              '',
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
                        if (_currentUser?.email != null &&
                            _currentUser!.email!.isNotEmpty)
                          Text(
                            _currentUser!.email!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build avatar widget dựa trên thông tin user
  Widget _buildAvatar() {
    if (_isLoadingUser) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }

    // Nếu có ảnh avatar
    if (_currentUser?.picture != null && _currentUser!.picture!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: CachedNetworkImageProvider( 
          _isSocialPlatform() ? _currentUser!.picture! :
           ApiConstant.storageHost + (_currentUser!.picture ?? '')),
        backgroundColor: Colors.white,
        onBackgroundImageError: (_, __) {
          // Fallback sẽ hiển thị initials bên dưới
        },
      );
    }

    // Nếu có tên, hiển thị chữ cái đầu
    if (_currentUser?.fullName != null && _currentUser!.fullName!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: Text(
          _getInitials(_currentUser!.fullName!),
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

  bool _isSocialPlatform() {
    return _currentUser?.isGoogleUser == true || _currentUser?.isFacebookUser == true || _currentUser?.isAppleUser == true;
  }
}
