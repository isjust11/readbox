import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

class PdfScannerScreen extends StatefulWidget {
  final ScanFormatEnum scanFormat;
  final bool multiSelect;
  const PdfScannerScreen({
    super.key,
    this.multiSelect = false,
    this.scanFormat = ScanFormatEnum.pdf,
  });

  @override
  State<PdfScannerScreen> createState() => _PdfScannerScreenState();
}

class _PdfScannerScreenState extends State<PdfScannerScreen> {
  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _selectedFiles = [];
  bool _isScanning = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request storage permissions
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        setState(() => _hasPermission = true);
        _scanForFiles();
      } else {
        // Fallback to regular storage permission
        final storageStatus = await Permission.storage.request();
        setState(() => _hasPermission = storageStatus.isGranted);
        if (storageStatus.isGranted) {
          _scanForFiles();
        }
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      setState(() => _hasPermission = status.isGranted);
      if (status.isGranted) {
        _scanForFiles();
      }
    }
  }

  /// Chọn file qua File Picker (SAF) — hoạt động với Scoped Storage, kể cả Download/Telegram
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions:
            widget.scanFormat == ScanFormatEnum.pdf
                ? ['pdf', 'epub', 'mobi']
                : widget.scanFormat == ScanFormatEnum.word
                    ? ['doc', 'docx']
                    : ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;
      final existing = _files.map((e) => e.path).toSet();
      final toAdd = <FileSystemEntity>[];
      for (final f in result.files) {
        if (f.path != null &&
            f.path!.isNotEmpty &&
            !existing.contains(f.path)) {
          toAdd.add(File(f.path!));
          existing.add(f.path!);
        }
      }
      if (toAdd.isEmpty) return;
      setState(() {
        _files = [..._files, ...toAdd];
        _selectedFiles = [..._selectedFiles, ...toAdd];
      });
      if (mounted) {
        AppSnackBar.show(
          context,
          message:
              '${AppLocalizations.current.added} ${toAdd.length} ${AppLocalizations.current.files} ${AppLocalizations.current.from_directory}',
          snackBarType: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.error_selecting_file}: $e',
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _scanForFiles() async {
    setState(() {
      _isScanning = true;
      _files = [];
    });

    try {
      List<FileSystemEntity> allFiles = [];

      if (Platform.isAndroid) {
        // Common directories to scan on Android (Scoped Storage có thể chặn thư mục con như Download/Telegram)
        final directories = [
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/Downloads'),
          Directory('/storage/emulated/0/Documents'),
          Directory('/storage/emulated/0/DCIM'),
          Directory('/mnt/shared'),
          await getExternalStorageDirectory(),
          await getApplicationDocumentsDirectory(),
        ];

        for (var dir in directories) {
          if (dir != null && await dir.exists()) {
            await _scanDirectory(dir, allFiles);
          }
        }
      } else if (Platform.isIOS) {
        // iOS directories
        final appDir = await getApplicationDocumentsDirectory();
        await _scanDirectory(appDir, allFiles);
      }

      setState(() {
        _files = allFiles;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.error_scanning_files}: $e',
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _scanDirectory(
    Directory directory,
    List<FileSystemEntity> files,
  ) async {
    try {
      final entities = directory.listSync(recursive: true, followLinks: false);
      for (var entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (widget.scanFormat == ScanFormatEnum.pdf) {
            if (path.endsWith('.pdf') ||
                path.endsWith('.epub') ||
                path.endsWith('.mobi')) {
              files.add(entity);
            }
          } else if (widget.scanFormat == ScanFormatEnum.word) {
            // chỉ hỗ trợ file .docx file .doc không hỗ trợ
            if (path.endsWith('.docx')) {
              files.add(entity);
            }
          } else if (widget.scanFormat == ScanFormatEnum.image) {
            if (path.endsWith('.jpg') ||
                path.endsWith('.jpeg') ||
                path.endsWith('.png')) {
              files.add(entity);
            }
          }
        }
      }
    } catch (e) {
      // Skip directories we don't have permission to access
      debugPrint('Cannot access directory: ${directory.path}');
    }
  }

  void _toggleFileSelection(FileSystemEntity file) {
    setState(() {
      if (widget.multiSelect) {
        _selectedFiles.clear();
        _selectedFiles.add(file);
      } else {
        if (_selectedFiles.contains(file)) {
          _selectedFiles.remove(file);
        } else {
          _selectedFiles.add(file);
        }
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedFiles = List.from(_files);
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _selectOrImportSelected() async {
    if (widget.multiSelect) {
      Navigator.pop(context, _selectedFiles[0].path);
      return;
    } else {
      try {
        int addedCount = 0;
        int skippedCount = 0;

        for (var file in _selectedFiles) {
          final filePath = file.path;
          final isAdded = await SharedPreferenceUtil.isBookAdded(filePath);

          if (!isAdded) {
            await SharedPreferenceUtil.addLocalBook(filePath);
            addedCount++;
          } else {
            skippedCount++;
          }
        }

        if (mounted) {
          String message =
              '${AppLocalizations.current.added} $addedCount ${AppLocalizations.current.books} ${AppLocalizations.current.to_library}';
          if (skippedCount > 0) {
            message +=
                '\n${AppLocalizations.current.books_already_exist} $skippedCount ${AppLocalizations.current.books}';
          }

          AppSnackBar.show(
            context,
            message: message,
            snackBarType: SnackBarType.success,
          );

          // Return success
          Navigator.pop(context, _selectedFiles.map((e) => e.path).toList());
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: '${AppLocalizations.current.error}: $e',
            snackBarType: SnackBarType.error,
          );
        }
      }
    }
  }

  String _getFileSize(FileSystemEntity file) {
    try {
      if (file is File) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)} KB';
        }
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown';
    }
    return 'Unknown';
  }

  String get _getTitle {
    if (widget.scanFormat == ScanFormatEnum.pdf) {
      return AppLocalizations.current.find_book;
    } else if (widget.scanFormat == ScanFormatEnum.word) {
      return AppLocalizations.current.find_word;
    } else if (widget.scanFormat == ScanFormatEnum.image) {
      return AppLocalizations.current.find_image;
    }
    return AppLocalizations.current.find_book;
  }

  String _getFileName(FileSystemEntity file) {
    return file.path.split('/').last;
  }

  SvgPicture _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return SvgPicture.asset(Assets.icons.icPdf);
      case 'epub':
        return SvgPicture.asset(Assets.icons.icEpub);
      case 'mobi':
        return SvgPicture.asset(Assets.icons.icMobi);
      case 'doc':
        return SvgPicture.asset(Assets.icons.icDoc);
      case 'docx':
        return SvgPicture.asset(Assets.icons.icDocx);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return SvgPicture.asset(Assets.icons.icImage);
      default:
        return SvgPicture.asset(Assets.icons.icFile);
    }
  }

  Color _getFileColor(BuildContext context, String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    final fallback = Theme.of(context).colorScheme.outline;
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'epub':
        return Colors.green;
      case 'mobi':
        return Colors.purple;
      case 'doc':
        return const Color.fromARGB(255, 41, 18, 255);
      case 'docx':
        return const Color.fromARGB(255, 59, 37, 255);
      default:
        return fallback;
    }
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String headerNotFound = ''; 
    String title = '';
    String subtitle = AppLocalizations.current.use_select_file_to_browse_directory;
    switch (widget.scanFormat) {
      case ScanFormatEnum.pdf:
        headerNotFound = AppLocalizations.current.no_book_found;
        title = AppLocalizations.current.no_pdf_epub_mobi_found;
        break;
      case ScanFormatEnum.word:
        headerNotFound = AppLocalizations.current.no_file_found;
        title = AppLocalizations.current.no_word_file_found;
        break;
      case ScanFormatEnum.image:
        headerNotFound = AppLocalizations.current.no_file_found;
        title = AppLocalizations.current.no_image_file_found;        
        break;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            headerNotFound,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _scanForFiles,
                icon: const Icon(Icons.refresh),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.outline,
                ),
                label: Text(
                  AppLocalizations.current.scan_again,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.folder_open),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
                label: Text(AppLocalizations.current.select_file,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BaseScreen(
      colorBg: colorScheme.surface,
      customAppBar: BaseAppBar(
        title: _getTitle,
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _isScanning ? null : _pickFiles,
            icon: Icon(Icons.folder_open, color: colorScheme.onPrimary),
            label: Text(
              AppLocalizations.current.select_file,
              style: TextStyle(color: colorScheme.onPrimary),
            ),
          ),
          if (_files.isNotEmpty && !widget.multiSelect)
            TextButton.icon(
              onPressed:
                  _selectedFiles.length == _files.length
                      ? _deselectAll
                      : _selectAll,
              icon: Icon(
                _selectedFiles.length == _files.length
                    ? Icons.deselect
                    : Icons.select_all,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                _selectedFiles.length == _files.length
                    ? AppLocalizations.current.unselect_all
                    : AppLocalizations.current.select_all,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _isScanning ? null : _scanForFiles,
          ),
        ],
      ),
      body:
          !_hasPermission
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.current.need_permission_to_access_memory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations
                          .current
                          .please_grant_permission_to_search_file,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations
                          .current
                          .or_use_select_file_to_browse_directory_without_permission,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _requestPermissions,
                          icon: const Icon(Icons.settings),
                          label: Text(
                            AppLocalizations.current.grant_permission,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.folder_open),
                          label: Text(AppLocalizations.current.select_file),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : _isScanning
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.current.scanning_in_memory,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              )
              : _files.isEmpty
              ? _buildEmptyState()
              : Column(
                children: [
                  // Header with file count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color: colorScheme.primaryContainer,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary, size: AppSize.iconSizeSmall,),
                        const SizedBox(width: 10),
                        Expanded(
                          child:
                              widget.multiSelect
                                  ? Text(
                                    AppLocalizations
                                        .current
                                        .tap_or_long_press_to_select_file,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onPrimaryContainer,
                                      fontStyle: FontStyle.italic,
                                      fontSize: AppSize.fontSizeSmall,
                                    ),
                                  )
                                  : Text(
                                    '${AppLocalizations.current.found} ${_files.length} ${AppLocalizations.current.files} • ${AppLocalizations.current.selected} ${_selectedFiles.length} ${AppLocalizations.current.files}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onPrimaryContainer,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 10,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // File list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        final fileName = _getFileName(file);
                        final isSelected = _selectedFiles.contains(file);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: isSelected ? 1 : 0,
                          color:
                              isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surface,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outline.withValues(alpha: 0.2)  ,
                                width: 1,
                              ),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getFileColor(
                                  context,
                                  fileName,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getFileColor(
                                    context,
                                    fileName,
                                  ).withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: _getFileIcon(fileName),
                              ),
                            ),
                            title: Text(
                              fileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color: colorScheme.onSurface,
                                fontSize: AppSize.fontSizeMedium,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  _getFileSize(file),
                                  style: TextStyle(
                                    fontSize: AppSize.fontSizeMedium,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  file.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: AppSize.fontSizeSmall,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _toggleFileSelection(file),
                            onLongPress: () {
                              // Long press để chọn file và trả về
                              Navigator.pop(context, file.path);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingButton:
          _selectedFiles.isNotEmpty
              ? FloatingActionButton.extended(
                backgroundColor: colorScheme.primary,
                onPressed: _selectOrImportSelected,
                icon: Icon(
                  widget.multiSelect ? Icons.check : Icons.add,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  '${widget.multiSelect ? AppLocalizations.current.select_file : AppLocalizations.current.add_book} (${_selectedFiles.length})',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: AppSize.fontSizeMedium,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
              : null,
    );
  }
}
