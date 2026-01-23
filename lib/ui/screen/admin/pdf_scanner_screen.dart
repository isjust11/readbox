import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/shared_preference.dart';

class PdfScannerScreen extends StatefulWidget {
  final bool isSelectedMode;
  const PdfScannerScreen({super.key, this.isSelectedMode = false});

  @override
  State<PdfScannerScreen> createState() => _PdfScannerScreenState();
}

class _PdfScannerScreenState extends State<PdfScannerScreen> {
  List<FileSystemEntity> _pdfFiles = [];
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
        _scanForPdfFiles();
      } else {
        // Fallback to regular storage permission
        final storageStatus = await Permission.storage.request();
        setState(() => _hasPermission = storageStatus.isGranted);
        if (storageStatus.isGranted) {
          _scanForPdfFiles();
        }
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      setState(() => _hasPermission = status.isGranted);
      if (status.isGranted) {
        _scanForPdfFiles();
      }
    }
  }

  /// Chọn file qua File Picker (SAF) — hoạt động với Scoped Storage, kể cả Download/Telegram
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'mobi'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;
      final existing = _pdfFiles.map((e) => e.path).toSet();
      final toAdd = <FileSystemEntity>[];
      for (final f in result.files) {
        if (f.path != null && f.path!.isNotEmpty && !existing.contains(f.path)) {
          toAdd.add(File(f.path!));
          existing.add(f.path!);
        }
      }
      if (toAdd.isEmpty) return;
      setState(() {
        _pdfFiles = [..._pdfFiles, ...toAdd];
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
          SnackBar(content: Text('Lỗi chọn file: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Future<void> _scanForPdfFiles() async {
    setState(() {
      _isScanning = true;
      _pdfFiles = [];
    });

    try {
      List<FileSystemEntity> allPdfFiles = [];

      if (Platform.isAndroid) {
        // Common directories to scan on Android (Scoped Storage có thể chặn thư mục con như Download/Telegram)
        final directories = [
          Directory('/storage/emulated/0/Download'),
          Directory('/storage/emulated/0/Downloads'),
          Directory('/storage/emulated/0/Documents'),
          Directory('/storage/emulated/0/DCIM'),
          await getExternalStorageDirectory(),
          await getApplicationDocumentsDirectory(),
        ];

        for (var dir in directories) {
          if (dir != null && await dir.exists()) {
            await _scanDirectory(dir, allPdfFiles);
          }
        }
      } else if (Platform.isIOS) {
        // iOS directories
        final appDir = await getApplicationDocumentsDirectory();
        await _scanDirectory(appDir, allPdfFiles);
      }

      setState(() {
        _pdfFiles = allPdfFiles;
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
    List<FileSystemEntity> pdfFiles,
  ) async {
    try {
      final entities = directory.listSync(recursive: true, followLinks: false);
      for (var entity in entities) {
        if (entity is File) {
          final path = entity.path.toLowerCase();
          if (path.endsWith('.pdf') ||
              path.endsWith('.epub') ||
              path.endsWith('.mobi')) {
            pdfFiles.add(entity);
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
      _selectedFiles = List.from(_pdfFiles);
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
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Theme.of(context).colorScheme.error),
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

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
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

  Color _getFileColor(BuildContext context, String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    final fallback = Theme.of(context).colorScheme.outline;
    switch (extension) {
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
            label: Text(AppLocalizations.current.select_file, style: TextStyle(color: colorScheme.onPrimary)),
          ),
          if (_pdfFiles.isNotEmpty && !widget.isSelectedMode)
            TextButton.icon(
              onPressed:
                  _selectedFiles.length == _pdfFiles.length
                      ? _deselectAll
                      : _selectAll,
              icon: Icon(
                _selectedFiles.length == _pdfFiles.length
                    ? Icons.deselect
                    : Icons.select_all,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                _selectedFiles.length == _pdfFiles.length
                    ? AppLocalizations.current.unselect_all
                    : AppLocalizations.current.select_all,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _isScanning ? null : _scanForPdfFiles,
          ),
        ],
      ),
      body:
          !_hasPermission && _pdfFiles.isEmpty
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
                    Text('Vui lòng cấp quyền để tìm kiếm file', style: TextStyle(color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Hoặc dùng "Chọn file" để duyệt thư mục (không cần quyền)',
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
                    Text('Đang quét bộ nhớ...', style: TextStyle(color: colorScheme.onSurface)),
                  ],
                ),
              )
              : _pdfFiles.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: colorScheme.outline),
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
                    Text(AppLocalizations.current.no_pdf_epub_mobi_found, style: TextStyle(color: colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.current.use_select_file_to_browse_directory,
                      style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _scanForPdfFiles,
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.current.scan_again, style: TextStyle(color: colorScheme.onPrimary)),
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
                    padding: const EdgeInsets.all(16),
                    color: colorScheme.primaryContainer,
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: widget.isSelectedMode ? Text(
                            'Nhấn vào file để chọn hoặc long press để xem đường dẫn',
                            style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
                          ): Text(
                            'Tìm thấy ${_pdfFiles.length} file • Đã chọn ${_selectedFiles.length}',
                            style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // File list
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pdfFiles.length,
                      itemBuilder: (context, index) {
                        final file = _pdfFiles[index];
                        final fileName = _getFileName(file);
                        final isSelected = _selectedFiles.contains(file);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: isSelected ? 4 : 1,
                          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getFileColor(context, fileName),
                              child: Icon(
                                _getFileIcon(fileName),
                                color: Colors.white,
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
                                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
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
                            trailing: widget.isSelectedMode ? null : Checkbox(
                              value: isSelected,
                              onChanged: (_) => _toggleFileSelection(file),
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
