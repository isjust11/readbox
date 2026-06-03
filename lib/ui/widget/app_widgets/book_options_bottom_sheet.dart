import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/entities/book_entity.dart';
import 'package:readbox/domain/data/entities/book_file_entity.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/interaction_target.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/rating_dialog.dart';
import 'package:readbox/utils/utils.dart';

class BookOptionsBottomSheet extends StatefulWidget {
  final BookModel book;
  final UserInteractionCubit userInteractionCubit;
  final String? ownerId;
  final Function(BookModel book, BookFileEntity? file) onRead;
  final Function(BookModel book)? onEdit;
  final Function(BookModel book)? onDelete;

  const BookOptionsBottomSheet({
    super.key,
    required this.book,
    required this.userInteractionCubit,
    required this.ownerId,
    required this.onRead,
    this.onEdit,
    this.onDelete,
  });

  static void show(
    BuildContext context, {
    required BookModel book,
    required UserInteractionCubit userInteractionCubit,
    required String? ownerId,
    required Function(BookModel book, BookFileEntity? file) onRead,
    Function(BookModel book)? onEdit,
    Function(BookModel book)? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      builder: (context) {
        return BookOptionsBottomSheet(
          book: book,
          userInteractionCubit: userInteractionCubit,
          ownerId: ownerId,
          onRead: onRead,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }

  @override
  State<BookOptionsBottomSheet> createState() => _BookOptionsBottomSheetState();
}

class _BookOptionsBottomSheetState extends State<BookOptionsBottomSheet> {
  bool? _isFavorite;
  bool? _isArchive;

  @override
  void initState() {
    super.initState();
    _loadUserInteractionStatus();
  }

  Future<void> _loadUserInteractionStatus() async {
    await widget.userInteractionCubit.getUserInteractionStatus(
      targetType: InteractionTarget.book,
      targetId: widget.book.id!,
    );
  }

  bool get _favoriteStatus {
    if (_isFavorite != null) return _isFavorite!;
    return widget.book.isFavorite == true;
  }

  bool get _archiveStatus {
    if (_isArchive != null) return _isArchive!;
    return widget.book.isArchived == true;
  }

  void _showRatingDialog(BookModel book) {
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
              await _loadUserInteractionStatus();
            },
          ),
    );
  }

  void _showReportBrokenLinkDialog(BookModel book) {
    Navigator.pop(context);
    final TextEditingController commentController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: AppLocalizations.current.report_broken_link,
            titleSubmit: AppLocalizations.current.report_broken_link_submit,
            titleCancel: AppLocalizations.current.close,
            autoPopWhenPressSubmit: true,
            contentWidget: CustomTextInput(
              textController: commentController,
              title: AppLocalizations.current.report_broken_link_optional_desc,
              hintText: AppLocalizations.current.report_broken_link_hint,
              maxLines: 3,
              minLines: 3,
              maxLength: 500,
            ),
            onSubmit: () async {
              try {
                await widget.userInteractionCubit.reportBrokenLink(
                  targetType: 'book',
                  targetId: book.id!,
                  comment: commentController.text.isNotEmpty ? commentController.text : null,
                );
                if (mounted) {
                  AppSnackBar.show(
                    context,
                    message: AppLocalizations.current.report_broken_link_success,
                  );
                }
              } catch (e) {
                if (mounted) {
                  AppSnackBar.show(
                    context,
                    message: "${AppLocalizations.current.report_broken_link_failed}$e",
                  );
                }
              }
            },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = widget.book;

    // Phân tích định dạng file có sẵn
    final List<BookFileEntity> availableFiles = book.files ?? [];
    BookFileEntity? epubFile;
    BookFileEntity? pdfFile;

    for (final f in availableFiles) {
      final fmt = f.format?.toLowerCase();
      if (fmt == 'epub') epubFile = f;
      if (fmt == 'pdf') pdfFile = f;
    }

    // Nếu không có mảng files, fallback về fileType (dữ liệu cũ)
    bool hasEpub = epubFile != null || book.fileType == BookType.epub;
    bool hasPdf = pdfFile != null || book.fileType == BookType.pdf;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BaseNetworkImage(
                          url: UrlBuilder.buildUrl(book.coverImageUrl),
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                            _categoryWidget(
                              Localizations.localeOf(context).languageCode ==
                                      'en'
                                  ? book.category?.nameEN ?? ''
                                  : book.category?.name ?? '',
                            ),
                          ],
                          SizedBox(height: 4),
                          // action delete and edit book
                          if (book.createById == widget.ownerId) ...[
                            Row(
                              children: [
                                if (widget.onEdit != null)
                                  TextButton(
                                    onPressed: () {
                                      widget.onEdit!(book);
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (widget.onDelete != null)
                                  TextButton(
                                    onPressed: () {
                                      widget.onDelete!(book);
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
              ],
            ),
          ),

          // Action buttons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (hasEpub)
                    _buildActionButton(
                      icon: Icons.menu_book_rounded,
                      label: "Đọc EPUB",
                      color: theme.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onRead(book, epubFile);
                      },
                    ),

                  if (hasPdf) ...[
                    if (hasEpub) SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: "Đọc PDF",
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onRead(book, pdfFile);
                      },
                    ),
                  ],

                  if (!hasEpub && !hasPdf)
                    _buildActionButton(
                      icon: Icons.menu_book_rounded,
                      label: AppLocalizations.current.read_book,
                      color: theme.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        widget.onRead(book, null);
                      },
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

                  // Report broken link button
                  _buildActionButton(
                    icon: Icons.report_problem_rounded,
                    label: AppLocalizations.current.report_broken_link,
                    color: Colors.deepOrangeAccent,
                    onTap: () {
                      _showReportBrokenLinkDialog(book);
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
                                    ? AppLocalizations.current.remove_favorite
                                    : AppLocalizations.current.add_favorite,
                            color: Theme.of(context).colorScheme.error,
                            onTap: () async {
                              await widget.userInteractionCubit.toggleFavorite(
                                targetType: 'book',
                                targetId: widget.book.id!,
                              );
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
                                    ? AppLocalizations.current.remove_archive
                                    : AppLocalizations.current.add_archive,
                            color:
                                _archiveStatus
                                    ? Theme.of(context).colorScheme.secondary
                                    : Colors.grey[700]!,
                            onTap: () async {
                              await widget.userInteractionCubit.toggleArchive(
                                targetType: 'book',
                                targetId: widget.book.id!,
                              );
                              await _loadUserInteractionStatus();
                            },
                            isOutlined: false,
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
