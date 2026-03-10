import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/google_drive_service.dart';
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

  // Google Drive state
  List<DriveFileInfo> _driveFiles = [];
  bool _isDriveLoading = false;
  String? _driveFolderId;
  final Set<String> _downloadingFileIds = {};

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    _loadBooks();
    _loadDriveFolder();
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

  // ==================== GOOGLE DRIVE ====================

  Future<void> _loadDriveFolder() async {
    final folderId = await SharedPreferenceUtil.getDriveFolderId();
    if (folderId != null && folderId.isNotEmpty) {
      setState(() => _driveFolderId = folderId);
      _loadDriveFiles();
    }
  }

  Future<void> _loadDriveFiles() async {
    if (_driveFolderId == null) return;

    setState(() => _isDriveLoading = true);
    try {
      final files = await GoogleDriveService.listFilesInFolder(_driveFolderId!);
      if (mounted) {
        setState(() {
          _driveFiles = files;
          _isDriveLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDriveLoading = false);
        AppSnackBar.show(
          context,
          message:
              '${AppLocalizations.current.drive_error}: ${e.toString()}',
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _showLinkDriveDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_to_drive, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.current.link_google_drive),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.current.enter_folder_id_or_url,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: AppLocalizations.current.folder_id_hint,
                  hintStyle: TextStyle(
                    fontSize: 11,
                    color: colorScheme.outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  prefixIcon: Icon(
                    Icons.folder,
                    color: colorScheme.primary,
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.current.paste_drive_folder_url,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.current.cancel),
            ),
            FilledButton.icon(
              onPressed: () {
                final input = controller.text.trim();
                if (input.isNotEmpty) {
                  Navigator.pop(ctx, input);
                }
              },
              icon: const Icon(Icons.link, size: 16),
              label: Text(AppLocalizations.current.connect),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Trích xuất folder ID
      final folderId = GoogleDriveService.extractFolderIdFromUrl(result);
      if (folderId == null || folderId.isEmpty) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.invalid_folder_id,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      // Lưu folder ID
      await SharedPreferenceUtil.saveDriveFolderId(folderId);
      setState(() => _driveFolderId = folderId);

      AppSnackBar.show(
        context,
        message: AppLocalizations.current.drive_link_success,
        snackBarType: SnackBarType.success,
      );

      _loadDriveFiles();
    }
  }

  Future<void> _unlinkDrive() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.current.unlink_drive),
        content: Text(AppLocalizations.current.unlink_drive_confirm),
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
            child: Text(AppLocalizations.current.unlink_drive),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SharedPreferenceUtil.removeDriveFolderId();
      setState(() {
        _driveFolderId = null;
        _driveFiles = [];
      });
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.drive_link_removed,
          snackBarType: SnackBarType.warning,
        );
      }
    }
  }

  Future<void> _downloadAndAddDriveFile(DriveFileInfo driveFile) async {
    if (_downloadingFileIds.contains(driveFile.id)) return;

    setState(() => _downloadingFileIds.add(driveFile.id));

    try {
      final localPath = await GoogleDriveService.downloadFile(
        driveFile.id,
        driveFile.name,
      );

      // Thêm vào local books
      await SharedPreferenceUtil.addLocalBook(localPath);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.file_downloaded,
          snackBarType: SnackBarType.success,
        );
        _loadBooks();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.drive_error}: ${e.toString()}',
          snackBarType: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _downloadingFileIds.remove(driveFile.id));
      }
    }
  }

  // ==================== END GOOGLE DRIVE ====================

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

  // ==================== DRIVE FILE CARD ====================

  Widget _buildDriveFileCard(BuildContext context, DriveFileInfo driveFile) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = driveFile.fileExtension;
    final color = _getFileColor(context, ext);
    final isDownloading = _downloadingFileIds.contains(driveFile.id);

    // Kiểm tra file đã được tải về local chưa
    final isAlreadyLocal = _books.any(
      (b) => b.fileUrl?.endsWith(driveFile.name) ?? false,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isAlreadyLocal
            ? () {
                // Mở file local nếu đã tải
                final localBook = _books.firstWhere(
                  (b) => b.fileUrl?.endsWith(driveFile.name) ?? false,
                );
                _openBook(localBook);
              }
            : isDownloading
                ? null
                : () => _downloadAndAddDriveFile(driveFile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // File icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFileIcon(ext),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driveFile.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                            ext.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          driveFile.fileSizeFormatted,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.outline,
                          ),
                        ),
                        if (isAlreadyLocal) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Download / Open button
              if (isDownloading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isAlreadyLocal)
                Icon(
                  Icons.open_in_new,
                  size: 20,
                  color: colorScheme.primary,
                )
              else
                IconButton(
                  onPressed: () => _downloadAndAddDriveFile(driveFile),
                  icon: Icon(
                    Icons.download_rounded,
                    color: colorScheme.primary,
                  ),
                  tooltip: AppLocalizations.current.download_to_read,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriveSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.add_to_drive, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.current.google_drive_books,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Refresh
              IconButton(
                onPressed: _isDriveLoading ? null : _loadDriveFiles,
                icon: Icon(
                  Icons.refresh,
                  size: 18,
                  color: colorScheme.primary,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: AppLocalizations.current.refresh,
              ),
              // Unlink
              IconButton(
                onPressed: _unlinkDrive,
                icon: Icon(
                  Icons.link_off,
                  size: 18,
                  color: colorScheme.error,
                ),
                visualDensity: VisualDensity.compact,
                tooltip: AppLocalizations.current.unlink_drive,
              ),
            ],
          ),
        ),
        // Content
        if (_isDriveLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_driveFiles.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                AppLocalizations.current.no_drive_files,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _driveFiles
                  .map((f) => _buildDriveFileCard(context, f))
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  // ==================== END DRIVE UI ====================

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
          // Google Drive button
          IconButton(
            icon: Icon(
              _driveFolderId != null ? Icons.add_to_drive : Icons.add_to_drive_outlined,
              color: colorScheme.onPrimary,
            ),
            onPressed: _driveFolderId != null ? _unlinkDrive : _showLinkDriveDialog,
            tooltip: AppLocalizations.current.google_drive,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: () {
              _loadBooks();
              if (_driveFolderId != null) _loadDriveFiles();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context),
      floatingButton: FloatingActionButton.small(
        onPressed: _scanAndAddBooks,
          child: Icon(Icons.add, color: Theme.of(context).primaryColor),
        ),
      );
    }

  Widget _buildBody(BuildContext context) {
    final hasDrive = _driveFolderId != null;
    final hasLocalBooks = _books.isNotEmpty;
    final hasFilteredBooks = _filteredBooks.isNotEmpty;

    // Nếu không có gì (không Drive, không local books)
    if (!hasDrive && !hasLocalBooks) {
      return EmptyData(
        emptyDataEnum: EmptyDataEnum.no_data,
        title: AppLocalizations.current.no_books,
        description: AppLocalizations.current.add_book_to_start_reading,
      );
    }

    return CustomScrollView(
      slivers: [
        // Google Drive section
        if (hasDrive)
          SliverToBoxAdapter(
            child: _buildDriveSection(context),
          ),

        // Local books header (nếu có cả Drive và local books)
        if (hasDrive && hasLocalBooks)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                AppLocalizations.current.local_library,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

        // Local books list
        if (hasLocalBooks && !hasFilteredBooks && searchQuery.isNotEmpty)
          SliverFillRemaining(
            child: EmptyData(
              emptyDataEnum: EmptyDataEnum.no_filter,
              title: AppLocalizations.current.no_book_found,
            ),
          )
        else if (hasLocalBooks)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = _filteredBooks[index];
                  return _buildBookCard(context, book);
                },
                childCount: _filteredBooks.length,
              ),
            ),
          ),

        // Nếu chỉ có Drive, thêm padding dưới
        if (hasDrive && !hasLocalBooks)
          const SliverToBoxAdapter(
            child: SizedBox(height: 88),
          ),
      ],
    );
  }
}
