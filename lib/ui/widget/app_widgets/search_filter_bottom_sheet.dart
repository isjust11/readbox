import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/enum.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final FilterModel? filterModel;
  final Function(FilterModel) onApplyFilters;

  const SearchFilterBottomSheet({
    super.key,
    this.filterModel,
    required this.onApplyFilters,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late String? _selectedCategoryId;
  late bool _isMyUpload;
  late String? _selectedFormat;
  late CategoryCubit _categoryCubit;
  List<CategoryModel> bookTypeCategories = [];
  List<CategoryModel> bookCategories = [];
  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.filterModel?.categoryId;
    _isMyUpload = widget.filterModel?.isMyUpload ?? false;
    _selectedFormat = widget.filterModel?.format;
    _categoryCubit = context.read<CategoryCubit>();
    loadCategories();
  }

  void loadCategories() async {
    bookTypeCategories = await _categoryCubit.getCategoriesByCode(
      categoryTypeCode: CategoryTypeEnum.BOOK_TYPE.name,
    );
    print(bookTypeCategories);
    bookCategories = await _categoryCubit.getCategoriesByCode(
      categoryTypeCode: CategoryTypeEnum.BOOK_CATEGORY.name,
    );
    print(bookCategories);
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.current.search_filter,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryId = null;
                          _isMyUpload = false;
                          _selectedFormat = null;
                        });
                      },
                      child: Text(
                        AppLocalizations.current.reset,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Loại ebook (Category)
                Text(
                  'Loại ebook',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Option "Tất cả"
                    _buildCategoryChip(
                      context,
                      label: AppLocalizations.current.all,
                      isSelected: _selectedCategoryId == null,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    // Category options
                    ...bookCategories.map((category) {
                      final categoryId = category.id.toString();
                      final categoryName =
                          category.name ?? AppLocalizations.current.no_name;
                      return _buildCategoryChip(
                        context,
                        label: categoryName,
                        isSelected: _selectedCategoryId == categoryId,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = categoryId;
                          });
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Checkbox "Tôi đăng tải"
                Row(
                  children: [
                    Checkbox(
                      value: _isMyUpload,
                      onChanged: (value) {
                        setState(() {
                          _isMyUpload = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.current.i_uploaded,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Định dạng (Format)
                Text(
                  AppLocalizations.current.format,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Option "Tất cả"
                    _buildFormatChip(
                      context,
                      label: AppLocalizations.current.all,
                      isSelected: _selectedFormat == null,
                      onTap: () {
                        setState(() {
                          _selectedFormat = null;
                        });
                      },
                    ),
                    // Format options
                    ...bookTypeCategories.map((bookType) {
                      return _buildFormatChip(
                        context,
                        label: bookType.name ?? AppLocalizations.current.no_name,
                        isSelected: _selectedFormat == bookType.code,
                        onTap: () {
                          setState(() {
                            _selectedFormat = bookType.code;
                          });
                        },
                      );
                    })
                  ],
                ),
                const SizedBox(height: 24),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(
                        FilterModel(
                          categoryId: _selectedCategoryId,
                          isMyUpload: _isMyUpload,
                          format: _selectedFormat,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: colorScheme.primary,
                    ),
                    child: Text(
                      AppLocalizations.current.apply_filters,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
