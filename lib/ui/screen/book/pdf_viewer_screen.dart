import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/constants.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/pdf_cache_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/pdf_text_extractor.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:readbox/utils/tts_lock_screen_controller.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:readbox/ui/widget/ai_assistant_sheet.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readbox/ui/widget/banner_ad_widget.dart';
import 'package:readbox/ui/widget/popup_ad_widget.dart';

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String? bookId;
  final String? userIdCreate;
  final String? thumbnailUrl;

  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    this.bookId,
    this.userIdCreate,
    this.thumbnailUrl,
  });

  @override
  PdfViewerScreenState createState() => PdfViewerScreenState();
}

class PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  late File _localFile; // Cache File object, tránh tạo mới mỗi lần rebuild
  final TextEditingController _searchQueryController = TextEditingController();
  bool _isLoading = true;
  bool _isLoadingText = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLocal = false;
  Uint8List? _pdfBytes;
  Map<String, bool>? _actionStatus = {};
  bool _isVisibleToolAction = false;
  PdfTextSearchResult? _searchResult;
  VoidCallback? _searchResultListener;
  bool showToolbar = true;
  bool showNavigationBar = true;
  String? actionToolbar = '';
  PdfScrollDirection _pdfScrollDirection = PdfScrollDirection.vertical;

  /// Tắt CircularProgressIndicator nội bộ của Syncfusion; dùng overlay Cupertino khi đổi trang.
  Timer? _pageLoadingTimer;
  bool _showPageCupertinoLoading = false;
  // Text selection & TTS
  String? _selectedText;
  final TextToSpeechService _ttsService = TextToSpeechService();
  final Dio _dio = Dio(); // Singleton Dio, tránh tạo mới mỗi lần download
  bool _isReadingContinuous = false;
  bool _isReadingNextPage = false;
  Timer? _ttsProgressTimer;
  bool _hasInternet = false;
  StreamSubscription?
  _subscriptionPlanStream; // Cancel trong dispose() tránh memory leak
  // Đánh dấu từ đang đọc (TTS word progress)
  String? _ttsReadingText;
  int _ttsWordStart = 0;
  int _ttsWordEnd = 0;
  // ValueNotifier cho TTS word progress → chỉ rebuild TTS panel, không rebuild toàn màn hình
  final ValueNotifier<(int, int)> _ttsWordProgressNotifier = ValueNotifier((
    0,
    0,
  ));
  final ScrollController _ttsScrollController = ScrollController();
  bool _showTtsReadingPanel = false;
  // Đánh dấu trực tiếp lên trang PDF (word bounds + annotation)
  PageTextWithBounds? _currentPageWordBounds;
  HighlightAnnotation? _ttsCurrentWordAnnotation;

  // Reading progress tracking (server side)
  UserInteractionCubit? _userInteractionCubit;
  Timer? _saveProgressTimer;
  int _lastSavedPage = 0;
  ReadingProgressModel? _currentProgress;

  // Reading time tracking
  DateTime? _readingStartTime;
  int _accumulatedReadingTime = 0;
  Timer? _readingTimeTimer;

  bool get isEnableAction => _error == null;
  UserModel? _currentUser;
  late UserSubscriptionModel? _userSubscription;

  // ── Performance monitoring (chỉ chạy ở debug/profile mode) ──
  late final DateTime _screenOpenTime;
  Timer? _memoryMonitorTimer;
  int _wordHighlightCount = 0;
  final ValueNotifier<String?> _selectedTextNotifier = ValueNotifier(null);
  // ValueNotifier cho (currentPage, totalPages) → tránh rebuild Scaffold mỗi lần cuộn trang
  late ValueNotifier<(int, int)> _pageStateNotifier;

  void _startPerfMonitors() {
    // Memory log mỗi 5 giây
    _memoryMonitorTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final rss = ProcessInfo.currentRss;
      dev.log(
        'Memory RSS: ${(rss / 1024 / 1024).toStringAsFixed(1)} MB',
        name: 'PdfMemory',
      );
    });
    // FPS monitor đã bỏ: addPersistentFrameCallback không thể gỡ bỏ,
    // gây leak callback mỗi lần mở screen. Dùng Flutter DevTools thay thế.
  }

  /// Super Admin luôn có quyền truy cập tính năng nâng cao
  bool get isSuperAdmin =>
      _currentUser?.roles.any(
        (role) =>
            role.code == RoleCode.superAdmin ||
            role.code == RoleCode.supperAdmin,
      ) ??
      false;

  bool get isProPlan => isSuperAdmin || !(_userSubscription?.isFree ?? true);
  @override
  void initState() {
    super.initState();
    _screenOpenTime = DateTime.now();
    _pageStateNotifier = ValueNotifier((1, 0));
    if (kDebugMode || kProfileMode) _startPerfMonitors();
    _loadCurrentUser();
    _checkInternetConnection();
    context.read<SubscriptionPlanCubit>().checkUsage();
    _subscriptionPlanStream = context
        .read<SubscriptionPlanCubit>()
        .stream
        .listen((state) {
          if (state is LoadedState<Map<String, bool>>) {
            setState(() {
              _actionStatus = state.data;
            });
          }
        });
    _checkCacheAndInit();

    _loadUserDataSettings();
    _initializeTTS();
    // Optional reading progress (only when bookId + cubit available)
    try {
      _userInteractionCubit = context.read<UserInteractionCubit>();
      if (widget.bookId != null) {
        _loadReadingProgress();
      }
    } catch (_) {
      // Không có UserInteractionCubit trong context => bỏ qua tracking server
    }

    // _pdfBytes được lazy-load khi user bắt đầu TTS (không load sẵn để tránh block main thread)

    // Tải và hiển thị quảng cáo toàn màn hình sau một khoảng delay (cho tài khoản Free)
    final isFree =
        context.read<UserSubscriptionCubit>().userSubscription?.isFree ?? true;
    if (!isSuperAdmin && isFree) {
      PopupAdWidget.showInterstitialAd(context: context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userSubscription = context.watch<UserSubscriptionCubit>().userSubscription;
  }

  void _loadCurrentUser() {
    final user = context.read<AppCubit>().getUser();
    if (user != null) {
      _currentUser = user;
    }
  }

  // load user data settings
  Future<void> _loadUserDataSettings() async {
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    final dirString = await SharedPreferenceUtil.getPdfScrollDirection();
    final direction = PdfScrollDirection.values.firstWhere(
      (e) => e.name == dirString,
      orElse: () => PdfScrollDirection.vertical,
    );
    setState(() {
      showNavigationBar = !hideNavigationBar;
      _pdfScrollDirection = direction;
    });
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (!mounted) return;
      setState(() {
        _hasInternet = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasInternet = false;
      });
    }
  }

  Future<void> _checkCacheAndInit() async {
    _localFile = File(widget.fileUrl);
    _isLocal = _localFile.existsSync();

    if (_isLocal) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final fileInfo = await PdfCacheManager.instance.getFileFromCache(
        _networkPdfUrl,
      );
      if (fileInfo != null && fileInfo.file.existsSync()) {
        _localFile = fileInfo.file;
        _isLocal = true; // Sử dụng file đã cache như file local
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    } catch (e) {
      debugPrint('Error checking cache: $e');
    }

    // Nếu chưa có trong cache, cho phép hiển thị qua network stream
    if (mounted) setState(() => _isLoading = false);

    // Bắt đầu cache ngầm cho các file từ Google Drive
    if (widget.fileUrl.contains('google-drive')) {
      PdfCacheManager.instance
          .downloadFile(_networkPdfUrl)
          .then((_) {})
          .catchError((_) {});
    }
  }

  String get _networkPdfUrl {
    if (widget.fileUrl.startsWith('http')) return widget.fileUrl;
    // Google Drive proxy: đi qua API server (port 4000), không phải storage (port 3005)
    if (widget.fileUrl.contains('google-drive/download/')) {
      return '${ApiConstant.apiHost}${widget.fileUrl}';
    }
    return '${ApiConstant.apiHostStorage}${widget.fileUrl}';
  }

  /// Tải bytes PDF khi cần (TTS, Share, Download) — chỉ gọi cho file network
  Future<Uint8List?> _ensurePdfBytesForNetwork() async {
    if (_pdfBytes != null) return _pdfBytes;
    if (_isLocal && _localFile.existsSync()) {
      return await _localFile.readAsBytes();
    }
    try {
      final bytes = await _downloadPdf();
      if (mounted) setState(() => _pdfBytes = bytes);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  bool get isOwner => _currentUser?.id == widget.userIdCreate;

  Future<Uint8List> _downloadPdf() async {
    final response = await _dio.get<List<int>>(
      _networkPdfUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      // Nếu file đã là local thực sự (không phải cache) thì coi như đã có trên máy
      if (_isLocal && !widget.fileUrl.startsWith('http')) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.tools_saved_successfully,
          snackBarType: SnackBarType.success,
        );
        return;
      }

      // Lấy bytes từ bộ nhớ, hoặc từ file cache, hoặc tải mới
      late Uint8List bytes;
      if (_pdfBytes != null) {
        bytes = _pdfBytes!;
      } else if (_isLocal && _localFile.existsSync()) {
        bytes = await _localFile.readAsBytes();
      } else {
        bytes = await _downloadPdf();
      }

      // Lưu file: Android dùng Downloads công khai, iOS dùng Documents của app
      final Directory downloadsDir;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        downloadsDir = dir;
      } else {
        // iOS và các nền tảng khác: sandbox Documents (truy cập qua Files app)
        final appDir = await getApplicationDocumentsDirectory();
        final dir = Directory(path.join(appDir.path, 'Downloads'));
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        downloadsDir = dir;
      }

      final baseName = path.basename(widget.fileUrl);
      final safeTitle =
          widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_').trim();
      final fileName =
          (baseName.isNotEmpty && baseName.toLowerCase().endsWith('.pdf'))
              ? baseName
              : '$safeTitle.pdf';

      final file = File(path.join(downloadsDir.path, fileName));
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.tools_saved_successfully,
        snackBarType: SnackBarType.success,
      );
      // save file to local library
      if (!await SharedPreferenceUtil.isBookAdded(file.path)) {
        await SharedPreferenceUtil.addLocalBook(file.path);
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
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.tools_save_failed,
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<void> _loadLocalBytesForTts() async {
    if (_pdfBytes != null) return; // đã có bytes, không load lại
    final sw = Stopwatch()..start();
    try {
      final filePath = widget.fileUrl;
      final exists = await File(filePath).exists();
      if (!exists) return;
      // Dùng compute() để đọc file trong isolate riêng, không block main thread
      final bytes = await compute(
        (String path) => File(path).readAsBytesSync(),
        filePath,
      );
      sw.stop();
      dev.log(
        'loadLocalBytes: ${sw.elapsedMilliseconds}ms '
        '(${(bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(2)} MB)',
        name: 'PdfPerf',
      );
      if (mounted) setState(() => _pdfBytes = bytes);
    } catch (_) {
      // Không cần hiển thị lỗi, chỉ ảnh hưởng tới TTS
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    final loadMs = DateTime.now().difference(_screenOpenTime).inMilliseconds;
    final total = details.document.pages.count;
    dev.log('documentLoaded: ${loadMs}ms | pages: $total', name: 'PdfPerf');
    _totalPages = total;

    // Đưa việc cập nhật UI vào PostFrameCallback để tránh lỗi 'setState() called during build'
    // có thể xảy ra khi SfPdfViewer gọi hàm này ngay trong quá trình render đầu tiên.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pageStateNotifier.value = (_currentPage, total);
        // _fitPageToViewportWidth(details);
      }
    });

    // Local reading position (SharedPreference)
    SharedPreferenceUtil.getPdfReadingPosition(widget.fileUrl).then((
      savedPage,
    ) {
      if (savedPage != null &&
          savedPage >= 1 &&
          savedPage <= total &&
          mounted) {
        _pdfController.jumpToPage(savedPage);
        _currentPage = savedPage;
        _pageStateNotifier.value = (savedPage, total);
      }
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    final page = details.newPageNumber;
    // Cập nhật field trực tiếp + notifier, KHÔNG setState → không rebuild Scaffold
    _currentPage = page;
    _pageStateNotifier.value = (page, _totalPages);
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, page);
    _onServerPageChanged(page);
    // _flashPageCupertinoLoading();
  }

  void _onDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    setState(() => _error = details.description);
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'ai_assistant':
        if (!isProPlan) {
          PopupAdWidget.showPrompt(
            context: context,
            onReward: () {
              AiAssistantSheet.show(context, ebookId: widget.bookId ?? '');
            },
          );
          return;
        }
        AiAssistantSheet.show(context, ebookId: widget.bookId ?? '');
        break;
      case 'search':
        actionToolbar = 'search';
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        break;
      case 'zoom_in_out':
        // _pdfController.zoomLevel += 0.25;
        actionToolbar = 'zoom_in_out';
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        break;
      case 'toolbar':
        actionToolbar = 'toolbar';
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        break;
      case 'read_continuous_ebook':
        if (!isProPlan) {
          PopupAdWidget.showPrompt(
            context: context,
            onReward: () {
              setState(() {
                _isVisibleToolAction = !_isVisibleToolAction;
              });
              actionToolbar = 'read_continuous_ebook';
              _readContinuousEbook();
            },
          );
          return;
        }
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        actionToolbar = 'read_continuous_ebook';
        _readContinuousEbook();
        break;
      case 'download':
        if (!isProPlan && !(_actionStatus?['canUseDownload'] ?? false)) {
          PopupAdWidget.showPrompt(
            context: context,
            onReward: () {
              _downloadAndSavePdf();
            },
          );
          return;
        }
        _downloadAndSavePdf();
        break;
      case 'share':
        // if (!(_actionStatus?['canUseShare'] ?? false)) {
        //   Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
        //   return;
        // }
        _shareEbook();
        break;
      case 'bookmark':
        // show bookmark list
        // _showBookmarkList();
        break;
    }
  }

  /// Chia sẻ ebook qua Universal Link
  Future<void> _shareEbook() async {
    final bookId = widget.bookId ?? '';
    if (bookId.isEmpty) return;

    // Universal Link — clickable trong mọi ứng dụng chat/email
    final shareLink = 'https://readbox.pro.vn/book/$bookId';
    final shareText =
        '${AppLocalizations.current.pdf_share_text(widget.title)}\n\n$shareLink';

    try {
      if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
        // Download thumbnail
        final tempDir = await getTemporaryDirectory();
        final fileExtension = widget.thumbnailUrl!.split('.').last.split('?').first;
        final tempFile = File('${tempDir.path}/share_thumbnail.$fileExtension');
        
        await Dio().download(widget.thumbnailUrl!, tempFile.path);
        
        final result = await Share.shareXFiles(
          [XFile(tempFile.path)],
          text: shareText,
          subject: widget.title,
        );
        
        if (!mounted) return;
        if (result.status == ShareResultStatus.success) {
          context.read<UserInteractionCubit>().incrementUsage(
            usage: IncrementUsageModel(shareCount: 1),
          );
          context.read<UserInteractionCubit>().share(
            targetType: InteractionType.share,
            targetId: widget.bookId,
          );
        }
      } else {
        final result = await SharePlus.instance.share(
          ShareParams(text: shareText, subject: widget.title),
        );

        if (!mounted) return;
        if (result.status == ShareResultStatus.success) {
          context.read<UserInteractionCubit>().incrementUsage(
            usage: IncrementUsageModel(shareCount: 1),
          );
          context.read<UserInteractionCubit>().share(
            targetType: InteractionType.share,
            targetId: widget.bookId,
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_share_error(e.toString()),
        snackBarType: SnackBarType.error,
      );
    }
  }

  /// Dừng đọc sách và giải phóng bộ nhớ PDF bytes
  Future<void> _stopReading() async {
    await _ttsService.stop();
    await TtsLockScreenController.instance.stop();
    _removePdfWordHighlight();
    if (mounted) {
      setState(() {
        _isReadingContinuous = false;
        _showTtsReadingPanel = false;
        _currentPageWordBounds = null;
      });
    }
    // Giải phóng ~600 MB bytes sau khi dừng TTS
    _pdfBytes = null;
    dev.log('_pdfBytes released after stopReading', name: 'PdfMemory');
  }

  Future<void> _readContinuousEbook() async {
    setState(() {
      _isReadingContinuous = true;
    });
    // Bắt đầu đọc từ trang hiện tại (nếu không gọi thì onSpeechComplete không bao giờ chạy)
    await _readCurrentPage();
  }

  /// Đọc trang hiện tại (dùng cho khởi động đọc liên tục)
  Future<void> _readCurrentPage() async {
    if (!_isReadingContinuous || !mounted) return;

    setState(() => _isLoadingText = true);

    // File local: đợi _pdfBytes nếu chưa có (load cho TTS)
    if (_isLocal && _pdfBytes == null) {
      await _loadLocalBytesForTts();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || !_isReadingContinuous) {
        if (mounted) setState(() => _isLoadingText = false);
        return;
      }
    }
    if (_pdfBytes == null && !_isLocal) {
      // Network: tải bytes on-demand cho TTS
      final bytes = await _ensurePdfBytesForNetwork();
      if (bytes == null || !mounted || !_isReadingContinuous) {
        if (mounted) {
          setState(() {
            _isReadingContinuous = false;
            _isLoadingText = false;
          });
          AppSnackBar.show(
            context,
            message: AppLocalizations.current.pdf_load_failed_retry,
            snackBarType: SnackBarType.warning,
          );
        }
        return;
      }
    }
    try {
      // Combined extraction: tránh parse PdfDocument 2 lần
      String? pageText;
      if (_selectedText != null && _selectedText!.isNotEmpty) {
        pageText = _selectedText;
        // Có selected text → chỉ cần bounds từ PDF
        if (_pdfBytes != null) {
          final bounds =
              await PdfTextExtractorService.extractPageTextWithWordBounds(
                _pdfBytes!,
                _currentPage - 1,
              );
          if (mounted) setState(() => _currentPageWordBounds = bounds);
        }
      } else if (_pdfBytes != null) {
        // Single parse cho cả text lẫn bounds
        final (
          text,
          bounds,
        ) = await PdfTextExtractorService.extractTextAndBounds(
          _pdfBytes!,
          _currentPage - 1,
        );
        pageText = text;
        if (bounds != null && mounted) {
          setState(() => _currentPageWordBounds = bounds);
        }
      }
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.setLanguageFromText(pageText);
        if (mounted) {
          setState(() {
            _ttsReadingText = pageText;
            _ttsWordStart = 0;
            _ttsWordEnd = 0;
            _isLoadingText = false;
            // _showTtsReadingPanel = true;
          });
        }
        await TtsLockScreenController.instance.startReadingSession(
          bookTitle: widget.title,
          page: _currentPage,
          text: pageText,
          bookId: widget.bookId,
        );
        await _ttsService.speak(pageText);
        // update tts interaction count
        if (mounted) {
          context.read<UserInteractionCubit>().incrementUsage(
            usage: IncrementUsageModel(ttsCount: pageText.length),
          );
        }
      } else {
        if (mounted) setState(() => _isLoadingText = false);
        // Trang trống → chuyển sang trang tiếp
        if (_currentPage < _totalPages) {
          _readNextPage();
        } else {
          if (!mounted) return;
          setState(() => _isReadingContinuous = false);
          AppSnackBar.show(
            context,
            message: AppLocalizations.current.pdf_document_read_complete,
            snackBarType: SnackBarType.success,
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingText = false);
      if (_currentPage < _totalPages) {
        _readNextPage();
      } else {
        if (mounted) setState(() => _isReadingContinuous = false);
      }
    }
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

  @override
  void dispose() {
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, _currentPage);
    final shouldContinueTtsInBackground =
        _isReadingContinuous && _pdfBytes != null && _currentPage < _totalPages;
    if (shouldContinueTtsInBackground) {
      TtsLockScreenController.instance.continuePdfInBackground(
        pdfBytes: _pdfBytes!,
        bookTitle: widget.title,
        currentPage: _currentPage,
        totalPages: _totalPages,
        bookId: widget.bookId,
      );
    } else {
      // Nếu không bàn giao được sang runner nền thì phải tắt hẳn, tránh icon
      // global vẫn hiển thị "đang đọc" trong khi TTS đã bị dispose theo màn.
      _isReadingContinuous = false;
      _isReadingNextPage = false;
      _ttsService.stop();
      TtsLockScreenController.instance.stop();
    }
    _removePdfWordHighlight();
    _ttsProgressTimer?.cancel();
    _saveProgressTimer?.cancel();
    _readingTimeTimer?.cancel();
    _memoryMonitorTimer?.cancel();
    _pageLoadingTimer?.cancel();
    _subscriptionPlanStream?.cancel();
    _ttsWordProgressNotifier.dispose();
    _selectedTextNotifier.dispose();
    _pageStateNotifier.dispose();
    _ttsScrollController.dispose();
    _pdfBytes = null; // giải phóng memory khi rời màn hình
    _saveReadingProgressNow();
    if (_searchResult != null && _searchResultListener != null) {
      _searchResult!.removeListener(_searchResultListener!);
    }
    _searchResult?.clear();
    _searchQueryController.dispose();
    _pdfController.dispose();
    super.dispose();
  }

  void _runSearch(String text) {
    if (_searchResult != null && _searchResultListener != null) {
      _searchResult!.removeListener(_searchResultListener!);
    }
    _searchResult?.clear();
    if (text.trim().isEmpty) {
      setState(() => _searchResult = null);
      return;
    }
    final result = _pdfController.searchText(text.trim());
    _searchResult = result;
    _searchResultListener = () {
      if (mounted) setState(() {});
    };
    result.addListener(_searchResultListener!);
    setState(() {});
  }

  void _clearSearch() {
    if (_searchResult != null && _searchResultListener != null) {
      _searchResult!.removeListener(_searchResultListener!);
    }
    _searchResult?.clear();
    _searchResult = null;
    _searchResultListener = null;
    _searchQueryController.clear();
    setState(() => _isVisibleToolAction = false);
  }

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    // Dùng ValueNotifier thay setState → không rebuild toàn Scaffold khi chọn chữ
    if (details.selectedText != null && details.selectedText!.isNotEmpty) {
      _selectedText = details.selectedText;
      _selectedTextNotifier.value = details.selectedText;
    }
  }

  void _setPdfScrollDirection(PdfScrollDirection direction) {
    if (_pdfScrollDirection == direction) return;
    setState(() => _pdfScrollDirection = direction);
    SharedPreferenceUtil.savePdfScrollDirection(direction.name);
  }

  Widget _buildPdfViewer() {
    final Widget viewer;
    if (_isLocal) {
      viewer = SfPdfViewer.file(
        _localFile,
        controller: _pdfController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: _onDocumentLoadFailed,
        enableTextSelection: true,
        onTextSelectionChanged: _onTextSelectionChanged,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPageLoadingIndicator: false,
        scrollDirection: _pdfScrollDirection,
        pageLayoutMode: PdfPageLayoutMode.single,
      );
    } else {
      viewer = SfPdfViewer.network(
        _networkPdfUrl,
        controller: _pdfController,
        onDocumentLoaded: _onDocumentLoaded,
        onPageChanged: _onPageChanged,
        onDocumentLoadFailed: _onDocumentLoadFailed,
        enableTextSelection: true,
        onTextSelectionChanged: _onTextSelectionChanged,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        canShowPageLoadingIndicator: false,
        scrollDirection: _pdfScrollDirection,
        pageLayoutMode: PdfPageLayoutMode.single,
      );
    }
    // KeyedSubtree buộc SfPdfViewer tạo lại khi đổi hướng cuộn
    return KeyedSubtree(key: ValueKey(_pdfScrollDirection), child: viewer);
  }

  Widget _buildPdfViewerArea({required bool showNavBar}) {
    return Stack(
      children: [
        _buildPdfViewer(),
        if (_showPageCupertinoLoading && !_isLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: Colors.grey.withValues(alpha: 0.04),
                child: const Center(
                  child: CupertinoActivityIndicator(radius: 8),
                ),
              ),
            ),
          ),
        _buildScrollDirectionControl(showNavBar: showNavBar),
      ],
    );
  }

  /// Nút nhỏ chuyển cuộn dọc / ngang (góc trái dưới)
  Widget _buildScrollDirectionControl({required bool showNavBar}) {
    final isVertical = _pdfScrollDirection == PdfScrollDirection.vertical;
    final bottom = showNavBar ? 96.0 : 24.0;
    final color = Theme.of(context).primaryColor;

    return Positioned(
      left: 12,
      bottom: bottom,
      child: Material(
        color: Colors.white.withValues(alpha: 0.95),
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDirChip(
                icon: Icons.swap_vert_rounded,
                label: AppLocalizations.current.pdf_scroll_vertical,
                isSelected: isVertical,
                color: color,
                onTap:
                    () => _setPdfScrollDirection(PdfScrollDirection.vertical),
              ),
              _buildDirChip(
                icon: Icons.swap_horiz_rounded,
                label: AppLocalizations.current.pdf_scroll_horizontal,
                isSelected: !isVertical,
                color: color,
                onTap:
                    () => _setPdfScrollDirection(PdfScrollDirection.horizontal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? color.withValues(alpha: 0.12)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isSelected ? color : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarToolTitle() {
    switch (actionToolbar) {
      case 'search':
        return TextField(
          controller: _searchQueryController,
          autofocus: true,
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: AppLocalizations.current.pdf_search_in_pdf,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 22,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.arrow_forward_rounded, color: Colors.white),
              onPressed: () => _runSearch(_searchQueryController.text),
              tooltip: AppLocalizations.current.pdf_search_tooltip,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            isDense: true,
          ),
          onSubmitted: _runSearch,
        );
      default:
        return Text(AppLocalizations.current.pdf_search_in_pdf);
    }
  }

  List<Widget> _buildAppBarToolActions() {
    List<Widget> actions = [];
    switch (actionToolbar) {
      case 'ai_assistant':
      case 'search':
        actions = [..._buildSearchActions()];
      case 'zoom_in_out':
        actions = [
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.white),
            onPressed: () => _pdfController.zoomLevel += 0.25,
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.white),
            onPressed: () => _pdfController.zoomLevel -= 0.25,
          ),
          IconButton(
            icon: Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
            onPressed: () => _pdfController.zoomLevel = 1.0,
          ),
        ];
      case 'read_continuous_ebook':
        actions = [
          IconButton(
            icon: Icon(
              _isReadingContinuous
                  ? Icons.pause_circle_outline
                  : Icons.play_circle_outline,
              color: _isReadingContinuous ? Colors.red : Colors.white,
            ),
            onPressed: () async {
              if (_isReadingContinuous) {
                await _stopReading();
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
              color: Colors.white,
            ),
            onPressed:
                () => {
                  setState(() {
                    _showTtsReadingPanel = !_showTtsReadingPanel;
                  }),
                },
          ),

          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              if (_isReadingContinuous) await _stopReading();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamed(Routes.textToSpeechSettingScreen);
              }
            },
          ),
        ];
      case 'toolbar':
        actions = [
          IconButton(
            icon: Icon(Icons.fullscreen, color: Colors.white),
            onPressed:
                () => setState(() {
                  showToolbar = !showToolbar;
                }),
          ),
          IconButton(
            icon: Icon(
              showNavigationBar
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.keyboard_arrow_up_rounded,
              color: Colors.white,
            ),
            onPressed:
                () => setState(() {
                  showNavigationBar = !showNavigationBar;
                }),
          ),
          IconButton(
            icon: Icon(Icons.skip_next_rounded, color: Colors.white),
            onPressed: () => _showJumpToPage(),
          ),
        ];
      default:
        return [];
    }
    if (actions.isNotEmpty) {
      actions = [
        Container(
          margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: actions),
        ),
      ];
    }
    actions.add(
      Container(
        margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: _clearSearch,
          iconSize: 24,
        ),
      ),
    );
    return actions;
  }

  List<Widget> _buildSearchActions() {
    final total = _searchResult?.totalInstanceCount ?? 0;
    final current = _searchResult?.currentInstanceIndex ?? 0;
    final canPrev = _searchResult != null && total > 0 && current > 1;
    final canNext = _searchResult != null && total > 0 && current < total;
    final searching =
        _searchResult != null &&
        !_searchResult!.isSearchCompleted &&
        total == 0;
    final noResults =
        _searchResult != null &&
        _searchResult!.isSearchCompleted &&
        total == 0 &&
        _searchQueryController.text.trim().isNotEmpty;

    return [
      if (_searchResult != null && total > 0) ...[
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$current/$total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_up_rounded,
            color: canPrev ? Colors.white : Colors.white54,
          ),
          onPressed: canPrev ? () => _searchResult!.previousInstance() : null,
          iconSize: 24,
        ),
        IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: canNext ? Colors.white : Colors.white54,
          ),
          onPressed: canNext ? () => _searchResult!.nextInstance() : null,
          iconSize: 24,
        ),
      ] else if (searching)
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CupertinoActivityIndicator(color: Colors.white70),
            ),
          ),
        )
      else if (noResults)
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '0',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
    ];
  }

  // visible toolbar actions
  bool get _visibleAppbarToolAction => _isVisibleToolAction;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showViewer =
        !_isLoading &&
        _error == null &&
        (_isLocal || _pdfBytes != null || !_isLocal);
    return Scaffold(
      appBar:
          showToolbar
              ? AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                    iconSize: 24,
                  ),
                ),
                title:
                    _visibleAppbarToolAction && actionToolbar == 'search'
                        ? _buildAppBarToolTitle()
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            ValueListenableBuilder<(int, int)>(
                              valueListenable: _pageStateNotifier,
                              builder: (_, pageState, __) {
                                if (pageState.$2 == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.current.pdf_page_of(
                                      pageState.$1,
                                      pageState.$2,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                actions:
                    _visibleAppbarToolAction
                        ? _buildAppBarToolActions()
                        : [
                          isEnableAction
                              ? Container(
                                margin: EdgeInsets.only(
                                  right: 8,
                                  top: 8,
                                  bottom: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.white,
                                  ),
                                  onSelected: _handleMenuAction,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  itemBuilder:
                                      (BuildContext context) => [
                                        _buildMenuItem(
                                          'ai_assistant',
                                          Icons.auto_awesome_rounded,
                                          AppLocalizations.current.ai_assistant,
                                          Colors.purple,
                                          isPro: true,
                                        ),
                                        _buildMenuItem(
                                          'search',
                                          Icons.search_rounded,
                                          AppLocalizations.current.search,
                                          Colors.blue,
                                        ),
                                        _buildMenuItem(
                                          'zoom_in_out',
                                          Icons.zoom_in,
                                          AppLocalizations
                                              .current
                                              .pdf_zoom_in_out,
                                          Colors.blueGrey,
                                        ),
                                        _buildMenuItem(
                                          'toolbar',
                                          Icons.settings_overscan_rounded,
                                          AppLocalizations.current.pdf_toolbar,
                                          theme.primaryColor,
                                        ),
                                        if (_hasInternet)
                                          _buildMenuItem(
                                            'read_continuous_ebook',
                                            Icons.play_circle_outline,
                                            AppLocalizations
                                                .current
                                                .pdf_read_ebook,
                                            Colors.orange,
                                            isEnabled:
                                                _actionStatus?['canUseTts'] ??
                                                false,
                                            isPro: true,
                                          ),
                                        if (!_isLocal)
                                          _buildMenuItem(
                                            'share',
                                            Icons.share_rounded,
                                            AppLocalizations.current.pdf_share,
                                            Colors.blue,
                                            isEnabled:
                                                _actionStatus?['canUseShare'] ??
                                                false,
                                          ),
                                        _buildMenuItem(
                                          'download',
                                          Icons.download_rounded,
                                          AppLocalizations.current.download,
                                          Colors.green,
                                          isEnabled:
                                              _actionStatus?['canUseDownload'] ??
                                              false,
                                        ),
                                      ],
                                ),
                              )
                              : SizedBox(),
                        ],
              )
              : null,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (_error != null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.current.pdf_cannot_load,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            AppLocalizations
                                .current
                                .cannot_load_pdf_description,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed:
                              _isLocal
                                  ? null
                                  : () => setState(() => _error = null),
                          child: Text(AppLocalizations.current.retry),
                        ),
                      ],
                    ),
                  )
                else if (showViewer)
                  _buildPdfViewerArea(
                    showNavBar: showNavigationBar && showToolbar,
                  ),
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CupertinoActivityIndicator(radius: 14),
                          SizedBox(height: 16),
                          Text(AppLocalizations.current.pdf_loading),
                          SizedBox(height: 8),
                          Text(
                            AppLocalizations.current.pdf_please_wait,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_isLoadingText)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CupertinoActivityIndicator(radius: 12),
                    ),
                  ),
                // Toggle toolbar button
                if (!showToolbar)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton.small(
                      onPressed: () {
                        setState(() {
                          showToolbar = !showToolbar;
                        });
                      },
                      child: Icon(Icons.menu),
                    ),
                  ),
                // Panel đánh dấu từ đang đọc (TTS)
                if (_showTtsReadingPanel && _ttsReadingText != null)
                  _buildTtsReadingPanel(),
                // Nút AI Assistant - hiện khi user bôi đen văn bản
                if (isProPlan &&
                    _selectedText != null &&
                    _selectedText!.isNotEmpty)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: _buildAiFloatingButton(),
                  ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          !showNavigationBar || !showToolbar || !showViewer
              ? null
              : Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<(int, int)>(
                  valueListenable: _pageStateNotifier,
                  builder: (_, pageState, __) {
                    final cur = pageState.$1;
                    final total = pageState.$2;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavButton(
                          icon: Icons.first_page_rounded,
                          isEnabled: cur > 1,
                          onPressed: () => _pdfController.jumpToPage(1),
                        ),
                        _buildNavButton(
                          icon: Icons.chevron_left_rounded,
                          isEnabled: cur > 1,
                          onPressed: () => _pdfController.previousPage(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.current.pdf_page_of(cur, total),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        _buildNavButton(
                          icon: Icons.chevron_right_rounded,
                          isEnabled: cur < total,
                          onPressed: () => _pdfController.nextPage(),
                        ),
                        _buildNavButton(
                          icon: Icons.last_page_rounded,
                          isEnabled: cur < total,
                          onPressed: () => _pdfController.jumpToPage(total),
                        ),
                      ],
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isEnabled
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isEnabled ? Theme.of(context).primaryColor : Colors.grey[400],
        ),
        onPressed: isEnabled ? onPressed : null,
        iconSize: 18,
      ),
    );
  }

  // ====== Text selection & TTS (moved from selection screen) ======

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
      // Cập nhật ValueNotifier thay vì setState → chỉ rebuild TTS panel, không rebuild toàn Scaffold
      _ttsWordStart = start.clamp(0, text.length);
      _ttsWordEnd = end.clamp(0, text.length);
      _ttsWordProgressNotifier.value = (_ttsWordStart, _ttsWordEnd);
      TtsLockScreenController.instance.updateWordProgress(
        fullText: text,
        start: start,
        end: end,
      );
      _updatePdfWordHighlight(start, end);
    };

    _ttsService.onSpeechComplete = (_) {
      TtsLockScreenController.instance.markCompleted();
      _removePdfWordHighlight();
      // Nếu đang đọc liên tục, chuyển sang trang tiếp theo
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
      } else {
        // Hết session (hết sách hoặc user đã tắt continuous) → đóng dứt khoát
        // session TTS nền để mini-player ẩn, tránh người dùng nghĩ TTS vẫn còn.
        TtsLockScreenController.instance.stop();
        _isReadingContinuous = false;
        _ttsProgressTimer?.cancel();
        if (mounted) {
          setState(() {
            _showTtsReadingPanel = false;
            _currentPageWordBounds = null;
          });
        }
      }
    };

    _ttsService.onSpeechError = (error) {
      TtsLockScreenController.instance.markError(error);
      _removePdfWordHighlight();
      // Nếu đang đọc liên tục thì skip sang trang tiếp thay vì dừng hẳn
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
        return;
      }
      TtsLockScreenController.instance.stop();
      if (mounted) {
        setState(() {
          _isReadingContinuous = false;
          _showTtsReadingPanel = false;
          _currentPageWordBounds = null;
        });
      }
      _ttsProgressTimer?.cancel();
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_tts_read_error(error),
        snackBarType: SnackBarType.error,
      );
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

  void _removePdfWordHighlight() {
    if (_ttsCurrentWordAnnotation != null) {
      _pdfController.removeAnnotation(_ttsCurrentWordAnnotation!);
      _ttsCurrentWordAnnotation = null;
    }
  }

  void _updatePdfWordHighlight(int start, int end) {
    final bounds = _currentPageWordBounds;
    if (bounds == null || bounds.wordBounds.isEmpty) return;
    final overlapping =
        bounds.wordBounds
            .where((e) => e.startIndex < end && e.endIndex > start)
            .toList();
    if (overlapping.isEmpty) return;

    final sw = Stopwatch()..start();
    _removePdfWordHighlight();
    final collection =
        overlapping
            .map(
              (e) => PdfTextLine(
                e.bounds,
                bounds.fullText.substring(e.startIndex, e.endIndex),
                bounds.pageNumber,
              ),
            )
            .toList();
    final annotation = HighlightAnnotation(textBoundsCollection: collection);
    annotation.color = Theme.of(context).primaryColor.withValues(alpha: 0.35);
    _pdfController.addAnnotation(annotation);
    _ttsCurrentWordAnnotation = annotation;
    sw.stop();
    _wordHighlightCount++;
    // Cảnh báo nếu annotation chậm hơn 1 frame (16ms)
    if (sw.elapsedMilliseconds > 16) {
      dev.log(
        'wordHighlight #$_wordHighlightCount SLOW: ${sw.elapsedMilliseconds}ms',
        name: 'PdfPerf',
      );
    }
  }

  Future<void> _readNextPage() async {
    // Chặn gọi đồng thời trong giai đoạn setup (stop→navigate→extract→setLanguage)
    // Flag phải được release TRƯỚC khi speak() để onSpeechComplete có thể gọi lại hàm này
    if (_isReadingNextPage) return;
    _isReadingNextPage = true;

    try {
      if (_currentPage >= _totalPages) {
        await TtsLockScreenController.instance.stop();
        if (!mounted) return;
        setState(() => _isReadingContinuous = false);
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_document_read_complete,
          snackBarType: SnackBarType.success,
        );
        return;
      }

      // Stop engine trước để tránh Android TTS kích hoạt lại completionHandler
      await _ttsService.stop();

      // Lưu số trang cần đọc trước khi nextPage() (vì _onPageChanged sẽ cập nhật _currentPage ngay)
      final nextPageNumber = _currentPage + 1;
      _pdfController.nextPage();
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted || !_isReadingContinuous) return;

      _removePdfWordHighlight();
      if (mounted) setState(() => _currentPageWordBounds = null);

      // Combined extraction: single PdfDocument parse cho cả text lẫn bounds
      String? pageText;
      PageTextWithBounds? pageBounds;
      if (_pdfBytes != null) {
        final sw = Stopwatch()..start();
        final (
          text,
          bounds,
        ) = await PdfTextExtractorService.extractTextAndBounds(
          _pdfBytes!,
          nextPageNumber - 1,
        );
        sw.stop();
        dev.log(
          'extractTextAndBounds p$nextPageNumber: ${sw.elapsedMilliseconds}ms',
          name: 'PdfPerf',
        );
        pageText = text;
        pageBounds = bounds;
      }

      if (pageText == null || pageText.isEmpty) {
        // Trang trống → thử trang tiếp
        _isReadingNextPage = false;
        if (nextPageNumber < _totalPages) {
          _readNextPage();
        } else {
          await TtsLockScreenController.instance.stop();
          if (!mounted) return;
          setState(() => _isReadingContinuous = false);
          AppSnackBar.show(
            context,
            message: AppLocalizations.current.pdf_document_read_complete,
            snackBarType: SnackBarType.success,
          );
        }
        return;
      }

      // Đổi ngôn ngữ rồi chờ engine ổn định trước khi speak
      final swLang = Stopwatch()..start();
      await _ttsService.setLanguageFromText(pageText);
      await Future.delayed(const Duration(milliseconds: 150));
      swLang.stop();
      dev.log(
        'setLanguage p$nextPageNumber: ${swLang.elapsedMilliseconds}ms',
        name: 'PdfPerf',
      );

      if (!mounted || !_isReadingContinuous) return;

      if (pageBounds != null && mounted) {
        setState(() => _currentPageWordBounds = pageBounds);
      }
      if (mounted) {
        setState(() {
          _ttsReadingText = pageText;
          _ttsWordStart = 0;
          _ttsWordEnd = 0;
        });
      }
      await TtsLockScreenController.instance.startReadingSession(
        bookTitle: widget.title,
        page: nextPageNumber,
        text: pageText,
        bookId: widget.bookId,
      );

      // Release lock TRƯỚC khi speak để onSpeechComplete có thể gọi _readNextPage() tiếp theo
      // (trên Android, speak() có thể block và onSpeechComplete fire ngay trong await)
      _isReadingNextPage = false;
      await _ttsService.speak(pageText);
    } catch (_) {
      // Lỗi trong setup → skip sang trang tiếp
      _isReadingNextPage = false;
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
      } else {
        if (mounted) setState(() => _isReadingContinuous = false);
      }
    }
  }

  /// Panel hiển thị text đang đọc với từ đang đọc được đánh dấu
  Future<void> _speakFromPosition(int charOffset) async {
    final text = _ttsReadingText;
    if (text == null || text.isEmpty) return;

    final offset = charOffset.clamp(0, text.length);
    await _ttsService.stop();
    _removePdfWordHighlight();

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
      _updatePdfWordHighlight(realStart, realEnd);
    };

    final originalComplete = _ttsService.onSpeechComplete;
    _ttsService.onSpeechComplete = (msg) {
      _ttsService.onSpeechWordProgress = originalHandler;
      _ttsService.onSpeechComplete = originalComplete;
      originalComplete?.call(msg);
    };

    await _ttsService.speak(subText);
  }

  void _handleAutoScroll(int start, String text, BoxConstraints constraints) {
    if (!_ttsScrollController.hasClients) return;

    final textStyle = TextStyle(
      fontSize: 15,
      height: 1.6,
      color: Colors.black, // Color doesn't matter for layout
    );

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: constraints.maxWidth - 32); // 16*2 padding

    final offset = textPainter.getOffsetForCaret(
      TextPosition(offset: start),
      Rect.zero,
    );
    textPainter.dispose(); // Giải phóng native resource sau khi dùng

    final currentScroll = _ttsScrollController.offset;
    final viewportHeight = constraints.maxHeight;

    // Nếu vị trí từ đang đọc nằm ngoài vùng nhìn thấy (có padding)
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.45,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.vertical(
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
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.current.pdf_reading,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.primaryColor,
                          ),
                        ),
                        Spacer(),
                        if (len > 0)
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.primaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                        SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.close, size: 20),
                          onPressed:
                              () =>
                                  setState(() => _showTtsReadingPanel = false),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
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
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: RoundSliderOverlayShape(
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                                _removePdfWordHighlight();
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
                            if (_currentPage < _totalPages) _readNextPage();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),

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
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
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

  int _findWordBoundary(String text, int pos) {
    if (pos <= 0) return 0;
    if (pos >= text.length) return text.length;
    var p = pos;
    while (p > 0 && text[p - 1] != ' ' && text[p - 1] != '\n') {
      p--;
    }
    return p;
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            SizedBox(height: 2),
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

  // ====== Reading progress (server) ======

  Future<void> _loadReadingProgress() async {
    if (_userInteractionCubit == null || widget.bookId == null) return;
    try {
      final interaction = await _userInteractionCubit!.getInteractionAction(
        targetType: InteractionTarget.book,
        actionType: InteractionType.reading,
        targetId: widget.bookId!,
      );
      if (!mounted) return;
      if (interaction.isReading) {
        _currentProgress = interaction.getReadingProgressForFormat('pdf');
        _accumulatedReadingTime = _currentProgress?.totalReadingTime ?? 0;
        if (_currentProgress?.currentPage != null &&
            _currentProgress!.currentPage! > 0) {
          _lastSavedPage = _currentProgress!.currentPage!;
        }
      }
      _startReadingTimeTracker();
    } catch (_) {
      _startReadingTimeTracker();
    }
  }

  void _startReadingTimeTracker() {
    _readingStartTime = DateTime.now();
    _readingTimeTimer?.cancel();
    _readingTimeTimer = Timer.periodic(const Duration(seconds: 10), (_) {});
  }

  void _onServerPageChanged(int newPage) {
    if (_userInteractionCubit == null || widget.bookId == null) return;
    if (newPage == _lastSavedPage) return;
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(const Duration(seconds: 5), () {
      _saveReadingProgress(newPage);
    });
  }

  int _calculateTotalReadingTime() {
    if (_readingStartTime == null) {
      return _accumulatedReadingTime;
    }
    final currentSessionTime =
        DateTime.now().difference(_readingStartTime!).inSeconds;
    return _accumulatedReadingTime + currentSessionTime;
  }

  Future<void> _saveReadingProgress(int page) async {
    if (_userInteractionCubit == null || widget.bookId == null) return;
    if (page == _lastSavedPage) return;

    try {
      double progressValue = 0.0;
      if (_totalPages > 0) {
        progressValue = page / _totalPages;
      }
      final totalReadingTime = _calculateTotalReadingTime();
      final progressModel = ReadingProgressModel.fromJson({
        'bookId': widget.bookId,
        'currentPage': page,
        'progress': progressValue,
        'lastUpdated': DateTime.now().toIso8601String(),
        'totalReadingTime': totalReadingTime,
        'format': 'pdf',
      });

      final savedProgress = await _userInteractionCubit!.saveReadingProgress(
        targetType: InteractionTarget.book,
        actionType: InteractionType.reading,
        targetId: widget.bookId!,
        readingProgress: progressModel,
      );

      if (mounted) {
        final savedTime = savedProgress?.totalReadingTime ?? totalReadingTime;
        _accumulatedReadingTime = savedTime;
        _readingStartTime = DateTime.now();
        // Không cần setState: _currentProgress và _lastSavedPage là internal state, không có widget nào dùng trực tiếp
        _currentProgress = savedProgress;
        _lastSavedPage = page;
      }
    } catch (_) {
      // Bỏ qua lỗi, không ảnh hưởng trải nghiệm đọc
    }
  }

  Future<void> _saveReadingProgressNow() async {
    _saveProgressTimer?.cancel();
    if (_userInteractionCubit == null || widget.bookId == null) return;
    if (_currentPage <= 0) return;

    final totalReadingTime = _calculateTotalReadingTime();
    if (_currentPage != _lastSavedPage ||
        totalReadingTime > _accumulatedReadingTime) {
      await _saveReadingProgress(_currentPage);
    }
  }

  void _showJumpToPage() {
    final pageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.skip_next_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                AppLocalizations.current.pdf_jump_to_page,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pageController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.current.pdf_page_number,
                  hintText: '1-$_totalPages',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.current.cancel,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(pageController.text);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _pdfController.jumpToPage(page);
                  Navigator.pop(context);
                } else {
                  AppSnackBar.show(
                    context,
                    message: AppLocalizations.current.pdf_invalid_page,
                    snackBarType: SnackBarType.error,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.current.pdf_go,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Nút AI nổi xuất hiện khi user bôi đen văn bản trong PDF
  Widget _buildAiFloatingButton() {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder:
          (context, value, child) =>
              Transform.scale(scale: value, child: child),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () async {
              final text = _selectedText;
              if (text == null || text.trim().isEmpty) return;

              // Theo logic mong muốn: Copy trước, rồi mới mở AI Assistant
              await Clipboard.setData(ClipboardData(text: text));
              if (!mounted) return;
              setState(() => _selectedText = null);
              AiAssistantSheet.show(
                context,
                selectedText: text,
                ebookId: widget.bookId ?? '',
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
