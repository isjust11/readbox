import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:readbox/constants.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/ui/widget/base_network_image.dart';
import 'package:readbox/ui/widget/safe_network_svg.dart';
import 'package:readbox/utils/icon_mapper.dart';

/// Opacity levels cho text/icon/background theo vai trò
class _OpacityLevel {
  static const double secondary = 0.6; // Text phụ, icon không chọn
  static const double muted = 0.4; // Text ít quan trọng
  static const double disabled = 0.3; // Empty state, icon placeholder
  static const double divider = 0.2; // Handle bar, viền nhạt
  static const double selectedBg = 0.1; // Nền item được chọn
  static const double searchBg = 0.5; // Nền ô search
}

/// Bottom sheet chọn category dạng cây.
///
/// - Nhận flat list [categories] (mỗi item có thể có `parentId`).
/// - Tự dựng tree theo `parentId` rồi cho phép drill-down từng cấp.
/// - Khi tap vào item có con => mở danh sách con.
/// - Khi tap vào item không có con => chọn luôn.
/// - Ở mỗi cấp con, hàng đầu cho phép chọn ngay danh mục cha hiện tại
///   (không cần đi tới lá).
class CategoryBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel) onSelected;
  final String? selectedCategoryId;

  const CategoryBottomSheet({
    super.key,
    required this.categories,
    required this.onSelected,
    this.selectedCategoryId,
  });

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedCategoryId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// Map parentId -> danh sách con (parentId == null nghĩa là root).
  late Map<String?, List<CategoryModel>> _childrenByParent;

  /// Stack các cha đã drill-in (rỗng = đang ở root).
  final List<CategoryModel> _navigationStack = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _buildIndex();
    _restoreNavigationStackForSelected();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _buildIndex();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _buildIndex() {
    _childrenByParent = <String?, List<CategoryModel>>{};
    for (final c in widget.categories) {
      final pId =
          (c.parentId == null || c.parentId!.isEmpty) ? null : c.parentId;
      _childrenByParent.putIfAbsent(pId, () => []).add(c);
    }
  }

  /// Khi mở lại bottom sheet, tự động navigate xuống đúng nhánh chứa
  /// `selectedCategoryId` để user thấy ngay item đang chọn.
  void _restoreNavigationStackForSelected() {
    final selectedId = _selectedCategoryId;
    if (selectedId == null || selectedId.isEmpty) return;

    final byId = <String, CategoryModel>{
      for (final c in widget.categories)
        if (c.id != null) c.id!: c,
    };
    final selected = byId[selectedId];
    if (selected == null) return;

    // Từ selected đi ngược lên cha. Nếu chính selected có con, dừng ở selected
    // (mở thẳng list con) — ngược lại drill tới cha gần nhất.
    final ancestors = <CategoryModel>[];
    final visited = <String>{};
    var cursor =
        _hasChildren(selected)
            ? selected
            : (selected.parentId != null ? byId[selected.parentId!] : null);
    while (cursor != null && cursor.id != null && visited.add(cursor.id!)) {
      ancestors.insert(0, cursor);
      final parentId = cursor.parentId;
      if (parentId == null || parentId.isEmpty) break;
      cursor = byId[parentId];
    }
    _navigationStack
      ..clear()
      ..addAll(ancestors);
  }

  CategoryModel? get _currentParent =>
      _navigationStack.isEmpty ? null : _navigationStack.last;

  bool get _isAtRoot => _navigationStack.isEmpty;

  /// Danh sách category cần render ở cấp hiện tại (đã filter theo search).
  List<CategoryModel> get _visibleCategories {
    final pId = _currentParent?.id;
    final list = _childrenByParent[pId] ?? const <CategoryModel>[];
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    final lang = Localizations.localeOf(context).languageCode;
    return list.where((c) {
      final name =
          (lang == LanguageCode.en ? c.nameEN : c.name)?.toLowerCase() ?? '';
      final desc =
          (lang == LanguageCode.en ? c.descriptionEN : c.description)
              ?.toLowerCase() ??
          '';
      return name.contains(q) || desc.contains(q);
    }).toList();
  }

  bool _hasChildren(CategoryModel c) {
    if (c.id == null) return false;
    final list = _childrenByParent[c.id];
    return list != null && list.isNotEmpty;
  }

  void _drillInto(CategoryModel parent) {
    setState(() {
      _navigationStack.add(parent);
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _drillBack() {
    if (_navigationStack.isEmpty) return;
    setState(() {
      _navigationStack.removeLast();
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _selectAndClose(CategoryModel category) {
    setState(() => _selectedCategoryId = category.id);
    widget.onSelected(category);
    Navigator.pop(context);
  }

  String _localizedName(CategoryModel c) {
    final lang = Localizations.localeOf(context).languageCode;
    return (lang == LanguageCode.en ? c.nameEN : c.name) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.SIZE_24),
            ),
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildHandleBar(colorScheme),
              _buildHeader(theme, colorScheme),
              _buildSearchBar(colorScheme),
              Divider(height: AppDimens.SIZE_1),
              if (_isAtRoot) ...[
                _buildAllCategoriesOption(theme, colorScheme),
                Divider(height: AppDimens.SIZE_1),
              ] else ...[
                _buildSelectCurrentParentOption(theme, colorScheme),
                Divider(height: AppDimens.SIZE_1),
              ],
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: _buildCategoriesList(theme, colorScheme),
                ),
              ),
              const SizedBox(height: AppDimens.SIZE_16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandleBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimens.SIZE_12),
      width: AppDimens.SIZE_40,
      height: AppDimens.SIZE_4,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: _OpacityLevel.divider),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    final parent = _currentParent;
    final title =
        parent != null
            ? _localizedName(parent)
            : AppLocalizations.current.select_category;
    final count = _visibleCategories.length;
    final subtitle =
        parent != null
            ? '$count ${AppLocalizations.current.subcategories}'
            : '${widget.categories.length} ${AppLocalizations.current.categories}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_12,
        vertical: AppDimens.SIZE_12,
      ),
      child: Row(
        children: [
          if (!_isAtRoot)
            IconButton(
              tooltip: AppLocalizations.current.back,
              onPressed: _drillBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: AppSize.iconSizeXLarge,
                color: colorScheme.onSurface,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize.fontSizeXLarge,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppSize.fontSizeMedium,
                    color: colorScheme.onSurface.withValues(
                      alpha: _OpacityLevel.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              size: AppSize.iconSizeXLarge,
              color: colorScheme.onSurface.withValues(
                alpha: _OpacityLevel.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_16,
        vertical: AppDimens.SIZE_8,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: AppLocalizations.current.search_categories,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: AppSize.iconSizeXLarge,
            color: colorScheme.primary,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: AppSize.iconSizeXLarge,
                      color: colorScheme.onSurface.withValues(
                        alpha: _OpacityLevel.secondary,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                  : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: _OpacityLevel.searchBg,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimens.SIZE_16,
            vertical: AppDimens.SIZE_12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme, ColorScheme colorScheme) {
    final categories = _visibleCategories;
    if (categories.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }
    return LayoutBuilder(
      key: ValueKey<String>('lvl_${_currentParent?.id ?? 'root'}'),
      builder: (context, constraints) {
        // 2 cột cho phone, 3 cột cho tablet
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 3;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.SIZE_16,
            AppDimens.SIZE_16,
            AppDimens.SIZE_16,
            AppDimens.SIZE_16,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimens.SIZE_16,
            mainAxisSpacing: AppDimens.SIZE_16,
            childAspectRatio: 1, // ô vuông
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryGridCard(category, theme, colorScheme);
          },
        );
      },
    );
  }

  /// Item "Tất cả danh mục" — chỉ hiển thị ở root.
  Widget _buildAllCategoriesOption(ThemeData theme, ColorScheme colorScheme) {
    final isSelected =
        _selectedCategoryId == null || _selectedCategoryId!.isEmpty;

    return InkWell(
      onTap: () {
        final allCategory = CategoryModel(
          id: '',
          name: AppLocalizations.current.all_categories,
        );
        _selectAndClose(allCategory);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_16,
          vertical: AppDimens.SIZE_16,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withValues(
                    alpha: _OpacityLevel.selectedBg,
                  )
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            _buildIconBox(
              icon: Icons.apps_rounded,
              isSelected: isSelected,
              colorScheme: colorScheme,
              radius: AppDimens.SIZE_12,
            ),
            const SizedBox(width: AppDimens.SIZE_16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.current.all_categories,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.fontSizeLarge,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppDimens.SIZE_2),
                  Text(
                    AppLocalizations.current.show_all_books,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.fontSizeMedium,
                      color: colorScheme.onSurface.withValues(
                        alpha: _OpacityLevel.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: AppSize.iconSizeXLarge,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// Item "Chọn danh mục này" — hiện ở mỗi cấp con, cho phép chọn cha hiện tại
  /// mà không cần đi tới lá.
  Widget _buildSelectCurrentParentOption(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final parent = _currentParent!;
    final isSelected = _selectedCategoryId == parent.id;
    final parentName = _localizedName(parent);

    return InkWell(
      onTap: () => _selectAndClose(parent),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_16,
          vertical: AppDimens.SIZE_14,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withValues(
                    alpha: _OpacityLevel.selectedBg,
                  )
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: AppDimens.SIZE_40,
              height: AppDimens.SIZE_40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: _OpacityLevel.selectedBg,
                ),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: AppSize.iconSizeLarge,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppDimens.SIZE_16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.current.select_this_category,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: AppSize.fontSizeLarge,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: AppDimens.SIZE_2),
                  Text(
                    parentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: AppSize.fontSizeMedium,
                      color: colorScheme.onSurface.withValues(
                        alpha: _OpacityLevel.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: AppSize.iconSizeXLarge,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  /// Card category dạng grid: nền theo `color` từ BE, ảnh `image` cover lên trên,
  /// fallback về icon nếu không có ảnh. Tên hiển thị ở dải gradient dưới đáy.
  Widget _buildCategoryGridCard(
    CategoryModel category,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedCategoryId == category.id;
    final hasChildren = _hasChildren(category);
    final childCount = _childrenByParent[category.id]?.length ?? 0;
    final categoryName = _localizedName(category);

    final baseColor = _resolveCategoryColor(category, colorScheme);
    final rawImageUrl = _resolveCategoryImageUrl(category);
    final imageUrl = rawImageUrl?.trim();
    final bool isSvg =
        imageUrl != null &&
        imageUrl.split('?').first.toLowerCase().endsWith('.svg');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        onTap: () {
          if (hasChildren) {
            _drillInto(category);
          } else {
            _selectAndClose(category);
          }
        },
        // Long-press = chọn cha trực tiếp khi item có con
        onLongPress: hasChildren ? () => _selectAndClose(category) : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: _OpacityLevel.selectedBg),
                baseColor.withValues(alpha: 0.25),
              ],
            ),
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary.withValues(alpha: 0.6)
                      : colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: baseColor.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  if (isSvg)
                    Container(
                      padding: const EdgeInsets.all(AppDimens.SIZE_12),
                      alignment: Alignment.center,
                      child: SafeNetworkSvg(url: imageUrl, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppDimens.SIZE_12),
                      alignment: Alignment.center,
                      child: BaseNetworkImage(
                        url: imageUrl,
                        fit: BoxFit.cover,
                        showShimmer: false,
                      ),
                    )
                else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.SIZE_24),
                      child: _buildCategoryIconLarge(category, baseColor),
                    ),
                  ),

                // Glassmorphism Label at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(AppDimens.SIZE_8),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.SIZE_12,
                          vertical: AppDimens.SIZE_8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                categoryName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: AppSize.fontSizeSmall,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Badge "n mục con" góc trên trái
                if (hasChildren)
                  Positioned(
                    top: AppDimens.SIZE_8,
                    left: AppDimens.SIZE_8,
                    child: _buildChildrenBadge(childCount),
                  ),

                // Tick chọn góc trên phải
                if (isSelected)
                  Positioned(
                    top: AppDimens.SIZE_8,
                    right: AppDimens.SIZE_8,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.SIZE_2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: colorScheme.primary,
                        size: AppSize.iconSizeXLarge,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenBadge(int count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.SIZE_8,
            vertical: AppDimens.SIZE_4,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Assets.icons.icCategory,
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  Colors.orange.shade400,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_4),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppSize.fontSizeSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBox({
    required IconData icon,
    required bool isSelected,
    required ColorScheme colorScheme,
    double radius = AppDimens.SIZE_8,
  }) {
    return Container(
      width: AppDimens.SIZE_48,
      height: AppDimens.SIZE_48,
      decoration: BoxDecoration(
        color:
            isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        icon,
        size: AppSize.iconSizeXLarge,
        color:
            isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withValues(
                  alpha: _OpacityLevel.secondary,
                ),
      ),
    );
  }

  /// Icon to dùng làm placeholder khi không có image — vẽ giữa card.
  Widget _buildCategoryIconLarge(CategoryModel category, Color baseColor) {
    final iconData =
        (category.icon != null && category.icon!.isNotEmpty)
            ? IconMapper.getIcon(category.icon, category.iconType)
            : null;
    return iconData != null
        ? Icon(
          iconData,
          size: AppSize.iconSizeXXLarge,
          color: Colors.white.withValues(alpha: 0.85),
        )
        : SvgPicture.asset(
          Assets.icons.icCategory,
          width: AppSize.iconSizeXXLarge,
          height: AppSize.iconSizeXXLarge,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
  }

  /// Lấy URL ảnh đầy đủ. Hỗ trợ cả relative path (BE lưu) lẫn URL tuyệt đối.
  String? _resolveCategoryImageUrl(CategoryModel category) {
    final raw = category.image;
    if (raw == null || raw.trim().isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return '${ApiConstant.storageHost}$raw';
  }

  /// Parse `color` HEX từ BE (`#RRGGBB` hoặc `#RRGGBBAA`).
  /// Nếu không có/sai format, tạo màu deterministic từ id/name để mỗi card vẫn
  /// có tone riêng thay vì xám đồng loạt.
  Color _resolveCategoryColor(CategoryModel category, ColorScheme colorScheme) {
    final hex = category.color?.trim();
    if (hex != null && hex.isNotEmpty) {
      final parsed = _parseHexColor(hex);
      if (parsed != null) return parsed;
    }
    return _fallbackColor(category, colorScheme);
  }

  Color? _parseHexColor(String hex) {
    var value = hex.startsWith('#') ? hex.substring(1) : hex;
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final intVal = int.tryParse(value, radix: 16);
    if (intVal == null) return null;
    return Color(intVal);
  }

  Color _fallbackColor(CategoryModel category, ColorScheme colorScheme) {
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

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.SIZE_32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: AppDimens.SIZE_60,
              color: colorScheme.onSurface.withValues(
                alpha: _OpacityLevel.disabled,
              ),
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            Text(
              AppLocalizations.current.no_categories_found,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: AppSize.fontSizeLarge,
                color: colorScheme.onSurface.withValues(
                  alpha: _OpacityLevel.secondary,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.SIZE_8),
            Text(
              AppLocalizations.current.try_different_search,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppSize.fontSizeMedium,
                color: colorScheme.onSurface.withValues(
                  alpha: _OpacityLevel.muted,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
