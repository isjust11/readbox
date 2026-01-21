import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:readbox/blocs/admin/admin_cubit.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/book_refresh/book_refresh_cubit.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/ui/screen/admin/pdf_scanner_screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/pdf_thumbnail_service.dart';

class AdminUploadScreen extends StatelessWidget {
  final String? fileUrl;
  final String? title;
  const AdminUploadScreen({super.key, this.fileUrl, this.title});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (_) => getIt.get<AdminCubit>()..loadCategories(),
      child: AdminUploadBody(fileUrl: fileUrl, title: title),
    );
  }
}

class AdminUploadBody extends StatefulWidget {
  final String? fileUrl;
  final String? title;
  const AdminUploadBody({super.key, this.fileUrl, this.title});
  @override
  AdminUploadBodyState createState() => AdminUploadBodyState();
}

class AdminUploadBodyState extends State<AdminUploadBody> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _publisherController = TextEditingController();
  final _isbnController = TextEditingController();
  final _totalPagesController = TextEditingController();
  
  File? _ebookFile;
  File? _coverImageFile;
  bool _isPublic = true;
  String _language = 'vi';
  int? _selectedCategoryId;
  
  bool _isUploadingEbook = false;
  bool _isUploadingCover = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _totalPagesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<BookRefreshCubit>().reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.fileUrl != null) {
      _ebookFile = File(widget.fileUrl!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadThumbnailFromPdf(_ebookFile);
      });
    }
    if (widget.title != null) {
      _titleController.text = widget.title!;
    }
  }

  /// Tạo thumbnail từ trang đầu PDF và gán làm ảnh bìa để upload.
  Future<void> _loadThumbnailFromPdf(File? ebookFile) async {
    if (ebookFile == null || !mounted) return;
    final path = ebookFile.path.toLowerCase();
    if (!path.endsWith('.pdf')) return;

    final bytes = await PdfThumbnailService.getThumbnail(
      ebookFile.path,
      width: 300,
      height: 420,
    );
    if (bytes == null || !mounted) return;
    if (_ebookFile?.path != ebookFile.path) return;

    final dir = await getTemporaryDirectory();
    final thumbPath =
        '${dir.path}/readbox_pdf_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final thumbFile = File(thumbPath);
    await thumbFile.writeAsBytes(bytes);

    if (!mounted || _ebookFile?.path != ebookFile.path) return;
    setState(() {
      _coverImageFile = thumbFile;
    });
    if (!mounted) return;
    if (context.read<AdminCubit>().coverImageUrl != null) {
      context.read<AdminCubit>().resetCoverImage();
    }
  }

  Future<void> _pickEbookFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub', 'mobi'],
        initialDirectory: '/storage/emulated/0/Download',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _ebookFile = File(result.files.single.path!);
        });
        await _loadThumbnailFromPdf(_ebookFile);
      }
    } catch (e) {
      // showCustomSnackBar(context, 'Error picking file: $e', isError: true);
    }
  }

  Future<void> _scanAndPickEbookFile() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PdfScannerScreen(),
        ),
      );

      if (result == true) {
        // Files were added to SharedPreferences
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sách đã được thêm vào thư viện local'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickCoverImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _coverImageFile = File(image.path);
        });
      }
    } catch (e) {
      // showCustomSnackBar(context, 'Error picking image: $e', isError: true);
    }
  }

  Future<void> _uploadEbookFile() async {
    if (_ebookFile == null) {
      // showCustomSnackBar(context, 'Please select an ebook file first', isError: true);
      return;
    }

    setState(() {
      _isUploadingEbook = true;
    });

    await context.read<AdminCubit>().uploadEbook(_ebookFile!);

    setState(() {
      _isUploadingEbook = false;
    });
  }

  Future<void> _uploadCoverImage() async {
    if (_coverImageFile == null) {
      // showCustomSnackBar(context, 'Please select a cover image first', isError: true);
      return;
    }

    setState(() {
      _isUploadingCover = true;
    });

    await context.read<AdminCubit>().uploadCoverImage(_coverImageFile!);

    setState(() {
      _isUploadingCover = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cubit = context.read<AdminCubit>();
    
    if (cubit.ebookFileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.current.please_upload_ebook_file_first),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await cubit.createBook(
      title: _titleController.text,
      author: _authorController.text,
      description: _descriptionController.text.isEmpty 
          ? null 
          : _descriptionController.text,
      publisher: _publisherController.text.isEmpty 
          ? null 
          : _publisherController.text,
      isbn: _isbnController.text.isEmpty 
          ? null 
          : _isbnController.text,
      totalPages: _totalPagesController.text.isEmpty 
          ? null 
          : int.tryParse(_totalPagesController.text),
      language: _language,
      isPublic: _isPublic,
      categoryId: _selectedCategoryId,
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _publisherController.clear();
    _isbnController.clear();
    _totalPagesController.clear();
    
    setState(() {
      _ebookFile = null;
      _coverImageFile = null;
      _isPublic = true;
      _language = 'vi';
      _selectedCategoryId = null;
    });
    
    context.read<AdminCubit>().reset();
    
    // Notify toàn app rằng danh sách sách đã thay đổi
    context.read<BookRefreshCubit>().notifyBookListChanged();
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.upload_file_rounded, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.current.upload_book,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.current.create_new_book,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<AdminCubit, BaseState>(
        listener: (context, state) {
          if (state is ErrorState) {
            // showCustomSnackBar(context, state.data, isError: true);
          } else if (state is LoadedState) {
            final cubit = context.read<AdminCubit>();
            if (cubit.uploadEbookSuccess) {
              _resetForm();
            }
          }
        },
        child: BlocBuilder<AdminCubit, BaseState>(
          builder: (context, state) {
            final cubit = context.read<AdminCubit>();
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ebook File Section
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryColor.withValues(alpha: 0.1),
                                        theme.primaryColor.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: theme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.current.fileEbook,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.current.pdfEpubMobi,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.current.required_field,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            if (_ebookFile == null) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: _pickEbookFile,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: theme.primaryColor.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.folder_open_rounded,
                                              size: 40,
                                              color: theme.primaryColor,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              AppLocalizations.current.select_file,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              AppLocalizations.current.from_file_picker,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: _scanAndPickEbookFile,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          color: Colors.green.withValues(alpha: 0.02),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.search_rounded,
                                              size: 40,
                                              color: Colors.green,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              AppLocalizations.current.search,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              AppLocalizations.current.in_memory,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: theme.colorScheme.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                            else if (cubit.ebookFileUrl == null)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.insert_drive_file_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _ebookFile!.path.split('/').last,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                AppLocalizations.current.ready_to_upload,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close_rounded,
                                           color: theme.iconTheme.color),
                                          onPressed: () {
                                            setState(() {
                                              _ebookFile = null;
                                              _coverImageFile = null;
                                            });
                                            context.read<AdminCubit>().resetCoverImage();
                                            context.read<AdminCubit>().resetErrorUpload();
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    if (cubit.errorUploadEbook != null)
                                      Text(
                                        cubit.errorUploadEbook!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _isUploadingEbook ? null : _uploadEbookFile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.primaryColor,
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (_isUploadingEbook)
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: theme.primaryColor,
                                                ),
                                              )
                                            else
                                              Icon(Icons.upload_rounded, size: 20, color: theme.colorScheme.onSecondary),
                                              SizedBox(width: 8),
                                              Text(
                                                _isUploadingEbook ? AppLocalizations.current.uploading : AppLocalizations.current.upload_file,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.colorScheme.onSecondary
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withValues(alpha: 0.05),
                                      theme.colorScheme.primary.withValues(alpha: 0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLocalizations.current.upload_success,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          Text(
                                            _ebookFile!.path.split('/').last,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Cover Image Section
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withValues(alpha: 0.3),
                                        theme.colorScheme.primary.withValues(alpha: 0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.image_rounded,
                                    color: theme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.current.cover_image,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.current.jpgPngWebp,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    AppLocalizations.current.optional,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            
                            if (_coverImageFile == null)
                              InkWell(
                                onTap: _pickCoverImage,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: theme.primaryColor.withValues(alpha: 0.3),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    color: theme.primaryColor.withValues(alpha: 0.02),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 48,
                                          color: theme.primaryColor,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          AppLocalizations.current.select_cover_image,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          AppLocalizations.current.recommended_size,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      _coverImageFile!,
                                      height: 250,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  if (cubit.coverImageUrl == null)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: _isUploadingCover ? null : _uploadCoverImage,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.primaryColor,
                                              padding: EdgeInsets.symmetric(vertical: 14),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                if (_isUploadingCover)
                                                  SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: theme.colorScheme.onSecondary,
                                                    ),
                                                  )
                                                else
                                                  Icon(Icons.upload_rounded, size: 20, color: theme.colorScheme.onSecondary),
                                                SizedBox(width: 8),
                                                Text(
                                                  _isUploadingCover ? AppLocalizations.current.uploading : AppLocalizations.current.upload_cover_image,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.onSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.close_rounded, color: Colors.grey[700]),
                                            onPressed: () {
                                              setState(() {
                                                _coverImageFile = null;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.current.cover_image_uploaded_successfully,
                                              style: TextStyle(
                                                color: Colors.green[900],
                                                fontWeight: FontWeight.w600,
                                              ),
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
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Book Information
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.cardColor,
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.withValues(alpha: 0.1),
                                        Colors.blue.withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  AppLocalizations.current.book_information,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            CustomTextInput(
                              textController: _titleController,
                              title: AppLocalizations.current.title,
                              hintText: AppLocalizations.current.please_enter_title,
                              isRequired: true,
                              prefixIcon: Icon(Icons.title_rounded),
                              validator: (value) => value.isEmpty ? AppLocalizations.current.please_enter_title : null,
                            ),
                            
                            SizedBox(height: 16),
                            CustomTextInput(
                              textController: _authorController,
                              title: AppLocalizations.current.author,
                              hintText: AppLocalizations.current.please_enter_author,
                              isRequired: true,
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              validator: (value) => value.isEmpty ? AppLocalizations.current.please_enter_author : null,
                            ),
                            SizedBox(height: 16),
                            CustomTextInput(
                              textController: _descriptionController,
                              title: AppLocalizations.current.description,
                              hintText: AppLocalizations.current.please_enter_description,
                              prefixIcon: Icon(Icons.description_outlined),
                              maxLines: 4,
                              minLines: 4,
                              validator: (value) => value.isEmpty ? AppLocalizations.current.please_enter_description : null,
                            ),
                            
                            SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextInput(
                                    textController: _publisherController,
                                  title: AppLocalizations.current.publisher,
                                  hintText: AppLocalizations.current.please_enter_publisher,
                                  prefixIcon: Icon(Icons.business_rounded),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextInput(
                                    textController: _isbnController,
                                    title: AppLocalizations.current.isbn,
                                    hintText: AppLocalizations.current.please_enter_isbn,
                                    prefixIcon: Icon(Icons.tag_rounded),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextInput(
                                    textController: _totalPagesController,
                                    title: AppLocalizations.current.total_pages,
                                    hintText: '0',
                                    formatCurrency: true,
                                    prefixIcon: Icon(Icons.numbers_rounded),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: CustomDropDown(
                                    hintText: AppLocalizations.current.select_language,
                                    listValues: ['vi', 'en'],
                                    selectedIndex: _language.indexOf(_language),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 16),
                            
                            if (cubit.categories.isNotEmpty)
                              DropdownButtonFormField<int>(
                                value: _selectedCategoryId,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.current.category,
                                  prefixIcon: Icon(Icons.category_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: theme.primaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                items: cubit.categories.map((category) {
                                  return DropdownMenuItem<int>(
                                    value: category['id'],
                                    child: Text(category['name'] ?? '', style: TextStyle(color: theme.colorScheme.secondary.withValues(alpha: 0.8))),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                  });
                                },
                              ),
                            
                            SizedBox(height: 16),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: _isPublic 
                                    ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isPublic
                                      ? theme.primaryColor.withValues(alpha: 0.3)
                                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: SwitchListTile(
                                title: Text(
                                  AppLocalizations.current.public,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  _isPublic 
                                      ? AppLocalizations.current.book_will_be_displayed_for_everyone
                                      : AppLocalizations.current.book_will_be_displayed_for_admin,
                                  style: TextStyle(fontSize: 12),
                                ),
                                value: _isPublic,
                                activeColor: theme.primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _isPublic = value;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[600]!,
                            Colors.green[500]!,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: state is LoadingState ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state is LoadingState
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    AppLocalizations.current.creating_book,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    AppLocalizations.current.create_new_book,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
