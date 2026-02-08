import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/entities/user_interaction_entity.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/interaction_target.dart';
import 'package:readbox/domain/enums/interaction_type.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:readbox/ui/widget/rating_dialog.dart';
import 'package:readbox/ui/widget/reviews_list_widget.dart';

String _getUserAvatarUrl(String picture) {
  if (picture.startsWith('http://') || picture.startsWith('https://')) {
    return picture;
  }
  return '${ApiConstant.storageHost}$picture';
}

class ReviewsScreen extends StatefulWidget {
  final String bookId;
  final String? bookTitle;
  final double? averageRating;
  final int? totalRatings;


  const ReviewsScreen({
    super.key,
    required this.bookId,
    this.bookTitle,
    this.averageRating,
    this.totalRatings,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<UserInteractionEntity> _reviews = [];
  int _currentPage = 1;
  int _totalCount = 0; // Total from API
  static const int _pageSize = 10;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;
    UserModel? currentUser;
  @override
  void initState() {
    super.initState();
    _loadReviews(isRefresh: true);
    _scrollController.addListener(_onScroll);
    currentUser = context.read<AppCubit>().getUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadReviews(isRefresh: false);
    }
  }

  Future<void> _loadReviews({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _currentPage = 1;
        _reviews.clear();
        _hasMore = true;
      });
    } else {
      if (_isLoadingMore || !_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final cubit = context.read<UserInteractionCubit>();
      final page = isRefresh ? 1 : _currentPage;
      await cubit.loadInteractions(
        targetType: InteractionTarget.book,
        targetId: widget.bookId,
        query: {
          'interactionType': InteractionType.rating.value,
          'page': page,
          'limit': _pageSize,
        },
        isLoadMore: !isRefresh,
      );

      if (!mounted) return;

      setState(() {
        _reviews.clear();
        _reviews.addAll(cubit.reviews);
        _hasMore = cubit.hasMore;
        if (isRefresh) {
          _currentPage = 2;
          _isLoading = false;
        } else {
          _currentPage++;
        }
        _isLoadingMore = false;
        _totalCount = cubit.reviews.length;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  double get _calculatedAverageRating {
    if (_reviews.isEmpty) return widget.averageRating ?? 0;
    final sum = _reviews
        .where((r) => r.rating != null)
        .fold<double>(0, (s, r) => s + (r.rating ?? 0));
    final count = _reviews.where((r) => r.rating != null).length;
    return count > 0 ? sum / count : 0;
  }

  Map<int, int> get _ratingDistribution {
    final dist = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in _reviews) {
      if (r.rating != null) {
        final star = r.rating!.round().clamp(1, 5);
        dist[star] = (dist[star] ?? 0) + 1;
      }
    }
    return dist;
  }

  void _showRatingDialog({UserInteractionEntity? existingReview}) {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        initialRating: existingReview?.rating?.toDouble(),
        initialComment: existingReview?.comment,
        onSubmit: (rating, comment) async {
          await context.read<UserInteractionCubit>().rateAndComment(
            targetType: 'book',
            targetId: widget.bookId,
            rating: rating,
            comment: comment.isNotEmpty ? comment : null,
          );
          await _loadReviews(isRefresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider.value(
      value: context.read<UserInteractionCubit>(),
      child: BaseScreen(
        colorBg: colorScheme.surface,
        customAppBar: BaseAppBar(
          title: AppLocalizations.current.reviews,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: () => _loadReviews(isRefresh: true),
          child: _buildBody(colorScheme),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading && _reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _reviews.isEmpty) {
      return _buildErrorState(colorScheme);
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Book title
        if (widget.bookTitle != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                widget.bookTitle!,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

        // Rating summary
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: RatingSummaryWidget(
              averageRating: _calculatedAverageRating,
              totalRatings: _totalCount > 0
                  ? _totalCount
                  : (widget.totalRatings ?? _reviews.length),
              ratingDistribution:
                  _reviews.isNotEmpty ? _ratingDistribution : null,
            ),
          ),
        ),

        // Write review button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showRatingDialog(),
              icon: const Icon(Icons.rate_review, size: 20),
              label: Text(AppLocalizations.current.write_a_review),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // Section title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Text(
                  AppLocalizations.current.reviews,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                if (_reviews.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_reviews.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Reviews list
        _reviews.isEmpty
            ? SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.current.no_reviews_yet,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = _reviews[index];
                      return Column(
                        children: [
                          _ReviewTile(
                            review: review,
                            onEdit: () => _showRatingDialog(existingReview: review),
                            onDelete: () async {
                              await _loadReviews(isRefresh: true);
                            },
                          ),
                          if (index < _reviews.length - 1)
                            Divider(
                              height: 1,
                              color: colorScheme.outlineVariant,
                            ),
                        ],
                      );
                    },
                    childCount: _reviews.length,
                  ),
                ),
              ),

        // Load more indicator
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? AppLocalizations.current.error_common,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadReviews(isRefresh: true),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.current.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final UserInteractionEntity review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewTile({
    required this.review,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppCubit>().getUser();
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = review.user?.fullName ??
        review.user?.username ??
        review.user?.email ??
        'Anonymous';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: review.user?.picture != null
                    ? ClipOval(
                        child: Image.network(
                          _getUserAvatarUrl(review.user!.picture!),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.person,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (review.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDateString(review.createdAt!, context),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (currentUser?.id == review.userId && (onEdit != null || onDelete != null))
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.current.edit_review),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.current.delete_review,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          if (review.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final star = i + 1;
                return Icon(
                  review.rating! >= star
                      ? Icons.star_rounded
                      : review.rating! >= star - 0.5
                          ? Icons.star_half_rounded
                          : Icons.star_border_rounded,
                  size: 20,
                  color: Colors.amber,
                );
              }),
            ),
          ],
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateString(String dateStr, BuildContext context) {
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays > 365) return '${diff.inDays ~/ 365} ${AppLocalizations.current.years_ago}';
      if (diff.inDays > 30) return '${diff.inDays ~/ 30} ${AppLocalizations.current.months_ago}';
      if (diff.inDays > 0) return '${diff.inDays} ${AppLocalizations.current.days_ago}';
      if (diff.inHours > 0) return '${diff.inHours} ${AppLocalizations.current.hours_ago}';
      if (diff.inMinutes > 0) return '${diff.inMinutes} ${AppLocalizations.current.minutes_ago}';
      return AppLocalizations.current.just_now;
    } catch (_) {
      return dateStr;
    }
  }
}
