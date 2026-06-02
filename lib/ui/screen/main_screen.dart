import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/config/theme_data.dart';
import 'package:readbox/constants.dart';
import 'package:readbox/domain/data/entities/entities.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/utils.dart';
import 'package:scale_size/scale_size.dart';
import 'package:readbox/ui/widget/app_widgets/ad_book_card.dart';
import 'package:readbox/blocs/user_subscription_cubit.dart';

import '../../domain/data/models/models.dart';

/// Màn "Tất cả ebook" - chứa toàn bộ logic search/filter/category cũ.
/// Trước đây là `MainScreen` và đang được điều hướng tới qua `Routes.mainScreen`.
/// Sau khi tách Discover, route `mainScreen` chuyển sang `DiscoverScreen` và
/// màn này được expose qua `Routes.allEbooksScreen`.
class AllEbooksScreen extends StatelessWidget {
  /// Filter mặc định khi mở (cho phép Discover điều hướng tới với filter tương ứng,
  /// vd: FilterType.favorite cho "Xem tất cả" của section favorite).
  final FilterType? initialFilter;
  const AllEbooksScreen({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    return AllEbooksBody(initialFilter: initialFilter);
  }
}

class AllEbooksBody extends StatefulWidget {
  final FilterType? initialFilter;
  const AllEbooksBody({super.key, this.initialFilter});
  @override
  AllEbooksBodyState createState() => AllEbooksBodyState();
}

class AllEbooksBodyState extends State<AllEbooksBody> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  // Thêm dòng này
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _showSearchRecent = false;
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
  // Stack các category cha mà user đã drill-in trên thanh chip.
  // Rỗng = đang ở root (hiển thị các root category).
  final List<CategoryModel> _chipNavStack = [];
  @override
  void initState() {
    super.initState();
    // Áp dụng filter khởi tạo nếu được truyền từ Discover ("Xem tất cả" của 1 section).
    if (widget.initialFilter != null) {
      filterType = widget.initialFilter!;
    }
    title = _resolveTitleForFilter(filterType);
    // context.read<UserSubscriptionCubit>().loadMe();

    // Thêm listener cho search focus để show/hide recent panel
    _searchFocusNode.addListener(_onSearchFocusChanged);

    // Load initial data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getUnreadCount();
      getBooks();
      //my interactions
      loadUserReadingBooks();
    });
    loadUserInfo();
    loadCategories();
    _wireFloatingActionCallbacks();
  }

  /// Map FilterType → tiêu đề AppBar mặc định (khi mở qua Discover/See-all).
  String _resolveTitleForFilter(FilterType filter) {
    switch (filter) {
      case FilterType.favorite:
        return AppLocalizations.current.favorite_books;
      case FilterType.archived:
        return AppLocalizations.current.archived_books;
      case FilterType.uploaded:
        return AppLocalizations.current.my_uploaded_books;
      case FilterType.discover:
      case FilterType.all:
        return AppLocalizations.current.book_discover;
    }
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showSearchRecent = true;
      });
    } else {
      setState(() {
        _showSearchRecent = false;
      });
    }
  }

  void _onSearchSelected(String searchTerm) {
    _searchController.text = searchTerm;
    _currentSearchQuery = searchTerm;
    setState(() {
      _showSearchRecent = false;
    });
    _searchFocusNode.unfocus();
    getBooks(isLoadMore: false);

    // Lưu vào history (sẽ đưa lên đầu danh sách)
    SearchHistoryService().addSearchTerm(searchTerm);
  }

  /// Đăng ký action cho cụm floating button toàn app:
  /// - Continue Reading → mở bottom sheet danh sách ebook đang đọc.
  /// - TTS background → mở lại book đang đọc nền (nếu match được).
  void _wireFloatingActionCallbacks() {
    FloatingActionsController.instance.onContinueReadingPressed = (
      ctx,
      interaction,
    ) {
      _showContinueReadingBottomSheet(ctx);
    };

    FloatingActionsController.instance.onTtsPressed = (ctx, info) {
      final readingBooks = ctx.read<UserInteractionCubit>().readingBooks;
      UserInteractionModel? matched;
      for (final r in readingBooks) {
        if (r.book?.id != null && r.book!.id == info.bookId) {
          matched = r;
          break;
        }
      }
      if (matched?.book != null) {
        _openBook(ctx, matched!.book!);
      } else {
        _showContinueReadingBottomSheet(ctx);
      }
    };
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
  Future<void> loadUserReadingBooks() async {
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
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _refreshController.dispose();
    // Tránh giữ closure trỏ vào State đã dispose (logout / tab switch).
    FloatingActionsController.instance.onContinueReadingPressed = null;
    FloatingActionsController.instance.onTtsPressed = null;
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      _showSearchRecent = false;
      if (_isSearching) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
        });
      } else {
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

  Widget _buildCategoryBar(ColorScheme colorScheme) {
    // Dựng map parentId -> children để render nhanh theo cấp đang đứng
    final childrenByParent = <String?, List<CategoryModel>>{};
    for (final c in categories) {
      final pId =
          (c.parentId == null || c.parentId!.isEmpty) ? null : c.parentId;
      childrenByParent.putIfAbsent(pId, () => []).add(c);
    }

    final isAtRoot = _chipNavStack.isEmpty;
    final currentParent = isAtRoot ? null : _chipNavStack.last;
    final visible = childrenByParent[currentParent?.id] ?? const [];
    final showSeeAllButton =
        categories.length > 3 ||
        categories.any((c) => (c.parentId ?? '').isNotEmpty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // AnimatedSwitcher để có cảm giác "refill" mượt khi drill in/out
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Row(
                  key: ValueKey<String>(
                    'chips_lvl_${currentParent?.id ?? 'root'}',
                  ),
                  children: [
                    if (isAtRoot)
                      _buildCategoryChip(
                        colorScheme: colorScheme,
                        label: AppLocalizations.current.all,
                        isSelected: categoryId.isEmpty,
                        onTap: () {
                          _chipNavStack.clear();
                          _onSelectCategoryById('');
                        },
                      )
                    else ...[
                      _buildBackChip(colorScheme),
                      _buildParentSelfChip(colorScheme, currentParent!),
                    ],
                    ...visible.map((c) {
                      final hasChildren =
                          (childrenByParent[c.id] ?? const []).isNotEmpty;
                      final isSelected = categoryId == c.id;
                      return _buildCategoryChip(
                        colorScheme: colorScheme,
                        label: _localizedName(c),
                        isSelected: isSelected,
                        color: _resolveCategoryColor(c),
                        imageUrl: _resolveCategoryImageUrl(c),
                        hasChildren: hasChildren,
                        onTap: () {
                          if (hasChildren) {
                            // Drill in: refill thành children của c
                            setState(() {
                              _chipNavStack.add(c);
                            });
                          } else {
                            _onSelectCategoryById(c.id ?? '');
                          }
                        },
                        onLongPress:
                            hasChildren
                                ? () => _onSelectCategoryById(c.id ?? '')
                                : null,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          if (showSeeAllButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: _openCategoryBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.indigoCyanGradient(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grid_view_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Chip "←" để pop chip nav stack (quay lại level cha).
  Widget _buildBackChip(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_chipNavStack.isNotEmpty) {
              _chipNavStack.removeLast();
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Chip "✓ <tên cha>" tương đương item "Chọn danh mục này" trong bottom sheet.
  /// Cho phép filter ngay theo cha hiện tại mà không cần đi tới lá.
  Widget _buildParentSelfChip(ColorScheme colorScheme, CategoryModel parent) {
    final isSelected = categoryId == parent.id;
    final color = _resolveCategoryColor(parent);
    return _buildCategoryChip(
      colorScheme: colorScheme,
      label: _localizedName(parent),
      isSelected: isSelected,
      color: color,
      imageUrl: _resolveCategoryImageUrl(parent),
      isParentSelfChip: true,
      onTap: () => _onSelectCategoryById(parent.id ?? ''),
    );
  }

  String _localizedName(CategoryModel c) {
    final lang = Localizations.localeOf(context).languageCode;
    final name = lang == LanguageCode.vi ? c.name : c.nameEN;
    return name ?? c.name ?? AppLocalizations.current.no_name;
  }

  void _onSelectCategoryById(String id) {
    setState(() {
      categoryId = id;
      // Khi clear filter, đưa chips về root
      if (id.isEmpty) {
        _chipNavStack.clear();
      }
    });
    page = 1;
    getBooks(isLoadMore: false);
  }

  void _openCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CategoryBottomSheet(
            categories: categories,
            selectedCategoryId: categoryId.isEmpty ? null : categoryId,
            onSelected: (category) {
              final id = category.id ?? '';
              _restoreChipNavStackForSelected(id);
              _onSelectCategoryById(id);
            },
          ),
    );
  }

  /// Đồng bộ stack chips với category vừa chọn từ bottom sheet.
  /// Stack chứa các tổ tiên (KHÔNG bao gồm chính selected) → các chips hiển thị
  /// = anh em + parent-self chip cho user thấy ngay context.
  void _restoreChipNavStackForSelected(String selectedId) {
    if (selectedId.isEmpty) {
      _chipNavStack.clear();
      return;
    }
    final byId = <String, CategoryModel>{
      for (final c in categories)
        if (c.id != null) c.id!: c,
    };
    final selected = byId[selectedId];
    if (selected == null) {
      _chipNavStack.clear();
      return;
    }
    final ancestors = <CategoryModel>[];
    final visited = <String>{};
    String? cursorId = selected.parentId;
    while (cursorId != null && cursorId.isNotEmpty && visited.add(cursorId)) {
      final cursor = byId[cursorId];
      if (cursor == null) break;
      ancestors.insert(0, cursor);
      cursorId = cursor.parentId;
    }
    _chipNavStack
      ..clear()
      ..addAll(ancestors);
  }

  Widget _buildCategoryChip({
    required ColorScheme colorScheme,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    Color? color,
    String? imageUrl,
    bool hasChildren = false,
    bool isParentSelfChip = false,
  }) {
    imageUrl = imageUrl?.trim();
    final bool isSvg =
        imageUrl != null &&
        imageUrl.split('?').first.toLowerCase().endsWith('.svg');
    final activeColor = color ?? colorScheme.primary;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    // Khi là chip "chọn cha hiện tại" → vẽ tone nhẹ với màu của cha kèm dấu ✓
    // để user phân biệt với chip con bình thường, kể cả khi chưa được tap.
    final isParentTone = isParentSelfChip && !isSelected;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: hasImage ? 8 : 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? null
                        : (isParentTone
                            ? activeColor.withValues(alpha: 0.12)
                            : colorScheme.surface.withValues(alpha: 0.6)),
                gradient:
                    isSelected
                        ? (color != null
                            ? LinearGradient(
                              colors: [
                                activeColor.withValues(alpha: 0.6),
                                activeColor.withValues(alpha: 0.2),
                              ],
                            )
                            : AppTheme.indigoCyanGradient())
                        : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
                border: Border.all(
                  color:
                      isSelected
                          ? activeColor.withValues(alpha: 0.6)
                          : (isParentTone
                              ? activeColor.withValues(alpha: 0.4)
                              : colorScheme.outline.withValues(alpha: 0.2)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isParentSelfChip) ...[
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : activeColor,
                    ),
                    const SizedBox(width: 4),
                  ] else if (hasImage) ...[
                    ClipOval(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            isSvg
                                ? SafeNetworkSvg(
                                  url: imageUrl,
                                  width: 20,
                                  height: 20,
                                )
                                : BaseNetworkImage(
                                  url: imageUrl,
                                  fit: BoxFit.cover,
                                  showShimmer: false,
                                ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected
                              ? Colors.white
                              : (isParentTone
                                  ? activeColor
                                  : colorScheme.onSurfaceVariant),
                    ),
                  ),
                  if (hasChildren && !isSelected) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Resolve URL ảnh đại diện. Hỗ trợ relative path (BE) lẫn URL tuyệt đối.
  String? _resolveCategoryImageUrl(CategoryModel category) {
    final raw = category.image;
    if (raw == null || raw.trim().isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${ApiConstant.storageHost}$raw';
  }

  /// Parse màu HEX từ BE; fallback theo hash để mỗi danh mục có tone riêng.
  Color _resolveCategoryColor(CategoryModel category) {
    final hex = category.color?.trim();
    if (hex != null && hex.isNotEmpty) {
      final parsed = _parseHexColor(hex);
      if (parsed != null) return parsed;
    }
    const palette = <Color>[
      Color(0xFF6366F1), // indigo
      Color(0xFF22C55E), // green
      Color(0xFFF97316), // orange
      Color(0xFFEF4444), // red
      Color(0xFF06B6D4), // cyan
      Color(0xFFA855F7), // purple
      Color(0xFFF59E0B), // amber
      Color(0xFF10B981), // emerald
    ];
    final seed = (category.id ?? category.name ?? 'x').hashCode.abs();
    return palette[seed % palette.length];
  }

  Color? _parseHexColor(String hex) {
    var value = hex.startsWith('#') ? hex.substring(1) : hex;
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final intVal = int.tryParse(value, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  Widget _buildNotificationButton() {
    return ValueListenableBuilder<int>(
      valueListenable: context.read<NotificationCubit>().unreadCountNotifier,
      builder: (context, unreadCount, child) {
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_12,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
                onTap: () {
                  Navigator.pushNamed(context, Routes.notificationScreen);
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SizedBox(
                    width: AppSize.iconSizeXXLarge,
                    height: AppSize.iconSizeXXLarge,
                    child: SvgPicture.asset(
                      Assets.icons.icRing,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            unreadCount > 0
                ? Positioned(
                  top: 0,
                  right: 12,
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
                )
                : SizedBox(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BaseScreen<LibraryCubit>(
      colorBg: colorScheme.surface,
      autoHandleState: true,
      showContinueReadingFab: true,
      customAppBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 22),
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  focusNode: _searchFocusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.current.search_books,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                  onChanged: (value) {
                    // Ẩn search recent panel khi user bắt đầu gõ
                    if (_showSearchRecent && value.isNotEmpty) {
                      setState(() {
                        _showSearchRecent = false;
                      });
                    } else if (!_showSearchRecent &&
                        value.isEmpty &&
                        _searchFocusNode.hasFocus) {
                      setState(() {
                        _showSearchRecent = true;
                      });
                    }

                    // Hủy timer trước đó nếu có
                    _debounceTimer?.cancel();
                    // Tạo timer mới, sau 700ms mới thực hiện search
                    _debounceTimer = Timer(
                      const Duration(milliseconds: 2000),
                      () {
                        if (mounted) {
                          _currentSearchQuery = value;
                          // Lưu vào history nếu có text và thực sự search
                          if (value.trim().isNotEmpty) {
                            SearchHistoryService().addSearchTerm(value.trim());
                          }
                          getBooks(isLoadMore: false);
                        }
                      },
                    );
                  },
                )
                : Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
        actions: [
          GestureDetector(
            onTap: _toggleSearch,
            child: SvgPicture.asset(
              _isSearching
                  ? Assets.icons.icCloseCircle
                  : Assets.images.icSearch,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
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
        currentFilter: filterType.name,
        onSelected: (filter, title) {
          // "Home" là mục riêng → trỏ về DiscoverScreen, không thuộc FilterType.
          if (filter == 'home') {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, Routes.mainScreen);
            }
            return;
          }
          // Các filter còn lại (all/favorite/archived/uploaded) giữ nguyên
          // hành vi cũ: đổi filter tại chỗ + reload list.
          setState(() {
            filterType = FilterType.values.firstWhere(
              (e) => e.name == filter,
              orElse: () => FilterType.all,
            );
            this.title = title;
          });
          getBooks(isLoadMore: false);
        },
      ),
      body: Stack(
        children: [
          BlocListener<BookRefreshCubit, int>(
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
                // Hiển thị empty state
                if (state is LoadedState && books.isEmpty) {
                  widgetView = EmptyData(
                    emptyDataEnum: EmptyDataEnum.no_data,
                    title: AppLocalizations.current.no_books,
                    description:
                        AppLocalizations.current.add_book_to_start_reading,
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

                // Responsive grid cho màn hình lớn/nhỏ
                final screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount;
                double childAspectRatio;
                if (screenWidth >= 1200) {
                  crossAxisCount = 5;
                  childAspectRatio = 0.7;
                } else if (screenWidth >= 992) {
                  crossAxisCount = 4;
                  childAspectRatio = 0.7;
                } else if (screenWidth >= 600) {
                  crossAxisCount = 3;
                  childAspectRatio = 0.7;
                } else {
                  crossAxisCount = 2;
                  childAspectRatio = 0.6;
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
                          height: AppDimens.SIZE_48,
                          child: Center(
                            child:
                                Platform.isIOS
                                    ? const CupertinoActivityIndicator()
                                    : const CircularProgressIndicator(),
                          ),
                        );
                      } else if (!cubit.hasMore) {
                        body = SizedBox(
                          height: AppDimens.SIZE_48,
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
                          : (() {
                            final isFreeUser =
                                context
                                    .watch<UserSubscriptionCubit>()
                                    .isFreeUser();
                            final int adInterval = 6;

                            int totalCount = filteredBooks.length;
                            if (isFreeUser && filteredBooks.isNotEmpty) {
                              totalCount += filteredBooks.length ~/ adInterval;
                            }

                            return GridView.builder(
                              padding: EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: childAspectRatio,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: totalCount,
                              itemBuilder: (context, index) {
                                if (isFreeUser &&
                                    index > 0 &&
                                    (index + 1) % (adInterval + 1) == 0) {
                                  return const AdBookCard();
                                }

                                int bookIndex = index;
                                if (isFreeUser) {
                                  bookIndex =
                                      index - (index ~/ (adInterval + 1));
                                }

                                if (bookIndex >= filteredBooks.length)
                                  return const SizedBox.shrink();
                                final book = filteredBooks[bookIndex];

                                return BookCard(
                                  filterType: filterType,
                                  book: book,
                                  onRead:
                                      (BookModel book, BookFileEntity? file) =>
                                          _openBook(
                                            context,
                                            book,
                                            selectedFile: file,
                                          ),
                                  ownerId: userInfo?.id,
                                  userInteractionCubit:
                                      context.read<UserInteractionCubit>(),
                                  onDelete: (BookModel book) async {
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
                            );
                          })(),
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
          // Search Recent Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SearchRecentPanel(
              isVisible: _showSearchRecent,
              onSearchSelected: _onSearchSelected,
            ),
          ),
        ],
      ),
      // Continue Reading FAB đã chuyển sang GlobalFloatingActions ở BaseScreen
      // (icon-only, có thể kéo thả + kéo để ẩn). Không cần khai báo ở đây nữa.
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
                url: UrlBuilder.buildUrl(book.coverImageUrl),
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

  Future<void> _openBook(
    BuildContext context,
    BookModel book, {
    BookFileEntity? selectedFile,
  }) async {
    final String targetUrl = selectedFile?.fileUrl ?? book.fileUrl ?? '';
    final targetType =
        selectedFile != null
            ? (selectedFile.format?.toLowerCase() == 'pdf'
                ? BookType.pdf
                : BookType.epub)
            : book.fileType;

    if (targetUrl.isEmpty) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.file_ebook_not_found,
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    final String route;
    if (targetType == BookType.epub) {
      route = Routes.epubViewerScreen;
    } else {
      route = Routes.pdfViewerScreen;
    }

    // Clone book with the specific selected file details to pass to viewer
    final bookToOpen = BookModel.fromJson(book.toJson());
    bookToOpen.fileUrl = targetUrl;
    bookToOpen.fileType = targetType;

    final result = await Navigator.pushNamed(
      context,
      route,
      arguments: bookToOpen,
    );
    if (result == true) {
      loadUserReadingBooks();
    }
  }
}
