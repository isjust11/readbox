import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';

/// Example implementation using backend API for Word to PDF conversion
/// This is more reliable and handles formatting properly
class WordToPdfApiConverterScreen extends StatefulWidget {
  const WordToPdfApiConverterScreen({super.key});

  @override
  State<WordToPdfApiConverterScreen> createState() => _WordToPdfApiConverterScreenState();
}

class _WordToPdfApiConverterScreenState extends State<WordToPdfApiConverterScreen> {
  File? _selectedFile;
  bool _isConverting = false;
  String? _outputPath;
  double _progress = 0.0;
  final Dio _dio = Dio();

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
          _progress = 0.0;
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  /// Method 1: Using LibreOffice API (if you have your own server)
  Future<void> _convertWithLibreOfficeAPI() async {
    if (_selectedFile == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
    });

    try {
      // 1. Upload file to your server
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: _selectedFile!.path.split('/').last,
        ),
      });

      // 2. Call conversion API
      final response = await _dio.post(
        'https://your-server.com/api/convert/word-to-pdf',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer YOUR_API_KEY',
          },
        ),
        onSendProgress: (sent, total) {
          setState(() {
            _progress = sent / total * 0.3; // Upload: 0-30%
          });
        },
        onReceiveProgress: (received, total) {
          setState(() {
            _progress = 0.3 + (received / total * 0.7); // Download: 30-100%
          });
        },
      );

      // 3. Save PDF
      await _savePdf(response.data);

      setState(() {
        _isConverting = false;
        _progress = 1.0;
      });

      _showSuccess();
    } catch (e) {
      setState(() {
        _isConverting = false;
        _progress = 0.0;
      });
      _showError('Conversion failed: $e');
    }
  }

  /// Method 2: Using CloudConvert API (third-party service)
  Future<void> _convertWithCloudConvert() async {
    if (_selectedFile == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
    });

    try {
      const apiKey = 'YOUR_CLOUDCONVERT_API_KEY';

      // 1. Create conversion job
      final jobResponse = await _dio.post(
        'https://api.cloudconvert.com/v2/jobs',
        data: {
          'tasks': {
            'upload-my-file': {
              'operation': 'import/upload',
            },
            'convert-my-file': {
              'operation': 'convert',
              'input': 'upload-my-file',
              'output_format': 'pdf',
              'some_other_option': 'value',
            },
            'export-my-file': {
              'operation': 'export/url',
              'input': 'convert-my-file',
            },
          },
        },
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      final jobId = jobResponse.data['data']['id'];
      final uploadTask = jobResponse.data['data']['tasks'].firstWhere(
        (task) => task['name'] == 'upload-my-file',
      );

      setState(() => _progress = 0.1);

      // 2. Upload file
      final uploadFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path),
      });

      await _dio.post(
        uploadTask['result']['form']['url'],
        data: uploadFormData,
      );

      setState(() => _progress = 0.3);

      // 3. Wait for conversion to complete
      String jobStatus = 'processing';
      while (jobStatus != 'finished' && jobStatus != 'error') {
        await Future.delayed(const Duration(seconds: 2));

        final statusResponse = await _dio.get(
          'https://api.cloudconvert.com/v2/jobs/$jobId',
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
          ),
        );

        jobStatus = statusResponse.data['data']['status'];
        setState(() => _progress = 0.3 + (_progress < 0.8 ? 0.1 : 0));
      }

      if (jobStatus == 'error') {
        throw Exception('Conversion failed on server');
      }

      setState(() => _progress = 0.8);

      // 4. Download converted file
      final exportTask = jobResponse.data['data']['tasks'].firstWhere(
        (task) => task['name'] == 'export-my-file',
      );

      final downloadUrl = exportTask['result']['files'][0]['url'];
      final pdfResponse = await _dio.get(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      await _savePdf(pdfResponse.data);

      setState(() {
        _isConverting = false;
        _progress = 1.0;
      });

      _showSuccess();
    } catch (e) {
      setState(() {
        _isConverting = false;
        _progress = 0.0;
      });
      _showError('Conversion failed: $e');
    }
  }

  /// Method 3: Using Aspose.Words Cloud API
  Future<void> _convertWithAspose() async {
    if (_selectedFile == null) return;

    setState(() {
      _isConverting = true;
      _progress = 0.0;
    });

    try {
      const clientId = 'YOUR_CLIENT_ID';
      const clientSecret = 'YOUR_CLIENT_SECRET';

      // 1. Get access token
      final tokenResponse = await _dio.post(
        'https://api.aspose.cloud/connect/token',
        data: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      final accessToken = tokenResponse.data['access_token'];
      setState(() => _progress = 0.1);

      // 2. Upload file
      final fileName = _selectedFile!.path.split('/').last;
      final uploadFormData = FormData.fromMap({
        'file': await MultipartFile.fromFile(_selectedFile!.path),
      });

      await _dio.put(
        'https://api.aspose.cloud/v4.0/words/storage/file/$fileName',
        data: uploadFormData,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      setState(() => _progress = 0.4);

      // 3. Convert to PDF
      final convertResponse = await _dio.get(
        'https://api.aspose.cloud/v4.0/words/$fileName?format=pdf',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      await _savePdf(convertResponse.data);

      setState(() {
        _isConverting = false;
        _progress = 1.0;
      });

      _showSuccess();
    } catch (e) {
      setState(() {
        _isConverting = false;
        _progress = 0.0;
      });
      _showError('Conversion failed: $e');
    }
  }

  Future<void> _savePdf(List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/converted_$timestamp.pdf';
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(bytes);

    setState(() {
      _outputPath = outputPath;
    });
  }

  void _showSuccess() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.current.tools_conversion_success),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
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
        title: 'Word to PDF (API)',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'API-based Conversion',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uses backend API for accurate conversion',
                    style: TextStyle(
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
                          Icon(Icons.description, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile!.path.split('/').last,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Conversion method buttons
              Text(
                'Choose conversion method:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _isConverting ? null : _convertWithLibreOfficeAPI,
                child: const Text('Convert with Own Server'),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _isConverting ? null : _convertWithCloudConvert,
                child: const Text('Convert with CloudConvert'),
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _isConverting ? null : _convertWithAspose,
                child: const Text('Convert with Aspose.Words'),
              ),
            ],

            // Progress indicator
            if (_isConverting) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                '${(_progress * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],

            // Success message
            if (_outputPath != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.current.tools_saved_successfully,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _outputPath!,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Notes
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
                      Icon(Icons.info_outline, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'API Methods Comparison:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Own Server: Free, full control, requires backend\n'
                    '• CloudConvert: Easy, paid, 25 free conversions/day\n'
                    '• Aspose.Words: Powerful, paid, preserves formatting',
                    style: TextStyle(
                      fontSize: 12,
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

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
