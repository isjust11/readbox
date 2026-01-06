import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/ui/widget/app_widgets/app_drawer.dart';
import 'package:readbox/ui/widget/widget.dart';

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
  MainBodyState createState() => MainBodyState();
}

class MainBodyState extends State<MainBody> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _debounceTimer?.cancel();
        _searchController.clear();
        context.read<LibraryCubit>().getBooks();
      }
    });
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
                  hintStyle: TextStyle(color: AppColors.hintTextColor),
                ),
                style: TextStyle(color: AppColors.secondaryTextDark),
                onChanged: (value) {
                  // Hủy timer trước đó nếu có
                  _debounceTimer?.cancel();
                  
                  // Tạo timer mới, sau 700ms mới thực hiện search
                  _debounceTimer = Timer(const Duration(milliseconds: 700), () {
                    if (mounted) {
                      context.read<LibraryCubit>().searchBooks(value);
                    }
                  });
                },
              )
            : Text('Thư viện của tôi'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      drawer: AppDrawer(),
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
}
