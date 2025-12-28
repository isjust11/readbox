import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF Viewer với tính năng chọn text, copy và annotations
/// Sử dụng Syncfusion PDF Viewer
class PdfViewerWithSelectionScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const PdfViewerWithSelectionScreen({
    Key? key,
    required this.fileUrl,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerWithSelectionScreenState createState() =>
      _PdfViewerWithSelectionScreenState();
}

class _PdfViewerWithSelectionScreenState
    extends State<PdfViewerWithSelectionScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearchVisible = false;
  bool _showToolbar = true;
  String? _selectedText;

  @override
  void dispose() {
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
            widget.fileUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            
            // Enable text selection
            enableTextSelection: true,
            
            // Callback khi trang thay đổi
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
        // Search button
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
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
            color: Colors.white.withOpacity(0.2),
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
              color: color.withOpacity(0.1),
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

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        
        // Bookmark button
        FloatingActionButton(
          heroTag: 'bookmark',
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
          child: Icon(Icons.bookmark_border),
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
}

