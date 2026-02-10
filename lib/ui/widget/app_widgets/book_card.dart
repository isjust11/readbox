import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/rating_dialog.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final UserInteractionCubit userInteractionCubit;
  final String? ownerId;
  final Function(BookModel book) onDelete;
  final Function(BookModel book) onRead;
  const BookCard({
    super.key,
    required this.book,
    required this.userInteractionCubit,
    required this.ownerId,
    required this.onDelete,
    required this.onRead,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  bool? _isFavorite;
  bool? _isArchive;
  double? _rating = 0;
  @override
  void initState() {
    super.initState();
    _loadInteractionStats();
  }

  Future<void> _loadInteractionStats() async {
    await widget.userInteractionCubit.getStats(
      targetType: 'book',
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
      builder: (context) => RatingDialog(
        onSubmit: (rating, comment) async {
          await widget.userInteractionCubit.rateAndComment(
            targetType: 'book',
            targetId: book.id!,
            rating: rating,
            comment: comment.isNotEmpty ? comment : null,
          );
          
          // Reload stats after rating
          await _loadInteractionStats();
        },
      ),
    );
  }

  void _showBookOptions(BuildContext context, BookModel book) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // Book info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child:
                          book.coverImageUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _getImageUrl(book.coverImageUrl),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.book, color: Colors.grey);
                                  },
                                ),
                              )
                              : Icon(Icons.book, color: Colors.grey),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            book.author ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.current.edit_book,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
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
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        AppLocalizations.current.delete_book,
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

                SizedBox(height: 24),

                // Action buttons
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
                      if (state.data is InteractionStatsModel) {
                        final stats = state.data as InteractionStatsModel;
                        setState(() {
                          _isFavorite = stats.favoriteStatus;
                          _isArchive = stats.archiveStatus;
                          book.isFavorite = stats.favoriteStatus;
                          book.isArchived = stats.archiveStatus;
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
                                  ? AppLocalizations.current.remove_favorite
                                  : AppLocalizations.current.add_favorite,
                          color: Theme.of(context).colorScheme.error,
                          onTap: () async {
                            Navigator.pop(context);
                            await widget.userInteractionCubit.toggleFavorite(
                              targetType: 'book',
                              targetId: widget.book.id!,
                            );
                            // Reload stats after toggle
                            await _loadInteractionStats();
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
                                  ? AppLocalizations.current.remove_archive
                                  : AppLocalizations.current.add_archive,
                          color:
                              _archiveStatus
                                  ? Theme.of(context).colorScheme.secondary
                                  : Colors.grey[700]!,
                          onTap: () async {
                            Navigator.pop(context);
                            await widget.userInteractionCubit.toggleArchive(
                              targetType: 'book',
                              targetId: widget.book.id!,
                            );
                            // Reload stats after toggle
                            await _loadInteractionStats();
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
          border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3), width: 1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isOutlined
                        ? Colors.grey[100]
                        : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? Colors.grey[700] : color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color:
                  isOutlined ? Colors.grey[400] : color.withValues(alpha: 0.5),
              size: 16,
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
        child: SvgPicture.asset(
          Assets.icons.icPdfCover,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInteractionCubit, BaseState>(
      bloc: widget.userInteractionCubit,
      listener: (context, state) {
        if (state is LoadedState && state.data != null) {
          // Update favorite/archive status from stats response
          if (state.data is InteractionStatsModel) {
            final stats = state.data as InteractionStatsModel;
            if (stats.targetId == widget.book.id?.toString() &&
                stats.targetType?.value == 'book') {
              setState(() {
                _isFavorite = stats.favoriteStatus == true;
                _isArchive = stats.archiveStatus == true;
                _rating = stats.averageRating;
              });
            }
          } else if (state.data is Map<String, dynamic>) {
            final data = state.data as Map<String, dynamic>;
            setState(() {
              if (data.containsKey('favoriteStatus')) {
                _isFavorite = data['favoriteStatus'] == true;
              }
              if (data.containsKey('archiveStatus')) {
                _isArchive = data['archiveStatus'] == true;
              }
              if (data.containsKey('averageRating')) {
                _rating = data['averageRating'];
              }
            });
          }
        } else if (state is ErrorState) {
          // Fallback to book fields if error
          setState(() {
            _isFavorite = widget.book.isFavorite;
            _isArchive = widget.book.isArchived;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          child: InkWell(
            onTap: () => widget.onRead(widget.book),
            onLongPress: () {
              // Long press: Hiển thị menu options
              _showBookOptions(context, widget.book);
            },
            borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppDimens.SIZE_16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.1),
                              Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child:
                            widget.book.coverImageUrl != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(AppDimens.SIZE_16),
                                  ),
                                  child: Image.network(
                                    _getImageUrl(widget.book.coverImageUrl),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildErrorCover();
                                    },
                                  ),
                                )
                                : _buildErrorCover(),
                      ),
                      // Favorite badge
                      if (_favoriteStatus)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Book Info
                Expanded(
                  flex: 5,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),

                            if (widget.book.author != null) ...[
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    Assets.icons.icUser,
                                    width: AppSize.iconSizeMedium,
                                    height: AppSize.iconSizeMedium,
                                    colorFilter: ColorFilter.mode(
                                      Colors.blue[500]!,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.book.author ?? '',
                                      style: TextStyle(
                                        fontSize: AppSize.fontSizeMedium,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Category
                            if (widget.book.category != null)
                              Column(
                                children: [
                                  const SizedBox(height: AppDimens.SIZE_6),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        Assets.icons.icCategory,
                                        width: AppSize.iconSizeMedium,
                                        height: AppSize.iconSizeMedium,
                                        colorFilter: ColorFilter.mode(
                                          Colors.orange[400]!,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      SizedBox(width: AppDimens.SIZE_8),
                                      Text(
                                        widget.book.category?.name ?? '',
                                        style: TextStyle(
                                          fontSize: AppSize.fontSizeMedium,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.book.totalPages != null && widget.book.totalPages! > 0) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimens.SIZE_8,
                                vertical: AppDimens.SIZE_6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColor.withValues(alpha: 0.45),
                                    Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                                  width: 1,
                                ),
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
                                    '${widget.book.totalPages} ${AppLocalizations.current.pages}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: AppSize.fontSizeSmall,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              ),
                            ],
                              if (_rating != null && _rating! > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.SIZE_8,
                                  vertical: AppDimens.SIZE_4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.SIZE_8,
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                    Colors.amber.withValues(alpha: 0.45),
                                    Colors.amber.withValues(alpha: 0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                  border: Border.all(
                                    color: Colors.amber.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '$_rating',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber[900],
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
