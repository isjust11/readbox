import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/user_interaction_cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
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
  bool _isSearchVisible = false;
  PdfTextSearchResult? _searchResult;
  VoidCallback? _searchResultListener;
  bool showToolbar = true;
  bool showNavigationBar = true;
  // Text selection & TTS
  String? _selectedText;
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isReadingContinuous = false;
  Timer? _ttsProgressTimer;
  bool _hasInternet = false;

  // Reading progress tracking (server side)
  UserInteractionCubit? _userInteractionCubit;
  Timer? _saveProgressTimer;
  int _lastSavedPage = 0;
  ReadingProgressModel? _currentProgress;

  // Reading time tracking
  DateTime? _readingStartTime;
  int _accumulatedReadingTime = 0;
  Timer? _readingTimeTimer;

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
  }

  // load user data settings
  Future<void> _loadUserDataSettings() async {
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    setState(() {
      showToolbar = !hideNavigationBar;
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
      widget.fileUrl,
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
    setState(() => _currentPage = page);
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, page);
    _onServerPageChanged(page);
  }

  void _onDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    setState(() => _error = details.description);
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'jump':
        _showJumpToPage();
        break;
      case 'zoom_in':
        _pdfController.zoomLevel += 0.25;
        break;
      case 'zoom_out':
        if (_pdfController.zoomLevel > 1.0) {
          _pdfController.zoomLevel -= 0.25;
        }
        break;
      case 'fit_page':
        _pdfController.zoomLevel = 1.0;
        break;
      case 'hide_toolbar':
        setState(() {
          showToolbar = !showToolbar;
        });
        break;
      case 'hide_navigation_bar':
        setState(() {
          showNavigationBar = !showNavigationBar;
        });
        break;
      case 'read_page':
        _readCurrentPage();
        break;
      case 'read_continuous':
        // _readContinuous();
        break;
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
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, _currentPage);
    _ttsService.stop();
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
    setState(() => _isSearchVisible = false);
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

  Widget _buildAppBarSearchTitle() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      style: TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Tìm trong PDF...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.white.withValues(alpha: 0.9),
          size: 22,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.arrow_forward_rounded, color: Colors.white),
          onPressed: () => _runSearch(_searchQueryController.text),
          tooltip: 'Tìm',
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        isDense: true,
      ),
      onSubmitted: _runSearch,
    );
  }

  List<Widget> _buildAppBarSearchActions() {
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
      IconButton(
        icon: Icon(Icons.close_rounded, color: Colors.white),
        onPressed: _clearSearch,
        iconSize: 24,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final showViewer =
        !_isLoading && _error == null && (_isLocal || _pdfBytes != null);

    return Scaffold(
      appBar: AppBar(
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
            _isSearchVisible
                ? _buildAppBarSearchTitle()
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
                          'Trang $_currentPage/$_totalPages',
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
            _isSearchVisible
                ? _buildAppBarSearchActions()
                : [
                  Container(
                    margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.white),
                      onSelected: _handleMenuAction,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder:
                          (BuildContext context) => [
                            _buildMenuItem(
                              'search',
                              Icons.search_rounded,
                              'Tìm kiếm',
                              Colors.teal,
                            ),
                            _buildMenuItem(
                              'jump',
                              Icons.skip_next_rounded,
                              'Nhảy đến trang',
                              Theme.of(context).primaryColor,
                            ),
                            _buildMenuItem(
                              'zoom_in',
                              Icons.zoom_in,
                              'Phóng to',
                              Colors.blue,
                            ),
                            _buildMenuItem(
                              'zoom_out',
                              Icons.zoom_out,
                              'Thu nhỏ',
                              Colors.blue,
                            ),
                            _buildMenuItem(
                              'fit_page',
                              Icons.fit_screen,
                              'Vừa màn hình',
                              Colors.green,
                            ),
                            // _buildMenuItem(
                            //   'hide_toolbar',
                            //   Icons.fullscreen,
                            //   'Ẩn thanh công cụ',
                            //   Colors.purple,
                            // ),
                            if (_hasInternet)
                              _buildMenuItem(
                                'read_page',
                                Icons.volume_up,
                                'Đọc trang này',
                                Colors.orange,
                              ),
                            _buildMenuItem(
                              'share',
                              Icons.share_rounded,
                              'Chia sẻ',
                              Colors.blue,
                            ),
                            _buildMenuItem(
                              'hide_toolbar',
                              Icons.keyboard_arrow_up,
                              showToolbar
                                  ? 'Ẩn thanh điều hướng'
                                  : 'Hiện thanh điều hướng',
                              showToolbar ? Colors.grey : Colors.green,
                            ),
                          ],
                    ),
                  ),
                ],
      ),
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
                    'Không thể tải PDF',
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
                    child: Text('Thử lại'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _showPdfInfo(),
                    child: Text('Xem thông tin file'),
                  ),
                ],
              ),
            )
          else if (showViewer)
            _isLocal ? _buildPdfViewer() : _buildPdfViewerFromMemory(),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải PDF...'),
                    SizedBox(height: 8),
                    Text(
                      'Vui lòng đợi',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          !showNavigationBar || !showViewer
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
                        '$_currentPage / $_totalPages',
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
    _ttsService.onSpeechStart = (_) {
      if (!mounted) return;
    };
    _ttsService.onSpeechComplete = (_) {
      if (!mounted) return;
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
      } else {
        _isReadingContinuous = false;
        _ttsProgressTimer?.cancel();
      }
    };
    _ttsService.onSpeechError = (error) {
      if (!mounted) return;
      _ttsProgressTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đọc: $error'), backgroundColor: Colors.red),
      );
    };
  }

  Future<void> _readCurrentPage() async {
    if (!_hasInternet) return;
    try {
      String? textToRead = _selectedText;
      if (textToRead == null || textToRead.isEmpty) {
        textToRead = await _extractPageText(_currentPage);
      }

      if (textToRead != null && textToRead.isNotEmpty) {
        await _ttsService.speak(textToRead);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Đang đọc ${textToRead.length} ký tự từ trang $_currentPage',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Không thể trích xuất text từ trang này'),
                SizedBox(height: 4),
                Text(
                  'Vui lòng chọn text bằng tay để đọc',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đọc trang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _readNextPage() async {
    if (_currentPage >= _totalPages) {
      if (!mounted) return;
      setState(() {
        _isReadingContinuous = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đọc hết tài liệu'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    _pdfController.nextPage();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final pageText = await _extractPageText(_currentPage + 1);
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.speak(pageText);
      } else {
        if (_currentPage < _totalPages) {
          _readNextPage();
        }
      }
    } catch (_) {
      if (_currentPage < _totalPages) {
        _readNextPage();
      }
    }
  }

  Future<String?> _extractPageText(int pageNumber) async {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
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

  // Widget? _buildTTSControls() {
  //   if (!_showTTSControls || !_hasInternet) return null;

  //   String textToRead = '';
  //   if (_selectedText != null && _selectedText!.isNotEmpty) {
  //     textToRead = _selectedText!;
  //   }

  //   return TTSControlWidget(
  //     textToRead: textToRead,
  //     onStart: () {
  //       setState(() {
  //         _isTTSActive = true;
  //       });
  //     },
  //     onStop: () {
  //       setState(() {
  //         _isTTSActive = false;
  //         _isReadingContinuous = false;
  //         _showTTSControls = false;
  //       });
  //       _ttsProgressTimer?.cancel();
  //     },
  //   );
  // }

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
                'Nhảy đến trang',
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
                  labelText: 'Số trang',
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
                'Hủy',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Số trang không hợp lệ'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    'Đến',
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
          title: Text('Thông tin file PDF'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đường dẫn:'),
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
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
