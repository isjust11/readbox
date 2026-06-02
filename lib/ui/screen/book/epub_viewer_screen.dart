import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:epub_view/src/data/epub_parser.dart' as epub_parser;
import 'package:epub_view/src/data/models/paragraph.dart';

import 'package:dio/dio.dart';
import 'package:epub_view/epub_view.dart' hide Image;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/constants.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/interaction_type.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/ai_assistant_sheet.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/banner_ad_widget.dart';
import 'package:readbox/ui/widget/popup_ad_widget.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:readbox/utils/tts_lock_screen_controller.dart';
import 'package:share_plus/share_plus.dart';

class EpubViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String? bookId;
  final String? userIdCreate;

  const EpubViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    this.bookId,
    this.userIdCreate,
  });

  @override
  EpubViewerScreenState createState() => EpubViewerScreenState();
}

class EpubViewerScreenState extends State<EpubViewerScreen> {
  late EpubController _epubController;
  bool _isLoading = true;
  String? _error;
  bool _isLocal = false;
  Uint8List? _epubBytes;
  Map<String, bool>? _actionStatus = {};
  bool _isVisibleToolAction = false;
  bool showToolbar = true;
  bool showNavigationBar = true;
  String? actionToolbar = '';

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<EpubSearchResult> _searchResults = [];
  int _currentSearchIndex = -1;
  bool _isSearching = false;
  bool _showSearchResults = false;
  String _searchQuery = '';

  // Cached parsed data for search (populated on document load)
  List<Paragraph> _parsedParagraphs = [];
  List<EpubChapter> _parsedChapters = [];
  List<int> _chapterIndexes = [];

  // TTS related
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isReadingContinuous = false;
  bool _isLoadingText = false;
  final ValueNotifier<(int, int)> _ttsWordProgressNotifier = ValueNotifier((
    0,
    0,
  ));
  final ScrollController _ttsScrollController = ScrollController();
  bool _showTtsReadingPanel = false;
  String? _ttsReadingText;
  int _ttsWordStart = 0;
  int _ttsWordEnd = 0;
  int _currentReadingParagraphIndex = 0;

  final Dio _dio = Dio();
  UserModel? _currentUser;
  late UserSubscriptionModel? _userSubscription;

  bool get isEnableAction => _error == null;

  /// Super Admin luôn có quyền truy cập tính năng nâng cao
  bool get isSuperAdmin =>
      _currentUser?.roles.any(
        (role) =>
            role.code == RoleCode.superAdmin ||
            role.code == RoleCode.supperAdmin,
      ) ??
      false;

  bool get isProPlan => isSuperAdmin || !(_userSubscription?.isFree ?? true);
  bool get isOwner => _currentUser?.id == widget.userIdCreate;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUserDataSettings();
    _initController();
    _initializeTTS();

    context.read<SubscriptionPlanCubit>().checkUsage();
    context.read<SubscriptionPlanCubit>().stream.listen((state) {
      if (state is LoadedState<Map<String, bool>> && mounted) {
        setState(() {
          _actionStatus = state.data;
        });
      }
    });

