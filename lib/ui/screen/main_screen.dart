import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';
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
                  return BookCard(book: books[index]);
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
}
