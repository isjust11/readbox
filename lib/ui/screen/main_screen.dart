import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LibraryCubit>(
      create: (_) => getIt.get<LibraryCubit>(),
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
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  bool _isSearching = false;
  int page = 1;
  int limit = 10;
  String title = "";
  FilterType filterType = FilterType.all;
  Timer? _debounceTimer;
  String categoryId = "";
  String? _currentSearchQuery;

  @override
  void initState() {
    super.initState();
    title = AppLocalizations.current.my_library;  
    // Load initial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getBooks();
    });
  }

  Future<void> getBooks({bool isLoadMore = false}) async {
    if (isLoadMore) {
      page++;
    } else {
      page = 1;
    }

    await context.read<LibraryCubit>().getBooks(
      filterType: filterType,
      searchQuery: _currentSearchQuery,
      page: page,
      limit: limit,
      categoryId: categoryId,
      isLoadMore: isLoadMore,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _debounceTimer?.cancel();
        _searchController.clear();
        _currentSearchQuery = null;
        page = 1;
        getBooks();
      }
    });
  }

  void _onRefresh() async {
    page = 1;
    try {
      await context.read<LibraryCubit>().refreshBooks(
        filterType: filterType,
        searchQuery: _currentSearchQuery,
        page: page,
        limit: limit,
        categoryId: categoryId,
      );
    } finally {
      if (mounted) {
        _refreshController.refreshCompleted();
        // Reset load more state
        _refreshController.resetNoData();
      }
    }
  }

  void _onLoadMore() async {
    final cubit = context.read<LibraryCubit>();

    if (!cubit.hasMore || cubit.isLoadingMore) {
      if (mounted) {
        _refreshController.loadNoData();
      }
      return;
    }

    try {
      // Await getBooks để đợi API response thực sự
      await getBooks(isLoadMore: true);

      if (mounted) {
        final updatedCubit = context.read<LibraryCubit>();
        if (!updatedCubit.hasMore) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      }
    } catch (e) {
      if (mounted) {
        _refreshController.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.current.search_books,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.hintTextColor),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                  onChanged: (value) {
                    // Hủy timer trước đó nếu có
                    _debounceTimer?.cancel();

                    // Tạo timer mới, sau 700ms mới thực hiện search
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 700),
                      () {
                        if (mounted) {
                          _currentSearchQuery = value;
                          getBooks();
                        }
                      },
                    );
                  },
                )
                : Text(title, style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: colorScheme.onSurface),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.pushNamed(context, Routes.notificationScreen);
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        onSelected: (filter, title) {
          setState(() {
            filterType = FilterType.values.firstWhere((e) => e.name == filter);
            this.title = title;
          });
          getBooks();
        }, 
      ),
      body: BlocListener<BookRefreshCubit, int>(
        listener: (context, state) {
          // Lắng nghe sự thay đổi từ BookRefreshCubit
          // Khi có sự thay đổi (thêm/sửa/xóa sách), tự động refresh
          if (state > 0) {
            getBooks();
          }
        },
        child: BlocBuilder<LibraryCubit, BaseState>(
          builder: (context, state) {
            // Lấy books và cubit từ state
            final books = context.read<LibraryCubit>().books;
            final cubit = context.read<LibraryCubit>();

            // Hiển thị loading khi đang tải lần đầu
            if (state is LoadingState && books.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            // Hiển thị error khi có lỗi và chưa có data
            if (state is ErrorState && books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                    SizedBox(height: 16),
                    Text(
                      state.data?.toString() ??
                          AppLocalizations.current.error_loading_books,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => getBooks(),
                      child: Text(AppLocalizations.current.try_again),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị empty state
            if (books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 64, color: colorScheme.onSurface),
                    SizedBox(height: 16),
                    Text(
                      AppLocalizations.current.no_books,
                      style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
                    ),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.current.add_book_to_start_reading,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                    ),
                  ],
                ),
              );
            }

            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: cubit.hasMore,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: () {
                _onLoadMore();
              },
              header: WaterDropMaterialHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body = Container(height: 0);

                  // Check state từ cubit để hiển thị chính xác trạng thái
                  if (cubit.isLoadingMore) {
                    body = SizedBox(
                      height: 55,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (!cubit.hasMore) {
                    body = SizedBox(
                      height: 55,
                      child: Center(
                        child: Text(
                          AppLocalizations.current.all_data_loaded,
                          style: TextStyle(color: Theme.of(context).
                          colorScheme.onSurface.withValues(alpha: 0.8)),
                        ),
                      ),
                    );
                  } else if (mode == LoadStatus.idle) {
                    body = SizedBox(height: 0);
                  }
                  return body;
                },
              ),
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return BookCard(book: books[index], 
                  userInteractionCubit: context.read<UserInteractionCubit>());
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
