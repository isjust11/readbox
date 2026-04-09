import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
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
          return BaseScreen(
            title: AppLocalizations.current.subscriptionPlans,
            colorTitle: Theme.of(context).colorScheme.onSurface,
            colorBg: Theme.of(context).colorScheme.surfaceContainerLowest,
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<SubscriptionPlanCubit>().loadPlans(
                  activeOnly: true,
                );
              },
              child: _buildBodyByState(context, state),
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
      return _buildPlanList(context, plans);
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                // Header
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.current.choosePlanDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        theme.textTheme.bodyMedium?.color ??
                        AppColors.textMediumGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Plan selector tabs
                _buildPlanTabs(context, plans, userSub),
                const SizedBox(height: 24),

                // Selected plan detail card
                _buildPlanDetail(context, selectedPlan, isCurrent),
                const SizedBox(height: 12),

                // Restore Purchases for iOS
                if (Platform.isIOS)
                  Center(
                    child: TextButton(
                      onPressed:
                          () =>
                              context
                                  .read<SubscriptionPlanCubit>()
                                  .restorePurchases(),
                      child: Text(
                        AppLocalizations.current.restore_purchases,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Compliance Footer (Privacy & Terms)
                _buildComplianceFooter(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Bottom CTA
        _buildBottomCTA(context, selectedPlan, isCurrent),
      ],
    );
  }

  Widget _buildComplianceFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.current.subscription_disclosure,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink(
              context,
              AppLocalizations.current.privacy_policy,
              () => Navigator.pushNamed(context, Routes.privacySecurityScreen),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 1,
              height: 12,
              color: theme.dividerColor,
            ),
            _buildFooterLink(context, AppLocalizations.current.terms_of_use, () {
              // Giả sử có slug termsOfUse hoặc dùng chung privacySecurityScreen với logic khác
              // Ở đây dùng tạm privacySecurityScreen để demo
              Navigator.pushNamed(context, Routes.privacySecurityScreen);
            }),
          ],
        ),
      ],
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

  Widget _buildPlanTabs(
    BuildContext context,
    List<SubscriptionPlanModel> plans,
    UserSubscriptionModel? userSub,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(plans.length, (i) {
          final plan = plans[i];
          final isSelected = _selectedIndex == i;
          final isCurrent = userSub?.plan?.id == plan.id;

          return Expanded(
            child: GestureDetector(
              onTap:
                  () => setState(() {
                    _selectedIndex = i;
                    _selectedDurationMonths = 1;
                  }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.isFree
                                ? AppLocalizations.current.free
                                : '\$\$\$',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary.withValues(
                                        alpha: 0.7,
                                      )
                                      : (theme.textTheme.bodySmall?.color ??
                                          AppColors.textLightGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child:
                              isCurrent && plan.isFree
                                  ? Icon(
                                    Icons.workspace_premium_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  )
                                  : Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlanDetail(
    BuildContext context,
    SubscriptionPlanModel plan,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    final isPopular = plan.code == 'advanced' || plan.code == 'ultra';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            isPopular
                ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                : Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18.5),
                ),
              ),
              child: Text(
                AppLocalizations.current.popular,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Price
                if (plan.isFree)
                  Text(
                    AppLocalizations.current.free,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            _getFormattedPrice(plan),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (plan.description != null &&
                    plan.description!.isNotEmpty) ...[
                  Text(
                    plan.description!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),

                // Features
                _buildFeatureItem(
                  context,
                  Icons.cloud_outlined,
                  AppLocalizations.current.storageLimit,
                  _getStorageDisplayForDuration(plan),
                  false,
                  true,
                  !plan.isFree,
                ),
                _buildFeatureItem(
                  context,
                  Icons.auto_awesome_rounded,
                  AppLocalizations.current.ai_assistant,
                  '${_getLimitForDuration(plan.convertLimitPerPeriod, plan)} ${AppLocalizations.current.perPeriod}',
                  plan.isFree,
                  false,
                  !plan.isFree,
                ),

                _buildFeatureItem(
                  context,
                  Icons.record_voice_over_outlined,
                  AppLocalizations.current.ttsLimit,
                  '${_getLimitForDuration(plan.ttsLimitPerPeriod, plan)} ${AppLocalizations.current.perPeriod}',
                  plan.isFree,
                  false,
                  !plan.isFree,
                ),
                _buildFeatureItem(
                  context,
                  Icons.picture_as_pdf_outlined,
                  AppLocalizations.current.convertLimit,
                  '${_getLimitForDuration(plan.convertLimitPerPeriod, plan)} ${AppLocalizations.current.perPeriod}',
                  plan.isFree,
                  false,
                  !plan.isFree,
                ),

                _buildFeatureItem(
                  context,
                  Icons.download_outlined,
                  AppLocalizations.current.download_limit,
                  '${_getLimitForDuration(plan.downloadLimitPerPeriod, plan)} ${AppLocalizations.current.perPeriod}',
                  false,
                  plan.isFree ? true : false,
                  !plan.isFree,
                ),
                _buildFeatureItem(
                  context,
                  Icons.share_outlined,
                  AppLocalizations.current.share_limit,
                  '${_getLimitForDuration(plan.shareLimitPerPeriod, plan)} ${AppLocalizations.current.perPeriod}',
                  false,
                  false,
                  !plan.isFree,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool? requiredProPlan,
    bool? showValue,
    bool? isPro,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color:
                    theme.textTheme.bodyMedium?.color ??
                    AppColors.textMediumGrey,
                decoration:
                    requiredProPlan == true ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (showValue == true) ...[
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color ?? AppColors.colorTitle,
              ),
            ),
          ],
          if (isPro == true && showValue == false) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.all_inclusive, size: 16, color: Colors.orange),
            ),
          ],
        ],
      ),
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
        8,
        12,
        8,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
        ),
      ),
      child: SafeArea(
        top: false,
        child:
            isCurrent
                ? SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon:
                        plan.isFree
                            ? const Icon(
                              Icons.workspace_premium_rounded,
                              size: 20,
                              color: AppColors.successGreen,
                            )
                            : const Icon(
                              Icons.star,
                              size: 20,
                              color: Colors.orange,
                            ),
                    label: Text(
                      AppLocalizations.current.currentPlan,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.primaryColor,
                      side: BorderSide(color: theme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
                : SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        isFreePlanVisible
                            ? null
                            : () => _onSelectPlan(context, plan),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          isFreePlan
                              ? AppColors.successGreen
                              : theme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      plan.isFree
                          ? AppLocalizations.current.useFree
                          : AppLocalizations.current.selectPlan,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
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

  String _getFormattedPrice(SubscriptionPlanModel plan) {
    if (plan.price == null || plan.price! <= 0) return '';
    return '\$\$\$';
  }

  void _onSelectPlan(BuildContext context, SubscriptionPlanModel plan) async {
    if (plan.isFree) {
      await context.read<SubscriptionPlanCubit>().createSubscriptionPlan(
        plan.id!,
      );
      return;
    }

    if (Platform.isIOS) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const PaywallView()));
      // Lấy trạng thái mới nhất để refresh
      if (context.mounted) {
        context.read<SubscriptionPlanCubit>().loadPlans(activeOnly: true);
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
