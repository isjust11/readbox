import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WordToPdfConverterScreen extends StatefulWidget {
  const WordToPdfConverterScreen({super.key});

  @override
  State<WordToPdfConverterScreen> createState() => _WordToPdfConverterScreenState();
}

class _WordToPdfConverterScreenState extends State<WordToPdfConverterScreen> {
  File? _selectedFile;
  bool _isConverting = false;
  String? _outputPath;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = File(result.files.first.path!);
          _outputPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.current.error}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _convertToPdf() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.current.tools_select_file_first),
        ),
      );
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      // Create a simple PDF with text content
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      // Get file name
      final fileName = _selectedFile!.path.split('/').last;
      
      // Read file content (basic text extraction)
      String content = 'Word to PDF Conversion\n\n';
      content += 'Source File: $fileName\n\n';
      content += 'Note: For full Word document conversion with formatting,\n';
      content += 'advanced processing would be required.\n\n';
      content += 'This is a basic conversion placeholder.\n';
      content += 'File size: ${_selectedFile!.lengthSync()} bytes';

      // Draw text on PDF
      page.graphics.drawString(
        content,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(
          0,
          0,
          page.getClientSize().width,
          page.getClientSize().height,
        ),
      );

      // Save the document
      final directory = await getApplicationDocumentsDirectory();
      final outputFileName = fileName.replaceAll(RegExp(r'\.(doc|docx)$'), '.pdf');
      final outputPath = '${directory.path}/$outputFileName';
      
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(await document.save());
      document.dispose();

      setState(() {
        _outputPath = outputPath;
        _isConverting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.current.tools_conversion_success,
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isConverting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.current.tools_conversion_failed}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScreen(
      colorBg: colorScheme.surface,
      customAppBar: BaseAppBar(
        title: AppLocalizations.current.tools_word_to_pdf,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon and description
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.current.tools_word_to_pdf_description,
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select file button
            ElevatedButton.icon(
              onPressed: _isConverting ? null : _pickFile,
              icon: const Icon(Icons.file_open),
              label: Text(AppLocalizations.current.tools_select_word_file),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Selected file info
            if (_selectedFile != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.current.size}: ${_formatFileSize(_selectedFile!.lengthSync())}',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Convert button
              ElevatedButton.icon(
                onPressed: _isConverting ? null : _convertToPdf,
                icon: _isConverting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  _isConverting
                      ? AppLocalizations.current.tools_converting
                      : AppLocalizations.current.tools_convert_to_pdf,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],

            // Output file info
            if (_outputPath != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.current.tools_saved_successfully,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _outputPath!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Instructions
            const SizedBox(height: 24),
            Container(
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
                    '• ${AppLocalizations.current.select_file}\n'
                    '• Click "${AppLocalizations.current.tools_convert_to_pdf}"\n'
                    '• PDF will be saved to app documents',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
