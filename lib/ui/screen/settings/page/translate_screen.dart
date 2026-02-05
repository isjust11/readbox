import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isLoading = true;
  List<dynamic> _availableLanguages = [];
  String _currentLanguage = '';

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
      final languages = await _ttsService.getLanguages();
      
      setState(() {
        _availableLanguages = languages;
        _currentLanguage = _ttsService.language;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _changeLanguage(String language) async {
    try {
      await _ttsService.setLanguage(language);
      setState(() {
        _currentLanguage = language;
      });
      _showSuccess(AppLocalizations.current.languageChanged);
    } catch (e) {
      _showError(AppLocalizations.current.errorChangingLanguage);
    }
  }

  String _getLanguageDisplayName(String langCode) {
    // Map common language codes to display names
    final Map<String, String> languageNames = {
      'vi-VN': 'Tiếng Việt',
      'vi': 'Tiếng Việt',
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'en': 'English',
      'ja-JP': '日本語',
      'ja': '日本語',
      'ko-KR': '한국어',
      'ko': '한국어',
      'zh-CN': '中文 (简体)',
      'zh-TW': '中文 (繁體)',
      'zh': '中文',
      'fr-FR': 'Français',
      'fr': 'Français',
      'de-DE': 'Deutsch',
      'de': 'Deutsch',
      'es-ES': 'Español',
      'es': 'Español',
      'it-IT': 'Italiano',
      'it': 'Italiano',
      'pt-BR': 'Português (Brasil)',
      'pt': 'Português',
      'ru-RU': 'Русский',
      'ru': 'Русский',
      'ar': 'العربية',
      'hi-IN': 'हिन्दी',
      'hi': 'हिन्दी',
      'th-TH': 'ไทย',
      'th': 'ไทย',
    };

    return languageNames[langCode] ?? langCode;
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
      title: AppLocalizations.current.ttsLanguageSettings ,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            CustomTextLabel(
              AppLocalizations.current.initializingTTS,
              fontSize: AppDimens.SIZE_14,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
            ),
          ],
        ),
      );
    }

    if (_availableLanguages.isEmpty) {
      return Center(
        child: CustomTextLabel(
          AppLocalizations.current.noLanguagesAvailable,
          fontSize: AppDimens.SIZE_16,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentLanguageCard(),
          const SizedBox(height: AppDimens.SIZE_24),
          _buildSectionTitle(AppLocalizations.current.availableLanguages),
          const SizedBox(height: AppDimens.SIZE_12),
          _buildLanguageList(),
        ],
      ),
    );
  }

  Widget _buildCurrentLanguageCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: AppDimens.SIZE_24,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_12),
              Expanded(
                child: CustomTextLabel(
                  AppLocalizations.current.currentLanguage,
                  fontSize: AppDimens.SIZE_14,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          CustomTextLabel(
            _getLanguageDisplayName(_currentLanguage),
            fontSize: AppDimens.SIZE_24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: AppDimens.SIZE_4),
          CustomTextLabel(
            _currentLanguage,
            fontSize: AppDimens.SIZE_14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CustomTextLabel(
      title,
      fontSize: AppDimens.SIZE_18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
    );
  }

  Widget _buildLanguageList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _availableLanguages.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          indent: AppDimens.SIZE_16,
          endIndent: AppDimens.SIZE_16,
        ),
        itemBuilder: (context, index) {
          final language = _availableLanguages[index].toString();
          final isSelected = language == _currentLanguage;

          return InkWell(
            onTap: () => _changeLanguage(language),
            borderRadius: BorderRadius.circular(
              index == 0
                  ? AppDimens.SIZE_12
                  : (index == _availableLanguages.length - 1
                      ? AppDimens.SIZE_12
                      : 0),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_16,
                vertical: AppDimens.SIZE_16,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.SIZE_8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
                    ),
                    child: Icon(
                      Icons.translate,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      size: AppDimens.SIZE_20,
                    ),
                  ),
                  const SizedBox(width: AppDimens.SIZE_16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextLabel(
                          _getLanguageDisplayName(language),
                          fontSize: AppDimens.SIZE_16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
                        ),
                        const SizedBox(height: 2),
                        CustomTextLabel(
                          language,
                          fontSize: AppDimens.SIZE_12,
                          color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(AppDimens.SIZE_6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: AppDimens.SIZE_16,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
