import 'package:flutter/material.dart';
import 'package:readbox/domain/data/entities/user_interaction_entity.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReviewsListWidget extends StatelessWidget {
  final List<UserInteractionEntity> reviews;
  final Function(UserInteractionEntity)? onEdit;
  final Function(UserInteractionEntity)? onDelete;

  const ReviewsListWidget({
    super.key,
    required this.reviews,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (reviews.isEmpty) {
      return Center(
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
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return _ReviewCard(
          review: review,
          onEdit: onEdit != null ? () => onEdit!(review) : null,
          onDelete: onDelete != null ? () => onDelete!(review) : null,
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final UserInteractionEntity review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReviewCard({
    required this.review,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: review.user?.picture != null
                    ? ClipOval(
                        child: Image.network(
                          review.user!.picture!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: colorScheme.onPrimaryContainer,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
              const SizedBox(width: 12),

              // User name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.fullName ?? 
                      review.user?.username ?? 
                      'Anonymous',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.createdAt != null
                          ? timeago.format(DateTime.parse(review.createdAt!))
                          : '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions menu
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
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
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.current.delete_review,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Star rating
          if (review.rating != null) ...[
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return Icon(
                  review.rating! >= starValue
                      ? Icons.star_rounded
                      : review.rating! >= starValue - 0.5
                          ? Icons.star_half_rounded
                          : Icons.star_border_rounded,
                  size: 20,
                  color: Colors.amber,
                );
              }),
            ),
            const SizedBox(height: 8),
          ],

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
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
}

/// Widget to display rating summary
class RatingSummaryWidget extends StatelessWidget {
  final double averageRating;
  final int totalRatings;
  final Map<int, int>? ratingDistribution; // star -> count

  const RatingSummaryWidget({
    super.key,
    required this.averageRating,
    required this.totalRatings,
    this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Average rating
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return Icon(
                      averageRating >= starValue
                          ? Icons.star_rounded
                          : averageRating >= starValue - 0.5
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded,
                      size: 20,
                      color: Colors.amber,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.current.total_ratings(totalRatings),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Rating distribution
          if (ratingDistribution != null) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                children: List.generate(5, (index) {
                  final star = 5 - index;
                  final count = ratingDistribution![star] ?? 0;
                  final percentage = totalRatings > 0
                      ? (count / totalRatings * 100).toInt()
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          '$star',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: colorScheme.surfaceContainerHigh,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
