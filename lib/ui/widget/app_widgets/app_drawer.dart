import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/app_widgets/app_profile.dart';

class AppDrawer extends StatefulWidget {
  final Function(String, String) onSelected;
  const AppDrawer({super.key, required this.onSelected});

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
            AppProfile(),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.library_books,
                    title: AppLocalizations.current.all_books,
                    isSelected: _currentFilter == 'all',
                    onTap: () => _filterBooks('all', AppLocalizations.current.all_books),
                    iconColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite,
                    title: AppLocalizations.current.favorite_books,
                    isSelected: _currentFilter == 'favorite',
                    onTap: () => _filterBooks('favorite', AppLocalizations.current.favorite_books),
                    iconColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  _buildDrawerItem(
                    icon: Icons.archive,
                    title: AppLocalizations.current.archived_books,
                    isSelected: _currentFilter == 'archived',
                    onTap: () => _filterBooks('archived', AppLocalizations.current.archived_books),
                    iconColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1, color: Theme.of(context).dividerColor),
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(height: 1, color: Theme.of(context).dividerColor),
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
                    icon: Icons.settings,
                    title: AppLocalizations.current.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, Routes.settingsScreen);
                    },
                    iconColor: Colors.blueGrey,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   child: Divider(height: 1),
                  // ),
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
                    : (iconColor?.withValues(alpha: 0.25) ?? Colors.grey[100]),
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
