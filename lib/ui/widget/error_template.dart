import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/widget.dart';

class ErrorTemplate extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const ErrorTemplate({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomTextLabel(
          message ?? AppLocalizations.current.error_common,
          color: AppColors.errorRed,
          fontSize: AppDimens.SIZE_14,
        ),
        const SizedBox(height: AppDimens.SIZE_8),
        ElevatedButton(
          onPressed: () {
            onRetry();
          },
          child: CustomTextLabel(AppLocalizations.current.retry),
        ),
      ],
    );
  }
}
