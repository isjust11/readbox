import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/injection_container.dart';

class NewsCreateEditScreen extends StatelessWidget {
  final NewsModel? news;

  const NewsCreateEditScreen({Key? key, this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewsCubit>(
      create: (_) => getIt.get<NewsCubit>(),
      child: NewsCreateEditBody(news: news),
    );
  }
}

class NewsCreateEditBody extends StatefulWidget {
  final NewsModel? news;

  const NewsCreateEditBody({Key? key, this.news}) : super(key: key);

  @override
  State<NewsCreateEditBody> createState() => _NewsCreateEditBodyState();
}

class _NewsCreateEditBodyState extends State<NewsCreateEditBody> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();
  final _sourceController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Controller cho URL hình ảnh
  
  bool _isPublished = false;
  bool _isFeatured = false;
  
  // Biến lưu file hình ảnh đã chọn
  File? _selectedImage;

  bool get isEditMode => widget.news != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode && widget.news != null) {
      final news = widget.news!;
      _titleController.text = news.title ?? '';
      _summaryController.text = news.summary ?? '';
      _contentController.text = news.content ?? '';
      _authorController.text = news.author ?? '';
      _categoryController.text = news.category ?? '';
      _sourceController.text = news.source ?? '';
      _sourceUrlController.text = news.sourceUrl ?? '';
      _tagsController.text = news.tags?.join(', ') ?? '';
      _isPublished = news.isPublished ?? false;
      _isFeatured = news.isFeatured ?? false;
      _imageUrlController.text = news.imageUrl ?? ''; // Lưu URL hình ảnh cũ khi edit
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _sourceController.dispose();
    _sourceUrlController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Hàm chọn hình ảnh từ gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.clear(); // Reset URL khi chọn hình mới
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chọn hình ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hàm chụp hình ảnh từ camera
  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.clear(); // Reset URL khi chọn hình mới
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi chụp hình ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hiển thị dialog chọn nguồn hình ảnh
  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn nguồn hình ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Thư viện ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Xử lý imageUrl: ưu tiên URL từ TextField, nếu không có thì dùng file path tạm thời
    // Lưu ý: Trong thực tế, cần upload file lên server trước và lấy URL về
    String? finalImageUrl = _imageUrlController.text.trim().isNotEmpty 
        ? _imageUrlController.text.trim() 
        : null;
    if (_selectedImage != null && finalImageUrl == null) {
      // Tạm thời lưu file path, trong thực tế cần upload lên server và lấy URL về
      finalImageUrl = _selectedImage!.path;
      // TODO: Upload file lên server và lấy URL về
    }

    final newsData = NewsModel.fromJson({
      if (isEditMode && widget.news!.id != null) 'id': widget.news!.id,
      'title': _titleController.text,
      'summary': _summaryController.text,
      'content': _contentController.text,
      'author': _authorController.text,
      'category': _categoryController.text,
      'source': _sourceController.text,
      'sourceUrl': _sourceUrlController.text,
      'tags': tags,
      'isPublished': _isPublished,
      'isFeatured': _isFeatured,
      'imageUrl': finalImageUrl, // Thêm imageUrl vào dữ liệu gửi lên
      'publishedDate': _isPublished ? DateTime.now().toIso8601String() : null,
      'createdAt': isEditMode ? widget.news!.createdAt?.toIso8601String() : DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    if (isEditMode) {
      context.read<NewsCubit>().updateNews(newsData);
    } else {
      context.read<NewsCubit>().addNews(newsData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit News' : 'Create News'),
        actions: [
          BlocListener<NewsCubit, BaseState>(
            listener: (context, state) {
              if (state is LoadedState) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditMode ? 'News updated successfully' : 'News created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.data}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: BlocBuilder<NewsCubit, BaseState>(
              builder: (context, state) {
                return IconButton(
                  icon: state is LoadingState
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  onPressed: state is LoadingState ? null : _submitForm,
                );
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Summary
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: 'Summary',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content *',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., technology, science, health',
              ),
            ),
            const SizedBox(height: 16),
            // Source
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Source',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Source URL
            TextFormField(
              controller: _sourceUrlController,
              decoration: const InputDecoration(
                labelText: 'Source URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            // Upload hình ảnh
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hình ảnh',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Hiển thị hình ảnh đã chọn hoặc URL cũ
                if (_selectedImage != null || (_imageUrlController.text.isNotEmpty))
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                    ),
                  ),
                // Nút chọn hình ảnh
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Chọn hình ảnh'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (_selectedImage != null || _imageUrlController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _imageUrlController.clear();
                            });
                          },
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: 'Xóa hình ảnh',
                        ),
                      ),
                  ],
                ),
                // TextField để nhập URL hình ảnh (tùy chọn)
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Hoặc nhập URL hình ảnh',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: Icon(Icons.link),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _selectedImage = null; // Reset file khi nhập URL
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Published
            SwitchListTile(
              title: const Text('Published'),
              value: _isPublished,
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
            // Featured
            SwitchListTile(
              title: const Text('Featured'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() {
                  _isFeatured = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

