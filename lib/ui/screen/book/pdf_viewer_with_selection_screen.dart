import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/user_interaction_cubit.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readbox/ui/widget/tts_control_widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'package:readbox/utils/pdf_text_extractor.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'dart:async';


/// PDF Viewer với tính năng chọn text, copy và annotations
/// Sử dụng Syncfusion PDF Viewer
class PdfViewerWithSelectionScreen extends StatefulWidget {
  final String fileUrl;
  final String title;
  final String bookId;
  const PdfViewerWithSelectionScreen({
    super.key,
    required this.fileUrl,
    required this.title,
    required this.bookId,
  });

  @override
  State<PdfViewerWithSelectionScreen> createState() => _PdfViewerWithSelectionScreenState();
}

class _PdfViewerWithSelectionScreenState extends State<PdfViewerWithSelectionScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late UserInteractionCubit _userInteractionCubit;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearchVisible = false;
  bool _showToolbar = true;
  String? _selectedText;
  
  // TTS related
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isTTSActive = false;
  bool _showTTSControls = false;
  bool _isReadingContinuous = false;
  Timer? _ttsProgressTimer;
  
  // PDF data for text extraction
  Uint8List? _pdfBytes;
  bool _isLoadingPdf = false;
  
  // Reading progress tracking
  Timer? _saveProgressTimer;
  int _lastSavedPage = 0;
  // ignore: unused_field
  ReadingProgressModel? _currentProgress; // Giữ để theo dõi tiến trình hiện tại (có thể dùng để hiển thị sau)

  // get bind host url
  String get bindHostUrl => '${ApiConstant.apiHostStorage}${widget.fileUrl}';
  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadPdfBytes();
    _userInteractionCubit = context.read<UserInteractionCubit>();
    _loadReadingProgress();
  }

  /// Load PDF bytes để sử dụng cho text extraction
  Future<void> _loadPdfBytes() async {
    setState(() {
      _isLoadingPdf = true;
    });

    try {
      final bytes = await PdfTextExtractorService.downloadPdf(bindHostUrl);
      setState(() {
        _pdfBytes = bytes;
        _isLoadingPdf = false;
      });
      debugPrint('PDF bytes loaded: ${bytes?.length} bytes');
    } catch (e) {
      debugPrint('Error loading PDF bytes: $e');
      setState(() {
        _isLoadingPdf = false;
      });
    }
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    _setupTTSCallbacks();
  }

  void _setupTTSCallbacks() {
    _ttsService.onSpeechStart = (_) {
      setState(() {
        _isTTSActive = true;
      });
    };

    _ttsService.onSpeechComplete = (_) {
      setState(() {
        _isTTSActive = false;
      });
      
      // Nếu đang đọc liên tục, chuyển sang trang tiếp theo
      if (_isReadingContinuous && _currentPage < _totalPages) {
        _readNextPage();
      } else {
        _isReadingContinuous = false;
        _ttsProgressTimer?.cancel();
      }
    };

    _ttsService.onSpeechError = (error) {
      setState(() {
        _isTTSActive = false;
        _isReadingContinuous = false;
      });
      _ttsProgressTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đọc: $error'),
          backgroundColor: Colors.red,
        ),
      );
    };
  }

  @override
  void dispose() {
    _ttsService.stop();
    _ttsProgressTimer?.cancel();
    _saveProgressTimer?.cancel();
    _saveReadingProgressNow(); // Lưu tiến trình cuối cùng khi dispose
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _showToolbar ? _buildAppBar() : null,
      body: Stack(
        children: [
          // PDF Viewer với text selection
          SfPdfViewer.network(
            bindHostUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            
            // Enable text selection
            enableTextSelection: true,
            
            // Callback khi trang thay đổi
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
              _onPageChanged(details.newPageNumber);
            },
            
            // Callback khi document load xong
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
              });
            },
            
            // Callback khi text được chọn
            onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                setState(() {
                  _selectedText = details.selectedText;
                });
                _showTextSelectionMenu(details);
              }
            },
          ),

          // Search bar
          if (_isSearchVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildSearchBar(),
            ),

          // Toggle toolbar button
          if (!_showToolbar)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() {
                    _showToolbar = !_showToolbar;
                  });
                },
                child: Icon(Icons.menu),
              ),
            ),
        ],
      ),
      
      // Bottom navigation
      bottomNavigationBar: _showToolbar ? _buildBottomBar() : null,
      
      // Floating action buttons
      floatingActionButton: _buildFloatingButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // TTS Controls (hiện ở bottom khi đang đọc)
      bottomSheet: _showTTSControls ? _buildTTSControls() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
      actions: [
        // Search button
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
        ),
        
        // More options
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
            itemBuilder: (BuildContext context) => [
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
              PopupMenuDivider(),
              _buildMenuItem(
                'hide_toolbar',
                Icons.fullscreen,
                'Ẩn thanh công cụ',
                Colors.purple,
              ),
              PopupMenuDivider(),
              _buildMenuItem(
                'read_page',
                Icons.volume_up,
                'Đọc trang này',
                Colors.orange,
              ),
              _buildMenuItem(
                'read_continuous',
                Icons.play_circle_outline,
                'Đọc liên tục',
                Colors.teal,
              ),
              
            ],
          ),
        ),
      ],
    );
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

  void _handleMenuAction(String value) {
    switch (value) {
      case 'jump':
        _showJumpToPage();
        break;
      case 'zoom_in':
        _pdfViewerController.zoomLevel += 0.25;
        break;
      case 'zoom_out':
        if (_pdfViewerController.zoomLevel > 1.0) {
          _pdfViewerController.zoomLevel -= 0.25;
        }
        break;
      case 'fit_page':
        _pdfViewerController.zoomLevel = 1.0;
        break;
      case 'hide_toolbar':
        setState(() {
          _showToolbar = false;
        });
        break;
      case 'read_page':
        _readCurrentPage();
        break;
    }
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm trong PDF...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _pdfViewerController.searchText(text);
                  }
                },
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearchVisible = false;
                });
                _pdfViewerController.clearSelection();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
            onPressed: () => _pdfViewerController.jumpToPage(1),
          ),
          _buildNavButton(
            icon: Icons.chevron_left_rounded,
            isEnabled: _currentPage > 1,
            onPressed: () => _pdfViewerController.previousPage(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          _buildNavButton(
            icon: Icons.chevron_right_rounded,
            isEnabled: _currentPage < _totalPages,
            onPressed: () => _pdfViewerController.nextPage(),
          ),
          _buildNavButton(
            icon: Icons.last_page_rounded,
            isEnabled: _currentPage < _totalPages,
            onPressed: () => _pdfViewerController.jumpToPage(_totalPages),
          ),
        ],
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
        color: isEnabled
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
        iconSize: 28,
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TTS button - đọc text đã chọn hoặc trang hiện tại
        FloatingActionButton(
          heroTag: 'tts',
          onPressed: _toggleTTS,
          backgroundColor: _isTTSActive ? Colors.red : Colors.green,
          tooltip: _isTTSActive ? 'Dừng đọc' : 'Đọc text',
          child: Icon(
            _isTTSActive ? Icons.stop : Icons.volume_up,
            color: Colors.white,
          ),
        ),
        
        // Copy selected text button (hiện khi có text được chọn)
        if (_selectedText != null && _selectedText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: FloatingActionButton.extended(
              heroTag: 'copy',
              onPressed: _copySelectedText,
              icon: Icon(Icons.content_copy),
              label: Text('Copy'),
              backgroundColor: Colors.blue,
            ),
          ),
        
      ],
    );
  }

  void _showTextSelectionMenu(PdfTextSelectionChangedDetails details) {
    // Menu sẽ tự động hiện khi chọn text
    // Syncfusion tự động xử lý context menu
  }

  Future<void> _copySelectedText() async {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _selectedText!));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã copy ${_selectedText!.length} ký tự',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      
      setState(() {
        _selectedText = null;
      });
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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(pageController.text);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _pdfViewerController.jumpToPage(page);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Số trang không hợp lệ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Đến'),
            ),
          ],
        );
      },
    );
  }

  // ========== TTS Functions ==========

  /// Toggle TTS - đọc text đã chọn hoặc dừng
  Future<void> _toggleTTS() async {
    if (_isTTSActive) {
      await _ttsService.stop();
      setState(() {
        _isTTSActive = false;
        _isReadingContinuous = false;
        _showTTSControls = false;
      });
      _ttsProgressTimer?.cancel();
    } else {
      // Nếu có text đã chọn, đọc text đó
      if (_selectedText != null && _selectedText!.isNotEmpty) {
        await _ttsService.speak(_selectedText!);
        setState(() {
          _showTTSControls = true;
        });
      } else {
        // Nếu không có text chọn, đọc trang hiện tại
        await _readCurrentPage();
      }
    }
  }


  /// Đọc trang hiện tại
  Future<void> _readCurrentPage() async {
    try {
      // Ưu tiên dùng text đã chọn nếu có
      String? textToRead = _selectedText;
      
      // Nếu không có text chọn, thử trích xuất từ trang
      if (textToRead == null || textToRead.isEmpty) {
        textToRead = await _extractPageText(_currentPage);
      }
      
      if (textToRead != null && textToRead.isNotEmpty) {
        await _ttsService.speak(textToRead);
        setState(() {
          _showTTSControls = true;
        });
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Đang đọc ${textToRead.length} ký tự từ trang $_currentPage'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Không thể trích xuất text từ trang này'),
                SizedBox(height: 4),
                Text(
                  'Vui lòng chọn text bằng tay để đọc',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đọc trang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Đọc trang tiếp theo (dùng cho đọc liên tục)
  Future<void> _readNextPage() async {
    if (_currentPage >= _totalPages) {
      setState(() {
        _isReadingContinuous = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đọc hết tài liệu'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // Chuyển sang trang tiếp theo
    _pdfViewerController.nextPage();
    
    // Đợi một chút để trang load
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Đọc trang mới
    try {
      final pageText = await _extractPageText(_currentPage + 1);
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.speak(pageText);
      } else {
        // Nếu trang không có text, chuyển tiếp
        if (_currentPage < _totalPages) {
          _readNextPage();
        }
      }
    } catch (e) {
      debugPrint('Error reading next page: $e');
      if (_currentPage < _totalPages) {
        _readNextPage();
      }
    }
  }

  /// Đọc liên tục từ trang hiện tại
  Future<void> _readContinuousPages() async {
    setState(() {
      _isReadingContinuous = true;
      _showTTSControls = true;
    });

    // Bắt đầu đọc từ trang hiện tại
    await _readCurrentPage();
  }

  /// Trích xuất text từ một trang PDF
  Future<String?> _extractPageText(int pageNumber) async {
    // Nếu có text đã chọn, ưu tiên dùng text đó
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      return _selectedText;
    }

    // Nếu chưa load PDF bytes, thử load
    if (_pdfBytes == null) {
      if (_isLoadingPdf) {
        // Đang load, đợi một chút
        await Future.delayed(const Duration(milliseconds: 500));
        if (_pdfBytes == null) {
          return null;
        }
      } else {
        // Chưa load, load ngay
        await _loadPdfBytes();
        if (_pdfBytes == null) {
          return null;
        }
      }
    }

    try {
      // Sử dụng PdfTextExtractorService để trích xuất text
      // Page number trong Syncfusion bắt đầu từ 1, nhưng extractor dùng 0-based
      final text = await PdfTextExtractorService.extractTextFromPage(
        _pdfBytes!,
        pageNumber - 1, // Convert to 0-based index
      );
      
      if (text != null && text.isNotEmpty) {
        debugPrint('Extracted ${text.length} characters from page $pageNumber');
        return text;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error extracting page text: $e');
      return null;
    }
  }

  /// Build TTS Controls widget
  Widget? _buildTTSControls() {
    if (!_showTTSControls) return null;

    String textToRead = '';
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      textToRead = _selectedText!;
    }

    return TTSControlWidget(
      textToRead: textToRead,
      onStart: () {
        setState(() {
          _isTTSActive = true;
        });
      },
      onStop: () {
        setState(() {
          _isTTSActive = false;
          _isReadingContinuous = false;
          _showTTSControls = false;
        });
        _ttsProgressTimer?.cancel();
      },
    );
  }

  // ========== Reading Progress Tracking Functions ==========

  /// Load reading progress khi mở sách
  Future<void> _loadReadingProgress() async {
    try {
      final interaction = await _userInteractionCubit.
      getInteractionAction(targetType: InteractionTarget.book,
       actionType: InteractionType.reading, targetId: widget.bookId);
      if (mounted) {
        if (interaction.isReading) {
          _currentProgress = interaction.readingProgress;
          if (_currentProgress?.currentPage != null 
          && _currentProgress!.currentPage! > 0) {
            _lastSavedPage = _currentProgress!.currentPage!;
            _currentPage = _currentProgress!.currentPage!;
            _pdfViewerController.jumpToPage(_currentProgress!.currentPage!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading reading progress: $e');
      // Không hiển thị lỗi cho user vì không quan trọng lắm
    }
  }

  /// Xử lý khi trang thay đổi - lưu tiến trình với debounce
  void _onPageChanged(int newPage) {
    // Chỉ lưu nếu trang đã thay đổi đáng kể (tránh lưu quá nhiều)
    if (newPage == _lastSavedPage) return;

    // Hủy timer cũ nếu có
    _saveProgressTimer?.cancel();

    // Tạo timer mới với debounce 2 giây
    _saveProgressTimer = Timer(const Duration(seconds: 2), () {
      _saveReadingProgress(newPage);
    });
  }

  /// Lưu tiến trình đọc (với debounce)
  Future<void> _saveReadingProgress(int page) async {
    if (page == _lastSavedPage) return; // Tránh lưu trùng

    try {
      // Tính toán progress percentage (0.0 to 1.0)
      double progressValue = 0.0;
      if (_totalPages > 0) {
        progressValue = page / _totalPages;
      }

      // Tạo ReadingProgressModel từ JSON
      final progressModel = ReadingProgressModel.fromJson({
        'bookId': widget.bookId,
        'currentPage': page,
        'progress': progressValue,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      // Lưu tiến trình
      final savedProgress = await _userInteractionCubit.
      saveReadingProgress
      (targetType: InteractionTarget.book, actionType: InteractionType.reading, targetId: widget.bookId, readingProgress: progressModel);

      if (mounted) {
        setState(() {
          _currentProgress = savedProgress;
          _lastSavedPage = page;
        });
        debugPrint('Saved reading progress: page $page (${(progressValue * 100).toStringAsFixed(1)}%)');
      }
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
      // Không hiển thị lỗi cho user để không làm gián đoạn việc đọc
    }
  }

  /// Lưu tiến trình ngay lập tức (khi dispose hoặc khi cần)
  Future<void> _saveReadingProgressNow() async {
    _saveProgressTimer?.cancel(); // Hủy timer nếu có
    
    // Lưu trang hiện tại
    if (_currentPage > 0 && _currentPage != _lastSavedPage) {
      await _saveReadingProgress(_currentPage);
    }
  }
}

