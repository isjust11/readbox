import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/enums/payment_method.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/res/enum.dart';
import 'package:readbox/ui/screen/settings/page/payment_webview_screen.dart';
import 'package:readbox/ui/screen/settings/page/payment_result_screen.dart';
import 'package:readbox/ui/widget/widget.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:readbox/routes.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  int _selectedIndex = 0;
  bool _didInitSelectedIndex = false; // đã set index theo current plan chưa
  int _selectedDurationMonths = 1; // 1, 3, 6, 12
  Offerings? _offerings;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.45, initialPage: 0);
    _fetchOfferings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (mounted) {
        setState(() {
          _offerings = offerings;
        });
      }
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
    }
  }

  Package? _getPackageForPlan(SubscriptionPlanModel plan) {
    if (_offerings == null || _offerings!.current == null || plan.isFree) {
      return null;
    }
    final currentOffering = _offerings!.current!;

    final code = plan.code.toUpperCase();
    if (plan.periodType == 'lifetime' || code.contains('LIFETIME')) {
      return currentOffering.lifetime;
    } else if (plan.periodType == 'year' || code.contains('YEAR')) {
      return currentOffering.annual;
    } else if (plan.periodType == 'month' ||
        code.contains('MONTH') ||
        code.contains('PRO')) {
      return currentOffering.monthly;
    }
    return null;
  }

  String _getPriceDisplay(SubscriptionPlanModel plan) {
    if (Platform.isIOS) {
      final package = _getPackageForPlan(plan);
      if (package != null) {
        return package.storeProduct.priceString;
      }
    }
    return plan.priceDisplay;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              getIt.get<SubscriptionPlanCubit>()..loadPlans(activeOnly: true),
      child: BlocConsumer<SubscriptionPlanCubit, BaseState>(
        listener: (context, state) {
          if (state is LoadedState<UserSubscriptionModel>) {
            _showMessage(
              context,
              AppLocalizations.current.activationFreePlanSuccess,
            );
            context.read<SubscriptionPlanCubit>().loadPlans(activeOnly: true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [
                            const Color(0xFF2B1055),
                            const Color(0xFF1B1B2F),
                          ] // Deep premium colors
                          : [
                            const Color(0xFFFDE4FF),
                            const Color(0xFFE6EBFB),
                          ], // Vibrant light colors
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        context.read<SubscriptionPlanCubit>().loadPlans(
                          activeOnly: true,
                        );
                      },
                      child: _buildBodyByState(context, state),
                    ),
                    // Custom Back Button
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 24),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBodyByState(BuildContext context, BaseState state) {
    if (state is LoadingState || state is InitState) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimens.SIZE_24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state is ErrorState) {
      return _buildError(context, state.data.toString());
    }
    if (state is LoadedState<List<SubscriptionPlanModel>>) {
      final plans = state.data;
      if (plans.isEmpty) return _buildEmpty(context);
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: _buildPlanList(context, plans),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.SIZE_24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppDimens.SIZE_48,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            CustomTextLabel(
              message,
              fontSize: AppDimens.SIZE_14,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.colorTitle,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            FilledButton.icon(
              onPressed:
                  () => context.read<SubscriptionPlanCubit>().loadPlans(
                    activeOnly: true,
                  ),
              icon: const Icon(Icons.refresh, size: AppDimens.SIZE_20),
              label: Text(AppLocalizations.current.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.SIZE_24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership_outlined,
              size: AppDimens.SIZE_60,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            CustomTextLabel(
              AppLocalizations.current.noSubscriptionPlans,
              fontSize: AppDimens.SIZE_16,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ??
                  AppColors.colorTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(
    BuildContext context,
    List<SubscriptionPlanModel> plans,
  ) {
    final userSub = context.watch<UserSubscriptionCubit>().userSubscription;
    final theme = Theme.of(context);
    // Set tab đang chọn = current plan lần đầu tiên
    if (!_didInitSelectedIndex && userSub?.plan?.id != null) {
      final idx = plans.indexWhere((p) => p.id == userSub!.plan!.id);
      if (idx != -1) {
        _selectedIndex = idx;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(idx);
          }
        });
      }
      _didInitSelectedIndex = true;
    }
    if (_selectedIndex >= plans.length) _selectedIndex = 0;
    final selectedPlan = plans[_selectedIndex];
    final isCurrent = userSub?.plan?.id == selectedPlan.id;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Stacked app icon
                Text(
                  'Get Readbox Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.bodyLarge?.color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    AppLocalizations.current.choosePlanDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color:
                          theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.7,
                          ) ??
                          AppColors.textMediumGrey,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Testimonial / Value prop card
                _buildValuePropCard(context, selectedPlan),
                const SizedBox(height: 16),

                // Horizontal Plan Options
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  child: _buildPlanOptions(context, plans, userSub),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Bottom CTA & Footer
        _buildBottomCTA(context, selectedPlan, isCurrent),
      ],
    );
  }

  Widget _buildValuePropCard(BuildContext context, SubscriptionPlanModel plan) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildMiniFeature(
            AppLocalizations.current.storageLimit,
            _getStorageDisplayForDuration(plan),
            theme,
          ),
          _buildMiniFeature(
            AppLocalizations.current.ai_assistant,
            '${_getLimitForDuration(plan.convertLimitPerPeriod, plan)}',
            theme,
          ),
          _buildMiniFeature(
            AppLocalizations.current.textToSpeech,
            '${_getLimitForDuration(plan.ttsLimitPerPeriod, plan)}',
            theme,
          ),
          _buildMiniFeature(
            AppLocalizations.current.tools_word_to_pdf,
            '${_getLimitForDuration(plan.convertLimitPerPeriod, plan)}',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFeature(String title, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions(
    BuildContext context,
    List<SubscriptionPlanModel> plans,
    UserSubscriptionModel? userSub,
  ) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _pageController,
        itemCount: plans.length,
        onPageChanged: (i) {
          setState(() {
            _selectedIndex = i;
          });
          HapticFeedback.selectionClick();
        },
        clipBehavior: Clip.none,
        itemBuilder: (context, i) {
          final plan = plans[i];
          final isSelected = _selectedIndex == i;
          final theme = Theme.of(context);

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (i - (_pageController.page ?? 0)).toDouble();
              } else {
                value = (i - (_pageController.initialPage.toDouble()));
              }

              // Hiệu ứng "cuộn tròn" - scaling và rotation nhẹ
              final double scale = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
              final double opacity = (1 - (value.abs() * 0.4)).clamp(0.5, 1.0);
              final double rotation =
                  value * 0.2; // Chỗ này tạo hiệu ứng vòng cung

              return Transform(
                transform:
                    Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..scale(scale)
                      ..rotateY(rotation),
                alignment: Alignment.center,
                child: Opacity(opacity: opacity, child: child),
              );
            },
            child: _buildPlanItem(context, plan, i, isSelected, theme, plans),
          );
        },
      ),
    );
  }

  Widget _buildPlanItem(
    BuildContext context,
    SubscriptionPlanModel plan,
    int i,
    bool isSelected,
    ThemeData theme,
    List<SubscriptionPlanModel> plans,
  ) {
    final type = plan.periodType.toLowerCase();
    final code = plan.code.toUpperCase();

    String mainVal = '1';
    String unitVal = 'MONTH';
    bool isInfinity = false;

    if (type == 'month' || code.contains('MONTH')) {
      mainVal = '30';
      unitVal = 'DAYS';
    } else if (type == 'year' || code.contains('YEAR')) {
      mainVal = '12';
      unitVal = 'MONTHS';
    } else if (type == 'lifetime' || code.contains('LIFETIME')) {
      mainVal = '∞';
      unitVal = 'LIFETIME';
      isInfinity = true;
    } else if (plan.isFree) {
      mainVal = '0';
      unitVal = 'FREE';
    }

    final Color textColor =
        isSelected
            ? Colors.white
            : (theme.textTheme.bodyLarge?.color ?? Colors.black);

    final Decoration decoration =
        isSelected
            ? BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withAlpha(200)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            )
            : BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // ── Bóng không gian (ambient ground shadow) ──
        Positioned(
          bottom: -4,
          left: 18,
          right: 18,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 550),
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? theme.primaryColor.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.18),
                  blurRadius: isSelected ? 28 : 16,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
          ),
        ),

        // ── Card chính ──
        GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
            setState(() {
              _selectedIndex = i;
              _selectedDurationMonths = 1;
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: decoration,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isInfinity)
                        Icon(Icons.all_inclusive, size: 40, color: textColor)
                      else
                        plan.isFree
                            ? const SizedBox()
                            : Text(
                              mainVal,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                height: 1.1,
                              ),
                            ),
                      const SizedBox(height: 6),
                      plan.isFree
                          ? Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Text(
                              "FREE",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textColor.withValues(alpha: 0.9),
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                          : Text(
                            unitVal,
                            style: TextStyle(
                              fontSize: plan.isFree ? 24 : 12,
                              fontWeight: FontWeight.w800,
                              color: textColor.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                      const SizedBox(height: 16),
                      Text(
                        plan.isFree ? "" : _getPriceDisplay(plan),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -15,
                    right: -5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 26,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCTA(
    BuildContext context,
    SubscriptionPlanModel plan,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    final userSub = context.watch<UserSubscriptionCubit>().userSubscription;
    final hasPaidPlan = userSub?.plan != null && !(userSub!.plan!.isFree);
    final isFreePlan = plan.isFree;
    final isFreePlanVisible = isFreePlan && hasPaidPlan;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56, // Tall prominent button
            child:
                isCurrent
                    ? OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(
                        Icons.check_circle,
                        size: 20,
                        color: AppColors.successGreen,
                      ),
                      label: Text(
                        AppLocalizations.current.currentPlan,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: theme.primaryColor, width: 2),
                      ),
                    )
                    : FilledButton(
                      onPressed:
                          isFreePlanVisible
                              ? null
                              : () => _onSelectPlan(context, plan),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            theme.primaryColor, // The bright purple/blue
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        plan.isFree
                            ? AppLocalizations.current.useFree
                            : AppLocalizations.current.selectPlan,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
          ),
          const SizedBox(height: 20),
          // Footer Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Platform.isIOS) ...[
                _buildFooterLink(
                  context,
                  AppLocalizations.current.restore_purchases,
                  () {
                    context.read<SubscriptionPlanCubit>().restorePurchases();
                  },
                ),
                _buildDivider(theme),
              ],
              _buildFooterLink(
                context,
                AppLocalizations.current.terms_of_use,
                () {
                  Navigator.pushNamed(context, Routes.privacySecurityScreen);
                },
              ),
              _buildDivider(theme),
              _buildFooterLink(
                context,
                AppLocalizations.current.privacy_policy,
                () {
                  Navigator.pushNamed(context, Routes.privacySecurityScreen);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: theme.dividerColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  double _getDurationMultiplier(SubscriptionPlanModel plan) {
    final baseMonths = plan.periodType == 'year' ? 12 : 1;
    return _selectedDurationMonths / baseMonths;
  }

  String _getStorageDisplayForDuration(SubscriptionPlanModel plan) {
    // final multiplier = _getDurationMultiplier(plan);
    final totalBytes = (plan.storageLimitBytes).round();

    const int mb = 1024 * 1024;
    const int gb = 1024 * mb;

    if (totalBytes >= gb) {
      return '${(totalBytes / gb).toStringAsFixed(1)} GB';
    }
    if (totalBytes >= mb) {
      return '${(totalBytes / mb).round()} MB';
    }
    return '$totalBytes B';
  }

  int _getLimitForDuration(int baseLimit, SubscriptionPlanModel plan) {
    final multiplier = _getDurationMultiplier(plan);
    return (baseLimit * multiplier).round();
  }

  void _onSelectPlan(BuildContext context, SubscriptionPlanModel plan) async {
    if (plan.isFree) {
      await context.read<SubscriptionPlanCubit>().createSubscriptionPlan(
        plan.id!,
      );
      return;
    }

    if (Platform.isIOS) {
      final package = _getPackageForPlan(plan);

      if (package != null) {
        final purchaseParams = PurchaseParams.package(package);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final result = await Purchases.purchase(purchaseParams);
          if (context.mounted) Navigator.pop(context); // hide loading

          final isActive =
              result.customerInfo.entitlements.all.isNotEmpty &&
              result.customerInfo.entitlements.all.values.any(
                (e) => e.isActive,
              );

          if (isActive && context.mounted) {
            context.read<SubscriptionPlanCubit>().loadPlans(activeOnly: true);
            _showMessage(context, AppLocalizations.current.success);
          }
        } on PlatformException catch (e) {
          if (context.mounted) Navigator.pop(context); // hide loading
          final errorCode = PurchasesErrorHelper.getErrorCode(e);
          if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
            if (context.mounted) {
              _showMessage(
                context,
                e.message ?? 'Purchase failed',
                isError: true,
              );
            }
          }
        } catch (e) {
          if (context.mounted) Navigator.pop(context); // hide loading
          if (context.mounted) {
            _showMessage(
              context,
              'An unexpected error occurred.',
              isError: true,
            );
          }
        }
        return;
      }

      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const PaywallView()));
      // Lấy trạng thái mới nhất để refresh
      if (context.mounted) {
        // Refresh danh sách gói
        context.read<SubscriptionPlanCubit>().loadPlans(activeOnly: true);
        // QUAN TRỌNG: Refresh thông tin đăng ký của User để UI biết đã mua thành công
        context.read<UserSubscriptionCubit>().loadMe();
      }
      return;
    }

    final paymentMethod = await _showPaymentMethodDialog(context);
    if (paymentMethod == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final paymentRepo = getIt.get<PaymentRepository>();
      final payment = await paymentRepo.createPayment(
        planId: plan.id!,
        paymentMethod: paymentMethod,
        periodMonths: _selectedDurationMonths,
        discountPercentage:
            _selectedDurationMonths == 3
                ? 10
                : _selectedDurationMonths == 6
                ? 15
                : _selectedDurationMonths == 12
                ? 20
                : 0,
      );

      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (context) => PaymentWebViewScreen(
                  paymentUrl: payment.paymentUrl,
                  transactionId: payment.transactionId,
                ),
          ),
        );

        if (result != null && context.mounted) {
          _handlePaymentResult(context, result);
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      _showMessage(context, 'Lỗi: ${e.toString()}', isError: true);
    }
  }

  Future<String?> _showPaymentMethodDialog(BuildContext context) async {
    final theme = Theme.of(context);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.current.selectPaymentMethod,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentOption(
                    context,
                    paymentIcon: PaymentIconWidget(
                      paymentMethod: PaymentMethod.vnpay,
                    ),
                    title: AppLocalizations.current.paymentMethodVnpay,
                    subtitle:
                        AppLocalizations.current.paymentMethodVnpayDescription,
                    value: 'vnpay',
                    visible: false,
                  ),
                  _buildPaymentOption(
                    context,
                    paymentIcon: PaymentIconWidget(
                      paymentMethod: PaymentMethod.momo,
                    ),
                    title: AppLocalizations.current.paymentMethodMomo,
                    subtitle:
                        AppLocalizations.current.paymentMethodMomoDescription,
                    value: 'momo',
                    visible: false,
                  ),
                  _buildPaymentOption(
                    context,
                    paymentIcon: PaymentIconWidget(
                      paymentMethod: PaymentMethod.payos,
                    ),
                    title: AppLocalizations.current.paymentMethodPayos,
                    subtitle:
                        AppLocalizations.current.paymentMethodPayosDescription,
                    value: 'payos',
                    visible: true,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required Widget paymentIcon,
    required String title,
    required String subtitle,
    required String value,
    required bool? visible,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: paymentIcon,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        trailing:
            visible == true
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.textTheme.bodySmall?.color,
                )
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: () => visible == true ? Navigator.of(context).pop(value) : null,
      ),
    );
  }

  void _handlePaymentResult(BuildContext context, dynamic result) {
    final status = result['status'] as String?;
    final message = result['message'] as String?;
    final transactionId = result['transactionId'] as String?;

    if (status == 'PAID') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => PaymentResultScreen(
                status: status!,
                message: message,
                transactionId: transactionId!,
              ),
        ),
      );
    } else {
      _showMessage(
        context,
        message ?? AppLocalizations.current.paymentFailed,
        isError: true,
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    AppSnackBar.show(
      context,
      message: message,
      snackBarType: isError ? SnackBarType.error : SnackBarType.success,
    );
  }
}
