import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TextToSpeechSettingScreen extends StatefulWidget {
  const TextToSpeechSettingScreen({super.key});

  @override
  State<TextToSpeechSettingScreen> createState() =>
      _TextToSpeechSettingScreenState();
}

class _TextToSpeechSettingScreenState extends State<TextToSpeechSettingScreen> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isLoading = true;
  bool _isTesting = false;

  //timer
  Timer? _volumeDebounce;
  Timer? _pitchDebounce;
  Timer? _speechRateDebounce;
  // TTS Settings
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  // Available voices
  List<dynamic> _availableVoices = [];
  List<dynamic> _filteredVoices = [];
  Map<String, String>? _selectedVoice;
  bool _isRefreshingVoices = false;

  // Voice filter: 'enhanced' | 'locale' | 'all'
  String _voiceFilter = Platform.isIOS ? 'enhanced' : 'locale';

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
    });

    _volumeDebounce?.cancel();

    _volumeDebounce = Timer(const Duration(milliseconds: 300), () {
      _updateVolume(value);
    });
  }

  void _onPitchChanged(double value) {
    setState(() {
      _pitch = value;
    });

    _pitchDebounce?.cancel();
    _pitchDebounce = Timer(const Duration(milliseconds: 100), () {
      _updatePitch(value);
    });
  }

  void _onSpeechRateChanged(double value) {
    setState(() {
      _speechRate = value;
    });

    _speechRateDebounce?.cancel();
    _speechRateDebounce = Timer(const Duration(milliseconds: 300), () {
      _updateSpeechRate(value);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _ttsService.initialize();
      await _loadSettings();

      // Get available voices
      final voices = await _ttsService.getVoices();

      setState(() {
        _speechRate = _ttsService.speechRate;
        _volume = _ttsService.volume;
        _pitch = _ttsService.pitch;
        _availableVoices = voices;
        _filteredVoices = _filterVoices(voices, _voiceFilter);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
      final ttVoice =
          prefs.getString('tts_voice') != null
              ? jsonDecode(prefs.getString('tts_voice')!)
                  as Map<String, dynamic>
              : null;
      _selectedVoice =
          ttVoice != null ? Map<String, String>.from(ttVoice) : null;
    });

    // Apply loaded settings to TTS service
    await _ttsService.setSpeechRate(_speechRate);
    await _ttsService.setVolume(_volume);
    await _ttsService.setPitch(_pitch);
    if (_selectedVoice != null) {
      await _ttsService.setVoice(_selectedVoice!);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', _speechRate);
    await prefs.setDouble('tts_volume', _volume);
    await prefs.setDouble('tts_pitch', _pitch);
  }

  Future<void> _updateSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    setState(() {
      _speechRate = rate;
    });
    await _saveSettings();
  }

  Future<void> _updateVolume(double vol) async {
    await _ttsService.setVolume(vol);
    setState(() {
      _volume = vol;
    });
    await _saveSettings();
  }

  Future<void> _updatePitch(double p) async {
    await _ttsService.setPitch(p);
    setState(() {
      _pitch = p;
    });
    await _saveSettings();
  }

  Future<void> _testTTS() async {
    if (_isTesting) {
      await _ttsService.stop();
      setState(() {
        _isTesting = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
    });

    _ttsService.onSpeechComplete = (_) {
      setState(() {
        _isTesting = false;
      });
    };

    _ttsService.onSpeechError = (error) {
      setState(() {
        _isTesting = false;
      });
      _showError(error);
    };

    await _ttsService.speak(AppLocalizations.current.ttsTestText);
  }

  /// Reload lại danh sách giọng sau khi user cài thêm từ Settings hệ thống
  Future<void> _refreshVoices() async {
    setState(() => _isRefreshingVoices = true);
    try {
      final voices = await _ttsService.getVoices();
      setState(() {
        _availableVoices = voices;
        _filteredVoices = _filterVoices(voices, _voiceFilter);
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isRefreshingVoices = false);
    }
  }

  /// Mở trang cài đặt giọng nói của hệ thống
  Future<void> _openVoiceSettings() async {
    Uri uri;
    if (Platform.isIOS) {
      // iOS: Accessibility > Spoken Content > Voices
      uri = Uri.parse('App-Prefs:ACCESSIBILITY&path=SPEECH');
    } else {
      // Android: TTS Settings
      uri = Uri.parse('com.android.settings.TTS_SETTINGS');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: mở Settings chung
      final fallback = Uri.parse(
        Platform.isIOS ? 'App-Prefs:' : 'package:com.android.settings',
      );
      if (await canLaunchUrl(fallback)) await launchUrl(fallback);
    }
  }

  /// Dialog hướng dẫn tải giọng nâng cao
  void _showDownloadVoiceDialog() {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  color: Theme.of(context).primaryColor,
                  size: AppDimens.SIZE_24,
                ),
                const SizedBox(width: AppDimens.SIZE_8),
                Expanded(
                  child: CustomTextLabel(
                    Platform.isIOS
                        ? AppLocalizations.current.ttsDownloadAdvancedVoiceIos
                        : AppLocalizations
                            .current
                            .ttsDownloadAdvancedVoiceAndroid,
                    fontSize: AppDimens.SIZE_16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  Platform.isIOS
                      ? AppLocalizations.current.ttsDownloadVoiceInstructionIos
                      : AppLocalizations
                          .current
                          .ttsDownloadVoiceInstructionAndroid,
                  fontSize: AppDimens.SIZE_14,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: AppDimens.SIZE_12),
                ...(Platform.isIOS
                        ? [
                          AppLocalizations.current.ttsDownloadVoiceStepIos1,
                          AppLocalizations.current.ttsDownloadVoiceStepIos2,
                          AppLocalizations.current.ttsDownloadVoiceStepIos3,
                          AppLocalizations.current.ttsDownloadVoiceStepIos4,
                        ]
                        : [
                          AppLocalizations.current.ttsDownloadVoiceStepAndroid1,
                          AppLocalizations.current.ttsDownloadVoiceStepAndroid2,
                          AppLocalizations.current.ttsDownloadVoiceStepAndroid3,
                        ])
                    .map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.arrow_right,
                              size: AppDimens.SIZE_16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: CustomTextLabel(
                                step,
                                fontSize: AppDimens.SIZE_13,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color ??
                                    AppColors.colorTitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: AppDimens.SIZE_8),
                CustomTextLabel(
                  AppLocalizations.current.ttsDownloadVoiceRefreshHint,
                  fontSize: AppDimens.SIZE_12,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      AppColors.colorTitle,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: CustomTextLabel(
                  AppLocalizations.current.cancel,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      AppColors.colorTitle,
                  fontSize: AppDimens.SIZE_14,
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openVoiceSettings();
                },
                icon: const Icon(Icons.open_in_new, size: AppDimens.SIZE_16),
                label: CustomTextLabel(
                  AppLocalizations.current.ttsOpenSettings,
                  color: Colors.white,
                  fontSize: AppDimens.SIZE_14,
                  fontWeight: FontWeight.w600,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Lọc danh sách giọng nói theo chế độ:
  /// - 'enhanced': chỉ lấy giọng nâng cao (iOS)
  /// - 'locale'  : khớp ngôn ngữ thiết bị
  /// - 'all'     : tất cả giọng
  List<dynamic> _filterVoices(List<dynamic> voices, String filter) {
    final deviceLang =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    List<dynamic> result;
    if (filter == 'enhanced') {
      result = voices.where((v) => v['quality'] == 'enhanced').toList();
      // Fallback: nếu không có enhanced thì hiển thị tất cả
      // if (result.isEmpty) result = List.from(voices);
    } else if (filter == 'locale') {
      result =
          voices
              .where(
                (v) => (v['locale'] as String? ?? '').toLowerCase().startsWith(
                  deviceLang,
                ),
              )
              .toList();
      // Fallback: nếu không khớp locale thì hiển thị tất cả
      if (result.isEmpty) result = List.from(voices);
    } else {
      result = List.from(voices);
    }

    // Sắp xếp: locale khớp trước → enhanced trước → tên alphabet
    result.sort((a, b) {
      final aLocale = (a['locale'] as String).toLowerCase().startsWith(
        deviceLang,
      );
      final bLocale = (b['locale'] as String).toLowerCase().startsWith(
        deviceLang,
      );
      if (aLocale && !bLocale) return -1;
      if (!aLocale && bLocale) return 1;

      final aEnhanced = a['quality'] == 'enhanced';
      final bEnhanced = b['quality'] == 'enhanced';
      if (aEnhanced && !bEnhanced) return -1;
      if (!aEnhanced && bEnhanced) return 1;

      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return result;
  }

  String _getSpeedLabel(double rate) {
    if (rate < 0.3) return AppLocalizations.current.slow;
    if (rate < 0.6) return AppLocalizations.current.normal;
    if (rate < 0.8) return AppLocalizations.current.fast;
    return AppLocalizations.current.veryFast;
  }

  String _getPitchLabel(double pitch) {
    if (pitch < 0.8) return AppLocalizations.current.low;
    if (pitch < 1.3) return AppLocalizations.current.medium;
    return AppLocalizations.current.high;
  }

  void _showError(String message) {
    AppSnackBar.show(
      context,
      message: message,
      snackBarType: SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BaseScreen(
      hideAppBar: false,
      colorBg: theme.colorScheme.surface,
      title: AppLocalizations.current.ttsSettings,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Theme.of(context).primaryColor),
            const SizedBox(height: AppDimens.SIZE_16),
            CustomTextLabel(
              AppLocalizations.current.initializingTTS,
              fontSize: AppDimens.SIZE_14,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.colorTitle,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTestSection(),
          const SizedBox(height: AppDimens.SIZE_12),
          _buildSpeedSection(),
          const SizedBox(height: AppDimens.SIZE_12),
          _buildVolumeSection(),
          const SizedBox(height: AppDimens.SIZE_12),
          _buildPitchSection(),
          const SizedBox(height: AppDimens.SIZE_12),
          // if (_availableVoices.isNotEmpty) ...[
          //   _buildVoiceSection(),
          //   const SizedBox(height: AppDimens.SIZE_12),
          // ],
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isTesting ? Icons.stop_circle : Icons.play_circle_fill,
            color: Colors.white,
            size: AppDimens.SIZE_48,
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          CustomTextLabel(
            AppLocalizations.current.testTTS,
            fontSize: AppDimens.SIZE_18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.SIZE_8),
          CustomTextLabel(
            AppLocalizations.current.ttsTestText,
            fontSize: AppDimens.SIZE_14,
            color: Colors.white.withValues(alpha: 0.9),
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          ElevatedButton.icon(
            onPressed: _testTTS,
            icon: Icon(
              _isTesting ? Icons.stop : Icons.play_arrow,
              size: AppDimens.SIZE_20,
            ),
            label: CustomTextLabel(
              _isTesting
                  ? AppLocalizations.current.stopTest
                  : AppLocalizations.current.playTest,
              color: Theme.of(context).primaryColor,
              fontSize: AppDimens.SIZE_16,
              fontWeight: FontWeight.w600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_32,
                vertical: AppDimens.SIZE_12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedSection() {
    return _buildSettingCard(
      icon: Icons.speed,
      title: AppLocalizations.current.readingSpeed,
      subtitle: _getSpeedLabel(_speechRate),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLabel(
                AppLocalizations.current.slow,
                fontSize: AppDimens.SIZE_12,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.colorTitle,
              ),
              CustomTextLabel(
                '${(_speechRate * 2).toStringAsFixed(1)}x',
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              CustomTextLabel(
                AppLocalizations.current.veryFast,
                fontSize: AppDimens.SIZE_12,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.colorTitle,
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _speechRate,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              onChanged: _onSpeechRateChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSection() {
    return _buildSettingCard(
      icon: Icons.volume_up,
      title: AppLocalizations.current.ttsVolume,
      subtitle: '${(_volume * 100).toInt()}%',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.volume_mute, size: AppDimens.SIZE_16),
              CustomTextLabel(
                '${(_volume * 100).toInt()}%',
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              const Icon(Icons.volume_up, size: AppDimens.SIZE_16),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              onChanged: _onVolumeChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitchSection() {
    return _buildSettingCard(
      icon: Icons.tune,
      title: AppLocalizations.current.voicePitch,
      subtitle: _getPitchLabel(_pitch),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLabel(
                AppLocalizations.current.low,
                fontSize: AppDimens.SIZE_12,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.colorTitle,
              ),
              CustomTextLabel(
                _pitch.toStringAsFixed(1),
                fontSize: AppDimens.SIZE_16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              CustomTextLabel(
                AppLocalizations.current.high,
                fontSize: AppDimens.SIZE_12,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.colorTitle,
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _pitch,
              min: 0.5,
              max: 2.0,
              divisions: 10,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(
                context,
              ).primaryColor.withValues(alpha: 0.2),
              onChanged: _onPitchChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return _buildSettingCard(
      icon: Icons.record_voice_over,
      title: AppLocalizations.current.selectVoice,
      subtitle:
          _selectedVoice?['name'] ?? AppLocalizations.current.defaultVoice,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimens.SIZE_8),
          // Filter tabs
          _buildVoiceFilterChips(),
          const SizedBox(height: AppDimens.SIZE_8),
          // Download banner (chỉ hiện khi filter = enhanced)
          if (_voiceFilter == 'enhanced') _buildDownloadVoiceBanner(),
          if (_voiceFilter == 'enhanced')
            const SizedBox(height: AppDimens.SIZE_8),
          // Voice count info + refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextLabel(
                '${_filteredVoices.length} / ${_availableVoices.length} ${AppLocalizations.current.availableLanguages.toLowerCase()}',
                fontSize: AppDimens.SIZE_12,
                color:
                    Theme.of(context).textTheme.bodyMedium?.color ??
                    AppColors.colorTitle,
              ),
              // Nút refresh để reload voices sau khi cài từ Settings
              GestureDetector(
                onTap: _isRefreshingVoices ? null : _refreshVoices,
                child: AnimatedRotation(
                  turns: _isRefreshingVoices ? 1 : 0,
                  duration: const Duration(milliseconds: 600),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: AppDimens.SIZE_20,
                    color:
                        _isRefreshingVoices
                            ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.4)
                            : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            ),
            child:
                _filteredVoices.isEmpty
                    ? Center(
                      child: CustomTextLabel(
                        AppLocalizations.current.empty,
                        fontSize: AppDimens.SIZE_14,
                        color:
                            Theme.of(context).textTheme.bodyMedium?.color ??
                            AppColors.colorTitle,
                      ),
                    )
                    : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredVoices.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                      itemBuilder: (context, index) {
                        final voice = _filteredVoices[index];
                        final voiceName = voice['name'] as String;
                        final locale = voice['locale'] as String;
                        final quality = voice['quality'] as String? ?? '';
                        final isEnhanced = quality == 'enhanced';
                        final isSelected = _selectedVoice?['name'] == voiceName;

                        return ListTile(
                          dense: true,
                          title: Row(
                            children: [
                              if (isEnhanced) ...[
                                Icon(
                                  Icons.auto_awesome,
                                  size: AppDimens.SIZE_14,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: CustomTextLabel(
                                  '$voiceName - ($locale)',
                                  fontSize: AppDimens.SIZE_14,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color ??
                                      AppColors.colorTitle,
                                ),
                              ),
                            ],
                          ),
                          trailing:
                              isSelected
                                  ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                  : null,
                          onTap: () async {
                            final Map<String, String> voiceMap = {
                              'name': voiceName,
                              'locale': locale,
                              'identifier':
                                  Platform.isIOS
                                      ? (voice['identifier'] as String? ?? '')
                                      : '',
                              'quality': quality,
                            };
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                              'tts_voice',
                              jsonEncode(voiceMap),
                            );
                            await _ttsService.setVoice(voiceMap);
                            setState(() {
                              _selectedVoice = voiceMap;
                            });
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// Banner hướng dẫn tải giọng nâng cao
  Widget _buildDownloadVoiceBanner() {
    return GestureDetector(
      onTap: _showDownloadVoiceDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_12,
          vertical: AppDimens.SIZE_10,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.download_rounded,
              size: AppDimens.SIZE_16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: AppDimens.SIZE_8),
            Expanded(
              child: CustomTextLabel(
                Platform.isIOS
                    ? AppLocalizations.current.ttsDownloadMoreVoicesIos
                    : AppLocalizations.current.ttsDownloadMoreVoicesAndroid,
                fontSize: AppDimens.SIZE_12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppDimens.SIZE_12,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceFilterChips() {
    final filters = [
      (
        id: 'enhanced',
        label: '✨ ${AppLocalizations.current.advanced}',
        icon: Icons.auto_awesome,
      ),
      (
        id: 'locale',
        label: '🌐 ${AppLocalizations.current.language}',
        icon: Icons.language,
      ),
      (
        id: 'all',
        label: '📋 ${AppLocalizations.current.all}',
        icon: Icons.list,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.map((f) {
              final isActive = _voiceFilter == f.id;
              return Padding(
                padding: const EdgeInsets.only(right: AppDimens.SIZE_8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _voiceFilter = f.id;
                      _filteredVoices = _filterVoices(_availableVoices, f.id);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.SIZE_12,
                      vertical: AppDimens.SIZE_6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isActive
                              ? Theme.of(context).primaryColor
                              : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppDimens.SIZE_20),
                      border: Border.all(
                        color:
                            isActive
                                ? Theme.of(context).primaryColor
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: CustomTextLabel(
                      f.label,
                      fontSize: AppDimens.SIZE_12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isActive
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color ??
                                  AppColors.colorTitle,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: AppDimens.SIZE_24,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextLabel(
                      title,
                      fontSize: AppDimens.SIZE_16,
                      fontWeight: FontWeight.w600,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          AppColors.colorTitle,
                    ),
                    const SizedBox(height: 2),
                    CustomTextLabel(
                      subtitle,
                      fontSize: AppDimens.SIZE_14,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          child,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}
