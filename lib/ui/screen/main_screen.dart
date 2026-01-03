import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/utils/shared_preference.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryCubit>(
      create: (_) => getIt.get<LibraryCubit>()..getBooks(),
      child: MainBody(),
    );
  }
}

class MainBody extends StatefulWidget {
  const MainBody({super.key});
  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  UserModel? _currentUser;
  String _currentFilter = 'all'; // 'all', 'favorite', 'archived'

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await SharedPreferenceUtil.getUserInfo();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<LibraryCubit>().searchBooks(query);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<LibraryCubit>().getBooks();
      }
    });
  }

  void _filterBooks(String filter) {
    setState(() {
      _currentFilter = filter;
    });
    
    switch (filter) {
      case 'all':
        context.read<LibraryCubit>().getBooks();
        break;
      case 'favorite':
        context.read<LibraryCubit>().getBooks(isFavorite: true);
        break;
      case 'archived':
        context.read<LibraryCubit>().getBooks(isArchived: true);
        break;
    }
    Navigator.pop(context); // Close drawer
  }

  void _handleLogout() async {
    await SharedPreferenceUtil.clearData();
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.loginScreen,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sách...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              )
            : Text('Thư viện của tôi'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<LibraryCubit>().refreshBooks();
        },
        child: BlocBuilder<LibraryCubit, BaseState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is ErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      state.data?.toString() ?? 'Đã xảy ra lỗi',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<LibraryCubit>().getBooks(),
                      child: Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is LoadedState) {
              final books = context.read<LibraryCubit>().books;

              if (books.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có sách nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Thêm sách để bắt đầu đọc',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return _buildBookCard(books[index]);
                },
              );
            }

            return Center(child: Text('Tải danh sách sách...'));
          },
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 24, bottom: 24),
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
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _currentUser?.username ?? 'User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _currentUser?.address ?? '',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            _buildDrawerItem(
              icon: Icons.library_books,
              title: 'Tất cả sách',
              isSelected: _currentFilter == 'all',
              onTap: () => _filterBooks('all'),
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'Sách yêu thích',
              isSelected: _currentFilter == 'favorite',
              onTap: () => _filterBooks('favorite'),
              iconColor: Colors.red,
            ),
            _buildDrawerItem(
              icon: Icons.archive,
              title: 'Đã lưu trữ',
              isSelected: _currentFilter == 'archived',
              onTap: () => _filterBooks('archived'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDrawerItem(
              icon: Icons.phone_android,
              title: 'Thư viện Local',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.localLibraryScreen);
              },
              iconColor: Colors.green,
            ),
            _buildDrawerItem(
              icon: Icons.upload_file,
              title: 'Upload sách',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.adminUploadScreen);
              },
            ),
            _buildDrawerItem(
              icon: Icons.book,
              title: 'Demo PDF Viewer',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.pdfTextToSpeechScreen);
              },
            ),
            _buildDrawerItem(
              icon: Icons.volume_up_rounded,
              title: 'Demo Text-to-Speech',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.ttsDemoScreen);
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(height: 1),
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: _handleLogout,
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.15)
                : (iconColor?.withValues(alpha: 0.1) ?? Colors.grey[100]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).primaryColor
                : (iconColor ?? Colors.grey[700]),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (isSelected ? Theme.of(context).primaryColor : Colors.grey[800]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Otherwise, it's from our backend
    return '${ApiConstant.apiHostStorage}$imagePath';
  }

  void _openPdfViewer(BookModel book) {
    if (book.fileUrl != null) {
      Navigator.pushNamed(
        context,
        Routes.pdfViewerWithSelectionScreen,
        arguments: {
          'fileUrl': '${ApiConstant.apiHostStorage}${book.fileUrl}',
          'title': book.displayTitle,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File ebook không tồn tại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showBookOptions(BookModel book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              
              // Book info
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: book.coverImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _getImageUrl(book.coverImageUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.book, color: Colors.grey);
                              },
                            ),
                          )
                        : Icon(Icons.book, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.displayTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          book.displayAuthor,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Action buttons
              _buildActionButton(
                icon: Icons.menu_book_rounded,
                label: 'Đọc sách',
                color: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  _openPdfViewer(book);
                },
              ),
              
              SizedBox(height: 12),
              
              _buildActionButton(
                icon: Icons.info_outline_rounded,
                label: 'Xem chi tiết',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.bookDetailScreen, arguments: book);
                },
              ),
              
              SizedBox(height: 12),
              
              _buildActionButton(
                icon: book.isFavorite == true 
                    ? Icons.favorite_rounded 
                    : Icons.favorite_border_rounded,
                label: book.isFavorite == true 
                    ? 'Bỏ yêu thích' 
                    : 'Yêu thích',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement toggle favorite
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        book.isFavorite == true 
                            ? 'Đã bỏ khỏi yêu thích' 
                            : 'Đã thêm vào yêu thích',
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 12),
              
              _buildActionButton(
                icon: Icons.close_rounded,
                label: 'Đóng',
                color: Colors.grey[700]!,
                onTap: () => Navigator.pop(context),
                isOutlined: true,
              ),
              
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: isOutlined 
              ? Border.all(color: Colors.grey[300]!, width: 1.5)
              : Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOutlined 
                    ? Colors.grey[100]
                    : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? Colors.grey[700] : color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isOutlined ? Colors.grey[400] : color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // Tap thường: Đọc ebook trực tiếp
            _openPdfViewer(book);
          },
          onLongPress: () {
            // Long press: Hiển thị menu options
            _showBookOptions(book);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                _getImageUrl(book.coverImageUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.book, size: 48, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(Icons.book, size: 48, color: Colors.grey[400]),
                            ),
                    ),
                    // Favorite badge
                    if (book.isFavorite == true)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Book Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            book.displayAuthor,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Rating
                      Row(
                        children: [
                          if (book.rating != null && book.rating! > 0) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                  SizedBox(width: 4),
                                  Text(
                                    book.rating!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Mới',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
