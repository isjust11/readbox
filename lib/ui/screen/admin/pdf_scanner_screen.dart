import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readbox/utils/shared_preference.dart';

class PdfScannerScreen extends StatefulWidget {
  const PdfScannerScreen({super.key});

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
      // Check current status first
      final manageStorageStatus = await Permission.manageExternalStorage.status;
      debugPrint('Android manageExternalStorage status: $manageStorageStatus');
      
      if (manageStorageStatus.isGranted) {
        setState(() => _hasPermission = true);
        _scanForPdfFiles();
        return;
      }
      
      // Request permission
      final status = await Permission.manageExternalStorage.request();
      debugPrint('Android manageExternalStorage request result: $status');
      
      if (status.isGranted) {
        setState(() => _hasPermission = true);
        _scanForPdfFiles();
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, need to open settings
        setState(() => _hasPermission = false);
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      } else {
        // Try fallback to regular storage permission (for Android < 13)
        final storageStatus = await Permission.storage.status;
        debugPrint('Android storage status: $storageStatus');
        
        if (storageStatus.isGranted) {
          setState(() => _hasPermission = true);
          _scanForPdfFiles();
        } else {
          final requestedStorageStatus = await Permission.storage.request();
          debugPrint('Android storage request result: $requestedStorageStatus');
          
          setState(() => _hasPermission = requestedStorageStatus.isGranted);
          if (requestedStorageStatus.isGranted) {
            _scanForPdfFiles();
          } else if (requestedStorageStatus.isPermanentlyDenied && mounted) {
            _showPermissionDeniedDialog();
          }
        }
      }
    } else if (Platform.isIOS) {
      // On iOS, app documents directory doesn't need permission
      // We can scan files in app's own directories without permission
      setState(() => _hasPermission = true);
      _scanForPdfFiles();
      
      // Note: If you need to access files outside app directory, use file_picker
      // which handles permissions automatically
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cần quyền truy cập'),
          content: const Text(
            'Ứng dụng cần quyền truy cập bộ nhớ để tìm kiếm file. '
            'Vui lòng cấp quyền trong Settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Mở Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _scanForPdfFiles() async {
    setState(() {
      _isScanning = true;
      _pdfFiles = [];
    });

    try {
      List<FileSystemEntity> allPdfFiles = [];

      if (Platform.isAndroid) {
        // Common directories to scan on Android
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning files: $e')),
        );
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
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
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
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
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

  Color _getFileColor(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
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
        title: const Text('Tìm kiếm file Ebook'),
        actions: [
          if (_pdfFiles.isNotEmpty)
            TextButton.icon(
              onPressed: _selectedFiles.length == _pdfFiles.length
                  ? _deselectAll
                  : _selectAll,
              icon: Icon(
                _selectedFiles.length == _pdfFiles.length
                    ? Icons.deselect
                    : Icons.select_all,
                color: Colors.white,
              ),
              label: Text(
                _selectedFiles.length == _pdfFiles.length ? 'Bỏ chọn' : 'Chọn tất cả',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanForPdfFiles,
          ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Cần quyền truy cập bộ nhớ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Vui lòng cấp quyền để tìm kiếm file'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _requestPermissions,
                    icon: const Icon(Icons.settings),
                    label: const Text('Cấp quyền'),
                  ),
                ],
              ),
            )
          : _isScanning
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang quét bộ nhớ...'),
                    ],
                  ),
                )
              : _pdfFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Không tìm thấy file nào',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Không có file PDF, EPUB, hoặc MOBI'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _scanForPdfFiles,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Quét lại'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header with file count
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.blue.shade50,
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tìm thấy ${_pdfFiles.length} file • Đã chọn ${_selectedFiles.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
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
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getFileColor(fileName),
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
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        _getFileSize(file),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        file.path,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleFileSelection(file),
                                  ),
                                  onTap: () => _toggleFileSelection(file),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: _selectedFiles.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _importSelected,
              icon: const Icon(Icons.check),
              label: Text('Import (${_selectedFiles.length})'),
            )
          : null,
    );
  }
}

