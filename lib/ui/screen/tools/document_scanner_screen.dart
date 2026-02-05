import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen> {
  final List<File> _scannedPages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.cannot_access_camera,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    await _requestCameraPermission();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _scannedPages.add(File(photo.path));
        });
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

  void _removePage(int index) {
    setState(() {
      _scannedPages.removeAt(index);
    });
  }

  Future<void> _saveAsPdf() async {
    if (_scannedPages.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.tools_no_file_selected,
        snackBarType: SnackBarType.error,
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create PDF document
      final PdfDocument document = PdfDocument();

      for (final imageFile in _scannedPages) {
        // Add page to document
        final PdfPage page = document.pages.add();

        // Load image
        final image = PdfBitmap(await imageFile.readAsBytes());

        // Calculate dimensions to fit page
        final pageSize = page.getClientSize();
        final imageAspect = image.width / image.height;
        final pageAspect = pageSize.width / pageSize.height;

        double drawWidth, drawHeight;
        if (imageAspect > pageAspect) {
          drawWidth = pageSize.width;
          drawHeight = pageSize.width / imageAspect;
        } else {
          drawHeight = pageSize.height;
          drawWidth = pageSize.height * imageAspect;
        }

        // Center the image
        final x = (pageSize.width - drawWidth) / 2;
        final y = (pageSize.height - drawHeight) / 2;

        // Draw image on page
        page.graphics.drawImage(
          image,
          Rect.fromLTWH(x, y, drawWidth, drawHeight),
        );
      }

      // Save document
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${directory.path}/scanned_document_$timestamp.pdf';
      
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(await document.save());
      document.dispose();

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.tools_saved_successfully}\n$outputPath',
          snackBarType: SnackBarType.success,
        );

        // Clear pages after successful save
        setState(() {
          _scannedPages.clear();
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.tools_save_failed}: $e',
          snackBarType: SnackBarType.warning,
        );
      }
    }
  }

  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.current.tools_take_photo),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.current.tools_choose_from_gallery),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfScannerScreen(scanFormat: ScanFormatEnum.image,
                      multiSelect: false,
                      ),
                    ),
                  );
                  if (result != null && mounted) {
                    List<File> files = [];
                    for (var file in result) {
                      files.add(File(file));
                    }
                    setState(() {
                      _scannedPages.addAll(files);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScreen(
      colorBg: colorScheme.surface,
      customAppBar: BaseAppBar(
        title: AppLocalizations.current.tools_document_scanner,
        centerTitle: true,
        actions: [
          if (_scannedPages.isNotEmpty)
            TextButton.icon(
              onPressed: _isProcessing ? null : _saveAsPdf,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.save, color: colorScheme.onPrimary),
              label: Text(
                AppLocalizations.current.tools_save_as_pdf,
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
        ],
      ),
      body: _scannedPages.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildPagesList(colorScheme),
      floatingButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _showOptionsDialog,
        icon: const Icon(Icons.add_a_photo),
        label: Text(_scannedPages.isEmpty
            ? AppLocalizations.current.tools_scan_document
            : AppLocalizations.current.tools_add_more_pages),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.document_scanner,
              size: 80,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.current.tools_document_scanner,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.current.tools_document_scanner_description,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.current.info,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Take photos or select from gallery\n'
                  '• Add multiple pages\n'
                  '• Save as PDF document',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagesList(ColorScheme colorScheme) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: colorScheme.primaryContainer,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_scannedPages.length} ${AppLocalizations.current.pages}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Pages grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: _scannedPages.length,
            itemBuilder: (context, index) {
              return _buildPageCard(index, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPageCard(int index, ColorScheme colorScheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            _scannedPages[index],
            fit: BoxFit.cover,
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          // Page number
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => _removePage(index),
            ),
          ),
        ],
      ),
    );
  }
}
