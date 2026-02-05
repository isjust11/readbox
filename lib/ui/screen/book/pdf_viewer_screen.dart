import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/user_interaction_cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/pdf_drawing_service.dart';
import 'package:readbox/utils/pdf_text_extractor.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String? bookId;

  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    this.bookId,
  });

  @override
  PdfViewerScreenState createState() => PdfViewerScreenState();
}

class PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final TextEditingController _searchQueryController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLocal = false;
  Uint8List? _pdfBytes;
  bool _isVisibleToolAction = false;
  PdfTextSearchResult? _searchResult;
  VoidCallback? _searchResultListener;
  bool showToolbar = true;
  bool showNavigationBar = true;
  String? actionToolbar = '';
  // Text selection & TTS
  String? _selectedText;
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isReadingContinuous = false;
  Timer? _ttsProgressTimer;
  bool _hasInternet = false;
  // Đánh dấu từ đang đọc (TTS word progress)
  String? _ttsReadingText;
  int _ttsWordStart = 0;
  int _ttsWordEnd = 0;
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

  // Vẽ & Ghi chú
  bool _isDrawMode = false;
  List<List<Offset>> _currentPageStrokes = [];
  Map<int, List<List<Offset>>> _allDrawStrokes = {};
  List<Offset> _currentStroke = [];
  Color _drawColor = Colors.red;
  final double _strokeWidth = 3.0;
  List<Map<String, dynamic>> _notes = [];
  Size _drawOverlaySize = Size.zero;

  bool get _hasDrawingsForCurrentPage =>
      (_allDrawStrokes[_currentPage]?.isNotEmpty ?? false) && !_isDrawMode;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    final file = File(widget.fileUrl);
    _isLocal = file.existsSync();
    if (_isLocal) {
      setState(() => _isLoading = false);
    } else {
      _loadFromNetwork();
    }
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

    // Chuẩn bị bytes cho TTS khi đọc file local
    if (_isLocal) {
      _loadLocalBytesForTts();
    }
    _loadDrawings();
    _loadNotes();
  }

  // load user data settings
  Future<void> _loadUserDataSettings() async {
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    setState(() {
      showNavigationBar = !hideNavigationBar;
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

  Future<void> _loadFromNetwork() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final bytes = await _downloadPdf();
      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
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

  Future<Uint8List> _downloadPdf() async {
    final dio = Dio();
    final response = await dio.get<List<int>>(
      '${ApiConstant.apiHostStorage}${widget.fileUrl}',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  Future<void> _loadLocalBytesForTts() async {
    try {
      final file = File(widget.fileUrl);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _pdfBytes = bytes;
          });
        }
      }
    } catch (_) {
      // Không cần hiển thị lỗi, chỉ ảnh hưởng tới TTS
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    final total = details.document.pages.count;
    setState(() => _totalPages = total);

    // Local reading position (SharedPreference)
    SharedPreferenceUtil.getPdfReadingPosition(widget.fileUrl).then((
      savedPage,
    ) {
      if (savedPage != null &&
          savedPage >= 1 &&
          savedPage <= total &&
          mounted) {
        _pdfController.jumpToPage(savedPage);
        setState(() => _currentPage = savedPage);
      }
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    final page = details.newPageNumber;
    if (_isDrawMode) {
      _saveCurrentPageDrawings();
    }
    setState(() {
      _currentPage = page;
      if (_isDrawMode) {
        _currentPageStrokes =
            _allDrawStrokes[page]?.map((s) => List<Offset>.from(s)).toList() ??
            [];
      }
    });
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, page);
    _onServerPageChanged(page);
  }

  void _onDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    setState(() => _error = details.description);
  }

  void _handleMenuAction(String value) {
    switch (value) {
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
        setState(() {
          _isVisibleToolAction = !_isVisibleToolAction;
        });
        actionToolbar = 'read_continuous_ebook';
        _readContinuousEbook();
        break;
      case 'share':
        _shareEbook();
        break;
      case 'bookmark':
        // show bookmark list
        // _showBookmarkList();
        break;
      case 'draw':
        setState(() {
          _isDrawMode = !_isDrawMode;
          if (_isDrawMode) {
            _currentPageStrokes =
                _allDrawStrokes[_currentPage]
                    ?.map((s) => List<Offset>.from(s))
                    .toList() ??
                [];
          } else {
            _saveCurrentPageDrawings();
            _persistDrawings();
          }
        });
        break;
      case 'notes':
        _showNotesList();
        break;
    }
  }

  Future<void> _loadDrawings() async {
    final data = await SharedPreferenceUtil.getPdfDrawings(widget.fileUrl);
    if (data != null) {
      final map = <int, List<List<Offset>>>{};
      for (final e in data.entries) {
        final page = int.tryParse(e.key.toString());
        if (page != null && e.value is List) {
          final strokes = <List<Offset>>[];
          for (final s in e.value as List) {
            if (s is List) {
              strokes.add(
                s
                    .map(
                      (p) => Offset(
                        (p is Map && p['x'] != null)
                            ? (p['x'] as num).toDouble()
                            : 0,
                        (p is Map && p['y'] != null)
                            ? (p['y'] as num).toDouble()
                            : 0,
                      ),
                    )
                    .toList(),
              );
            }
          }
          map[page] = strokes;
        }
      }
      if (mounted) setState(() => _allDrawStrokes = map);
    }
  }

  void _saveCurrentPageDrawings() {
    if (_currentPageStrokes.isNotEmpty) {
      _allDrawStrokes[_currentPage] =
          _currentPageStrokes.map((s) => List<Offset>.from(s)).toList();
    }
  }

  Future<void> _persistDrawings() async {
    final map = <String, dynamic>{};
    for (final e in _allDrawStrokes.entries) {
      map['${e.key}'] =
          e.value
              .map(
                (stroke) => stroke.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
              )
              .toList();
    }
    await SharedPreferenceUtil.savePdfDrawings(widget.fileUrl, map);
  }

  Future<void> _loadNotes() async {
    final list = await SharedPreferenceUtil.getPdfNotes(widget.fileUrl);
    if (mounted) setState(() => _notes = list);
  }

  Future<void> _saveNotes() async {
    await SharedPreferenceUtil.savePdfNotes(widget.fileUrl, _notes);
  }

  /// Chia sẻ ebook qua mạng xã hội, messaging, email...
  Future<void> _shareEbook() async {
    try {
      String? filePath;
      final shareText = AppLocalizations.current.pdf_share_text(widget.title);

      if (_isLocal) {
        final file = File(widget.fileUrl);
        if (await file.exists()) {
          filePath = widget.fileUrl;
        }
      } else if (_pdfBytes != null && _pdfBytes!.isNotEmpty) {
        // File từ mạng: lưu tạm để chia sẻ
        final dir = await getTemporaryDirectory();
        final baseName = path.basename(widget.fileUrl);
        final fileName =
            (baseName.isNotEmpty && baseName.toLowerCase().endsWith('.pdf'))
                ? baseName
                : '${widget.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
        final tempFile = File(path.join(dir.path, fileName));
        await tempFile.writeAsBytes(_pdfBytes!);
        filePath = tempFile.path;
      }

      if (filePath == null) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: _isLocal
              ? AppLocalizations.current.pdf_share_file_not_found
              : AppLocalizations.current.pdf_share_wait_download,
          snackBarType: SnackBarType.warning,
        );
        return;
      }

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: shareText,
        subject: widget.title,
      );

      if (!mounted) return;
      if (result.status == ShareResultStatus.success) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.pdf_share_success,
          snackBarType: SnackBarType.success,
        );
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
    // File local: đợi _pdfBytes nếu chưa có (load cho TTS)
    if (_isLocal && _pdfBytes == null) {
      await _loadLocalBytesForTts();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || !_isReadingContinuous) return;
    }
    if (_pdfBytes == null && !_isLocal) {
      if (!mounted) return;
      setState(() => _isReadingContinuous = false);
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_load_failed_retry,
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    try {
      final pageText = await _extractPageText(_currentPage);
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.setLanguageFromText(pageText);
        if (_pdfBytes != null) {
          final bounds =
              await PdfTextExtractorService.extractPageTextWithWordBounds(
                _pdfBytes!,
                _currentPage - 1,
              );
          if (mounted) setState(() => _currentPageWordBounds = bounds);
        }
        if (mounted) {
          setState(() {
            _ttsReadingText = pageText;
            _ttsWordStart = 0;
            _ttsWordEnd = 0;
            // _showTtsReadingPanel = true;
          });
        }
        await _ttsService.speak(pageText);
      } else {
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
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_isDrawMode) {
      _saveCurrentPageDrawings();
      _persistDrawings();
    }
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, _currentPage);
    _ttsService.stop();
    _removePdfWordHighlight();
    _ttsProgressTimer?.cancel();
    _saveProgressTimer?.cancel();
    _readingTimeTimer?.cancel();
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

  Widget _buildPdfViewer() {
    return SfPdfViewer.file(
      File(widget.fileUrl),
      controller: _pdfController,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onDocumentLoadFailed: _onDocumentLoadFailed,
      enableTextSelection: true,
      onTextSelectionChanged: (details) {
        if (details.selectedText != null && details.selectedText!.isNotEmpty) {
          setState(() {
            _selectedText = details.selectedText;
          });
        }
      },
      canShowScrollHead: false,
      canShowScrollStatus: false,
      scrollDirection: PdfScrollDirection.vertical,
    );
  }

  Widget _buildPdfViewerFromMemory() {
    return SfPdfViewer.memory(
      _pdfBytes!,
      controller: _pdfController,
      onDocumentLoaded: _onDocumentLoaded,
      onPageChanged: _onPageChanged,
      onDocumentLoadFailed: _onDocumentLoadFailed,
      enableTextSelection: true,
      onTextSelectionChanged: (details) {
        if (details.selectedText != null && details.selectedText!.isNotEmpty) {
          setState(() {
            _selectedText = details.selectedText;
          });
        }
      },
      canShowScrollHead: false,
      canShowScrollStatus: false,
      scrollDirection: PdfScrollDirection.vertical,
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
            icon: Icon(Icons.fullscreen, color: Colors.white),
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
                await _ttsService.stop();
                _removePdfWordHighlight();
                setState(() {
                  _isReadingContinuous = false;
                  _currentPageWordBounds = null;
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
              if (_isReadingContinuous) {
                await _ttsService.stop();
                _removePdfWordHighlight();
                setState(() {
                  _isReadingContinuous = false;
                  _showTtsReadingPanel = false;
                  _currentPageWordBounds = null;
                });
              }
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
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
    final showViewer =
        !_isLoading && _error == null && (_isLocal || _pdfBytes != null);

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
                    onPressed: () => Navigator.pop(context),
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
                            if (_totalPages > 0)
                              Container(
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
                                    _currentPage,
                                    _totalPages,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                actions:
                    _visibleAppbarToolAction
                        ? _buildAppBarToolActions()
                        : [
                          Container(
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
                                      'search',
                                      Icons.search_rounded,
                                      AppLocalizations.current.search,
                                      Colors.teal,
                                    ),
                                    _buildMenuItem(
                                      'zoom_in_out',
                                      Icons.zoom_in,
                                      AppLocalizations.current.pdf_zoom_in_out,
                                      Colors.blue,
                                    ),
                                    _buildMenuItem(
                                      'toolbar',
                                      Icons.settings_overscan_rounded,
                                      AppLocalizations.current.pdf_toolbar,
                                      Colors.grey,
                                    ),
                                    if (_hasInternet)
                                      _buildMenuItem(
                                        'read_continuous_ebook',
                                        Icons.play_circle_outline,
                                        AppLocalizations.current.pdf_read_ebook,
                                        Colors.teal,
                                      ),
                                    // _buildMenuItem(
                                    //   'bookmark',
                                    //   Icons.bookmark_rounded,
                                    //   "bookmark",
                                    //   Colors.teal,
                                    // ),
                                    _buildMenuItem(
                                      'share',
                                      Icons.share_rounded,
                                      AppLocalizations.current.pdf_share,
                                      Colors.blue,
                                    ),
                                    // _buildMenuItem(
                                    //   'draw',
                                    //   Icons.brush_rounded,
                                    //   AppLocalizations.current.pdf_draw,
                                    //   Colors.deepPurple,
                                    // ),
                                    // _buildMenuItem(
                                    //   'notes',
                                    //   Icons.note_add_rounded,
                                    //   AppLocalizations.current.pdf_notes,
                                    //   Colors.orange,
                                    // ),
                                  ],
                            ),
                          ),
                        ],
              )
              : null,
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.current.pdf_cannot_load,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLocal ? null : () => _loadFromNetwork(),
                    child: Text(AppLocalizations.current.retry),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _showPdfInfo(),
                    child: Text(AppLocalizations.current.pdf_view_file_info),
                  ),
                ],
              ),
            )
          else if (showViewer)
            Stack(
              children: [
                IgnorePointer(
                  ignoring: _isDrawMode,
                  child:
                      _pdfBytes != null
                          ? _buildPdfViewerFromMemory()
                          : _buildPdfViewer(),
                ),
                if (_hasDrawingsForCurrentPage || _isDrawMode)
                  _buildDrawingOverlay(),
              ],
            ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.first_page_rounded,
                      isEnabled: _currentPage > 1,
                      onPressed: () => _pdfController.jumpToPage(1),
                    ),
                    _buildNavButton(
                      icon: Icons.chevron_left_rounded,
                      isEnabled: _currentPage > 1,
                      onPressed: () => _pdfController.previousPage(),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
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
                        AppLocalizations.current.pdf_page_of(
                          _currentPage,
                          _totalPages,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    _buildNavButton(
                      icon: Icons.chevron_right_rounded,
                      isEnabled: _currentPage < _totalPages,
                      onPressed: () => _pdfController.nextPage(),
                    ),
                    _buildNavButton(
                      icon: Icons.last_page_rounded,
                      isEnabled: _currentPage < _totalPages,
                      onPressed: () => _pdfController.jumpToPage(_totalPages),
                    ),
                  ],
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
      setState(() {
        _ttsWordStart = start.clamp(0, text.length);
        _ttsWordEnd = end.clamp(0, text.length);
      });
      _updatePdfWordHighlight(start, end);
    };

    _ttsService.onSpeechComplete = (_) {
      _removePdfWordHighlight();
      // Nếu đang đọc liên tục, chuyển sang trang tiếp theo
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
      } else {
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
      _removePdfWordHighlight();
      setState(() {
        _isReadingContinuous = false;
        _showTtsReadingPanel = false;
        _currentPageWordBounds = null;
      });
      _ttsProgressTimer?.cancel();
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_tts_read_error(error),
        snackBarType: SnackBarType.error,
      );
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
  }

  Future<void> _readNextPage() async {
    if (_currentPage >= _totalPages) {
      if (!mounted) return;
      setState(() {
        _isReadingContinuous = false;
      });
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_document_read_complete,
        snackBarType: SnackBarType.success,
      );
      return;
    }

    // Lưu số trang cần đọc trước khi nextPage() (vì _onPageChanged sẽ cập nhật _currentPage ngay)
    final nextPageNumber = _currentPage + 1;
    _pdfController.nextPage();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || !_isReadingContinuous) return;

    _removePdfWordHighlight();
    if (mounted) setState(() => _currentPageWordBounds = null);

    try {
      // Đọc trang tiếp theo luôn lấy full trang, không dùng selection của trang cũ
      final pageText = await _extractPageText(
        nextPageNumber,
        useSelection: false,
      );
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.setLanguageFromText(pageText);
        if (_pdfBytes != null) {
          final bounds =
              await PdfTextExtractorService.extractPageTextWithWordBounds(
                _pdfBytes!,
                nextPageNumber - 1,
              );
          if (mounted) setState(() => _currentPageWordBounds = bounds);
        }
        if (mounted) {
          setState(() {
            _ttsReadingText = pageText;
            _ttsWordStart = 0;
            _ttsWordEnd = 0;
            // _showTtsReadingPanel = true;
          });
        }
        await _ttsService.speak(pageText);
      } else {
        if (nextPageNumber < _totalPages) {
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
      if (nextPageNumber < _totalPages) {
        _readNextPage();
      } else {
        if (mounted) setState(() => _isReadingContinuous = false);
      }
    }
  }

  Future<String?> _extractPageText(
    int pageNumber, {
    bool useSelection = true,
  }) async {
    if (useSelection && _selectedText != null && _selectedText!.isNotEmpty) {
      return _selectedText;
    }

    if (_pdfBytes == null) {
      return null;
    }

    try {
      final text = await PdfTextExtractorService.extractTextFromPage(
        _pdfBytes!,
        pageNumber - 1,
      );
      if (text != null && text.isNotEmpty) {
        return text;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Panel hiển thị text đang đọc với từ đang đọc được đánh dấu
  Widget _buildTtsReadingPanel() {
    final text = _ttsReadingText ?? '';
    final len = text.length;
    final start = _ttsWordStart.clamp(0, len);
    final end = _ttsWordEnd.clamp(0, len);
    final hasHighlight = start < end;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh tiêu đề + nút đóng
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.record_voice_over,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.current.pdf_reading,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, size: 22),
                      onPressed: () {
                        setState(() => _showTtsReadingPanel = false);
                      },
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),
              // Nội dung với từ đang đọc được đánh dấu
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: RichText(
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      children: [
                        if (start > 0) TextSpan(text: text.substring(0, start)),
                        if (hasHighlight)
                          TextSpan(
                            text: text.substring(start, end),
                            style: TextStyle(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.35),
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        if (end < len) TextSpan(text: text.substring(end)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        _currentProgress = interaction.readingProgress;
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
    _saveProgressTimer = Timer(const Duration(seconds: 2), () {
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
        setState(() {
          _currentProgress = savedProgress;
          _lastSavedPage = page;
        });
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

  Future<void> _embedDrawingsIntoPdfAndSave() async {
    if (_allDrawStrokes.isEmpty) return;
    if (_drawOverlaySize.width <= 0 || _drawOverlaySize.height <= 0) return;

    Uint8List? pdfBytesToUse = _pdfBytes;
    if (_isLocal && pdfBytesToUse == null) {
      final file = File(widget.fileUrl);
      if (await file.exists()) {
        pdfBytesToUse = await file.readAsBytes();
      }
    }
    if (pdfBytesToUse == null || pdfBytesToUse.isEmpty) return;

    final newBytes = await PdfDrawingService.embedDrawings(
      pdfBytes: pdfBytesToUse,
      strokesByPage: _allDrawStrokes,
      overlaySize: _drawOverlaySize,
      strokeColor: _drawColor,
      strokeWidth: _strokeWidth,
    );

    if (newBytes == null || !mounted) return;

    setState(() {
      _pdfBytes = newBytes;
      _allDrawStrokes = {};
      _currentPageStrokes = [];
    });
    await _persistDrawings();

    if (_isLocal) {
      try {
        await File(widget.fileUrl).writeAsBytes(newBytes);
      } catch (_) {}
    }

    if (mounted) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.pdf_drawings_saved,
        snackBarType: SnackBarType.success,
      );
    }
  }

  Widget _buildDrawingOverlay() {
    final strokesToShow =
        _isDrawMode
            ? [
              ..._currentPageStrokes,
              if (_currentStroke.isNotEmpty) _currentStroke,
            ]
            : _allDrawStrokes[_currentPage] ?? [];
    final colorToShow = _isDrawMode ? _drawColor : Colors.red;

    return LayoutBuilder(
      builder: (context, constraints) {
        final overlaySize = constraints.biggest;
        if (_isDrawMode && overlaySize != Size.zero) {
          _drawOverlaySize = overlaySize;
        }
        return Stack(
          children: [
            Positioned.fill(
              child:
                  _isDrawMode
                      ? GestureDetector(
                        onPanStart: (d) {
                          setState(() {
                            _currentStroke = [d.localPosition];
                          });
                        },
                        onPanUpdate: (d) {
                          setState(() {
                            _currentStroke.add(d.localPosition);
                          });
                        },
                        onPanEnd: (_) {
                          if (_currentStroke.length > 1) {
                            setState(() {
                              _currentPageStrokes.add(
                                List<Offset>.from(_currentStroke),
                              );
                              _currentStroke = [];
                            });
                          } else {
                            setState(() => _currentStroke = []);
                          }
                        },
                        child: CustomPaint(
                          painter: _DrawingPainter(
                            strokes: strokesToShow,
                            color: colorToShow,
                            strokeWidth: _strokeWidth,
                          ),
                          size: Size.infinite,
                        ),
                      )
                      : IgnorePointer(
                        child: CustomPaint(
                          painter: _DrawingPainter(
                            strokes: strokesToShow,
                            color: colorToShow,
                            strokeWidth: _strokeWidth,
                          ),
                          size: Size.infinite,
                        ),
                      ),
            ),
            if (_isDrawMode)
              Positioned(
                left: 16,
                right: 16,
                bottom: showNavigationBar ? 100 : 24,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Wrap(
                          spacing: 4,
                          children:
                              [
                                Colors.red,
                                Colors.blue,
                                Colors.green,
                                Colors.black,
                              ].map((c) {
                                return GestureDetector(
                                  onTap:
                                      () => setState(() {
                                        _drawColor = c;
                                      }),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            _drawColor == c
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        IconButton(
                          icon: Icon(Icons.undo_rounded),
                          onPressed: () {
                            if (_currentPageStrokes.isNotEmpty) {
                              setState(() => _currentPageStrokes.removeLast());
                            }
                          },
                          tooltip: AppLocalizations.current.pdf_undo,
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            _saveCurrentPageDrawings();
                            if (_allDrawStrokes.isNotEmpty) {
                              await _embedDrawingsIntoPdfAndSave();
                            } else {
                              await _persistDrawings();
                            }
                            if (mounted) setState(() => _isDrawMode = false);
                          },
                          icon: Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            AppLocalizations.current.pdf_done_drawing,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotesList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.current.pdf_notes_list,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_circle_rounded),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showAddNoteDialog();
                            },
                            tooltip: AppLocalizations.current.pdf_add_note,
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      _notes.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_add_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  AppLocalizations.current.pdf_no_notes,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _showAddNoteDialog();
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text(
                                    AppLocalizations.current.pdf_add_note,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.builder(
                            controller: controller,
                            padding: EdgeInsets.all(16),
                            itemCount: _notes.length,
                            itemBuilder: (_, i) {
                              final n = _notes[i];
                              final page = n['page'] as int? ?? 0;
                              final text = n['text'] as String? ?? '';
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    child: Text(page.toString()),
                                  ),
                                  title: Text(
                                    text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      setState(() => _notes.removeAt(i));
                                      await _saveNotes();
                                      if (ctx.mounted) Navigator.pop(ctx);
                                      _showNotesList();
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.note_add_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text(AppLocalizations.current.pdf_add_note),
            ],
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppLocalizations.current.pdf_note_hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.current.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _notes.add({
                      'page': _currentPage,
                      'text': text,
                      'timestamp': DateTime.now().toIso8601String(),
                    });
                  });
                  _saveNotes();
                  Navigator.pop(ctx);
                  AppSnackBar.show(
                    context,
                    message: AppLocalizations.current.pdf_note_added,
                    snackBarType: SnackBarType.success,
                  );
                }
              },
              child: Text(AppLocalizations.current.save),
            ),
          ],
        );
      },
    );
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

  void _showPdfInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.current.pdf_file_info),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.current.pdf_path_label),
              SizedBox(height: 8),
              Text(
                widget.fileUrl,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.current.close),
            ),
          ],
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  _DrawingPainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..isAntiAlias = true;

    for (final stroke in strokes) {
      if (stroke.length > 1) {
        for (var i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.color != color;
  }
}
