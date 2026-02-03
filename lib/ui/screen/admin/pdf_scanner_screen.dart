import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

class PdfScannerScreen extends StatefulWidget {
  final ScanFormatEnum scanFormat;
  final bool isSelectedMode;
  const PdfScannerScreen({
    super.key,
    this.isSelectedMode = false,
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
        allowedExtensions: widget.scanFormat == ScanFormatEnum.pdf ? ['pdf', 'epub', 'mobi'] : ['doc', 'docx'],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm ${toAdd.length} file từ thư mục')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning files: $e')));
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
          if(widget.scanFormat == ScanFormatEnum.pdf) {
            if (path.endsWith('.pdf') ||
                path.endsWith('.epub') ||
                path.endsWith('.mobi')) {
              files.add(entity);
            }
          } else if (widget.scanFormat == ScanFormatEnum.word) {
            if (path.endsWith('.doc') ||
                path.endsWith('.docx')) {
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
      if (_selectedFiles.contains(file)) {
        _selectedFiles.remove(file);
      } else {
        _selectedFiles.add(file);
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

  Future<void> _importSelected() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một file')),
      );
      return;
    }

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
        String message = 'Đã thêm $addedCount sách vào thư viện';
        if (skippedCount > 0) {
          message += '\n$skippedCount sách đã tồn tại';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Return success
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
        return SvgPicture.asset(Assets.icons.icDoc);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BaseScreen(
      colorBg: colorScheme.surface,
      customAppBar: BaseAppBar(
        title: AppLocalizations.current.find_book,
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
          if (_files.isNotEmpty && !widget.isSelectedMode)
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
          !_hasPermission && _files.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Cần quyền truy cập bộ nhớ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng cấp quyền để tìm kiếm file',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hoặc dùng "Chọn file" để duyệt thư mục (không cần quyền)',
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
                          label: const Text('Cấp quyền'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Chọn file'),
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
                      'Đang quét bộ nhớ...',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              )
              : _files.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.current.no_book_found,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.current.no_pdf_epub_mobi_found,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations
                          .current
                          .use_select_file_to_browse_directory,
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
                          onPressed: _scanForFiles,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            AppLocalizations.current.scan_again,
                            style: TextStyle(color: colorScheme.onPrimary),
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
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child:
                              widget.isSelectedMode
                                  ? Text(
                                    'Nhấn vào file để chọn hoặc long press để xem đường dẫn',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onPrimaryContainer,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                  : Text(
                                      'Tìm thấy ${_files.length} file • Đã chọn ${_selectedFiles.length}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: colorScheme.onPrimaryContainer,
                                      fontStyle: FontStyle.italic,
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
                          elevation: isSelected ? 4 : 1,
                          color:
                              isSelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surface,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getFileColor(context, fileName).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getFileColor(context, fileName).withValues(alpha: 0.2),
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
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  _getFileSize(file),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  file.path,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            trailing:
                                widget.isSelectedMode
                                    ? null
                                    : Checkbox(
                                      value: isSelected,
                                      onChanged:
                                          (_) => _toggleFileSelection(file),
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
          _selectedFiles.isNotEmpty && !widget.isSelectedMode
              ? FloatingActionButton.extended(
                onPressed: _importSelected,
                icon: const Icon(Icons.check),
                label: Text('Import (${_selectedFiles.length})'),
              )
              : null,
    );
  }
}