    if (widget.bookId != null) {
      _loadReadingProgress();
    }
  }

  void _loadCurrentUser() {
    final user = context.read<AppCubit>().getUser();
    if (user != null) {
      _currentUser = user;
    }
  }

  Future<void> _loadUserDataSettings() async {
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    if (mounted) {
      setState(() {
        showNavigationBar = !hideNavigationBar;
      });
    }
  }

  Future<void> _initController() async {
    final file = File(widget.fileUrl);
    _isLocal = await file.exists();

    if (_isLocal) {
      _epubBytes = await file.readAsBytes();
      _epubController = EpubController(
        document: EpubDocument.openData(_epubBytes!),
      );
    } else {
      final String networkUrl;
      if (widget.fileUrl.startsWith('http')) {
        networkUrl = widget.fileUrl;
      } else if (widget.fileUrl.contains('google-drive/download/')) {
        // Google Drive proxy: đi qua API server (port 4000), không phải storage (port 3005)
        networkUrl = '${ApiConstant.apiHost}${widget.fileUrl}';
      } else {
        networkUrl = '${ApiConstant.apiHostStorage}${widget.fileUrl}';
      }

      // Wait, we should download it first if it's network.
      await _downloadAndLoadEpub(networkUrl);
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndLoadEpub(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      _epubBytes = Uint8List.fromList(response.data!);
      _epubController = EpubController(
        document: EpubDocument.openData(_epubBytes!),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _loadReadingProgress() {
    // Implement loading progress if needed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userSubscription = context.watch<UserSubscriptionCubit>().userSubscription;
  }

  @override
  void dispose() {
    // Khi rời màn EPUB, các parser/controller của màn bị dispose nên không thể
    // đọc tiếp paragraph kế. Tắt continuous trước khi stop để callback TTS
    // không publish lại icon "đang đọc" giả.
    _isReadingContinuous = false;
    _ttsService.stop();
    TtsLockScreenController.instance.stop();
    _epubController.dispose();
    _ttsWordProgressNotifier.dispose();
    _ttsScrollController.dispose();
    _searchController.dispose();
    _dio.close();
    super.dispose();
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'ai_assistant':
        if (!isProPlan) {
          PopupAdWidget.showPrompt(context: context, onReward: () {
            AiAssistantSheet.show(context);
          });
          return;
        }
        AiAssistantSheet.show(context);
        break;
      case 'search':
        actionToolbar = 'search';
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        break;
      case 'download':
        if (!isProPlan && !(_actionStatus?['canUseDownload'] ?? false)) {
          PopupAdWidget.showPrompt(context: context, onReward: () {
            _downloadAndSaveEpub();
          });
          return;
        }
        _downloadAndSaveEpub();
        break;
      case 'share':
        _shareEbook();
        break;
      case 'read_continuous_ebook':
        if (!isProPlan) {
          PopupAdWidget.showPrompt(context: context, onReward: () {
            setState(() {
              _isVisibleToolAction = !_isVisibleToolAction;
            });
            actionToolbar = 'read_continuous_ebook';
            _readContinuousEbook();
          });
          return;
        }
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        actionToolbar = 'read_continuous_ebook';
        _readContinuousEbook();
        break;
    }
  }

  Future<void> _downloadAndSaveEpub() async {
    try {
      if (_epubBytes == null) return;

      final Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory(path.join(appDir.path, 'Downloads'));
      }

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = path.basename(widget.fileUrl);
      final file = File(path.join(downloadsDir.path, fileName));
      await file.writeAsBytes(_epubBytes!);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.tools_saved_successfully,
          snackBarType: SnackBarType.success,
        );
      }
      // update interaction action for download
      context.read<UserInteractionCubit>().incrementUsage(
        usage: IncrementUsageModel(downloadCount: 1),
      );
      context.read<UserInteractionCubit>().download(
        targetType: InteractionType.download,
        targetId: widget.bookId,
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.tools_save_failed,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _shareEbook() async {
    try {
      if (_epubBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(widget.fileUrl);
      final tempFile = File(path.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(_epubBytes!);

      await SharePlus.instance.share(
        ShareParams(
          text: AppLocalizations.current.pdf_share_text(widget.title),
          subject: widget.title,
          files: [XFile(tempFile.path)],
        ),
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_share_error(e.toString()),
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _readContinuousEbook() async {
    setState(() {
      _isReadingContinuous = true;
    });
    // Xác định paragraph hiện tại đang hiển thị
    final currentValue = _epubController.currentValue;
    if (currentValue != null) {
      _currentReadingParagraphIndex = currentValue.position.index;
    }
    await _readCurrentParagraph();
  }

  // ====== TTS Logic ======

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    _setupTTSCallbacks();
  }

  void _setupTTSCallbacks() {
    _ttsService.onSpeechStart = (_) {};

    _ttsService.onSpeechWordProgress = (
      String text,
      int start,
      int end,
      String word,
    ) {
      if (!mounted) return;
      _ttsWordStart = start.clamp(0, text.length);
      _ttsWordEnd = end.clamp(0, text.length);
      _ttsWordProgressNotifier.value = (_ttsWordStart, _ttsWordEnd);
      TtsLockScreenController.instance.updateWordProgress(
        fullText: text,
        start: start,
        end: end,
      );
    };

    _ttsService.onSpeechComplete = (_) {
      TtsLockScreenController.instance.markCompleted();
      // Đọc liên tục: chuyển sang paragraph tiếp theo
      if (_isReadingContinuous) {
        _readNextParagraph();
      } else {
        // Hết session → đóng dứt khoát để mini-player ẩn.
        TtsLockScreenController.instance.stop();
        if (mounted) {
          setState(() {
            _showTtsReadingPanel = false;
          });
        }
      }
    };

    _ttsService.onSpeechError = (error) {
      TtsLockScreenController.instance.markError(error);
      // EPUB không skip lỗi tự động → coi như session kết thúc.
      TtsLockScreenController.instance.stop();
      if (mounted) {
        setState(() {
          _isReadingContinuous = false;
          _showTtsReadingPanel = false;
        });
        AppSnackBar.show(
          context,
          message: error,
          snackBarType: SnackBarType.error,
        );
      }
    };

    TtsLockScreenController.instance.onSkipForward = () {
      if (!mounted) return;
      final text = _ttsReadingText ?? '';
      final pos = (_ttsWordStart + 200).clamp(0, text.length);
      if (pos < text.length) {
        _speakFromPosition(_findWordBoundary(text, pos));
      }
    };

    TtsLockScreenController.instance.onSkipBackward = () {
      if (!mounted) return;
      final text = _ttsReadingText ?? '';
      final pos = (_ttsWordStart - 200).clamp(0, text.length);
      _speakFromPosition(_findWordBoundary(text, pos));
    };

    TtsLockScreenController.instance.onRestartPage = () {
      if (!mounted) return;
      _speakFromPosition(0);
    };
  }

  /// Trích xuất plain text từ paragraph element, loại bỏ HTML tags
  String _extractParagraphText(int index) {
    if (index < 0 || index >= _parsedParagraphs.length) return '';
    return _parsedParagraphs[index].element.text.trim();
  }

  /// Lấy tên chapter chứa paragraph tại index
  String _getChapterTitleForParagraph(int index) {
    for (int ci = _chapterIndexes.length - 1; ci >= 0; ci--) {
      if (index >= _chapterIndexes[ci]) {
        if (ci < _parsedChapters.length) {
          return _parsedChapters[ci].Title ?? '';
        }
        break;
      }
    }
    return '';
  }

  /// Kiểm tra paragraph có phải là title/heading không
  bool _isParagraphTitle(int index) {
    if (index < 0 || index >= _parsedParagraphs.length) return false;
    final tagName =
        _parsedParagraphs[index].element.localName?.toLowerCase() ?? '';
    return tagName.startsWith('h');
  }

  /// Đọc paragraph hiện tại
  Future<void> _readCurrentParagraph() async {
    if (!_isReadingContinuous || !mounted) return;
    if (_parsedParagraphs.isEmpty) {
      setState(() => _isReadingContinuous = false);
      return;
    }

    setState(() => _isLoadingText = true);

    // Bỏ qua các paragraph rỗng
    while (_currentReadingParagraphIndex < _parsedParagraphs.length) {
      final text = _extractParagraphText(_currentReadingParagraphIndex);
      if (text.isNotEmpty) break;
      _currentReadingParagraphIndex++;
    }

    if (_currentReadingParagraphIndex >= _parsedParagraphs.length) {
      if (mounted) {
        setState(() {
          _isReadingContinuous = false;
          _isLoadingText = false;
        });
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_document_read_complete,
          snackBarType: SnackBarType.success,
        );
      }
      return;
    }

    // Cuộn đến paragraph đang đọc
    _epubController.scrollTo(index: _currentReadingParagraphIndex);

    final paragraphText = _extractParagraphText(_currentReadingParagraphIndex);

    try {
      await _ttsService.setLanguageFromText(paragraphText);

      if (mounted) {
        setState(() {
          _ttsReadingText = paragraphText;
          _ttsWordStart = 0;
          _ttsWordEnd = 0;
          _isLoadingText = false;
        });
      }

      final chapterTitle = _getChapterTitleForParagraph(
        _currentReadingParagraphIndex,
      );
      await TtsLockScreenController.instance.startReadingSession(
        bookTitle: widget.title,
        page: _currentReadingParagraphIndex + 1,
        text: '$chapterTitle\n$paragraphText',
        bookId: widget.bookId,
      );

      await _ttsService.speak(paragraphText);

      // Cập nhật tương tác TTS
      if (mounted) {
        context.read<UserInteractionCubit>().incrementUsage(
          usage: IncrementUsageModel(ttsCount: paragraphText.length),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingText = false);
      // Paragraph lỗi → chuyển sang paragraph tiếp
      if (_currentReadingParagraphIndex < _parsedParagraphs.length - 1) {
        _readNextParagraph();
      } else {
        if (mounted) setState(() => _isReadingContinuous = false);
      }
    }
  }

  /// Chuyển sang đọc paragraph tiếp theo, có delay ngắt quãng giữa title/paragraph
  Future<void> _readNextParagraph() async {
    if (!mounted || !_isReadingContinuous) return;

    _currentReadingParagraphIndex++;

    if (_currentReadingParagraphIndex >= _parsedParagraphs.length) {
      await TtsLockScreenController.instance.stop();
      if (mounted) {
        setState(() => _isReadingContinuous = false);
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_document_read_complete,
          snackBarType: SnackBarType.success,
        );
      }
      return;
    }

    // Ngắt quãng giữa các paragraph: title thì pause lâu hơn
    final isTitle = _isParagraphTitle(_currentReadingParagraphIndex);
    final pauseDuration =
        isTitle
            ? const Duration(milliseconds: 800)
            : const Duration(milliseconds: 400);
    await Future.delayed(pauseDuration);

    if (!mounted || !_isReadingContinuous) return;

    await _readCurrentParagraph();
  }

  /// Đọc từ vị trí ký tự cụ thể trong paragraph hiện tại
  Future<void> _speakFromPosition(int charOffset) async {
    final text = _ttsReadingText;
    if (text == null || text.isEmpty) return;

    final offset = charOffset.clamp(0, text.length);
    await _ttsService.stop();

    if (offset >= text.length) return;

    final subText = text.substring(offset);
    if (subText.trim().isEmpty) return;

    _ttsWordStart = offset;
    _ttsWordEnd = offset;
    _ttsWordProgressNotifier.value = (offset, offset);
    setState(() => _isReadingContinuous = true);

    final originalHandler = _ttsService.onSpeechWordProgress;
    _ttsService.onSpeechWordProgress = (
      String t,
      int start,
      int end,
      String word,
    ) {
      if (!mounted) return;
      final realStart = start + offset;
      final realEnd = end + offset;
      _ttsWordStart = realStart.clamp(0, text.length);
      _ttsWordEnd = realEnd.clamp(0, text.length);
      _ttsWordProgressNotifier.value = (_ttsWordStart, _ttsWordEnd);
      TtsLockScreenController.instance.updateWordProgress(
        fullText: text,
        start: realStart,
        end: realEnd,
      );
    };

    final originalComplete = _ttsService.onSpeechComplete;
    _ttsService.onSpeechComplete = (msg) {
      _ttsService.onSpeechWordProgress = originalHandler;
      _ttsService.onSpeechComplete = originalComplete;
      originalComplete?.call(msg);
    };

    await _ttsService.speak(subText);
  }

  int _findWordBoundary(String text, int pos) {
    if (pos <= 0) return 0;
    if (pos >= text.length) return text.length;
    var p = pos;
    while (p > 0 && text[p - 1] != ' ' && text[p - 1] != '\n') {
      p--;
    }
    return p;
  }

  void _handleAutoScroll(int start, String text, BoxConstraints constraints) {
    if (!_ttsScrollController.hasClients) return;

    final textStyle = TextStyle(fontSize: 15, height: 1.6, color: Colors.black);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: constraints.maxWidth - 32);

    final offset = textPainter.getOffsetForCaret(
      TextPosition(offset: start),
      Rect.zero,
    );

    final currentScroll = _ttsScrollController.offset;
    final viewportHeight = constraints.maxHeight;

    if (offset.dy < currentScroll + 20 ||
        offset.dy > currentScroll + viewportHeight - 60) {
      final targetScroll = (offset.dy - 40).clamp(
        0.0,
        _ttsScrollController.position.maxScrollExtent,
      );

      _ttsScrollController.animateTo(
        targetScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _isVisibleToolAction ? _buildToolAppBar() : _buildDefaultAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        EpubView(
                          controller: _epubController,
                          onDocumentLoaded: _onDocumentLoaded,
                          onExternalLinkPressed: (link) {},
                          builders: EpubViewBuilders<DefaultBuilderOptions>(
                            options: const DefaultBuilderOptions(),
                            chapterBuilder: _buildChapterWithHighlight,
                          ),
                        ),
                        // Search results overlay
                        if (_showSearchResults && _searchResults.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, -4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${_searchResults.length} ${AppLocalizations.current.found}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(
                                              () => _showSearchResults = false,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Flexible(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: _searchResults.length,
                                      itemBuilder: (context, index) {
                                        final result = _searchResults[index];
                                        final isActive =
                                            index == _currentSearchIndex;
                                        return ListTile(
                                          dense: true,
                                          selected: isActive,
                                          selectedTileColor: theme.primaryColor
                                              .withValues(alpha: 0.1),
                                          leading: Icon(
                                            Icons.format_quote_rounded,
                                            size: 18,
                                            color:
                                                isActive
                                                    ? theme.primaryColor
                                                    : theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.5),
                                          ),
                                          title: RichText(
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            text: _buildHighlightedSpan(
                                              result.matchText,
                                              _searchQuery,
                                              TextStyle(
                                                fontSize: 13,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                          subtitle:
                                              result.chapterTitle.isNotEmpty
                                                  ? Text(
                                                    result.chapterTitle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: theme
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                    ),
                                                  )
                                                  : null,
                                          onTap:
                                              () =>
                                                  _scrollToSearchResult(index),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // No results message
                        if (_showSearchResults &&
                            _searchResults.isEmpty &&
                            !_isSearching &&
                            _searchController.text.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                AppLocalizations.current.no_book_found,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // TTS loading overlay
                        if (_isLoadingText)
                          Container(
                            color: Colors.black45,
                            child: Center(
                              child:
                                  Platform.isIOS
                                      ? CupertinoActivityIndicator()
                                      : CircularProgressIndicator(),
                            ),
                          ),
                        // Panel hiển thị text đang đọc (TTS)
                        if (_showTtsReadingPanel && _ttsReadingText != null)
                          _buildTtsReadingPanel(),
                      ],
                    ),
                  ),
                  const BannerAdWidget(),
                ],
              ),
    );
  }

  void _onDocumentLoaded(EpubBook document) {
    // Parse and cache chapters/paragraphs for search
    _parsedChapters = epub_parser.parseChapters(document);
    final parseResult = epub_parser.parseParagraphs(
      _parsedChapters,
      document.Content,
    );
    _parsedParagraphs = parseResult.flatParagraphs;
    _chapterIndexes = parseResult.chapterIndexes;
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(widget.title, style: const TextStyle(fontSize: 16)),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder:
              (context) => [
                _buildMenuItem(
                  'ai_assistant',
                  Icons.auto_awesome,
                  AppLocalizations.current.ai_assistant,
                  Colors.purple,
                  isPro: true,
                ),
                _buildMenuItem(
                  'search',
                  Icons.search,
                  AppLocalizations.current.search,
                  Colors.blue,
                ),
                _buildMenuItem(
                  'read_continuous_ebook',
                  Icons.record_voice_over,
                  AppLocalizations.current.pdf_read_ebook,
                  Colors.orange,
                  isPro: true,
                ),
                if (isOwner || _isLocal)
                  _buildMenuItem(
                    'share',
                    Icons.share_rounded,
                    AppLocalizations.current.pdf_share,
                    Colors.blue,
                    isEnabled: _actionStatus?['canUseShare'] ?? false,
                  )
                else
                  _buildMenuItem(
                    'download',
                    Icons.download_rounded,
                    AppLocalizations.current.download,
                    Colors.green,
                    isEnabled: _actionStatus?['canUseDownload'] ?? false,
                  ),
              ],
        ),
      ],
    );
  }

  AppBar _buildToolAppBar() {
    if (actionToolbar == 'read_continuous_ebook') {
      return _buildTtsToolAppBar();
    }

    final total = _searchResults.length;
    final current = _currentSearchIndex + 1;
    final canPrev = total > 0 && _currentSearchIndex > 0;
    final canNext = total > 0 && _currentSearchIndex < total - 1;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _clearSearch,
      ),
      title:
          actionToolbar == 'search'
              ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: AppLocalizations.current.search,
                  border: InputBorder.none,
                  suffixIcon:
                      _isSearching
                          ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  Platform.isIOS
                                      ? CupertinoActivityIndicator()
                                      : CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                            ),
                          )
                          : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed:
                                () => _searchEpub(_searchController.text),
                          ),
                ),
                onSubmitted: _searchEpub,
              )
              : Text(widget.title),
      actions:
          actionToolbar == 'search' && total > 0
              ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$current/$total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: canPrev ? null : Colors.grey,
                  ),
                  onPressed: canPrev ? _previousResult : null,
                ),
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: canNext ? null : Colors.grey,
                  ),
                  onPressed: canNext ? _nextResult : null,
                ),
                IconButton(
                  icon: Icon(
                    _showSearchResults ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() => _showSearchResults = !_showSearchResults);
                  },
                ),
              ]
              : null,
    );
  }

  AppBar _buildTtsToolAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () async {
          await _ttsService.stop();
          await TtsLockScreenController.instance.stop();
          setState(() {
            _isReadingContinuous = false;
            _showTtsReadingPanel = false;
            _isVisibleToolAction = false;
          });
        },
      ),
      title: Text(
        AppLocalizations.current.pdf_read_ebook,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isReadingContinuous
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            color: _isReadingContinuous ? Colors.red : null,
          ),
          onPressed: () async {
            if (_isReadingContinuous) {
              await _ttsService.stop();
              await TtsLockScreenController.instance.stop();
              setState(() {
                _isReadingContinuous = false;
              });
            } else {
              await _readContinuousEbook();
            }
          },
        ),
        IconButton(
          icon: Icon(
            _showTtsReadingPanel
                ? Icons.voice_over_off
                : Icons.record_voice_over_outlined,
          ),
          onPressed: () {
            setState(() {
              _showTtsReadingPanel = !_showTtsReadingPanel;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            if (_isReadingContinuous) {
              await _ttsService.stop();
              await TtsLockScreenController.instance.stop();
              setState(() {
                _isReadingContinuous = false;
                _showTtsReadingPanel = false;
              });
            }
            if (mounted) {
              Navigator.of(context).pushNamed(Routes.textToSpeechSettingScreen);
            }
          },
        ),
      ],
    );
  }

  // ====== Search Logic ======

  void _searchEpub(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
      _currentSearchIndex = -1;
      _showSearchResults = true;
      _searchQuery = query.trim();
    });

    final lowerQuery = query.toLowerCase();
    final results = <EpubSearchResult>[];

    for (int i = 0; i < _parsedParagraphs.length; i++) {
      final text = _parsedParagraphs[i].element.text;
      if (text.toLowerCase().contains(lowerQuery)) {
        // Determine chapter name
        String chapterTitle = '';
        for (int ci = _chapterIndexes.length - 1; ci >= 0; ci--) {
          if (i >= _chapterIndexes[ci]) {
            if (ci < _parsedChapters.length) {
              chapterTitle = _parsedChapters[ci].Title ?? '';
            }
            break;
          }
        }

        results.add(
          EpubSearchResult(
            paragraphIndex: i,
            matchText: text,
            chapterTitle: chapterTitle,
          ),
        );
      }
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
      if (results.isNotEmpty) {
        _currentSearchIndex = 0;
        _scrollToSearchResult(0);
      }
    });
  }

  void _scrollToSearchResult(int index) {
    if (index < 0 || index >= _searchResults.length) return;
    final result = _searchResults[index];
    _epubController.scrollTo(index: result.paragraphIndex);
    setState(() => _currentSearchIndex = index);
  }

  void _nextResult() {
    if (_currentSearchIndex < _searchResults.length - 1) {
      _scrollToSearchResult(_currentSearchIndex + 1);
    }
  }

  void _previousResult() {
    if (_currentSearchIndex > 0) {
      _scrollToSearchResult(_currentSearchIndex - 1);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    // Dừng TTS nếu đang đọc
    if (_isReadingContinuous) {
      _ttsService.stop();
      TtsLockScreenController.instance.stop();
    }
    setState(() {
      _searchResults = [];
      _currentSearchIndex = -1;
      _isSearching = false;
      _showSearchResults = false;
      _isVisibleToolAction = false;
      _searchQuery = '';
      _isReadingContinuous = false;
      _showTtsReadingPanel = false;
    });
  }

  // ====== Custom Chapter Builder with Search Highlight ======

  Widget _buildChapterWithHighlight(
    BuildContext context,
    EpubViewBuilders builders,
    EpubBook document,
    List<EpubChapter> chapters,
    List<Paragraph> paragraphs,
    int index,
    int chapterIndex,
    int paragraphIndex,
    ExternalLinkPressed onExternalLinkPressed,
  ) {
    if (paragraphs.isEmpty) return Container();

    final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;

    // Paragraph đang được TTS đọc → dùng RichText + ValueListenableBuilder
    // để highlight từ đang đọc real-time
    final isTtsActive =
        _isReadingContinuous && index == _currentReadingParagraphIndex;

    if (isTtsActive) {
      final plainText = paragraphs[index].element.text.trim();
      return Column(
        children: <Widget>[
          if (chapterIndex >= 0 && paragraphIndex == 0)
            builders.chapterDividerBuilder(chapters[chapterIndex]),
          ValueListenableBuilder<(int, int)>(
            valueListenable: _ttsWordProgressNotifier,
            builder: (context, progressValue, _) {
              final textLen = plainText.length;
              final start = progressValue.$1.clamp(0, textLen);
              final end = progressValue.$2.clamp(0, textLen);
              final hasHighlight = start < end;
              final theme = Theme.of(context);

              return Padding(
                padding:
                    options.paragraphPadding as EdgeInsets? ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: RichText(
                  text: TextSpan(
                    style: options.textStyle.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    children: [
                      if (start > 0)
                        TextSpan(text: plainText.substring(0, start)),
                      if (hasHighlight)
                        TextSpan(
                          text: plainText.substring(start, end),
                          style: TextStyle(
                            backgroundColor: theme.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                        ),
                      if (end < textLen)
                        TextSpan(text: plainText.substring(end)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    }

    // Paragraph thông thường → render HTML (có thể có search highlight)
    String htmlData = paragraphs[index].element.outerHtml;

    // Inject highlight <mark> tags around matched query text
    if (_searchQuery.isNotEmpty) {
      htmlData = _highlightHtml(htmlData, _searchQuery);
    }

    return Column(
      children: <Widget>[
        if (chapterIndex >= 0 && paragraphIndex == 0)
          builders.chapterDividerBuilder(chapters[chapterIndex]),
        Html(
          data: htmlData,
          onLinkTap: (href, _, __) => onExternalLinkPressed(href!),
          style: {
            'html': Style(
              padding: HtmlPaddings.only(
                top: (options.paragraphPadding as EdgeInsets?)?.top,
                right: (options.paragraphPadding as EdgeInsets?)?.right,
                bottom: (options.paragraphPadding as EdgeInsets?)?.bottom,
                left: (options.paragraphPadding as EdgeInsets?)?.left,
              ),
            ).merge(Style.fromTextStyle(options.textStyle)),
            'mark': Style(
              backgroundColor: Colors.yellow.withValues(alpha: 0.6),
              color: Colors.black,
              padding: HtmlPaddings.symmetric(horizontal: 2),
            ),
          },
          extensions: [
            TagExtension(
              tagsToExtend: {"img"},
              builder: (imageContext) {
                final url = imageContext.attributes['src']!.replaceAll(
                  '../',
                  '',
                );
                final content = Uint8List.fromList(
                  document.Content!.Images![url]!.Content!,
                );
                return Image(image: MemoryImage(content));
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Highlights all occurrences of [query] inside the text content of [html]
  /// by wrapping them in <mark> tags, while preserving HTML tags.
  String _highlightHtml(String html, String query) {
    // Escape special regex characters in the query
    final escapedQuery = RegExp.escape(query);
    // Match text outside of HTML tags and wrap matches in <mark>
    final result = StringBuffer();
    final tagRegex = RegExp(r'(<[^>]*>)');
    final parts = html.split(tagRegex);

    for (final part in parts) {
      if (part.startsWith('<') && part.endsWith('>')) {
        // This is an HTML tag — keep it as-is
        result.write(part);
      } else {
        // This is text content — highlight matches
        result.write(
          part.replaceAllMapped(
            RegExp(escapedQuery, caseSensitive: false),
            (match) => '<mark>${match.group(0)}</mark>',
          ),
        );
      }
    }

    return result.toString();
  }

  /// Builds a TextSpan with highlighted occurrences of [query] in [text]
  TextSpan _buildHighlightedSpan(
    String text,
    String query,
    TextStyle baseStyle,
  ) {
    if (query.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: baseStyle.copyWith(
            backgroundColor: Colors.yellow.withValues(alpha: 0.6),
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = index + query.length;
    }

    return TextSpan(children: spans);
  }

  /// Panel hiển thị text đang đọc với từ đang đọc được đánh dấu
  Widget _buildTtsReadingPanel() {
    final text = _ttsReadingText ?? '';
    final len = text.length;
    final theme = Theme.of(context);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ValueListenableBuilder<(int, int)>(
            valueListenable: _ttsWordProgressNotifier,
            builder: (context, progressValue, child) {
              final start = progressValue.$1.clamp(0, len);
              final end = progressValue.$2.clamp(0, len);
              final hasHighlight = start < end;
              final progress = len > 0 ? start / len : 0.0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.record_voice_over,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getChapterTitleForParagraph(
                                  _currentReadingParagraphIndex,
                                ).isNotEmpty
                                ? _getChapterTitleForParagraph(
                                  _currentReadingParagraphIndex,
                                )
                                : AppLocalizations.current.pdf_read_ebook,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        if (len > 0)
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.primaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed:
                              () =>
                                  setState(() => _showTtsReadingPanel = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar
                  if (len > 0)
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: theme.primaryColor,
                        inactiveTrackColor: theme.primaryColor.withValues(
                          alpha: 0.15,
                        ),
                        thumbColor: theme.primaryColor,
                      ),
                      child: Slider(
                        value: start.toDouble(),
                        min: 0,
                        max: len.toDouble(),
                        onChanged: (value) {
                          final pos = _findWordBoundary(text, value.toInt());
                          _speakFromPosition(pos);
                        },
                      ),
                    ),

                  // Control buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTtsControlButton(
                          icon: Icons.restart_alt_rounded,
                          label: AppLocalizations.current.start,
                          onTap: () => _speakFromPosition(0),
                        ),
                        _buildTtsControlButton(
                          icon: Icons.replay_10_rounded,
                          label: '-200',
                          onTap: () {
                            final pos = (start - 200).clamp(0, len);
                            _speakFromPosition(_findWordBoundary(text, pos));
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                _isReadingContinuous
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : theme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isReadingContinuous
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color:
                                  _isReadingContinuous
                                      ? Colors.red
                                      : theme.primaryColor,
                              size: 28,
                            ),
                            onPressed: () async {
                              if (_isReadingContinuous) {
                                await _ttsService.stop();
                                setState(() => _isReadingContinuous = false);
                              } else {
                                _speakFromPosition(start);
                              }
                            },
                          ),
                        ),
                        _buildTtsControlButton(
                          icon: Icons.forward_10_rounded,
                          label: '+200',
                          onTap: () {
                            final pos = (start + 200).clamp(0, len);
                            if (pos < len) {
                              _speakFromPosition(_findWordBoundary(text, pos));
                            }
                          },
                        ),
                        _buildTtsControlButton(
                          icon: Icons.skip_next_rounded,
                          label: AppLocalizations.current.next,
                          onTap: () {
                            if (_currentReadingParagraphIndex <
                                _parsedParagraphs.length - 1) {
                              _readNextParagraph();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Text content
                  Flexible(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Tự động cuộn theo từ đang đọc
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _handleAutoScroll(start, text, constraints);
                        });

                        return SingleChildScrollView(
                          controller: _ttsScrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: RichText(
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: theme.colorScheme.onSurface,
                              ),
                              children: [
                                if (start > 0)
                                  TextSpan(
                                    text: text.substring(0, start),
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                if (hasHighlight)
                                  TextSpan(
                                    text: text.substring(start, end),
                                    style: TextStyle(
                                      backgroundColor: theme.primaryColor
                                          .withValues(alpha: 0.3),
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                if (end < len)
                                  TextSpan(text: text.substring(end)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTtsControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color color, {
    bool? isEnabled = true,
    bool? isPro = false,
  }) {
    Color iconColor = color;
    if (value == 'read_continuous_ebook' && _isReadingContinuous) {
      iconColor = Colors.red;
    }
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isEnabled == true ? iconColor : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isEnabled == true ? null : Colors.grey),
          ),
          if (isPro == true && !isProPlan) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.current.pro,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EpubSearchResult {
  final int paragraphIndex;
  final String matchText;
  final String chapterTitle;

  const EpubSearchResult({
    required this.paragraphIndex,
    required this.matchText,
    required this.chapterTitle,
  });
}
