import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.fileUrl,
    required this.title,
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
  @override
  void initState() {
    super.initState();
    final file = File(widget.fileUrl);
    _isLocal = file.existsSync();
    if (_isLocal) {
      setState(() => _isLoading = false);
    } else {
      _loadFromNetwork();
    }
      _loadUserDataSettings();
  } 

  // load user data settings
  Future<void> _loadUserDataSettings() async{
    final hideNavigationBar = await SharedPreferenceUtil.getHideNavigationBar();
    setState(() {
        showToolbar = !hideNavigationBar;
    });
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

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    final total = details.document.pages.count;
    setState(() => _totalPages = total);
    SharedPreferenceUtil.getPdfReadingPosition(widget.fileUrl).then((savedPage) {
      if (savedPage != null && savedPage >= 1 && savedPage <= total && mounted) {
        _pdfController.jumpToPage(savedPage);
        setState(() => _currentPage = savedPage);
      }
    });
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    final page = details.newPageNumber;
    setState(() => _currentPage = page);
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, page);
  }

  void _onDocumentLoadFailed(PdfDocumentLoadFailedDetails details) {
    setState(() => _error = details.description);
  }

  @override
  void dispose() {
    SharedPreferenceUtil.savePdfReadingPosition(widget.fileUrl, _currentPage);
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
        prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.9), size: 22),
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
    final searching = _searchResult != null && !_searchResult!.isSearchCompleted && total == 0;
    final noResults = _searchResult != null && _searchResult!.isSearchCompleted && total == 0 &&
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
          icon: Icon(Icons.keyboard_arrow_up_rounded, color: canPrev ? Colors.white : Colors.white54),
          onPressed: canPrev ? () => _searchResult!.previousInstance() : null,
          iconSize: 24,
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: canNext ? Colors.white : Colors.white54),
          onPressed: canNext ? () => _searchResult!.nextInstance() : null,
          iconSize: 24,
        ),
      ]
      else if (searching)
        Center(
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
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
    final showViewer = !_isLoading && _error == null && (_isLocal || _pdfBytes != null);

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
        title: _isSearchVisible
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
        actions: _isSearchVisible
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
              onSelected: (value) {
                switch (value) {
                  case 'search':
                    setState(() => _isSearchVisible = true);
                    break;
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
                  case 'hide_navigation_bar':
                    setState(() {
                      showToolbar = !showToolbar;
                    });
                    SharedPreferenceUtil.saveHideNavigationBar(showToolbar);
                    break;
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: Colors.teal,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Tìm kiếm'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'jump',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                          color: Colors.blue.withValues(alpha: 0.1),
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
                  value: 'hide_navigation_bar',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          showToolbar ? Icons.keyboard_arrow_down 
                          : Icons.keyboard_arrow_up,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(showToolbar ? 'Ẩn thanh điều hướng' : 'Hiện thanh điều hướng'),
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
      bottomNavigationBar: !showToolbar || !showViewer
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          Theme.of(context).primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
        iconSize: 18,
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
              Text('Đường dẫn:'),
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
}
