import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/app_widgets/app_profile.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/services/biometric_test_helper.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _themeMode = true;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _appVersion = '';
  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
    _loadNotificationStatus();
    _loadAppVersion();
    _loadThemeStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final capability = await BiometricAuthService.checkBiometricCapability();
    final enabled = await BiometricAuthService.isBiometricEnabledInApp();

    setState(() {
      _biometricAvailable = capability == BiometricCapability.available;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _loadNotificationStatus() async {
    final fcmService = FCMService();
    setState(() {
      _notificationsEnabled = fcmService.notificationsEnabled;
    });
  }

  Future<void> _loadThemeStatus() async {
    final themeCubit = context.read<ThemeCubit>();
    setState(() {
      _themeMode = themeCubit.state == 'light';
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} ${packageInfo.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      hideAppBar: true,
      colorBg: Theme.of(context).colorScheme.secondaryContainer,
      body: _buildLayoutSection(context),
      floatingButton: _buildFloatingButton(),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppProfile(),
              const SizedBox(height: AppDimens.SIZE_12),
              _buildQuickActions(),
              const SizedBox(height: AppDimens.SIZE_12),
              _buildSettingsSection(context),
              const SizedBox(height: AppDimens.SIZE_12),
              _buildSupportSection(),
              const SizedBox(height: AppDimens.SIZE_12),
            ],
          ),
        );
    
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Icon(Icons.arrow_back_ios_new,),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.SIZE_12),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.edit,
              title: AppLocalizations.current.editProfile,
              subtitle: AppLocalizations.current.updateYourInfo,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.editProfile);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.security,
              title: AppLocalizations.current.security,
              subtitle: AppLocalizations.current.privacySettings,
              color: Colors.green,
              onTap: () {
                Navigator.of(context).pushNamed(Routes.privacySecurityScreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.SIZE_12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppDimens.SIZE_10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.SIZE_12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
              ),
              child: Icon(icon, color: color, size: AppDimens.SIZE_24),
            ),
            const SizedBox(height: AppDimens.SIZE_12),
            CustomTextLabel(
              title,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.SIZE_14,
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
            ),
            const SizedBox(height: AppDimens.SIZE_4),
            CustomTextLabel(
              subtitle,
              fontSize: AppDimens.SIZE_12,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.SIZE_12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: AppDimens.SIZE_10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.language,
            title: AppLocalizations.current.language,
            subtitle: AppLocalizations.current.changeAppLanguage,
            trailing: _buildLanguageDropdown(context),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.palette,
            title: AppLocalizations.current.theme,
            subtitle: AppLocalizations.current.chooseAppAppearance,
            trailing: Switch(
              value: _themeMode,
              onChanged: (value) async {
                setState(() {
                  _themeMode = value;
                });
                context.read<ThemeCubit>().changeTheme(value ? 'light' : 'dark');
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.notifications,
            title: AppLocalizations.current.notifications,
            subtitle: AppLocalizations.current.manageNotifications,
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await FCMService().toggleNotifications(value);
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.fingerprint,
            title: AppLocalizations.current.biometricLogin,
            subtitle: _getBiometricSubtitle(),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: _biometricAvailable ? _onBiometricToggle : null,
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),
          // Debug section chỉ hiển thị trong debug mode
          if (kDebugMode) ...[
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.bug_report,
              title: 'Debug: Test Secure Storage',
              subtitle:
                  'Test flutter_secure_storage and biometric capabilities',
              trailing: IconButton(
                icon: Icon(Icons.play_arrow, color: Theme.of(context).primaryColor),
                onPressed: () async {
                  await BiometricTestHelper.runAllTests();
                  _showSuccessMessage(
                    'Debug test completed. Check console logs.',
                  );
                },
              ),
            ),
            _buildDivider(),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Debug: Test FCM',
              subtitle: 'Test FCM notifications',
              trailing: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  // TODO: Navigate to FCM test screen when route is available
                  // Navigator.of(context).pushNamed(Routes.fcmTestScreen);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.SIZE_12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: AppDimens.SIZE_10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.help_outline,
            title: AppLocalizations.current.helpCenter,
            subtitle: AppLocalizations.current.getHelpAndSupport,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: AppDimens.SIZE_16,
            ),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.supportCenterScreen);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.feedback,
            title: AppLocalizations.current.sendFeedback,
            subtitle: AppLocalizations.current.shareYourThoughts,
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: AppDimens.SIZE_16,
            ),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.feedbackScreen);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: AppLocalizations.current.aboutApp,
            subtitle: '${AppLocalizations.current.version} $_appVersion',
            trailing: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_20,
          vertical: AppDimens.SIZE_12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.SIZE_8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: AppDimens.SIZE_20,
              ),
            ),
            const SizedBox(width: AppDimens.SIZE_16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextLabel(
                    title,
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimens.SIZE_16,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
                  ),
                  const SizedBox(height: 2),
                  CustomTextLabel(
                    subtitle,
                    fontSize: AppDimens.SIZE_14,
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return BlocBuilder<LanguageCubit, String>(
      builder: (context, lang) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.SIZE_12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: lang,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Theme.of(context).primaryColor,
            ),
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<LanguageCubit>().changeLanguage(value);
              }
            },
          ),
        );
      },
    );
  }



  String _getBiometricSubtitle() {
    if (!_biometricAvailable) {
      return AppLocalizations.current.biometricNotAvailable;
    }
    return AppLocalizations.current.useFingerprintOrFaceID;
  }

  Future<void> _onBiometricToggle(bool value) async {
    if (value) {
      await _enableBiometric();
    } else {
      _disableBiometric();
    }
  }

  Future<void> _enableBiometric() async {
    try {
      // Kiểm tra xem có thông tin đăng nhập nào không
      final credentials = await BiometricAuthService.getStoredCredentials();
      final socialInfo = await BiometricAuthService.getStoredSocialLoginInfo();

      if (credentials != null || socialInfo != null) {
        // Bật sinh trắc học trong app
        await BiometricAuthService.setBiometricEnabledInApp(true);
        
        setState(() {
          _biometricEnabled = true;
        });

        _showSuccessMessage(AppLocalizations.current.biometricSetupSuccess);
      } else {
        throw Exception(AppLocalizations.current.noLoginInfo);
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  Future<void> _disableBiometric() async {
    try {
      await BiometricAuthService.setBiometricEnabledInApp(false);

      setState(() {
        _biometricEnabled = false;
      });

      _showSuccessMessage(AppLocalizations.current.biometricDisabled);
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextLabel(message, color: AppColors.white),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextLabel(message, color: AppColors.white),
        backgroundColor: AppColors.errorRed,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
