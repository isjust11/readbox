import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/screen/local_library/google_drive_tab.dart';
import 'package:readbox/ui/screen/local_library/local_books_tab.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocalLibraryScreen extends StatefulWidget {
  const LocalLibraryScreen({super.key});

  @override
  State<LocalLibraryScreen> createState() => _LocalLibraryScreenState();
}

class _LocalLibraryScreenState extends State<LocalLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    checkConnectivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    hasInternet =
        results.isNotEmpty &&
        !(results.length == 1 && results.first == ConnectivityResult.none);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScreen(
      colorBg: colorScheme.surface,
      hiddenIconBack: true,
      customAppBar: BaseAppBar(
        showBackButton: hasInternet,
        title: AppLocalizations.current.local_library,
        centerTitle: false,
        customTitle: null,
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            color: colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              tabs: [
                Tab(
                  icon: const Icon(Icons.phone_android, size: 20),
                  text: AppLocalizations.current.local_library,
                ),
                Tab(
                  icon: const Icon(Icons.add_to_drive, size: 20),
                  text: AppLocalizations.current.google_drive,
                ),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [LocalBooksTab(), GoogleDriveTab()],
            ),
          ),
        ],
      ),
    );
  }
}
