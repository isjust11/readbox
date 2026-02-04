import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // TTS Settings
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  // Available voices
  List<dynamic> _availableVoices = [];
  Map<String, String>? _selectedVoice;

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
    });

    // Apply loaded settings to TTS service
    await _ttsService.setSpeechRate(_speechRate);
    await _ttsService.setVolume(_volume);
    await _ttsService.setPitch(_pitch);
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_speech_rate', _speechRate);
    await prefs.setDouble('tts_volume', _volume);
    await prefs.setDouble('tts_pitch', _pitch);
    _showSuccess(AppLocalizations.current.settingsSaved);
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

  void _showSuccess(String message) {
    AppSnackBar.show(
      context,
      message: message,
      snackBarType: SnackBarType.success,
    );
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
    return BaseScreen(
      hideAppBar: false,
      colorBg: Theme.of(context).colorScheme.secondaryContainer,
      title: AppLocalizations.current.ttsSettings,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
          const SizedBox(height: AppDimens.SIZE_24),
          _buildSpeedSection(),
          const SizedBox(height: AppDimens.SIZE_24),
          _buildVolumeSection(),
          const SizedBox(height: AppDimens.SIZE_24),
          _buildPitchSection(),
          const SizedBox(height: AppDimens.SIZE_24),
          if (_availableVoices.isNotEmpty) ...[
            _buildVoiceSection(),
            const SizedBox(height: AppDimens.SIZE_24),
          ],
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
              divisions: 20,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              onChanged: _updateSpeechRate,
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
              inactiveColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              onChanged: _updateVolume,
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
              divisions: 15,
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              onChanged: _updatePitch,
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
        children: [
          const SizedBox(height: AppDimens.SIZE_8),
          CustomTextLabel(
            '${_availableVoices.length} ${AppLocalizations.current.availableLanguages.toLowerCase()}',
            fontSize: AppDimens.SIZE_12,
            color:
                Theme.of(context).textTheme.bodyMedium?.color ??
                AppColors.colorTitle,
          ),
          const SizedBox(height: AppDimens.SIZE_8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            ),
            child: ListView.separated(
              itemCount:
                  _availableVoices.length > 10 ? 10 : _availableVoices.length,
              separatorBuilder:
                  (context, index) => Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
              itemBuilder: (context, index) {
                final voice = _availableVoices[index];
                final voiceName = voice.toString();

                return ListTile(
                  dense: true,
                  title: CustomTextLabel(
                    voiceName,
                    fontSize: AppDimens.SIZE_14,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        AppColors.colorTitle,
                  ),
                  trailing:
                      _selectedVoice?['name'] == voiceName
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                          : null,
                  onTap: () {
                    // Voice selection logic can be implemented here
                    // _ttsService.setVoice({'name': voiceName});
                  },
                );
              },
            ),
          ),
        ],
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
