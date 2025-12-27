import 'dart:io';
import 'package:flutter/material.dart';
import 'package:readbox/domain/models/local_book.dart';
import 'package:readbox/ui/screen/admin/pdf_scanner_screen.dart';
import 'package:readbox/utils/shared_preference.dart';

class LocalLibraryScreen extends StatefulWidget {
  const LocalLibraryScreen({super.key});

  @override
  State<LocalLibraryScreen> createState() => _LocalLibraryScreenState();
}

class _LocalLibraryScreenState extends State<LocalLibraryScreen> {
  List<LocalBook> _books = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    
    try {
      final filePaths = await SharedPreferenceUtil.getLocalBooks();
      final books = <LocalBook>[];

      for (var path in filePaths) {
        final file = File(path);
        
        // Check if file still exists
        if (await file.exists()) {
          final fileName = path.split('/').last;
          final fileType = fileName.split('.').last.toLowerCase();
          final fileSize = await file.length();

          books.add(LocalBook(
            filePath: path,
            fileName: fileName,
            fileType: fileType,
            fileSize: fileSize,
          ));
        } else {
          // Remove non-existent file from list
          await SharedPreferenceUtil.removeLocalBook(path);
        }
      }

      // Sort by added date (newest first)
      books.sort((a, b) => b.addedDate.compareTo(a.addedDate));

      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<LocalBook> get _filteredBooks {
    if (_searchQuery.isEmpty) return _books;
    
    return _books.where((book) {
      final query = _searchQuery.toLowerCase();
      return book.cleanTitle.toLowerCase().contains(query) ||
             book.author.toLowerCase().contains(query) ||
             book.fileName.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _scanAndAddBooks() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PdfScannerScreen(),
      ),
    );

    if (result == true) {
      _loadBooks();
    }
  }

  Future<void> _removeBook(LocalBook book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sách'),
        content: Text('Xóa "${book.cleanTitle}" khỏi thư viện?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SharedPreferenceUtil.removeLocalBook(book.filePath);
      _loadBooks();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa sách khỏi thư viện'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _openBook(LocalBook book) {
    // TODO: Implement PDF/EPUB reader
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mở file: ${book.fileName}')),
    );
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'epub':
        return Icons.book;
      case 'mobi':
        return Icons.menu_book;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileType) {
    switch (fileType) {
      case 'pdf':
        return Colors.red;
      case 'epub':
        return Colors.green;
      case 'mobi':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện Local'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBooks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sách...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Book count
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredBooks.length} cuốn sách',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Books list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_books,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có sách nào',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nhấn nút + để thêm sách',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredBooks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không tìm thấy sách',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredBooks.length,
                            itemBuilder: (context, index) {
                              final book = _filteredBooks[index];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => _openBook(book),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Icon
                                        Container(
                                          width: 50,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: _getFileColor(book.fileType)
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _getFileIcon(book.fileType),
                                            color: _getFileColor(book.fileType),
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Book info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                book.cleanTitle,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                book.author,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getFileColor(
                                                              book.fileType)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      book.fileType.toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getFileColor(
                                                            book.fileType),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    book.formattedSize,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Actions
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (value == 'delete') {
                                              _removeBook(book);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.red, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Xóa'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanAndAddBooks,
        icon: const Icon(Icons.add),
        label: const Text('Thêm sách'),
      ),
    );
  }
}

