import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
// import 'package:readbox/gen/i18n/generated_locales/l10n.dart'; 
import 'package:readbox/res/res.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/widget.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Map<String, int> interactionCounts = {};
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Load subscription data
    context.read<UserSubscriptionCubit>().loadMe();

    // Load interaction stats
    context.read<UserInteractionCubit>().getMyInteractionCounts().then((value) {
      setState(() {
        interactionCounts = value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: AppLocalizations.current.usage_statistics,
      body: BlocBuilder<UserSubscriptionCubit, BaseState>(
        builder: (context, state) {
          if (state is LoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message ?? AppLocalizations.current.error_loading_data,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<UserSubscriptionCubit>().loadMe();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.current.retry),
                  ),
                ],
              ),
            );
          }

          if (state is LoadedState<UserSubscriptionModel>) {
            final subscription = state.data;
            return FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(context, subscription),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserSubscriptionModel subscription) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<UserSubscriptionCubit>().loadMe();
        final counts = await context.read<UserInteractionCubit>().getMyInteractionCounts();
        if (mounted) {
          setState(() {
            interactionCounts = counts;
          });
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimens.SIZE_16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Card
            _buildCurrentPlanCard(context, subscription, theme, colorScheme),
            const SizedBox(height: AppDimens.SIZE_24),

            // Usage Statistics Title
            Text(
              AppLocalizations.current.usage_in_current_period,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimens.SIZE_16),

            // Storage Usage
            _buildStorageUsageCard(context, subscription, theme, colorScheme),
            const SizedBox(height: AppDimens.SIZE_16),

            // TTS Usage
            _buildTTSUsageCard(context, subscription, theme, colorScheme),
            const SizedBox(height: AppDimens.SIZE_16),

            // Convert Usage
            _buildConvertUsageCard(context, subscription, theme, colorScheme),
            const SizedBox(height: AppDimens.SIZE_24),

            // Activity Statistics
            if (interactionCounts.isNotEmpty) ...[
              Text(
                AppLocalizations.current.activity_statistics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimens.SIZE_16),
              _buildActivityGrid(context, theme, colorScheme),
              const SizedBox(height: AppDimens.SIZE_24),
            ],

            // Period Info
            _buildPeriodInfo(context, subscription, theme, colorScheme),
            const SizedBox(height: AppDimens.SIZE_24),

            // Upgrade Button (if free plan)
            if (subscription.isFree) ...[
              _buildUpgradeButton(context, theme, colorScheme),
              const SizedBox(height: AppDimens.SIZE_16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
    BuildContext context,
    UserSubscriptionModel subscription,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final plan = subscription.plan;
    final isFree = subscription.isFree;

    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFree
              ? [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainer,
                ]
              : [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: (isFree ? colorScheme.shadow : colorScheme.primary)
                .withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_12),
                decoration: BoxDecoration(
                  color: isFree
                      ? colorScheme.surface
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                ),
                child: Icon(
                  isFree ? Icons.workspace_premium_outlined : Icons.star_rounded,
                  color: isFree ? colorScheme.primary : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppDimens.SIZE_16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    AppLocalizations.current.currentPlan,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isFree
                            ? colorScheme.onSurface.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan?.name ?? AppLocalizations.current.freePlan,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isFree ? colorScheme.onSurface : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFree)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.SIZE_12,
                    vertical: AppDimens.SIZE_6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
                  ),
                  child: Text(
                    AppLocalizations.current.pro,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (plan?.description != null) ...[
            const SizedBox(height: AppDimens.SIZE_12),
            Text(
              plan!.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isFree
                    ? colorScheme.onSurface.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
          if (!isFree && subscription.priceDisplay.isNotEmpty) ...[
            const SizedBox(height: AppDimens.SIZE_12),
            Text(
              subscription.priceDisplay,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStorageUsageCard(
    BuildContext context,
    UserSubscriptionModel subscription,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final plan = subscription.plan;
    final used = subscription.storageUsedBytes;
    final limit = plan?.storageLimitBytes ?? 0;
    final percentage = limit > 0 ? (used / limit * 100).clamp(0.0, 100.0) : 0.0;
    final isUnlimited = limit == 0 || limit >= 1099511627776; // 1TB

    return _buildUsageCard(
      context: context,
      theme: theme,
      colorScheme: colorScheme,
      icon: Icons.storage_rounded,
      iconColor: Colors.blue,
      title: AppLocalizations.current.storage_usage,
      used: _formatBytes(used),
      limit: isUnlimited ? 'Unlimited' : _formatBytes(limit),
      percentage: percentage,
      isUnlimited: isUnlimited,
    );
  }

  Widget _buildTTSUsageCard(
    BuildContext context,
    UserSubscriptionModel subscription,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final plan = subscription.plan;
    final used = interactionCounts['tts'] ?? subscription.ttsUsedInPeriod;
    final limit = plan?.ttsLimitPerPeriod ?? 0;
    final percentage = limit > 0 ? (used / limit * 100).clamp(0.0, 100.0) : 0.0;
    final isUnlimited = limit == 0 || limit >= 999999;

    return _buildUsageCard(
      context: context,
      theme: theme,
      colorScheme: colorScheme,
      icon: Icons.record_voice_over_rounded,
      iconColor: Colors.green,
      title: AppLocalizations.current.tts_usage,
      used: '$used',
      limit: isUnlimited ? 'Unlimited' : '$limit',
      percentage: percentage,
      isUnlimited: isUnlimited,
      unit: AppLocalizations.current.times,
    );
  }

  Widget _buildConvertUsageCard(
    BuildContext context,
    UserSubscriptionModel subscription,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final plan = subscription.plan;
    final used = interactionCounts['convert'] ?? subscription.convertUsedInPeriod;
    final limit = plan?.convertLimitPerPeriod ?? 0;
    final percentage = limit > 0 ? (used / limit * 100).clamp(0.0, 100.0) : 0.0;
    final isUnlimited = limit == 0 || limit >= 999999;

    return _buildUsageCard(
      context: context,
      theme: theme,
      colorScheme: colorScheme,
      icon: Icons.transform_rounded,
      iconColor: Colors.orange,
      title: AppLocalizations.current.convert_usage,
      used: '$used',
      limit: isUnlimited ? 'Unlimited' : '$limit',
      percentage: percentage,
      isUnlimited: isUnlimited,
      unit: AppLocalizations.current.times,
    );
  }

  Widget _buildUsageCard({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String used,
    required String limit,
    required double percentage,
    required bool isUnlimited,
    String? unit,
  }) {
    final isNearLimit = percentage >= 80 && !isUnlimited;
    final isOverLimit = percentage >= 100 && !isUnlimited;

    Color getProgressColor() {
      if (isOverLimit) return Colors.red;
      if (isNearLimit) return Colors.orange;
      return iconColor;
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimens.SIZE_10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppDimens.SIZE_12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (isOverLimit)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.SIZE_8,
                    vertical: AppDimens.SIZE_4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.SIZE_6),
                  ),
                  child: Text(
                    AppLocalizations.current.over_limit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          
          // Usage text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$used ${unit ?? ''}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '/ $limit ${unit ?? ''}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_12),
          
          // Progress bar
          if (!isUnlimited) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
              ),
            ),
            const SizedBox(height: AppDimens.SIZE_8),
            Text(
              '${percentage.toStringAsFixed(1)}% ${AppLocalizations.current.used}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_12,
                vertical: AppDimens.SIZE_8,
              ),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.all_inclusive,
                    size: 16,
                    color: iconColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.current.unlimited,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodInfo(
    BuildContext context,
    UserSubscriptionModel subscription,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final daysRemaining = subscription.expiresAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining <= 7 && daysRemaining > 0;

    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_16),
      decoration: BoxDecoration(
        color: isExpiringSoon
            ? Colors.orange.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        border: isExpiringSoon
            ? Border.all(color: Colors.orange.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpiringSoon ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
                color: isExpiringSoon ? Colors.orange : colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.current.subscription_period,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.SIZE_12),
          _buildPeriodRow(
            context,
            AppLocalizations.current.started_at,
            _formatDate(subscription.startedAt),
            theme,
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildPeriodRow(
            context,
            AppLocalizations.current.expires_at,
            _formatDate(subscription.expiresAt),
            theme,
            colorScheme,
          ),
          const SizedBox(height: 8),
          _buildPeriodRow(
            context,
            AppLocalizations.current.days_remaining,
            daysRemaining > 0 ? '$daysRemaining ${AppLocalizations.current.days}' : AppLocalizations.current.expired,
            theme,
            colorScheme,
            isHighlight: isExpiringSoon,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(
    BuildContext context,
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.orange : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityGrid(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.current;
    final items = <_StatItem>[
      _StatItem(l10n.reading_count, interactionCounts['reading'] ?? 0, Icons.auto_stories_rounded, Colors.indigo),
      _StatItem(l10n.download_count, interactionCounts['download'] ?? 0, Icons.download_rounded, Colors.teal),
      _StatItem(l10n.bookmark_count, interactionCounts['bookmark'] ?? 0, Icons.bookmark_rounded, Colors.amber.shade700),
      _StatItem(l10n.favorite_count, interactionCounts['favorite'] ?? 0, Icons.favorite_rounded, Colors.red),
      _StatItem(l10n.share_count, interactionCounts['share'] ?? 0, Icons.share_rounded, Colors.blue),
      _StatItem(l10n.rating_count, interactionCounts['rating'] ?? 0, Icons.star_rounded, Colors.orange),
      _StatItem(l10n.archived_count, interactionCounts['archived'] ?? 0, Icons.archive_rounded, Colors.brown),
    ];

    final total = interactionCounts.values.fold<int>(0, (sum, v) => sum + v);

    return Column(
      children: [
        // Total count banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.SIZE_20,
            vertical: AppDimens.SIZE_16,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: colorScheme.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: AppDimens.SIZE_12),
              Expanded(
                child: Text(
                  l10n.total_interactions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Text(
                '$total',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.SIZE_12),
        // Grid of stats
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildStatTile(theme, colorScheme, item);
          },
        ),
      ],
    );
  }

  Widget _buildStatTile(ThemeData theme, ColorScheme colorScheme, _StatItem item) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.SIZE_12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(width: AppDimens.SIZE_10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.count}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.SIZE_20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppDimens.SIZE_12),
          Text(
            AppLocalizations.current.upgrade_to_premium,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.current.unlock_unlimited_features,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.SIZE_16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.subscriptionPlanScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.SIZE_32,
                vertical: AppDimens.SIZE_12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
              ),
            ),
            child: Text(
              AppLocalizations.current.view_plans,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;

    if (bytes >= gb) {
      return '${(bytes / gb).toStringAsFixed(2)} GB';
    } else if (bytes >= mb) {
      return '${(bytes / mb).toStringAsFixed(1)} MB';
    } else if (bytes >= kb) {
      return '${(bytes / kb).toStringAsFixed(0)} KB';
    } else {
      return '$bytes B';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatItem(this.label, this.count, this.icon, this.color);
}
