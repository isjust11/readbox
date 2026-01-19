import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/admin/admin_cubit.dart';
import 'package:readbox/blocs/base_bloc/base_state.dart';
import 'package:readbox/domain/data/entities/book_entity.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final String? selectedCategoryId;
  final bool isMyUpload;
  final BookType? selectedFormat;
  final Function(String?, bool, BookType?) onApplyFilters;

  const SearchFilterBottomSheet({
    super.key,
    this.selectedCategoryId,
    this.isMyUpload = false,
    this.selectedFormat,
    required this.onApplyFilters,
  });

  @override
  State<SearchFilterBottomSheet> createState() => _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late String? _selectedCategoryId;
  late bool _isMyUpload;
  late BookType? _selectedFormat;
  late AdminCubit _adminCubit;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _isMyUpload = widget.isMyUpload;
    _selectedFormat = widget.selectedFormat;
    _adminCubit = getIt.get<AdminCubit>();
    // Load categories if not already loaded
    if (_adminCubit.categories.isEmpty) {
      _adminCubit.loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _adminCubit,
      child: Container(
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
                  BlocBuilder<AdminCubit, BaseState>(
                    builder: (context, state) {
                      final categories = _adminCubit.categories;
                      if (categories.isEmpty && state is LoadingState) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      
                      if (categories.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Không có danh mục',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      }

                      return Wrap(
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
                          ...categories.map((category) {
                            final categoryId = category['id']?.toString();
                            final categoryName = category['name']?.toString() ?? AppLocalizations.current.no_name;
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
                      );
                    },
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
                      _buildFormatChip(
                        context,
                        label: AppLocalizations.current.epub,
                        isSelected: _selectedFormat == BookType.epub,
                        onTap: () {
                          setState(() {
                            _selectedFormat = BookType.epub;
                          });
                        },
                      ),
                      _buildFormatChip(
                        context,
                        label: AppLocalizations.current.pdf,
                        isSelected: _selectedFormat == BookType.pdf,
                        onTap: () {
                          setState(() {
                            _selectedFormat = BookType.pdf;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(
                          _selectedCategoryId,
                          _isMyUpload,
                          _selectedFormat,
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
                        style: TextStyle(fontSize: 14, color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ],
        ),
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
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
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
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
