import 'dart:io';

import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/google_drive_service.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

class GoogleDriveTab extends StatefulWidget {
  const GoogleDriveTab({super.key});

  @override
  State<GoogleDriveTab> createState() => _GoogleDriveTabState();
}

class _GoogleDriveTabState extends State<GoogleDriveTab>
    with AutomaticKeepAliveClientMixin {
  List<DriveFileInfo> _driveFiles = [];
  bool _isDriveLoading = false;
  String? _driveFolderId;
  final Set<String> _downloadingFileIds = {};
  List<String> _localBooks = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadDriveFolder();
    _loadLocalBooks();
  }

  Future<void> _loadLocalBooks() async {
    final books = await SharedPreferenceUtil.getLocalBooks();
    setState(() => _localBooks = books);
  }

  (bool, String) hasDownloadFile(String filename, String driverFileId) {
    final hasDownload = _localBooks.any(
      (local) => local.split(Platform.pathSeparator).last == filename,
    );
    if (hasDownload) {
      return (
        hasDownload,
        _localBooks.firstWhere(
          (local) => local.split(Platform.pathSeparator).last == filename,
        ),
      );
    }
    return (false, '');
  }

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
          message: '${AppLocalizations.current.drive_error}: ${e.toString()}',
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
              Text(
                AppLocalizations.current.link_google_drive,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
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
                  prefixIcon: Icon(Icons.folder, color: colorScheme.primary),
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
      final folderId = GoogleDriveService.extractFolderIdFromUrl(result);
      if (folderId == null || folderId.isEmpty) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.invalid_folder_id,
          snackBarType: SnackBarType.error,
        );
        return;
      }

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
      builder:
          (ctx) => AlertDialog(
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

      await SharedPreferenceUtil.addLocalBook(localPath);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.file_downloaded,
          snackBarType: SnackBarType.success,
        );
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

  void _openBook(BookModel book) {
    Navigator.pushNamed(context, Routes.pdfViewerScreen, arguments: book);
  }

  Widget _buildDriveFileCard(BuildContext context, DriveFileInfo driveFile) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = driveFile.fileExtension;
    final color = _getFileColor(context, ext);
    final isDownloading = _downloadingFileIds.contains(driveFile.id);
    final hasDownload = hasDownloadFile(driveFile.name, driveFile.id);
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
        onTap:
            hasDownload.$1
                ? () => _openBook(
                  BookModel.local(
                    hasDownload.$2,
                    hasDownload.$2.split(Platform.pathSeparator).last,
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    0,
                    driveFile.fileExtension,
                    0,
                  ),
                )
                : () => _downloadAndAddDriveFile(driveFile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File thumbnail / icon
              Container(
                width: 74,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    driveFile.thumbnailLink != null
                        ? Image.network(
                          driveFile.thumbnailLink!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Icon(
                                _getFileIcon(ext),
                                color: color,
                                size: 24,
                              ),
                        )
                        : Icon(_getFileIcon(ext), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
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
                      ],
                    ),
                  ],
                ),
              ),
              // Download button
              if (isDownloading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (hasDownload.$1)
                IconButton(
                  onPressed:
                      () => _openBook(
                        BookModel.local(
                          hasDownload.$2,
                          hasDownload.$2.split(Platform.pathSeparator).last,
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          0,
                          driveFile.fileExtension,
                          0,
                        ),
                      ),
                  icon: Icon(
                    Icons.library_books_rounded,
                    color: colorScheme.primary,
                  ),
                  tooltip: AppLocalizations.current.read_book,
                  visualDensity: VisualDensity.compact,
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Chưa liên kết Drive
    if (_driveFolderId == null) {
      return _buildNotLinkedState(context);
    }

    // Đang tải
    if (_isDriveLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Không có file
    if (_driveFiles.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.current.no_drive_files,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadDriveFiles,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(AppLocalizations.current.refresh),
                ),
              ],
            ),
          ),
          _buildUnlinkFab(),
        ],
      );
    }

    // Hiển thị danh sách file
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadDriveFiles,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: _driveFiles.length,
            itemBuilder: (context, index) {
              return _buildDriveFileCard(context, _driveFiles[index]);
            },
          ),
        ),
        _buildUnlinkFab(),
      ],
    );
  }

  Widget _buildNotLinkedState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_to_drive,
              size: 72,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.current.link_google_drive,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.current.enter_folder_id_or_url,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showLinkDriveDialog,
              icon: const Icon(Icons.link),
              label: Text(AppLocalizations.current.connect),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlinkFab() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: 'drive_fab',
        onPressed: _unlinkDrive,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.link_off,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}
