import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/injection_container.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/base_screen.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class PaymentResultScreen extends StatefulWidget {
  final String status; // success, failed, error
  final String? message;
  final String transactionId;

  const PaymentResultScreen({
    super.key,
    required this.status,
    this.message,
    required this.transactionId,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  bool _isVerifying = true;
  String? _verifiedStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.status == 'success') {
      _verifyPaymentStatus();
    } else {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _verifyPaymentStatus() async {
    try {
      final paymentRepo = getIt.get<PaymentRepository>();
      final result = await paymentRepo.getPaymentStatus(widget.transactionId);
      
      setState(() {
        _verifiedStatus = result.status;
        _isVerifying = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: AppLocalizations.current.paymentResult,
      hideAppBar: true,
      colorBg: Theme.of(context).colorScheme.surface,
      body: _isVerifying
          ? const Center(child: CircularProgressIndicator())
          : _buildResultContent(),
    );
  }

  Widget _buildResultContent() {
    final bool isSuccess = widget.status == 'success' && 
                          (_verifiedStatus == 'completed' || _verifiedStatus == null);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.SIZE_24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: AppDimens.SIZE_100,
              height: AppDimens.SIZE_100,
              decoration: BoxDecoration(
                color: isSuccess
                    ? AppColors.successGreen.withValues(alpha: 0.1)
                    : AppColors.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                size: AppDimens.SIZE_60,
                color: isSuccess ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: AppDimens.SIZE_24),

            // Title
            CustomTextLabel(
              isSuccess
                  ? AppLocalizations.current.paymentSuccess
                  : AppLocalizations.current.paymentFailed,
              fontSize: AppDimens.SIZE_24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.colorTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.SIZE_12),

            // Message
            if (widget.message != null || _errorMessage != null)
              CustomTextLabel(
                widget.message ?? _errorMessage ?? '',
                fontSize: AppDimens.SIZE_14,
                color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textMediumGrey,
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
            const SizedBox(height: AppDimens.SIZE_8),

            // Transaction ID
            CustomTextLabel(
              '${AppLocalizations.current.transactionId}: ${widget.transactionId}',
              fontSize: AppDimens.SIZE_12,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textMediumGrey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.SIZE_40),

            // Buttons
            if (isSuccess) ...[
              FilledButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.SIZE_48,
                    vertical: AppDimens.SIZE_16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                  ),
                ),
                child: Text(AppLocalizations.current.backToHome),
              ),
            ] else ...[
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.SIZE_48,
                    vertical: AppDimens.SIZE_16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
                  ),
                ),
                child: Text(AppLocalizations.current.tryAgain),
              ),
              const SizedBox(height: AppDimens.SIZE_12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(AppLocalizations.current.backToHome),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
