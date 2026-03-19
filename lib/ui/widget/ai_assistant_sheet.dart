import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readbox/domain/repositories/ai_repository.dart';

/// Ngôn ngữ hỗ trợ dịch thuật
const _supportedLanguages = [
  ('🇻🇳 Tiếng Việt', 'vi'),
  ('🇺🇸 English', 'en'),
  ('🇯🇵 日本語', 'ja'),
  ('🇨🇳 中文', 'zh'),
  ('🇰🇷 한국어', 'ko'),
  ('🇫🇷 Français', 'fr'),
  ('🇩🇪 Deutsch', 'de'),
  ('🇪🇸 Español', 'es'),
  ('🇷🇺 Русский', 'ru'),
];

/// Bottom sheet AI Tra cứu & Dịch thuật
/// Dùng: AiAssistantSheet.show(context, selectedText: text)
class AiAssistantSheet extends StatefulWidget {
  final String? initialText;

  const AiAssistantSheet({super.key, this.initialText});

  static Future<void> show(BuildContext context, {String? selectedText}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAssistantSheet(initialText: selectedText),
    );
  }

  @override
  State<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends State<AiAssistantSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _aiRepo = AiRepository();

  // Lookup state
  final _lookupController = TextEditingController();
  String _lookupLang = 'vi';
  String? _lookupResult;
  bool _lookupLoading = false;
  String? _lookupError;

  // Translate state
  final _translateController = TextEditingController();
  String _translateTargetLang = 'en';
  String? _translateResult;
  bool _translateLoading = false;
  String? _translateError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      final text = widget.initialText!.trim();
      _lookupController.text = text;
      _translateController.text = text;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lookupController.dispose();
    _translateController.dispose();
    super.dispose();
  }

  Future<void> _doLookup() async {
    final query = _lookupController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _lookupLoading = true;
      _lookupResult = null;
      _lookupError = null;
    });
    try {
      final result = await _aiRepo.lookup(query: query, language: _lookupLang);
      if (mounted) setState(() => _lookupResult = result);
    } catch (e) {
      if (mounted) setState(() => _lookupError = e.toString());
    } finally {
      if (mounted) setState(() => _lookupLoading = false);
    }
  }

  Future<void> _doTranslate() async {
    final text = _translateController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _translateLoading = true;
      _translateResult = null;
      _translateError = null;
    });
    try {
      final result = await _aiRepo.translate(
        text: text,
        targetLanguage: _translateTargetLang,
      );
      if (mounted) setState(() => _translateResult = result);
    } catch (e) {
      if (mounted) setState(() => _translateError = e.toString());
    } finally {
      if (mounted) setState(() => _translateLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: screenHeight * 0.82,
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLookupTab(theme), _buildTranslateTab(theme)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Powered by Gemini',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            iconSize: 22,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.search_rounded, size: 16), text: 'Tra cứu'),
          Tab(
            icon: Icon(Icons.translate_rounded, size: 16),
            text: 'Dịch thuật',
          ),
        ],
      ),
    );
  }

  // ===================== LOOKUP TAB =====================
  Widget _buildLookupTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Input field
          TextField(
            controller: _lookupController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: 'Từ hoặc khái niệm cần tra cứu',
              hintText: 'Nhập từ, câu hoặc câu hỏi...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
              suffixIcon:
                  _lookupController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _lookupController.clear();
                          setState(() {
                            _lookupResult = null;
                            _lookupError = null;
                          });
                        },
                      )
                      : null,
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _doLookup(),
          ),
          const SizedBox(height: 12),
          // Language selector
          Row(
            children: [
              Text(
                'Ngôn ngữ trả lời:',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              _buildLanguageChips(
                selected: _lookupLang,
                langs: [('Tiếng Việt', 'vi'), ('English', 'en')],
                onSelected: (v) => setState(() => _lookupLang = v),
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _lookupLoading ? null : _doLookup,
              icon:
                  _lookupLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                _lookupLoading ? 'Đang tra cứu...' : 'Tra cứu với AI',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Result
          if (_lookupError != null) _buildErrorCard(_lookupError!),
          if (_lookupResult != null) _buildResultCard(_lookupResult!, theme),
        ],
      ),
    );
  }

  // ===================== TRANSLATE TAB =====================
  Widget _buildTranslateTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Input field
          TextField(
            controller: _translateController,
            maxLines: 5,
            minLines: 2,
            decoration: InputDecoration(
              labelText: 'Văn bản cần dịch',
              hintText: 'Nhập hoặc dán văn bản...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 60),
                child: Icon(Icons.translate_rounded, color: theme.primaryColor),
              ),
              suffixIcon:
                  _translateController.text.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(bottom: 60),
                        child: IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _translateController.clear();
                            setState(() {
                              _translateResult = null;
                              _translateError = null;
                            });
                          },
                        ),
                      )
                      : null,
              filled: true,
              fillColor: Colors.grey[50],
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Target language
          Text(
            'Dịch sang:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children:
                _supportedLanguages.map((lang) {
                  final isSelected = _translateTargetLang == lang.$2;
                  return GestureDetector(
                    onTap: () => setState(() => _translateTargetLang = lang.$2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? theme.primaryColor : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? theme.primaryColor
                                  : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        lang.$1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _translateLoading ? null : _doTranslate,
              icon:
                  _translateLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.translate_rounded, size: 18),
              label: Text(_translateLoading ? 'Đang dịch...' : 'Dịch với AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Result
          if (_translateError != null) _buildErrorCard(_translateError!),
          if (_translateResult != null)
            _buildResultCard(_translateResult!, theme),
        ],
      ),
    );
  }

  // ===================== SHARED WIDGETS =====================

  Widget _buildLanguageChips({
    required String selected,
    required List<(String, String)> langs,
    required void Function(String) onSelected,
    required ThemeData theme,
  }) {
    return Row(
      children:
          langs.map((lang) {
            final isSelected = selected == lang.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => onSelected(lang.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? theme.primaryColor : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    lang.$1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Có lỗi xảy ra: $error',
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String result, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: theme.primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Kết quả từ Gemini AI',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép kết quả'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: theme.primaryColor,
                ),
                tooltip: 'Sao chép',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
          const Divider(height: 16),
          // Result text - selectable
          SelectableText(
            result,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
