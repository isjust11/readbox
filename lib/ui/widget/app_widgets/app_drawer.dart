import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';

import '../../../domain/data/models/models.dart';

class AppDrawer extends StatefulWidget {
  final Function(String) onSelected;
  const AppDrawer({super.key, required this.onSelected});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _currentFilter;
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
      print('Error loading user info: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
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
        backgroundImage: CachedNetworkImageProvider(_currentUser!.picture!),
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

  void _filterBooks(String filter) {
    setState(() {
      _currentFilter = filter;
    });

    switch (filter) {
      case 'all':
        widget.onSelected('all');
        break;
      case 'favorite':
        widget.onSelected('favorite');
        break;
      case 'archived':
        widget.onSelected('archived');
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
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Avatar
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
                          child: _buildAvatar(),
                        ),
                        SizedBox(width: 16),

                        // User Name
                        Column(
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              flex: 8,
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.library_books,
                    title: AppLocalizations.current.all_books,
                    isSelected: _currentFilter == 'all',
                    onTap: () => _filterBooks('all'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite,
                    title: AppLocalizations.current.favorite_books,
                    isSelected: _currentFilter == 'favorite',
                    onTap: () => _filterBooks('favorite'),
                    iconColor: Colors.red,
                  ),
                  _buildDrawerItem(
                    icon: Icons.archive,
                    title: AppLocalizations.current.archived_books,
                    isSelected: _currentFilter == 'archived',
                    onTap: () => _filterBooks('archived'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.phone_android,
                    title: AppLocalizations.current.local_library,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.localLibraryScreen);
                    },
                    iconColor: Colors.green,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.upload_file,
                    title: AppLocalizations.current.upload_book,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.adminUploadScreen);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.feedback,
                    title: AppLocalizations.current.feedback,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.feedbackScreen);
                    },
                    iconColor: Colors.blue,
                    textColor: Colors.blue,
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: AppLocalizations.current.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.settingsScreen);
                    },
                    iconColor: Colors.blueGrey,
                    textColor: Colors.blueGrey,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                onTap: _handleLogout,
                iconColor: Colors.red,
                textColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    await _secureStorage.clearAllSecureData();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
            isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                    : (iconColor?.withValues(alpha: 0.1) ?? Colors.grey[100]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : (iconColor ?? Colors.grey[700]),
            size: 22,
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
