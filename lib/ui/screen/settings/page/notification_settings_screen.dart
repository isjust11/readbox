import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/services/fcm_service.dart';
import 'package:readbox/services/local_notification_service.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final FCMService _fcmService = FCMService();
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();

  bool _isLoading = true;
  bool _pushNotificationsEnabled = true;
  bool _localNotificationsEnabled = true;
  bool _readingRemindersEnabled = false;
  bool _bookUpdatesEnabled = true;
  bool _systemNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _badgeEnabled = true;
  bool _previewEnabled = true;

  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  String? _fcmToken;
  String _permissionStatus = 'Unknown';
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize services
      await _fcmService.initialize();
      await _localNotificationService.initialize();

      // Get FCM token
      _fcmToken = _fcmService.fcmToken;

      // Get push notification status
      _pushNotificationsEnabled = _fcmService.notificationsEnabled;

      // Check permission status
      await _checkPermissionStatus();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPermissionStatus() async {
    final settings = await _fcmService.getNotificationSettings();
    final status = settings.authorizationStatus;

    setState(() {
      _permissionStatus = status.toString().split('.').last;
      _isPermissionGranted = status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;
    });
  }

  Future<void> _togglePushNotifications(bool value) async {
    if (value && !_isPermissionGranted) {
      final granted = await _requestPermission();
      if (!granted) {
        _showError(AppLocalizations.current.permissionDenied);
        return;
      }
    }

    await _fcmService.toggleNotifications(value);
    setState(() {
      _pushNotificationsEnabled = value;
    });
    _showSuccess(
      value
          ? AppLocalizations.current.enableNotifications
          : AppLocalizations.current.disableNotifications,
    );
  }

  Future<bool> _requestPermission() async {
    final granted = await _fcmService.requestPermissionAgain();
    await _checkPermissionStatus();
    return granted;
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });

      if (_readingRemindersEnabled) {
        await _scheduleDailyReminder();
      }

      _showSuccess(AppLocalizations.current.settingsSaved);
    }
  }

  Future<void> _scheduleDailyReminder() async {
    await _localNotificationService.scheduleDailyReadingReminder(
      id: 1,
      title: AppLocalizations.current.readingReminders,
      body: 'Đã đến giờ đọc sách của bạn!',
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
      payload: 'daily_reminder',
    );
  }

  Future<void> _sendTestNotification() async {
    await _localNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: AppLocalizations.current.testNotification,
      body: 'Đây là thông báo thử nghiệm từ ReadBox',
      payload: 'test',
    );
    _showSuccess(AppLocalizations.current.testNotificationSent);
  }

  Future<void> _copyFCMToken() async {
    if (_fcmToken != null) {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));
      _showSuccess(AppLocalizations.current.tokenCopied);
    }
  }

  Future<void> _refreshFCMToken() async {
    await _fcmService.refreshToken();
    setState(() {
      _fcmToken = _fcmService.fcmToken;
    });
    _showSuccess(AppLocalizations.current.tokenRefreshed);
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextLabel(message, color: AppColors.white),
        backgroundColor: AppColors.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextLabel(message, color: AppColors.white),
        backgroundColor: Theme.of(context).primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      hideAppBar: false,
      colorBg: Theme.of(context).colorScheme.secondaryContainer,
      title: AppLocalizations.current.notificationSettings,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPermissionCard(),
          const SizedBox(height: AppDimens.SIZE_20),
          _buildNotificationToggleSection(),
          const SizedBox(height: AppDimens.SIZE_20),
          _buildReminderSection(),
          const SizedBox(height: AppDimens.SIZE_20),
          _buildPreferencesSection(),
          const SizedBox(height: AppDimens.SIZE_20),
          _buildTestSection(),
          const SizedBox(height: AppDimens.SIZE_20),
          _buildTokenSection(),
        ],
      ),
    );
  }

  Widget _buildPermissionCard() {
    final isGranted = _isPermissionGranted;
    final color = isGranted ? Colors.green : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
                ),
                child: Icon(
                  isGranted ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: AppDimens.SIZE_24,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_12),
              Expanded(
                child: CustomTextLabel(
                  AppLocalizations.current.permissionStatus,
                  fontSize: AppDimens.SIZE_14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          CustomTextLabel(
            isGranted
                ? AppLocalizations.current.permissionGranted
                : AppLocalizations.current.notificationPermissionRequired,
            fontSize: AppDimens.SIZE_18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: AppDimens.SIZE_8),
          CustomTextLabel(
            _permissionStatus,
            fontSize: AppDimens.SIZE_14,
            color: Colors.white.withOpacity(0.8),
          ),
          if (!isGranted) ...[
            const SizedBox(height: AppDimens.SIZE_16),
            ElevatedButton.icon(
              onPressed: _openAppSettings,
              icon: const Icon(Icons.settings),
              label: CustomTextLabel(
                AppLocalizations.current.openSettings,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationToggleSection() {
    return _buildSettingCard(
      title: AppLocalizations.current.notificationPreferences,
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_active,
          title: AppLocalizations.current.pushNotifications,
          subtitle: AppLocalizations.current.receivePushNotifications,
          value: _pushNotificationsEnabled,
          onChanged: _togglePushNotifications,
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.notifications,
          title: AppLocalizations.current.localNotifications,
          subtitle: AppLocalizations.current.receiveLocalNotifications,
          value: _localNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _localNotificationsEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.book,
          title: AppLocalizations.current.bookUpdates,
          subtitle: AppLocalizations.current.receiveBookUpdates,
          value: _bookUpdatesEnabled,
          onChanged: (value) {
            setState(() {
              _bookUpdatesEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.system_update,
          title: AppLocalizations.current.systemNotifications,
          subtitle: AppLocalizations.current.receiveSystemNotifications,
          value: _systemNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _systemNotificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return _buildSettingCard(
      title: AppLocalizations.current.readingReminders,
      children: [
        _buildSwitchTile(
          icon: Icons.alarm,
          title: AppLocalizations.current.readingReminders,
          subtitle: AppLocalizations.current.setReadingReminders,
          value: _readingRemindersEnabled,
          onChanged: (value) async {
            setState(() {
              _readingRemindersEnabled = value;
            });
            if (value) {
              await _scheduleDailyReminder();
            } else {
              await _localNotificationService.cancelNotification(1);
            }
          },
        ),
        if (_readingRemindersEnabled) ...[
          _buildDivider(),
          _buildActionTile(
            icon: Icons.access_time,
            title: AppLocalizations.current.reminderTime,
            subtitle:
                '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
            onTap: _selectReminderTime,
          ),
        ],
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSettingCard(
      title: AppLocalizations.current.notificationPreferences,
      children: [
        _buildSwitchTile(
          icon: Icons.volume_up,
          title: AppLocalizations.current.notificationSound,
          subtitle: AppLocalizations.current.enableSound,
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.vibration,
          title: AppLocalizations.current.notificationVibration,
          subtitle: AppLocalizations.current.enableVibration,
          value: _vibrationEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.circle_notifications,
          title: AppLocalizations.current.notificationBadge,
          subtitle: AppLocalizations.current.showBadge,
          value: _badgeEnabled,
          onChanged: (value) {
            setState(() {
              _badgeEnabled = value;
            });
          },
        ),
        _buildDivider(),
        _buildSwitchTile(
          icon: Icons.preview,
          title: AppLocalizations.current.notificationPreview,
          subtitle: AppLocalizations.current.showPreview,
          value: _previewEnabled,
          onChanged: (value) {
            setState(() {
              _previewEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTestSection() {
    return _buildSettingCard(
      title: AppLocalizations.current.testNotification,
      children: [
        _buildActionTile(
          icon: Icons.send,
          title: AppLocalizations.current.sendTestNotification,
          subtitle: 'Gửi thông báo thử nghiệm',
          onTap: _sendTestNotification,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: AppDimens.SIZE_16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTokenSection() {
    return _buildSettingCard(
      title: AppLocalizations.current.fcmToken,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.SIZE_12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomTextLabel(
                  _fcmToken ?? 'No token',
                  fontSize: AppDimens.SIZE_12,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.colorTitle,
                  maxLines: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: AppDimens.SIZE_20),
                onPressed: _copyFCMToken,
                tooltip: AppLocalizations.current.copyToken,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: AppDimens.SIZE_20),
                onPressed: _refreshFCMToken,
                tooltip: AppLocalizations.current.refreshToken,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimens.SIZE_16),
            child: CustomTextLabel(
              title,
              fontSize: AppDimens.SIZE_16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color ??
                  AppColors.colorTitle,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_16,
        vertical: AppDimens.SIZE_8,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.SIZE_8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
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
                  fontSize: AppDimens.SIZE_14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color ??
                      AppColors.colorTitle,
                ),
                const SizedBox(height: 2),
                CustomTextLabel(
                  subtitle,
                  fontSize: AppDimens.SIZE_12,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.colorTitle,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_16,
          vertical: AppDimens.SIZE_12,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.SIZE_8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
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
                    fontSize: AppDimens.SIZE_14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.colorTitle,
                  ),
                  const SizedBox(height: 2),
                  CustomTextLabel(
                    subtitle,
                    fontSize: AppDimens.SIZE_12,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        AppColors.colorTitle,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: AppDimens.SIZE_16,
      endIndent: AppDimens.SIZE_16,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }
}
