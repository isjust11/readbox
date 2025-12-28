import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF Viewer nâng cao với:
/// - Text selection & copy
/// - Highlight text
/// - Annotations (ghi chú)
/// - Export annotations
class PdfViewerAdvancedScreen extends StatefulWidget {
  final String fileUrl;
  final String title;

  const PdfViewerAdvancedScreen({
    Key? key,
    required this.fileUrl,
    required this.title,
  }) : super(key: key);

  @override
  _PdfViewerAdvancedScreenState createState() =>
      _PdfViewerAdvancedScreenState();
}

class _PdfViewerAdvancedScreenState extends State<PdfViewerAdvancedScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearchVisible = false;
  bool _showToolbar = true;
  String? _selectedText;

  // Annotation mode
  PdfInteractionMode _interactionMode = PdfInteractionMode.selection;
  
  // Lưu trữ annotations (trong thực tế nên lưu vào database)
  List<Annotation> _annotations = [];
  Color _highlightColor = Colors.yellow;

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
          // PDF Viewer
          SfPdfViewer.network(
            widget.fileUrl,
            key: _pdfViewerKey,
            controller: _pdfViewerController,
            
            // Enable text selection
            enableTextSelection: true,
            
            // Set interaction mode
            interactionMode: _interactionMode,
            
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _totalPages = details.document.pages.count;
              });
            },
            
            onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
              if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                setState(() {
                  _selectedText = details.selectedText;
                });
              }
            },
          ),

          // Search bar
          if (_isSearchVisible) _buildSearchBar(),

          // Toolbar toggle button (khi ẩn toolbar)
          if (!_showToolbar) _buildShowToolbarButton(),
          
          // Annotation mode indicator
          if (_interactionMode != PdfInteractionMode.selection)
            _buildModeIndicator(),
            
          // Annotations list (floating)
          if (_annotations.isNotEmpty)
            Positioned(
              right: 16,
              top: 16,
              child: _buildAnnotationsCounter(),
            ),
        ],
      ),

      bottomNavigationBar: _showToolbar ? _buildBottomBar() : null,
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
        // Search
        _buildHeaderButton(
          icon: Icons.search,
          onPressed: () {
            setState(() {
              _isSearchVisible = !_isSearchVisible;
            });
          },
        ),
        
        // Highlight mode
        _buildHeaderButton(
          icon: Icons.highlight,
          onPressed: () => _showHighlightOptions(),
        ),
        
        // Annotations
        _buildHeaderButton(
          icon: Icons.note_add,
          onPressed: () => _showAnnotationsList(),
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
              _buildMenuItem('jump', Icons.skip_next_rounded, 'Nhảy đến trang', Theme.of(context).primaryColor),
              _buildMenuItem('zoom_in', Icons.zoom_in, 'Phóng to', Colors.blue),
              _buildMenuItem('zoom_out', Icons.zoom_out, 'Thu nhỏ', Colors.blue),
              _buildMenuItem('fit_page', Icons.fit_screen, 'Vừa màn hình', Colors.green),
              PopupMenuDivider(),
              _buildMenuItem('export_annotations', Icons.save_alt, 'Xuất ghi chú', Colors.purple),
              _buildMenuItem('hide_toolbar', Icons.fullscreen, 'Toàn màn hình', Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
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
      case 'export_annotations':
        _exportAnnotations();
        break;
      case 'hide_toolbar':
        setState(() {
          _showToolbar = false;
        });
        break;
    }
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
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
                    hintText: 'Tìm kiếm...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(Icons.search),
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
      ),
    );
  }

  Widget _buildShowToolbarButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: 'show_toolbar',
        onPressed: () {
          setState(() {
            _showToolbar = true;
          });
        },
        child: Icon(Icons.menu),
      ),
    );
  }

  Widget _buildModeIndicator() {
    String modeText = '';
    IconData modeIcon = Icons.touch_app;
    Color modeColor = Colors.blue;

    switch (_interactionMode) {
      case PdfInteractionMode.pan:
        modeText = 'Chế độ di chuyển';
        modeIcon = Icons.pan_tool;
        modeColor = Colors.blue;
        break;
      default:
        return SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: modeColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(modeIcon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              modeText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationsCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            '${_annotations.length}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
        // Copy button
        if (_selectedText != null && _selectedText!.isNotEmpty) ...[
          FloatingActionButton.extended(
            heroTag: 'copy',
            onPressed: _copySelectedText,
            icon: Icon(Icons.content_copy),
            label: Text('Copy'),
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'highlight',
            onPressed: () => _addHighlight(),
            icon: Icon(Icons.highlight),
            label: Text('Highlight'),
            backgroundColor: _highlightColor,
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'note',
            onPressed: () => _addNote(),
            icon: Icon(Icons.note_add),
            label: Text('Ghi chú'),
            backgroundColor: Colors.orange,
          ),
          SizedBox(height: 16),
        ],
      ],
    );
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
                child: Text('Đã copy ${_selectedText!.length} ký tự'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      setState(() {
        _selectedText = null;
      });
    }
  }

  void _addHighlight() {
    if (_selectedText == null || _selectedText!.isEmpty) return;

    setState(() {
      _annotations.add(Annotation(
        type: AnnotationType.highlight,
        text: _selectedText!,
        page: _currentPage,
        color: _highlightColor,
        timestamp: DateTime.now(),
      ));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã highlight text'),
        backgroundColor: _highlightColor,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _selectedText = null;
    });
  }

  void _addNote() {
    if (_selectedText == null || _selectedText!.isEmpty) return;

    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.note_add, color: Colors.orange),
            SizedBox(width: 12),
            Text('Thêm ghi chú'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text đã chọn:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow),
              ),
              child: Text(
                _selectedText!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ghi chú của bạn',
                hintText: 'Nhập ghi chú...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              if (noteController.text.isNotEmpty) {
                setState(() {
                  _annotations.add(Annotation(
                    type: AnnotationType.note,
                    text: _selectedText!,
                    note: noteController.text,
                    page: _currentPage,
                    color: Colors.orange,
                    timestamp: DateTime.now(),
                  ));
                  _selectedText = null;
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm ghi chú'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showHighlightOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.palette, color: Colors.orange),
            SizedBox(width: 12),
            Text('Chọn màu highlight'),
          ],
        ),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ].map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _highlightColor = color;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã chọn màu highlight'),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _highlightColor == color
                        ? Colors.black
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: _highlightColor == color
                    ? Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAnnotationsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, color: Colors.orange),
                        SizedBox(width: 12),
                        Text(
                          'Ghi chú & Highlights',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_annotations.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _annotations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có ghi chú nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Chọn text và thêm ghi chú hoặc highlight',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _annotations.length,
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final annotation = _annotations[index];
                          return _buildAnnotationCard(annotation, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnnotationCard(Annotation annotation, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _pdfViewerController.jumpToPage(annotation.page);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: annotation.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      annotation.type == AnnotationType.highlight
                          ? Icons.highlight
                          : Icons.note,
                      color: annotation.color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          annotation.type == AnnotationType.highlight
                              ? 'Highlight'
                              : 'Ghi chú',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Trang ${annotation.page}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _annotations.removeAt(index);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: annotation.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: annotation.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  annotation.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              if (annotation.note != null) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    annotation.note!,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _exportAnnotations() {
    if (_annotations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có ghi chú để xuất'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Tạo text export
    String exportText = '=== GHI CHÚ - ${widget.title} ===\n\n';
    
    for (var annotation in _annotations) {
      exportText += '---\n';
      exportText += 'Loại: ${annotation.type == AnnotationType.highlight ? "Highlight" : "Ghi chú"}\n';
      exportText += 'Trang: ${annotation.page}\n';
      exportText += 'Text: ${annotation.text}\n';
      if (annotation.note != null) {
        exportText += 'Ghi chú: ${annotation.note}\n';
      }
      exportText += '\n';
    }

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: exportText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Đã copy ${_annotations.length} ghi chú vào clipboard'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showJumpToPage() {
    final pageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.skip_next_rounded, color: Theme.of(context).primaryColor),
            SizedBox(width: 12),
            Text('Nhảy đến trang'),
          ],
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Số trang',
            hintText: '1-$_totalPages',
            prefixIcon: Icon(Icons.numbers),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
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
              }
            },
            child: Text('Đến'),
          ),
        ],
      ),
    );
  }
}

// Models
enum AnnotationType { highlight, note }

class Annotation {
  final AnnotationType type;
  final String text;
  final String? note;
  final int page;
  final Color color;
  final DateTime timestamp;

  Annotation({
    required this.type,
    required this.text,
    this.note,
    required this.page,
    required this.color,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString(),
        'text': text,
        'note': note,
        'page': page,
        'color': color.value,
        'timestamp': timestamp.toIso8601String(),
      };
}

