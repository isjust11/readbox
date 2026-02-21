import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/screen/admin/pdf_scanner_screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/book_metadata_service.dart';
import 'package:readbox/utils/pdf_thumbnail_service.dart';
import 'package:readbox/utils/shared_preference.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LocalLibraryScreen extends StatefulWidget {
  const LocalLibraryScreen({super.key});

  @override
  State<LocalLibraryScreen> createState() => _LocalLibraryScreenState();
}

class _LocalLibraryScreenState extends State<LocalLibraryScreen> {
  List<BookModel> _books = [];
  bool _isLoading = true;
  String searchQuery = '';
  bool hasInternet = false;
  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _loadBooks();
  }

  void checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    hasInternet =
        results.isNotEmpty &&
        !(results.length == 1 && results.first == ConnectivityResult.none);
    setState(() {});
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);

    try {
      final filePaths = await SharedPreferenceUtil.getLocalBooks();
      final books = <BookModel>[];

      for (var path in filePaths) {
        try {
          final file = File(path);
          if (await file.exists()) {
            final filename = path.split(Platform.pathSeparator).last;
            final bookMetadata = await BookMetadataService.extractFromFile(
              path,
            );
            final fileSize = await file.length();
            final ext = filename.split('.').last;
            final fileType =
                ['pdf', 'epub', 'mobi'].contains(ext) ? ext : 'pdf';
            books.add(
              BookModel.local(
                path,
                bookMetadata.title ?? filename,
                bookMetadata.author ?? '',
                bookMetadata.subject ?? '',
                bookMetadata.publisher ?? '',
                bookMetadata.isbn ?? '',
                bookMetadata.language ?? '',
                path,
                bookMetadata.totalPages ?? 0,
                fileType,
                fileSize,
              ),
            );
          } else {
            await SharedPreferenceUtil.removeLocalBook(path);
          }
        } catch (_) {
          await SharedPreferenceUtil.removeLocalBook(path);
        }
      }

      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.error}: ${e.toString()}',
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  List<BookModel> get _filteredBooks {
    if (searchQuery.isEmpty) return _books;

    return _books.where((book) {
      final query = searchQuery.toLowerCase();
      return book.displayTitle.toLowerCase().contains(query) ||
          (book.author?.toLowerCase().contains(query) ?? false) ||
          book.fileUrl!.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _scanAndAddBooks() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PdfScannerScreen(multiSelect: true),
      ),
    );

    if (result != null && mounted) {
      _loadBooks();
    }
  }

  Future<void> _removeBook(BookModel book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(AppLocalizations.current.delete_book),
            content: Text('${AppLocalizations.current.delete_book_confirmation} "${book.displayTitle}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.current.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.error,
                ),
                child: Text(AppLocalizations.current.delete_book),
              ),
            ],
          ),
    );

    if (confirm == true) {
      PdfThumbnailService.removeFromCache(book.fileUrl!);
      await SharedPreferenceUtil.removeLocalBook(book.fileUrl!);
      _loadBooks();

      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.book_removed_from_library,
          snackBarType: SnackBarType.warning,
        );
      }
    }
  }

  Future<void> _uploadBook(BookModel book) async {
    Navigator.pushNamed(context, Routes.adminUploadScreen, arguments: book);
  }

  void _openBook(BookModel book) {
    Navigator.pushNamed(context, Routes.pdfViewerScreen, arguments: book);
  }

  void _showBookInfoDrawer(BookModel book) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Align(
            alignment: Alignment.centerRight,
            child: AppDrawerInfo(book: book),
          ),
        );
      },
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

  Widget _buildBookCover(BuildContext context, BookModel book) {
    const w = 70.0;
    const h = 100.0;
    final color = _getFileColor(context, book.fileType?.name ?? '');
    final decor = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    );

    if (book.fileType?.name != 'pdf') {
      return Container(
        width: w,
        height: h,
        decoration: decor,
        child: Icon(
          _getFileIcon(book.fileType?.name ?? ''),
          color: color,
          size: 32,
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: PdfThumbnailService.getThumbnail(
        book.fileUrl!,
        width: 240,
        height: 300,
      ),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done && bytes != null) {
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
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

  Widget _buildBookCard(BuildContext context, BookModel book) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getFileColor(context, book.fileType?.name ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      book.displayTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author ?? 'unknown',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.fileType?.name.toUpperCase() ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              book.fileSizeFormatted,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.numbers_rounded,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${book.totalPages} ${AppLocalizations.current.pages}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 10,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'info') _showBookInfoDrawer(book);
                  if (value == 'delete') _removeBook(book);
                  if (value == 'upload') _uploadBook(book);
                },
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.zero,

                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'info',
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.current.info),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
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
                            Icon(
                              Icons.cloud_upload,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
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
      hiddenIconBack: true,
      customAppBar: BaseAppBar(
        showBackButton: hasInternet ? true : false,
        title: AppLocalizations.current.local_library,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _loadBooks,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _books.isEmpty
              ? EmptyData(emptyDataEnum: EmptyDataEnum.no_data,
              title: AppLocalizations.current.no_books,
              description: AppLocalizations.current.add_book_to_start_reading,
              )
              : _filteredBooks.isEmpty
              ? EmptyData(emptyDataEnum: EmptyDataEnum.no_filter,
              title: AppLocalizations.current.no_book_found,
              )
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                itemCount: _filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = _filteredBooks[index];
                  return _buildBookCard(context, book);
                },
              ),
      floatingButton: FloatingActionButton.small(
        onPressed: _scanAndAddBooks,
          child: Icon(Icons.add, color: Theme.of(context).primaryColor),
        ),
      );
    }
  }
