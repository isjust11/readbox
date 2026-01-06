import 'package:flutter/material.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/utils/shared_preference.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    _currentUser = await SharedPreferenceUtil.getUserInfo();
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
        child: ListView(
          padding: EdgeInsets.zero,
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
              child: Column(
                children: [
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
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _currentUser?.username ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _currentUser?.address ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            _buildDrawerItem(
              icon: Icons.library_books,
              title: 'Tất cả sách',
              isSelected: _currentFilter == 'all',
              onTap: () => _filterBooks('all'),
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'Sách yêu thích',
              isSelected: _currentFilter == 'favorite',
              onTap: () => _filterBooks('favorite'),
              iconColor: Colors.red,
            ),
            _buildDrawerItem(
              icon: Icons.archive,
              title: 'Đã lưu trữ',
              isSelected: _currentFilter == 'archived',
              onTap: () => _filterBooks('archived'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDrawerItem(
              icon: Icons.phone_android,
              title: 'Thư viện Local',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.localLibraryScreen);
              },
              iconColor: Colors.green,
            ),
            _buildDrawerItem(
              icon: Icons.upload_file,
              title: 'Upload sách',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.adminUploadScreen);
              },
            ),
            _buildDrawerItem(
              icon: Icons.book,
              title: 'Demo PDF Viewer',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.pdfTextToSpeechScreen);
              },
            ),
            _buildDrawerItem(
              icon: Icons.volume_up_rounded,
              title: 'Demo Text-to-Speech',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.ttsDemoScreen);
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: _handleLogout,
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    await SharedPreferenceUtil.clearData();
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
