import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:readbox/ui/widget/tts_control_widget.dart';
import 'package:readbox/utils/text_to_speech_service.dart';
import 'dart:async';

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.fileUrl,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  
  // TTS related
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _isTTSActive = false;
  bool _showTTSControls = false;
  bool _isReadingContinuous = false;
  Timer? _ttsProgressTimer;
  PdfDocument? _pdfDocument;

  @override
  void initState() {
    super.initState();
    _initializePdf();
    _initializeTTS();
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

  Future<void> _initializePdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      if (File(widget.fileUrl).existsSync()) {
        _pdfController = PdfController(
          document: PdfDocument.openFile(File(widget.fileUrl).path),
        );
      } else {
        _pdfController = PdfController(
          document: PdfDocument.openData(
            _downloadPdf(),
          ),
        );
      }

      // Wait for document to load
      _pdfDocument = await _pdfController.document;
      
      setState(() {
        _isLoading = false;
        _totalPages = _pdfController.pagesCount ?? 0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _downloadPdf() async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        widget.fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (e) {
      throw Exception('Không thể tải file PDF: $e');
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _ttsProgressTimer?.cancel();
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Trang $_currentPage/$_totalPages',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.bookmark_border_rounded, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đánh dấu trang $_currentPage'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.white),
              onSelected: (value) {
                switch (value) {
                  case 'jump':
                    _showJumpToPage();
                    break;
                  case 'share':
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tính năng chia sẻ đang phát triển'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    break;
                  case 'read_page':
                    _readCurrentPage();
                    break;
                  case 'read_continuous':
                    _readContinuousPages();
                    break;
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'jump',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.skip_next_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Nhảy đến trang'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Chia sẻ'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'read_page',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.volume_up,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Đọc trang này'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'read_continuous',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.teal,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Đọc liên tục'),
                    ],
                  ),
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
                    onPressed: () {
                      _initializePdf();
                    },
                    child: Text('Thử lại'),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      _showPdfInfo();
                    },
                    child: Text('Xem thông tin file'),
                  ),
                ],
              ),
            )
          else if (!_isLoading)
            PdfView(
              controller: _pdfController,
              scrollDirection: Axis.vertical,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              onDocumentLoaded: (document) {
                setState(() {
                  _totalPages = document.pagesCount;
                });
              },
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
      
      // Floating TTS button
      floatingActionButton: _buildFloatingTTSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // TTS Controls (hiện ở bottom khi đang đọc)
      bottomSheet: _showTTSControls ? _buildTTSControls() : null,
      
      // Page navigation buttons
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
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
                    onPressed: () => _pdfController.jumpToPage(0),
                  ),
                  _buildNavButton(
                    icon: Icons.chevron_left_rounded,
                    isEnabled: _currentPage > 1,
                    onPressed: () => _pdfController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                    onPressed: () => _pdfController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  _buildNavButton(
                    icon: Icons.last_page_rounded,
                    isEnabled: _currentPage < _totalPages,
                    onPressed: () => _pdfController.jumpToPage(_totalPages - 1),
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
        color: isEnabled
            ? Theme.of(context).primaryColor.withOpacity(0.1)
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(pageController.text);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _pdfController.jumpToPage(page - 1);
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
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
              Text('URL:'),
              SizedBox(height: 8),
              Text(
                widget.fileUrl,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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

  // ========== TTS Functions ==========

  /// Floating TTS button
  Widget _buildFloatingTTSButton() {
    return FloatingActionButton(
      heroTag: 'tts',
      onPressed: _toggleTTS,
      backgroundColor: _isTTSActive ? Colors.red : Colors.green,
      tooltip: _isTTSActive ? 'Dừng đọc' : 'Đọc trang',
      child: Icon(
        _isTTSActive ? Icons.stop : Icons.volume_up,
        color: Colors.white,
      ),
    );
  }

  /// Toggle TTS - đọc trang hiện tại hoặc dừng
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
      await _readCurrentPage();
    }
  }

  /// Đọc trang hiện tại
  Future<void> _readCurrentPage() async {
    if (_isLoading || _error != null || _pdfDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đợi PDF tải xong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Trích xuất text từ trang hiện tại
      final pageText = await _extractPageText(_currentPage);
      
      if (pageText != null && pageText.isNotEmpty) {
        await _ttsService.speak(pageText);
        setState(() {
          _showTTSControls = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trích xuất text chưa hỗ trợ với pdfx.\nVui lòng dùng PDF Viewer With Selection.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
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
    await _pdfController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
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

  /// Trích xuất text từ một trang PDF sử dụng pdfx
  /// Note: Package pdfx không hỗ trợ trực tiếp trích xuất text
  /// Cần dùng package khác như pdf_text hoặc syncfusion_pdf để parse text
  Future<String?> _extractPageText(int pageNumber) async {
    if (_pdfDocument == null) return null;
    
    try {
      // Package pdfx chủ yếu cho rendering, không có API extract text
      // Để implement tính năng này, cần:
      // 1. Dùng package pdf_text để trích xuất text
      // 2. Hoặc chuyển sang dùng Syncfusion PDF (có API extractText)
      // 3. Hoặc dùng package pdf để parse document
      
      // Ví dụ với package pdf (cần thêm vào pubspec.yaml):
      // import 'package:pdf/pdf.dart' as pdf_lib;
      // final bytes = await _pdfDocument!.getPage(pageNumber).render(...);
      // Sau đó parse để lấy text
      
      // Tạm thời return null và hiển thị thông báo cho user
      debugPrint('PDF text extraction not implemented yet for pdfx package');
      debugPrint('Consider using Syncfusion PDF Viewer for text extraction');
      
      return null;
    } catch (e) {
      debugPrint('Error extracting page text: $e');
      return null;
    }
  }

  /// Build TTS Controls widget
  Widget? _buildTTSControls() {
    if (!_showTTSControls) return null;

    return TTSControlWidget(
      textToRead: null, // Không cần truyền text vì đã đọc rồi
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
}
