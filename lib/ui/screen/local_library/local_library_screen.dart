import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/local_book.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/screen/admin/pdf_scanner_screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/pdf_thumbnail_service.dart';
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
        final fileName = path.split(Platform.pathSeparator).last;
        final ext =
            fileName.contains('.')
                ? fileName.split('.').last.toLowerCase()
                : 'pdf';
        final fileType = ['pdf', 'epub', 'mobi'].contains(ext) ? ext : 'pdf';

        try {
          final file = File(path);
          if (await file.exists()) {
            final fileSize = await file.length();
            books.add(
              LocalBook(
                filePath: path,
                fileName: fileName,
                fileType: fileType,
                fileSize: fileSize,
              ),
            );
          } else {
            // Vẫn hiển thị để user có thể thử mở hoặc xóa (file có thể bị di chuyển / Scoped Storage)
            books.add(
              LocalBook(
                filePath: path,
                fileName: fileName,
                fileType: fileType,
                fileSize: 0,
              ),
            );
          }
        } catch (_) {
          books.add(
            LocalBook(
              filePath: path,
              fileName: fileName,
              fileType: fileType,
              fileSize: 0,
            ),
          );
        }
      }

      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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
      MaterialPageRoute(builder: (context) => const PdfScannerScreen()),
    );

    if (result == true) {
      _loadBooks();
    }
  }

  Future<void> _removeBook(LocalBook book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(AppLocalizations.current.delete_book),
            content: Text('Xóa "${book.cleanTitle}" khỏi thư viện?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.current.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
                child: Text(AppLocalizations.current.delete_book),
              ),
            ],
          ),
    );

    if (confirm == true) {
      PdfThumbnailService.removeFromCache(book.filePath);
      await SharedPreferenceUtil.removeLocalBook(book.filePath);
      _loadBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.current.book_removed_from_library),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _uploadBook(LocalBook book) async {
    Navigator.pushNamed(
      context,
      Routes.adminUploadScreen,
      arguments: {'fileUrl': book.filePath, 'title': book.fileName},
    );
  }

  void _openBook(LocalBook book) {
    Navigator.pushNamed(
      context,
      Routes.pdfViewerScreen,
      arguments: BookModel.fromJson({'fileUrl': book.filePath, 'title': book.fileName, 'isLocalBook': true}),
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

  Color _getFileColor(BuildContext context, String fileType) {
    final fallback = Theme.of(context).colorScheme.outline;
    switch (fileType) {
      case 'pdf':
        return Colors.red;
      case 'epub':
        return Colors.green;
      case 'mobi':
        return Colors.blue;
      default:
        return fallback;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 80, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.current.no_books,
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.current.add_book_to_start_reading,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.current.no_books_found,
            style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover(BuildContext context, LocalBook book) {
    const w = 50.0;
    const h = 70.0;
    final color = _getFileColor(context, book.fileType);
    final decor = BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    );

    if (book.fileType != 'pdf') {
      return Container(
        width: w,
        height: h,
        decoration: decor,
        child: Icon(_getFileIcon(book.fileType), color: color, size: 32),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: PdfThumbnailService.getThumbnail(book.filePath, width: 140, height: 200),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && bytes != null) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.memory(bytes, fit: BoxFit.cover),
          );
        }
        return Container(
          width: w,
          height: h,
          decoration: decor,
          child: Icon(Icons.picture_as_pdf, color: color, size: 32),
        );
      },
    );
  }

  Widget _buildBookCard(BuildContext context, LocalBook book) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getFileColor(context, book.fileType);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: InkWell(
        onTap: () => _openBook(book),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildBookCover(context, book),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.cleanTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            book.fileType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          book.formattedSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') _removeBook(book);
                  if (value == 'upload') _uploadBook(book);
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.current.delete_book),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'upload',
                        child: Row(
                          children: [
                            Icon(Icons.upload, color: Theme.of(context).colorScheme.primary, size: 20,),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.current.upload_book),
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
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BaseScreen(
      colorBg: colorScheme.surface,
      customAppBar: BaseAppBar(
        title: AppLocalizations.current.local_library,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: colorScheme.onPrimary,
            ),
            onPressed: _loadBooks,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _books.isEmpty
              ? _buildEmptyState(context)
              : _filteredBooks.isEmpty
              ? _buildNoSearchResults(context)
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return _buildBookCard(context, book);
                },
              ),
      floatingButton: FloatingActionButton.extended(
        onPressed: _scanAndAddBooks,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.current.add_book),
      ),
    );
  }
}
