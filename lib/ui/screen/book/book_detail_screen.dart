import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/enums.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/utils/common.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookDetailCubit>(
      create: (_) => getIt.get<BookDetailCubit>()..getBookById(bookId),
      child: BookDetailBody(bookId: bookId),
    );
  }
}

class BookDetailBody extends StatefulWidget {
  final String bookId;
  const BookDetailBody({super.key, required this.bookId});

  @override
  BookDetailBodyState createState() => BookDetailBodyState();
}

class BookDetailBodyState extends State<BookDetailBody> {
  bool _isFavorite = false;
  bool _isArchived = false;
  bool _isReading = false;
  Map<String, dynamic> _readingMetadata = {};
  bool _descriptionExpanded = false;

  bool get isFavorite => _isFavorite;
  bool get isArchived => _isArchived;
  UserModel? currentUser;
  @override
  void initState() {
    super.initState();
    // Đảm bảo listener được đăng ký trước khi gọi getStats()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInteractionStatus();
      _loadInteractionStats();
    });
    currentUser = context.read<AppCubit>().getUser();
  }

  void _loadInteractionStatus() async {
    await context.read<UserInteractionCubit>().getUserInteractionStatus(
      targetType: InteractionTarget.book,
      targetId: widget.bookId,
    );
  }

  void _loadInteractionStats() async {
    await context.read<UserInteractionCubit>().getStats(
      targetType: InteractionTarget.book,
      targetId: widget.bookId,
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    return '${ApiConstant.apiHostStorage}$imagePath';
  }

  void _toggleFavorite() {
    if (widget.bookId.isEmpty) return;

    final newValue = !_isFavorite;
    context.read<UserInteractionCubit>().toggleFavorite(
      targetType: 'book',
      targetId: widget.bookId,
    );
    setState(() {
      _isFavorite = newValue;
    });
  }

  void _toggleArchive() {
    if (widget.bookId.isEmpty) return;
    final newValue = !_isArchived;
    context.read<UserInteractionCubit>().toggleArchive(
      targetType: 'book',
      targetId: widget.bookId,
    );
    setState(() {
      _isArchived = newValue;
    });
  }

  void _openPdfViewer(BookModel book) {
    if (book.fileUrl != null) {
      Navigator.pushNamed(context, Routes.pdfViewerScreen, arguments: book);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInteractionCubit, BaseState>(
      listener: (context, state) {
        if (state is LoadedState && state.data != null) {
          if (state.data is Map<String, dynamic>) {
            final data = state.data as Map<String, dynamic>;
            setState(() {
              if (data.containsKey('favorite') == true) {
                _isFavorite = data['favorite'] == true;
              }
              if (data.containsKey('archived') == true) {
                _isArchived = data['archived'] == true;
              }
              if (data.containsKey('reading') == true) {
                _isReading = data['reading'] != null;
                _readingMetadata = data['reading'] ?? {};
              }
            });
          }
        }
      },
      child: BlocBuilder<BookDetailCubit, BaseState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LoadedState) {
            return _buildBody(context, state.data as BookModel);
          }
          if (state is ErrorState) {
            return _buildErrorContent(context, state.data);
          }
          return Center(
            child: Text(
              AppLocalizations.current.error_common,
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
    return BaseScreen(
      title: AppLocalizations.current.view_details,
      body: Padding(
        padding: EdgeInsets.all(AppDimens.SIZE_16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              SizedBox(height: AppDimens.SIZE_16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.current.go_back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BookModel book) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar với Cover Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                book.displayTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSize.fontSizeXXLarge,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              titlePadding: EdgeInsets.only(left: 24, bottom: 16),
              centerTitle: false,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  book.coverImageUrl != null
                      ? Image.network(
                        _getImageUrl(book.coverImageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.book,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.book, size: 100, color: Colors.grey),
                      ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isArchived
                          ? Icons.archive_rounded
                          : Icons.archive_outlined,
                      color:
                          isArchived
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _toggleArchive(),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          isFavorite
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _toggleFavorite(),
                  ),
                ],
              ),
            ],
          ),

          // Book Details
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.displayTitle,
                    style: TextStyle(
                      fontSize: AppSize.fontSizeXXXLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // người đăng tải
                  // Author
                  Row(
                    children: [
                      SvgPicture.asset(
                        Assets.icons.icUser,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Colors.grey[700]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        book.author ?? '',
                        style: TextStyle(
                          fontSize: AppSize.fontSizeLarge,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // build statistical row  // likeCount, dislikeCount, bookmarkCount, shareCount, viewCount, commentCount, rateCount, followCount, favoriteCount, archiveCount
                  BlocBuilder<UserInteractionCubit, BaseState>(
                    buildWhen:
                        (previous, current) =>
                            current is LoadedState &&
                            current.data is InteractionStatsModel,
                    bloc: context.read<UserInteractionCubit>(),
                    builder: (context, state) {
                      if (state is LoadedState &&
                          state.data is InteractionStatsModel) {
                        final stats = state.data as InteractionStatsModel;
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildStatisticalRow(
                                Icons.favorite,
                                Colors.red,
                                '${stats.favoriteCount}',
                              ),
                              _buildStatisticalRow(
                                Icons.archive,
                                Colors.blue,
                                '${stats.archiveCount}',
                              ),
                              _buildStatisticalRow(
                                Icons.comment,
                                Colors.grey,
                                '${stats.commentCount}',
                              ),
                              if (stats.averageRating != null &&
                                  stats.averageRating! > 0)
                                _buildStatisticalRow(
                                  Icons.star,
                                  Colors.yellow,
                                  '${stats.averageRating}',
                                ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Rating
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Routes.reviewsScreen,
                        arguments: {
                          'bookId': widget.bookId,
                          'bookTitle': book.displayTitle,
                          'averageRating': book.rating,
                          'totalRatings': null,
                        },
                      );
                    },
                    icon: Icon(Icons.rate_review, size: 18),
                    label: Text(AppLocalizations.current.reviews),
                  ),
                  SizedBox(height: 24),

                  // Info Cards
                  if (book.totalPages != null && book.totalPages! > 0) ...[
                    _buildDetailRow(
                      AppLocalizations.current.pages,
                      '${book.totalPages ?? 0}',
                    ),
                    SizedBox(height: 8),
                  ],
                  if (book.fileSizeFormatted.isNotEmpty) ...[
                    _buildDetailRow(
                      AppLocalizations.current.size,
                      book.fileSizeFormatted,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (book.language?.isNotEmpty ?? false) ...[
                    _buildDetailRow(
                      AppLocalizations.current.language,
                      book.language?.toUpperCase() ?? 'VI',
                    ),
                    SizedBox(height: 8),
                  ],
                  if (book.createAt != null) ...[
                    _buildDetailRow(
                      AppLocalizations.current.created_at,
                      Common.formatDate(
                        book.createAt!,
                        format: 'dd/MM/yyyy HH:mm',
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                  if (book.category != null &&
                      book.category!.name!.isNotEmpty) ...[
                    _buildDetailRow(
                      AppLocalizations.current.category,
                      book.category!.name!,
                    ),
                    SizedBox(height: 8),
                  ],
                  // Publisher & ISBN
                  if (book.publisher != null) ...[
                    _buildDetailRow(
                      AppLocalizations.current.publisher,
                      book.publisher!,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (book.isbn != null) ...[
                    _buildDetailRow(AppLocalizations.current.isbn, book.isbn!),
                    SizedBox(height: 8),
                  ],
                  if (book.categories != null &&
                      book.categories!.isNotEmpty) ...[
                    _buildDetailRow(
                      AppLocalizations.current.category,
                      book.categoriesDisplay,
                    ),
                    SizedBox(height: 24),
                  ],

                  // Description
                  if (book.description != null &&
                      book.description!.isNotEmpty) ...[
                    Text(
                      AppLocalizations.current.description,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      book.description!,
                      maxLines: _descriptionExpanded ? null : 4,
                      overflow:
                          _descriptionExpanded ? null : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (book.description!.length > 150)
                      GestureDetector(
                        onTap:
                            () => setState(
                              () =>
                                  _descriptionExpanded = !_descriptionExpanded,
                            ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _descriptionExpanded
                                ? AppLocalizations.current.show_less
                                : AppLocalizations.current.read_more,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: 24),
                  ],

                  // Last Read Date
                  if (_readingMetadata['lastUpdated'] != null) ...[
                    Text(
                      '${AppLocalizations.current.last_read} : ${Common.formatDate(_readingMetadata['lastUpdated'], format: 'dd/MM/yyyy HH:mm')}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Read Button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(AppDimens.SIZE_8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _openPdfViewer(book),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 24,
                      color: theme.colorScheme.onInverseSurface,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    _isReading
                        ? AppLocalizations.current.continue_reading
                        : AppLocalizations.current.start_reading,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onInverseSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_readingMetadata['progress'] != null) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onInverseSurface.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${Common.formatNumberToPercentage(_readingMetadata['progress'] ?? 0).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onInverseSurface,
                        ),
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

  // build statistical row count
  Widget _buildStatisticalRow(IconData icon, Color? iconColor, String value) {
    return SizedBox(
      width: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 40, child: Icon(icon, size: 24, color: iconColor)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
