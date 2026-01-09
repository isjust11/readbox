import 'dart:async';

import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:scale_size/scale_size.dart';

import '../../res/resources.dart';
import 'custom_text_label.dart';

class BaseAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final Widget? customLeading;
  final List<Widget>? actions;
  final Widget? customTitle;
  final Color? backgroundColor;
  final VoidCallback? onBackTap;
  final bool? centerTitle;
  final bool? showSearch;
  final Function(String)? onSearchChanged;
  final String? searchHint;
  const BaseAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.customLeading,
    this.actions,
    this.backgroundColor,
    this.customTitle,
    this.onBackTap,
    this.centerTitle = true,
    this.showSearch = false,
    this.onSearchChanged,
    this.searchHint,
  });

  @override
  State<BaseAppBar> createState() => _BaseAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _BaseAppBarState extends State<BaseAppBar> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context, _isSearching),
      centerTitle: widget.centerTitle,
      backgroundColor: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: AppDimens.SIZE_40,
      leading: _buildLeading(context),
      actions: [ if (widget.showSearch ?? false) _buildSearchAction(),...(widget.actions ?? []), ],
    );
  }

  Widget? _buildTitle(BuildContext context, bool showSearch) {
    if (widget.customTitle != null) {
      return widget.customTitle;
    }
    return SizedBox(
      width: 250.sw,
      child: showSearch ? TextField(
        controller: TextEditingController(),
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? AppLocalizations.current.search,
          hintStyle: TextStyle(color: AppColors.hintTextColor),
          border: InputBorder.none,
        ),
        style: TextStyle(color: AppColors.secondaryTextDark),
        onChanged: (value) {
          widget.onSearchChanged?.call(value);
        },
      ) : CustomTextLabel(
        widget.title,
        color: AppColors.white,
        fontSize: AppDimens.SIZE_14,
        fontWeight: FontWeight.w700,
        maxLines: 1,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.customLeading != null) {
      return widget.customLeading;
    }

    if (widget.showBackButton) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap:
            widget.onBackTap ??
            () {
              Navigator.pop(context);
            },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: AppDimens.SIZE_16,
          ),
        ),
      );
    }
    return null;
  }
  Widget _buildSearchAction() {
    return IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
        });
      },
    );
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final Widget? customLeading;
  final Color? backgroundColor;
  final VoidCallback? onBackTap;
  final bool? centerTitle;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final VoidCallback? onSearchCanceled;
  final String? searchHint;
  final TextEditingController? searchController;

  const SearchAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.customLeading,
    this.backgroundColor,
    this.onBackTap,
    this.centerTitle = true,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchCanceled,
    this.searchHint,
    this.searchController,
  });

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearchMode = false;
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = widget.searchController ?? TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    if (widget.searchController == null) {
      _searchController.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (_isSearchMode) {
        _animationController.forward();
        // Focus vào search field sau khi animation bắt đầu
        Future.delayed(const Duration(milliseconds: 150), () {
          FocusScope.of(context).requestFocus();
        });
      } else {
        _animationController.reverse();
        _searchController.clear();
        widget.onSearchCanceled?.call();
        // Ẩn keyboard
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _onSearchSubmitted() {
    widget.onSearchSubmitted?.call();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _buildTitle(context),
      centerTitle: widget.centerTitle,
      backgroundColor: widget.backgroundColor ?? AppColors.secondaryBrand,
      elevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: AppDimens.SIZE_40,
      leading: _buildLeading(context),
      actions: _buildActions(context),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (_isSearchMode) {
      return AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: AppDimens.SIZE_32,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_20),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppDimens.SIZE_16,
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? 'Tìm kiếm...',
                  hintStyle: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: AppDimens.SIZE_16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimens.SIZE_16,
                    vertical: AppDimens.SIZE_8,
                  ),
                ),
                onChanged: widget.onSearchChanged,
                onSubmitted: (_) => _onSearchSubmitted(),
                autofocus: true,
              ),
            ),
          );
        },
      );
    }

    return CustomTextLabel(
      widget.title,
      color: AppColors.white,
      fontSize: AppDimens.SIZE_14,
      fontWeight: FontWeight.w700,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.customLeading != null) {
      return widget.customLeading;
    }

    if (widget.showBackButton) {
      return InkWell(
        borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap:
            widget.onBackTap ??
            () {
              Navigator.pop(context);
            },
        child: Container(
          padding: EdgeInsets.only(bottom: AppDimens.SIZE_4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.white,
            size: AppDimens.SIZE_14,
          ),
        ),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (_isSearchMode) {
      return [
        Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(
            bottom: AppDimens.SIZE_20,
            right: AppDimens.SIZE_16,
          ),
          child: InkWell(
            onTap: _toggleSearchMode,
            child: Icon(
              Icons.close,
              color: AppColors.white,
              size: AppDimens.SIZE_16,
            ),
          ),
        ),
      ];
    }

    return [
      Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(
          bottom: AppDimens.SIZE_20,
          right: AppDimens.SIZE_16,
        ),
        child: InkWell(
          onTap: _toggleSearchMode,
          child: Icon(
            Icons.search,
            color: AppColors.white,
            size: AppDimens.SIZE_16,
          ),
        ),
      ),
    ];
  }
}
