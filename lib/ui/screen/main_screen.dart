import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:scale_size/scale_size.dart';

import '../../domain/data/models/models.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MainBody();
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
  // Filter state
  FilterModel? _filterModel;
  UserModel? userInfo;
  List<CategoryModel> categories = [];
  @override
  void initState() {
    super.initState();
    title = AppLocalizations.current.book_discover;
    // Load initial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getUnreadCount();
      getBooks();
      //my interactions
      loadUserInteractions();
    });
    loadUserInfo();
    loadCategories();
  }

  // load category
  Future<void> loadCategories() async {
    final categories = await context.read<CategoryCubit>().getCategoriesByCode(
      categoryTypeCode: CategoryTypeEnum.BOOK_CATEGORY.name,
    );
    if (mounted) {
      setState(() {
        this.categories = categories;
      });
    }
  }

  // load user interactions
  Future<void> loadUserInteractions() async {
    Map<String, dynamic> query = {
      'page': 1,
      'limit': 10,
      'interactionType': InteractionType.reading.name,
      'targetType': InteractionTarget.book.name,
    };
    await context.read<UserInteractionCubit>().getMyInteractions(query: query);
  }

  Future<void> loadUserInfo() async {
    final user = await SecureStorageService().getUserInfo();
    if (user != null) {
      if (mounted) {
        context.read<AppCubit>().setUser(user);
        setState(() {
          userInfo = user;
        });
      }
    }
  }

  Future<void> getBooks({bool isLoadMore = false}) async {
    if (isLoadMore) {
      page++;
    } else {
      page = 1;
    }

    // Use filter category if in search mode, otherwise use drawer category
    final effectiveCategoryId =
        _isSearching && _filterModel?.categoryId != null
            ? _filterModel?.categoryId
            : categoryId;

    // Use filter "my upload" if in search mode, otherwise use filterType
    final effectiveIsDiscover =
        _isSearching && (_filterModel?.isMyUpload ?? false)
            ? false // fromMe = true means isDiscover = false
            : filterType == FilterType.discover;

    await context.read<LibraryCubit>().getBooks(
      filterType: filterType,
      searchQuery: _currentSearchQuery,
      page: page,
      limit: limit,
      categoryId: effectiveCategoryId,
      isLoadMore: isLoadMore,
      isDiscover: effectiveIsDiscover,
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
        // Reset filters when closing search
        _filterModel = null;
        page = 1;
        getBooks(isLoadMore: false);
      }
    });
  }

  void _onRefresh() async {
    page = 1;
    try {
      final effectiveCategoryId =
          _isSearching && _filterModel?.categoryId != null
              ? _filterModel?.categoryId
              : categoryId;
      await context.read<LibraryCubit>().refreshBooks(
        filterType: filterType,
        searchQuery: _currentSearchQuery,
        page: page,
        limit: limit,
        categoryId: effectiveCategoryId,
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SearchFilterBottomSheet(
            filterModel: _filterModel,
            onApplyFilters: (filterModel) {
              setState(() {
                _filterModel = filterModel;
              });
              page = 1;
              getBooks(isLoadMore: false);
            },
          ),
    );
  }

  Widget _buildCategoryBar(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_16,
        vertical: AppDimens.SIZE_8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip(
              colorScheme: colorScheme,
              label: AppLocalizations.current.all,
              isSelected: categoryId.isEmpty,
              onTap: () {
                setState(() {
                  categoryId = '';
                });
                page = 1;
                getBooks(isLoadMore: false);
              },
            ),
            ...categories.map((category) {
              final id = category.id ?? '';
              final idStr = id.toString();
              final label = category.name ?? AppLocalizations.current.no_name;
              return _buildCategoryChip(
                colorScheme: colorScheme,
                label: label,
                isSelected: categoryId == idStr,
                onTap: () {
                  setState(() {
                    categoryId = idStr;
                  });
                  page = 1;
                  getBooks(isLoadMore: false);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required ColorScheme colorScheme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: AppDimens.SIZE_8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.SIZE_8,
            vertical: AppDimens.SIZE_4,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border:
                isSelected
                    ? null
                    : Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
          ),
          child: Row(
            children: [
              isSelected
                  ? Padding(
                    padding: EdgeInsets.only(right: AppDimens.SIZE_4),
                    child: Icon(
                      Icons.check,
                      color: colorScheme.onPrimary,
                      size: AppDimens.SIZE_12,
                    ),
                  )
                  : SizedBox.shrink(),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppDimens.SIZE_10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return ValueListenableBuilder<int>(
      valueListenable: context.read<NotificationCubit>().unreadCountNotifier,
      builder: (context, unreadCount, child) {
        return unreadCount > 0
            ? Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_active_sharp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.notificationScreen);
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.notificationScreen);
                    },
                    child: Badge(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      label: Text(
                        unreadCount.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )
            : IconButton(
              icon: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.pushNamed(context, Routes.notificationScreen);
              },
            );
      },
    );
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
                          getBooks(isLoadMore: false);
                        }
                      },
                    );
                  },
                )
                : Text(title, style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          if (_isSearching)
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.tune, color: colorScheme.onSurface),
                  if (_filterModel?.categoryId != null ||
                      (_filterModel?.isMyUpload ?? false) ||
                      _filterModel?.format != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _showFilterBottomSheet,
            ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: colorScheme.onSurface,
            ),
            onPressed: _toggleSearch,
          ),
          if (filterType == FilterType.uploaded)
            IconButton(
              icon: Icon(Icons.pie_chart_rounded, color: Colors.grey[600]),
              onPressed: () {
                Navigator.pushNamed(context, Routes.dataStorageScreen);
              },
            ),
          _buildNotificationButton(),
        ],
      ),
      drawer: AppDrawer(
        user: userInfo,
        onSelected: (filter, title) {
          setState(() {
            filterType = FilterType.values.firstWhere((e) => e.name == filter);
            this.title = title;
          });
          getBooks(isLoadMore: false);
        },
      ),
      body: BlocListener<BookRefreshCubit, int>(
        listener: (context, state) {
          // Lắng nghe sự thay đổi từ BookRefreshCubit
          // Khi có sự thay đổi (thêm/sửa/xóa sách), tự động refresh
          if (state > 0) {
            getBooks(isLoadMore: true);
          }
        },
        child: BlocBuilder<LibraryCubit, BaseState>(
          builder: (context, state) {
            // Lấy books và cubit từ state
            final books = context.read<LibraryCubit>().books;
            final cubit = context.read<LibraryCubit>();
            Widget widgetView = SizedBox.shrink();
            if (state is LoadingState) {
              widgetView = Center(child: CircularProgressIndicator());
            } else if (state is ErrorState) {
              widgetView = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    SizedBox(height: 16),
                    Text(
                      state.data?.toString() ??
                          AppLocalizations.current.error_loading_books,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => getBooks(isLoadMore: true),
                      child: Text(AppLocalizations.current.try_again),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị empty state
            if (state is LoadedState && books.isEmpty) {
              widgetView = EmptyData(
                emptyDataEnum: EmptyDataEnum.no_data,
                title: AppLocalizations.current.no_books,
                description: AppLocalizations.current.add_book_to_start_reading,
              );
            }

            // Apply format filter client-side if needed
            var filteredBooks = books;
            if (_isSearching && _filterModel?.format != null) {
              filteredBooks =
                  books.where((book) {
                    return book.fileType?.name == _filterModel?.format;
                  }).toList();
            }

            // Khi không ở chế độ tìm kiếm: hiển thị thanh chọn category phía trên danh sách
            final content = SmartRefresher(
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
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    );
                  } else if (mode == LoadStatus.idle) {
                    body = SizedBox(height: 0);
                  }
                  return body;
                },
              ),
              child:
                  filteredBooks.isEmpty &&
                          _isSearching &&
                          (_filterModel?.format != null)
                      ? EmptyData(
                        emptyDataEnum: EmptyDataEnum.no_filter,
                        title: AppLocalizations.current.no_book_found,
                      )
                      : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          return BookCard(
                            filterType: filterType,
                            book: filteredBooks[index],
                            onRead: (book) => _openBook(context, book),
                            ownerId: userInfo?.id,
                            userInteractionCubit:
                                context.read<UserInteractionCubit>(),
                            onDelete: (book) async {
                              final result = await context
                                  .read<LibraryCubit>()
                                  .deleteBook(book.id!);
                              if (result) {
                                getBooks(isLoadMore: true);
                                AppSnackBar.show(
                                  context,
                                  message:
                                      AppLocalizations
                                          .current
                                          .book_deleted_successfully,
                                  snackBarType: SnackBarType.success,
                                );
                              } else {
                                AppSnackBar.show(
                                  context,
                                  message:
                                      AppLocalizations
                                          .current
                                          .error_deleting_book,
                                  snackBarType: SnackBarType.error,
                                );
                              }
                            },
                          );
                        },
                      ),
            );
            widgetView = filteredBooks.isNotEmpty ? content : widgetView;
            // Luôn dùng cùng một cấu trúc Column + Expanded để SmartRefresher
            // luôn nằm cùng một vị trí, tránh lỗi một RefreshController gắn nhiều SmartRefresher.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (!_isSearching && categories.isNotEmpty)
                  _buildCategoryBar(colorScheme),
                Expanded(child: widgetView),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildContinueReadingFab(context),
    );
  }

  Widget _buildContinueReadingFab(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<UserInteractionCubit, BaseState>(
      buildWhen:
          (prev, curr) => curr is LoadedState<List<UserInteractionModel>>,
      builder: (context, state) {
        if (state is LoadedState<List<UserInteractionModel>>) {
          final readingBooks = state.data;
          return readingBooks.isNotEmpty
              ? FloatingActionButton.extended(
                heroTag: 'continue-reading-fab',
                onPressed: () => _showContinueReadingBottomSheet(context),
                icon: Icon(
                  Icons.menu_book_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text(
                  AppLocalizations.current.continue_reading,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: theme.primaryColor,
              )
              : SizedBox.shrink();
        }
        return SizedBox.shrink();
      },
    );
  }

  void _showContinueReadingBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final interactions = context.read<UserInteractionCubit>().readingBooks;

    // Lọc các ebook đang đọc (dựa vào lastRead khác null)
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      AppLocalizations.current.reading_books,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (interactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      AppLocalizations.current.you_have_no_book_reading,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 4),
                SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: 300.sh,
                    child: ListView.builder(
                      itemCount: interactions.length,
                      itemBuilder: (context, index) {
                        return _buildContinueReadingItem(
                          context,
                          interactions[index],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueReadingItem(
    BuildContext context,
    UserInteractionModel interaction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final book = interaction.book!;
    final readingProgress = interaction.readingProgress;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: InkWell(
        onTap: () => _openBook(context, interaction.book!),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseNetworkImage(
                borderRadius: 8,
                height: 160.sh,
                width: 120.sw,
                url: '${ApiConstant.apiHostStorage}${book.coverImageUrl}',
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      book.displayTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                book.fileType?.name.toUpperCase() ?? '',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              book.fileSizeFormatted,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Visibility(
                          visible: book.totalPages != null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.numbers_rounded,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${book.totalPages} ${AppLocalizations.current.pages}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 10,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (readingProgress != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppLocalizations.current.reading_time,
                                      style: TextStyle(
                                        fontSize: AppDimens.SIZE_12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.access_time_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      readingProgress.readingTimeFormatted,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                if (readingProgress.currentPage != null &&
                                    book.totalPages != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${readingProgress.currentPage} / ${book.totalPages} ${AppLocalizations.current.pages}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Circular progress chart
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: readingProgress.progress ?? 0.0,
                                  strokeWidth: 4,
                                  backgroundColor: theme.primaryColor
                                      .withValues(alpha: 0.5),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  readingProgress.progressFormatted,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBook(BuildContext context, BookModel book) async {
    if (book.fileUrl == null) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.file_ebook_not_found,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      Routes.pdfViewerScreen,
      arguments: book,
    );
    if (result == true) {
      loadUserInteractions();
    }
  }
}
