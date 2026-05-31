import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/app_widgets/book_options_bottom_sheet.dart';
import 'package:readbox/domain/data/entities/book_file_entity.dart';
import 'package:readbox/utils/utils.dart';

class BookCard extends StatefulWidget {
  final BookModel book;
  final UserInteractionCubit userInteractionCubit;
  final String? ownerId;
  final FilterType? filterType;
  final Function(BookModel book) onDelete;
  final Function(BookModel book, BookFileEntity? file) onRead;
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

  void _showBookOptions(BuildContext context, BookModel book) {
    BookOptionsBottomSheet.show(
      context,
      book: book,
      userInteractionCubit: widget.userInteractionCubit,
      ownerId: widget.ownerId,
      onRead: widget.onRead,
      onEdit: (book) => _editBook(context, book),
      onDelete: (book) => _deleteBook(context, book),
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
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
              onTap: () => widget.onRead(widget.book, null),
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
                                BaseNetworkImage(
                                  url: UrlBuilder.buildUrl(
                                    widget.book.coverImageUrl,
                                  ),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
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
                                          Colors.grey.withValues(alpha: 0.2),
                                          Colors.grey.withValues(alpha: 0.0),
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
                                    color: Colors.black.withValues(alpha: 0.1),
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
                                  Localizations.localeOf(
                                            context,
                                          ).languageCode ==
                                          'en'
                                      ? widget.book.category?.nameEN ?? ''
                                      : widget.book.category?.name ?? '',
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
    );
  }

  Widget _authorWidget(String author) {
    return Row(
      children: [
        SvgPicture.asset(
          Assets.icons.icUser,
          width: 14,
          height: 14,
          colorFilter: ColorFilter.mode(Colors.blue.shade400, BlendMode.srcIn),
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
          SvgPicture.asset(
            Assets.icons.icCategory,
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(
              Colors.orange.shade400,
              BlendMode.srcIn,
            ),
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
