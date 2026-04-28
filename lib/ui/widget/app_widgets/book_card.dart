import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/rating_dialog.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final UserInteractionCubit userInteractionCubit;
  final String? ownerId;
  final FilterType? filterType;
  final Function(BookModel book) onDelete;
  final Function(BookModel book) onRead;
  const BookCard({
    super.key,
    required this.book,
    required this.userInteractionCubit,
    required this.ownerId,
    required this.onDelete,
    required this.onRead,
    this.filterType,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool? _isFavorite;
  bool? _isArchive;
  double? _rating;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadUserInteractionStatus() async {
    await widget.userInteractionCubit.getUserInteractionStatus(
      targetType: InteractionTarget.book,
      targetId: widget.book.id!,
    );
  }

  bool get _favoriteStatus {
    // Ưu tiên dùng stats, fallback về book.isFavorite
    if (_isFavorite != null) return _isFavorite!;
    return widget.book.isFavorite == true;
  }

  bool get _archiveStatus {
    if (_isArchive != null) return _isArchive!;
    return widget.book.isArchived == true;
  }

  void _editBook(BuildContext context, BookModel book) {
    Navigator.pushNamed(context, Routes.adminUploadScreen, arguments: book);
  }

  void _deleteBook(BuildContext context, BookModel book) {
    CustomDialogUtil.showDialogConfirm(
      context,
      title: AppLocalizations.current.delete_book,
      content: AppLocalizations.current.delete_book_confirmation_message,
      onSubmit: () {
        widget.onDelete(book);
        Navigator.pop(context);
      },
    );
  }

  void _showRatingDialog(BookModel book) {
    // Close the bottom sheet first
    Navigator.pop(context);

    showDialog(
      context: context,
      builder:
          (context) => RatingDialog(
            onSubmit: (rating, comment) async {
              await widget.userInteractionCubit.rateAndComment(
                targetType: 'book',
                targetId: book.id!,
                rating: rating,
                comment: comment.isNotEmpty ? comment : null,
              );

              // Reload stats after rating
              await _loadUserInteractionStatus();
            },
          ),
    );
  }

  void _showBookOptions(BuildContext context, BookModel book) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Book info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child:
                                book.coverImageUrl != null
                                    ? Flexible(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            Platform.isAndroid
                                                ? Image.network(
                                                  _getImageUrl(
                                                    book.coverImageUrl,
                                                  ),
                                                  width: 80,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                )
                                                : BaseNetworkImage(
                                                  url: _getImageUrl(
                                                    book.coverImageUrl,
                                                  ),
                                                  width: 80,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    )
                                    : _buildErrorCover(),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.displayTitle,
                                  style: TextStyle(
                                    fontSize: AppSize.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                if (book.author != null) ...[
                                  _authorWidget(book.author!),
                                ],
                                if (book.category != null) ...[
                                  _categoryWidget(book.category?.name ?? ''),
                                ],
                                SizedBox(height: 4),
                                // action delete and edit book
                                if (book.createById == widget.ownerId) ...[
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _editBook(context, book);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              AppLocalizations
                                                  .current
                                                  .edit_book,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteBook(context, book);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              AppLocalizations
                                                  .current
                                                  .delete_book,
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.error,
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
                    ],
                  ),
                ),
              ),

              // Action buttons
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.menu_book_rounded,
                        label: AppLocalizations.current.read_book,
                        color: theme.primaryColor,
                        onTap: () => widget.onRead(book),
                      ),

                      SizedBox(height: 12),

                      _buildActionButton(
                        icon: Icons.info_outline_rounded,
                        label: AppLocalizations.current.view_details,
                        color: Colors.lightBlueAccent,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            Routes.bookDetailScreen,
                            arguments: book.id,
                          );
                        },
                      ),

                      SizedBox(height: 12),

                      // Rate and Review button
                      _buildActionButton(
                        icon: Icons.star_rate_rounded,
                        label: AppLocalizations.current.rate_and_review,
                        color: Colors.amber,
                        onTap: () {
                          _showRatingDialog(book);
                        },
                      ),

                      SizedBox(height: 12),

                      BlocConsumer<UserInteractionCubit, BaseState>(
                        bloc: widget.userInteractionCubit,
                        listener: (context, state) {
                          if (state is LoadedState) {
                            if (state.data is Map<String, dynamic>) {
                              final data = state.data as Map<String, dynamic>;
                              setState(() {
                                if (data.containsKey('favorite') == true) {
                                  _isFavorite = data['favorite'] == true;
                                }
                                if (data.containsKey('archived') == true) {
                                  _isArchive = data['archived'] == true;
                                }
                              });
                            }
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            children: [
                              _buildActionButton(
                                icon:
                                    _favoriteStatus
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                label:
                                    _favoriteStatus
                                        ? AppLocalizations
                                            .current
                                            .remove_favorite
                                        : AppLocalizations.current.add_favorite,
                                color: Theme.of(context).colorScheme.error,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await widget.userInteractionCubit
                                      .toggleFavorite(
                                        targetType: 'book',
                                        targetId: widget.book.id!,
                                      );
                                  // Reload stats after toggle
                                  await _loadUserInteractionStatus();
                                },
                              ),
                              SizedBox(height: 12),
                              _buildActionButton(
                                icon:
                                    _archiveStatus
                                        ? Icons.close_rounded
                                        : Icons.archive_rounded,
                                label:
                                    _archiveStatus
                                        ? AppLocalizations
                                            .current
                                            .remove_archive
                                        : AppLocalizations.current.add_archive,
                                color:
                                    _archiveStatus
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.secondary
                                        : Colors.grey[700]!,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await widget.userInteractionCubit
                                      .toggleArchive(
                                        targetType: 'book',
                                        targetId: widget.book.id!,
                                      );
                                  // Reload stats after toggle
                                  await _loadUserInteractionStatus();
                                },
                                isOutlined: false,
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // Otherwise, it's from our backend
    return '${ApiConstant.apiHostStorage}$imagePath';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          // color: isOutlined ? Colors.white : color.withValues(alpha: 0.1),
          // borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isOutlined
                        ? Colors.grey[100]
                        : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: AppSize.iconSizeLarge),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSize.fontSizeLarge,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? Colors.grey[700] : color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color:
                  isOutlined ? Colors.grey[400] : color.withValues(alpha: 0.5),
              size: AppSize.iconSizeMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCover() {
    return Padding(
      padding: EdgeInsets.all(AppDimens.SIZE_16),
      child: Center(
        child: SvgPicture.asset(Assets.icons.icPdfCover, fit: BoxFit.fitHeight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<UserInteractionCubit, BaseState>(
      bloc: widget.userInteractionCubit,
      listener: (context, state) {
        if (state is LoadedState && state.data != null) {
          // Update favorite/archive status from stats response
          if (state.data is Map<String, dynamic>) {
            final data = state.data as Map<String, dynamic>;
            setState(() {
              if (data.containsKey('favorite') == true) {
                _isFavorite = data['favorite'] == true;
              }
              if (data.containsKey('archived') == true) {
                _isArchive = data['archived'] == true;
              }
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(4, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: () => widget.onRead(widget.book),
                onLongPress: () {
                  _loadUserInteractionStatus();
                  // Long press: Hiển thị menu options
                  _showBookOptions(context, widget.book);
                },
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  widget.book.coverImageUrl != null
                                      ? (Platform.isAndroid
                                          ? Image.network(
                                            _getImageUrl(
                                              widget.book.coverImageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                          : BaseNetworkImage(
                                            url: _getImageUrl(
                                              widget.book.coverImageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ))
                                      : Container(
                                        color: theme.colorScheme.surfaceVariant,
                                        child: _buildErrorCover(),
                                      ),
                                  // Spine effect
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black.withValues(alpha: 0.3),
                                            Colors.black.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Favorite badge
                          if (_favoriteStatus &&
                              widget.filterType == FilterType.favorite)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  size: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Book Info
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.book.displayTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),

                                if (widget.book.author != null) ...[
                                  _authorWidget(widget.book.author!),
                                ],
                                // Category
                                if (widget.book.category != null)
                                  _categoryWidget(
                                    widget.book.category?.name ?? '',
                                  ),
                              ],
                            ),
                            // Rating
                            Row(
                              children: [
                                if (_rating != null && _rating! > 0) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$_rating',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _authorWidget(String author) {
    return Row(
      children: [
        Icon(
          Icons.person_outline_rounded,
          size: 14,
          color: Colors.blue.shade400,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            author,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _categoryWidget(String category) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 12,
            color: Colors.orange.shade400,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
