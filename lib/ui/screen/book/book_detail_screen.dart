import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

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

  bool get isFavorite => _isFavorite;
  bool get isArchived => _isArchived;
  @override
  void initState() {
    super.initState();
    // Đảm bảo listener được đăng ký trước khi gọi getStats()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInteractionStats();
    });
  }

  void _loadInteractionStats() async {
    await context.read<UserInteractionCubit>().getStats(
      targetType: 'book',
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
      Navigator.pushNamed(
        context,
        Routes.pdfViewerScreen,
        arguments: {
          'fileUrl': '${ApiConstant.apiHostStorage}${book.fileUrl}',
          'title': book.displayTitle,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserInteractionCubit, BaseState>(
      listener: (context, state) {
        if (state is LoadedState && state.data != null) {
          final stats = state.data as InteractionStatsModel;
          setState(() {
            _isFavorite = stats.favoriteStatus == true;
            _isArchived = stats.archiveStatus == true;
          });
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

  Widget _buildBody(BuildContext context, BookModel book) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar với Cover Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Author
                  Row(
                    children: [
                      Icon(Icons.person, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        book.displayAuthor,
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Rating
                  if (book.rating != null && book.rating! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(5, (index) {
                            return Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                index < book.rating!.floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: Colors.amber[700],
                                size: 26,
                              ),
                            );
                          }),
                          SizedBox(width: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${book.rating!.toStringAsFixed(1)}/5.0',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 24),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.library_books,
                          label: AppLocalizations.current.pages,
                          value: '${book.totalPages ?? 0}',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.insert_drive_file,
                          label: AppLocalizations.current.size,
                          value: book.fileSizeFormatted,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.language,
                          label: AppLocalizations.current.language,
                          value: book.language?.toUpperCase() ?? 'VI',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

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
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Reading Progress (if available)
                  if (book.progressPercentage > 0) ...[
                    Text(
                      AppLocalizations.current.reading_progress,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: book.progressPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${AppLocalizations.current.completed}${book.progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 24),
                  ],

                  // Last Read Date
                  if (book.lastRead != null) ...[
                    Text(
                      AppLocalizations.current.last_read +
                          _formatDate(book.lastRead!),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 24),
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
            color: Colors.white,
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
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    book.progressPercentage > 0
                        ? AppLocalizations.current.continue_reading
                        : AppLocalizations.current.start_reading,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (book.progressPercentage > 0) ...[
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${book.progressPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Theme.of(context).primaryColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
