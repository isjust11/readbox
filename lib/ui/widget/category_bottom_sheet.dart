import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';

/// Opacity levels cho text/icon/background theo vai trò
class _OpacityLevel {
  static const double secondary = 0.6; // Text phụ, icon không chọn
  static const double muted = 0.4; // Text ít quan trọng
  static const double disabled = 0.3; // Empty state, icon placeholder
  static const double divider = 0.2; // Handle bar, viền nhạt
  static const double selectedBg = 0.1; // Nền item được chọn
  static const double searchBg = 0.5; // Nền ô search
}

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

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;

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
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return widget.categories;
    }
    return widget.categories.where((category) {
      final name = category.name?.toLowerCase() ?? '';
      final description = category.description?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: AppDimens.SIZE_12),
                width: AppDimens.SIZE_40,
                height: AppDimens.SIZE_4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(
                    alpha: _OpacityLevel.divider,
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.SIZE_12,
                  vertical: AppDimens.SIZE_12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.current.select_category,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: AppSize.fontSizeXLarge,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${widget.categories.length} ${AppLocalizations.current.categories}',
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
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.SIZE_16,
                  vertical: AppDimens.SIZE_8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
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
                                setState(() {
                                  _searchQuery = '';
                                });
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
              ),

              Divider(height: AppDimens.SIZE_1),

              // "All Categories" option
              _buildAllCategoriesOption(theme, colorScheme),

              Divider(height: AppDimens.SIZE_1),

              // Categories list
              Flexible(
                child:
                    _filteredCategories.isEmpty
                        ? _buildEmptyState(theme, colorScheme)
                        : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimens.SIZE_8,
                          ),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return _buildCategoryItem(
                              category,
                              theme,
                              colorScheme,
                            );
                          },
                        ),
              ),

              // Bottom padding
              const SizedBox(height: AppDimens.SIZE_16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllCategoriesOption(ThemeData theme, ColorScheme colorScheme) {
    final isSelected =
        _selectedCategoryId == null || _selectedCategoryId!.isEmpty;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategoryId = '';
        });
        // Create a dummy "All" category
        final allCategory = CategoryModel(
          id: '',
          name: AppLocalizations.current.all_categories,
        );
        widget.onSelected(allCategory);
        Navigator.pop(context);
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
            Container(
              width: AppDimens.SIZE_48,
              height: AppDimens.SIZE_48,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
              ),
              child: Icon(
                Icons.apps_rounded,
                size: AppSize.iconSizeXLarge,
                color:
                    isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(
                          alpha: _OpacityLevel.secondary,
                        ),
              ),
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

  Widget _buildCategoryItem(
    CategoryModel category,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedCategoryId == category.id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategoryId = category.id;
        });
        widget.onSelected(category);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.SIZE_16,
          vertical: AppDimens.SIZE_12,
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
            // Category icon
            Container(
              width: AppDimens.SIZE_48,
              height: AppDimens.SIZE_48,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Center(
                child: _buildCategoryIcon(category, isSelected, colorScheme),
              ),
            ),
            const SizedBox(width: AppDimens.SIZE_16),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? '',
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
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    SizedBox(height: AppDimens.SIZE_2),
                    Text(
                      category.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: AppSize.fontSizeMedium,
                        color: colorScheme.onSurface.withValues(
                          alpha: _OpacityLevel.secondary,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: AppSize.iconSizeXLarge,
                color: colorScheme.primary,
              )
            else
              Icon(
                Icons.circle_outlined,
                size: AppSize.iconSizeXLarge,
                color: colorScheme.onSurface.withValues(
                  alpha: _OpacityLevel.divider,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    CategoryModel category,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    // Try to parse icon from category
    if (category.icon != null && category.icon!.isNotEmpty) {
      final iconCode = int.tryParse(category.icon!);
      if (iconCode != null) {
        return Icon(
          IconData(iconCode, fontFamily: 'MaterialIcons'),
          size: AppSize.iconSizeLarge,
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodySmall?.color?.withValues(
                    alpha: _OpacityLevel.secondary,
                  ),
        );
      }
    }

    // Default icon based on category name
    IconData defaultIcon = Icons.book_rounded;
    final name = category.name?.toLowerCase() ?? '';

    if (name.contains('fiction') || name.contains('tiểu thuyết')) {
      defaultIcon = Icons.auto_stories_rounded;
    } else if (name.contains('science') || name.contains('khoa học')) {
      defaultIcon = Icons.science_rounded;
    } else if (name.contains('history') || name.contains('lịch sử')) {
      defaultIcon = Icons.history_edu_rounded;
    } else if (name.contains('art') || name.contains('nghệ thuật')) {
      defaultIcon = Icons.palette_rounded;
    } else if (name.contains('business') || name.contains('kinh doanh')) {
      defaultIcon = Icons.business_center_rounded;
    } else if (name.contains('technology') || name.contains('công nghệ')) {
      defaultIcon = Icons.computer_rounded;
    } else if (name.contains('health') || name.contains('sức khỏe')) {
      defaultIcon = Icons.health_and_safety_rounded;
    } else if (name.contains('cooking') || name.contains('nấu ăn')) {
      defaultIcon = Icons.restaurant_rounded;
    } else if (name.contains('travel') || name.contains('du lịch')) {
      defaultIcon = Icons.flight_rounded;
    } else if (name.contains('children') || name.contains('thiếu nhi')) {
      defaultIcon = Icons.child_care_rounded;
    }

    return Icon(
      defaultIcon,
      size: AppSize.iconSizeXLarge,
      color:
          isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withValues(
                alpha: _OpacityLevel.secondary,
              ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
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
