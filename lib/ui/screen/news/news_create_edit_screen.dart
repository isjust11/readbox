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

  Future<void> _submitForm() async {
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
      final response = await context.read<NewsCubit>().uploadImage(_selectedImage!);
      finalImageUrl = response['fileUrl'];
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
        title: Text(
          isEditMode ? 'Chỉnh sửa tin tức' : 'Tạo tin tức mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          BlocListener<NewsCubit, BaseState>(
            listener: (context, state) {
              if (state is LoadedState) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditMode ? 'Cập nhật tin tức thành công' : 'Tạo tin tức thành công'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${state.data}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: BlocBuilder<NewsCubit, BaseState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton.icon(
                    onPressed: state is LoadingState ? null : _submitForm,
                    icon: state is LoadingState
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, color: Colors.white),
                    label: Text(
                      state is LoadingState ? 'Đang lưu...' : 'Lưu',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Section: Thông tin cơ bản
            _buildSection(
              title: 'Thông tin cơ bản',
              icon: Icons.article,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Tiêu đề *',
                  icon: Icons.title,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _summaryController,
                  label: 'Tóm tắt',
                  icon: Icons.summarize,
                  maxLines: 3,
                  hintText: 'Nhập tóm tắt ngắn gọn về tin tức...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _contentController,
                  label: 'Nội dung *',
                  icon: Icons.description,
                  maxLines: 12,
                  hintText: 'Nhập nội dung chi tiết của tin tức...',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Section: Hình ảnh
            _buildSection(
              title: 'Hình ảnh',
              icon: Icons.image,
              children: [
                if (_selectedImage != null || _imageUrlController.text.isNotEmpty)
                  Container(
                    height: 220,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                            SizedBox(height: 8),
                                            Text('Không thể tải hình ảnh', style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _imageUrlController.clear();
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Chọn hình ảnh'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Hoặc nhập URL hình ảnh',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  hintText: 'https://example.com/image.jpg',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Section: Thông tin bổ sung
            _buildSection(
              title: 'Thông tin bổ sung',
              icon: Icons.info_outline,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _authorController,
                        label: 'Tác giả',
                        icon: Icons.person,
                        hintText: 'Nhập tên tác giả...',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _categoryController,
                        label: 'Danh mục',
                        icon: Icons.category,
                        hintText: 'Nhập danh mục...',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _tagsController,
                  label: 'Thẻ (phân cách bằng dấu phẩy)',
                  icon: Icons.tag,
                  hintText: 'ví dụ: công nghệ, khoa học, sức khỏe',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _sourceController,
                  label: 'Nguồn',
                  icon: Icons.source,
                  hintText: 'Nhập nguồn tin...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _sourceUrlController,
                  label: 'Link nguồn',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  hintText: 'https://example.com',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Section: Cài đặt
            _buildSection(
              title: 'Cài đặt',
              icon: Icons.settings,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _isPublished ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPublished ? Colors.green.shade200 : Colors.grey.shade300,
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Xuất bản',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Tin tức sẽ hiển thị công khai'),
                    value: _isPublished,
                    onChanged: (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
                    activeColor: Colors.green,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _isFeatured ? Colors.amber.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFeatured ? Colors.amber.shade200 : Colors.grey.shade300,
                    ),
                  ),
                  child: SwitchListTile(
                    title: const Text(
                      'Nổi bật',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Tin tức sẽ được đánh dấu nổi bật'),
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value;
                      });
                    },
                    activeColor: Colors.amber,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

