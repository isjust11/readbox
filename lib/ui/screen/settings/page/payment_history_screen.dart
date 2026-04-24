import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/payment/payment_cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/widget.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = GetIt.I<PaymentCubit>();
    _paymentCubit.getPaymentHistory();
  }

  @override
  void dispose() {
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentCubit,
      child: BaseScreen<PaymentCubit>(
        title: AppLocalizations.current.payment_history,
        emptyIcon: Assets.icons.walletEmpty,
        emptyMessage: AppLocalizations.current.no_payment_history,
        body: BlocBuilder<PaymentCubit, BaseState>(
          builder: (context, state) {
            if (state is LoadedState<List<PaymentHistoryModel>>) {
              final payments = state.data;

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.SIZE_16),
                itemCount: payments.length,
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: AppDimens.SIZE_12),
                itemBuilder: (context, index) {
                  final payment = payments[index];
                  return _buildPaymentItem(payment);
                },
              );
            }

            if (state is ErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppDimens.SIZE_16),
                    Text(
                      state.message ?? AppLocalizations.current.error,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: AppDimens.SIZE_16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PaymentCubit>().getPaymentHistory();
                      },
                      child: Text(AppLocalizations.current.retry),
                    ),
                  ],
                ),
              );
            }

            // Trả về SizedBox rỗng khi đang loading vì BaseScreen đã có overlay loading
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildPaymentItem(PaymentHistoryModel payment) {
    final isSuccess =
        payment.status?.name.toLowerCase() == 'completed' ||
        payment.status?.name.toLowerCase() == 'success';
    final amountText = NumberFormat.currency(
      locale: 'vi',
      symbol: 'VND',
    ).format(payment.amount ?? 0);
    final dateText =
        payment.createdAt != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt!)
            : 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.SIZE_16,
        vertical: AppDimens.SIZE_8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.SIZE_8),
                margin: const EdgeInsets.all(AppDimens.SIZE_4),
                decoration: BoxDecoration(
                  color:
                      isSuccess
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: PaymentIconWidget(paymentMethod: payment.paymentMethod),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.SIZE_4),
                  decoration: BoxDecoration(
                    color:
                        isSuccess
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.pending,
                    color: isSuccess ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.SIZE_16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.description ??
                      payment.transactionId?.toString() ??
                      AppLocalizations.current.service_package,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: AppDimens.SIZE_4),
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppDimens.SIZE_4),
              Text(
                payment.status?.name.toUpperCase() ?? 'UNKNOWN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSuccess ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
