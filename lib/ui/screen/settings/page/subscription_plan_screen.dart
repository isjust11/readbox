import 'package:flutter/material.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';
import 'package:readbox/ui/screen/settings/page/payment_webview_screen.dart';
import 'package:readbox/ui/screen/settings/page/payment_result_screen.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  late Future<List<SubscriptionPlanModel>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = getIt.get<SubscriptionRepository>().getPlans(activeOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: AppLocalizations.current.subscriptionPlans,
      colorTitle: Theme.of(context).colorScheme.onSurface,
      colorBg: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _plansFuture = getIt.get<SubscriptionRepository>().getPlans(activeOnly: true);
          });
        },
        child: FutureBuilder<List<SubscriptionPlanModel>>(
          future: _plansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimens.SIZE_24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildError(context, snapshot.error.toString());
            }
            final plans = snapshot.data ?? [];
            if (plans.isEmpty) {
              return _buildEmpty(context);
            }
            return _buildPlanList(context, plans);
          },
        ),
      ),
    );
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
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _plansFuture = getIt.get<SubscriptionRepository>().getPlans(activeOnly: true);
                });
              },
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimens.SIZE_16),
            CustomTextLabel(
              AppLocalizations.current.noSubscriptionPlans,
              fontSize: AppDimens.SIZE_16,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.colorTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(BuildContext context, List<SubscriptionPlanModel> plans) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_16,
        vertical: AppDimens.SIZE_20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextLabel(
            AppLocalizations.current.choosePlanDescription,
            fontSize: AppDimens.SIZE_14,
            color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textMediumGrey,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          const SizedBox(height: AppDimens.SIZE_24),
          ...plans.map((plan) => _PlanCard(
                plan: plan,
                onSelect: () => _onSelectPlan(context, plan),
              )),
        ],
      ),
    );
  }

  void _onSelectPlan(BuildContext context, SubscriptionPlanModel plan) async {
    // Nếu là gói miễn phí, kích hoạt trực tiếp
    if (plan.isFree) {
      _showMessage(context, 'Kích hoạt gói miễn phí thành công');
      return;
    }

    // Hiển thị dialog chọn phương thức thanh toán
    final paymentMethod = await _showPaymentMethodDialog(context);
    if (paymentMethod == null) return;

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Gọi API tạo payment
      final paymentRepo = getIt.get<PaymentRepository>();
      final payment = await paymentRepo.createPayment(
        planId: plan.id,
        paymentMethod: paymentMethod,
      );

      // Đóng loading
      if (context.mounted) Navigator.of(context).pop();

      // Mở WebView thanh toán
      if (context.mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: payment.paymentUrl,
              transactionId: payment.transactionId,
            ),
          ),
        );

        // Xử lý kết quả callback
        if (result != null && context.mounted) {
          _handlePaymentResult(context, result);
        }
      }
    } catch (e) {
      // Đóng loading
      if (context.mounted) Navigator.of(context).pop();
      _showMessage(context, 'Lỗi: ${e.toString()}', isError: true);
    }
  }

  Future<String?> _showPaymentMethodDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.current.selectPaymentMethod),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('VNPay'),
              subtitle: const Text('Thanh toán qua ngân hàng'),
              onTap: () => Navigator.of(context).pop('vnpay'),
            ),
            ListTile(
              leading: const Icon(Icons.wallet),
              title: const Text('MoMo'),
              subtitle: const Text('Ví điện tử MoMo'),
              onTap: () => Navigator.of(context).pop('momo'),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('ZaloPay'),
              subtitle: const Text('Ví điện tử ZaloPay'),
              onTap: () => Navigator.of(context).pop('zalopay'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.current.cancel),
          ),
        ],
      ),
    );
  }

  void _handlePaymentResult(BuildContext context, dynamic result) {
    final status = result['status'] as String?;
    final message = result['message'] as String?;
    final transactionId = result['transactionId'] as String?;

    if (status == 'success') {
      // Chuyển sang màn kết quả thành công
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            status: status!,
            message: message,
            transactionId: transactionId!,
          ),
        ),
      );
    } else {
      // Hiển thị lỗi
      _showMessage(
        context,
        message ?? AppLocalizations.current.paymentFailed,
        isError: true,
      );
    }
  }

  void _showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final VoidCallback onSelect;

  const _PlanCard({required this.plan, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isPopular = plan.code == 'advanced' || plan.code == 'ultra';
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.SIZE_16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        border: isPopular
            ? Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: AppDimens.SIZE_12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.SIZE_20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.SIZE_12,
                        vertical: AppDimens.SIZE_6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppDimens.SIZE_20),
                      ),
                      child: CustomTextLabel(
                        plan.name,
                        fontSize: AppDimens.SIZE_16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: AppDimens.SIZE_8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.SIZE_8,
                          vertical: AppDimens.SIZE_4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBrand.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                        ),
                        child: CustomTextLabel(
                          AppLocalizations.current.popular,
                          fontSize: AppDimens.SIZE_12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBrand,
                        ),
                      ),
                    ],
                  ],
                ),
                if (plan.description != null && plan.description!.isNotEmpty) ...[
                  const SizedBox(height: AppDimens.SIZE_12),
                  CustomTextLabel(
                    plan.description!,
                    fontSize: AppDimens.SIZE_14,
                    color: theme.textTheme.bodyMedium?.color ?? AppColors.textMediumGrey,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: AppDimens.SIZE_16),
                _FeatureRow(
                  icon: Icons.storage_rounded,
                  label: AppLocalizations.current.storageLimit,
                  value: plan.storageDisplay,
                ),
                if (plan.ttsLimitPerPeriod > 0)
                  _FeatureRow(
                    icon: Icons.record_voice_over_rounded,
                    label: AppLocalizations.current.ttsLimit,
                    value: '${plan.ttsLimitPerPeriod} ${AppLocalizations.current.perPeriod}',
                  ),
                if (plan.convertLimitPerPeriod > 0)
                  _FeatureRow(
                    icon: Icons.picture_as_pdf_rounded,
                    label: AppLocalizations.current.convertLimit,
                    value: '${plan.convertLimitPerPeriod} ${AppLocalizations.current.perPeriod}',
                  ),
                const SizedBox(height: AppDimens.SIZE_20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (plan.isFree)
                      CustomTextLabel(
                        AppLocalizations.current.free,
                        fontSize: AppDimens.SIZE_20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      )
                    else
                      CustomTextLabel(
                        plan.priceDisplay,
                        fontSize: AppDimens.SIZE_18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    FilledButton(
                      onPressed: onSelect,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.SIZE_24,
                          vertical: AppDimens.SIZE_12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                        ),
                      ),
                      child: Text(
                        plan.isFree
                            ? AppLocalizations.current.useFree
                            : AppLocalizations.current.selectPlan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.SIZE_8),
      child: Row(
        children: [
          Icon(icon, size: AppDimens.SIZE_18, color: theme.colorScheme.primary),
          const SizedBox(width: AppDimens.SIZE_10),
          Expanded(
            child: CustomTextLabel(
              label,
              fontSize: AppDimens.SIZE_14,
              color: theme.textTheme.bodyMedium?.color ?? AppColors.textMediumGrey,
            ),
          ),
          CustomTextLabel(
            value,
            fontSize: AppDimens.SIZE_14,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color ?? AppColors.colorTitle,
          ),
        ],
      ),
    );
  }
}
