import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart'
    show AppLocalizations;
import 'package:readbox/res/colors.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class CustomSnackBar<T extends Cubit<BaseState>> extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;

  const CustomSnackBar({super.key, this.fontSize, this.textColor});

  @override
  Widget build(BuildContext context) {
    return BlocListener<T, BaseState>(
      child: Container(),
      listener: (context, state) {
        String? mess;
        if (state is LoadedState) {
          mess = state.data?.message ?? AppLocalizations.current.success;
        } else if (state is ErrorState) {
          mess = "Error";
        } else if (state is LoadingState) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(_buildSnackBar(context, state, mess ?? ''));
      },
    );
  }

  SnackBar _buildSnackBar(BuildContext context, BaseState state, String mess) {
    final bool isSuccess = state is LoadedState;

    return SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppDimens.SIZE_8,
          horizontal: AppDimens.SIZE_4,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSuccess
                ? [
                    AppColors.primaryBlue.withValues(alpha: 0.7),
                    AppColors.primaryBlue.withValues(alpha: 0.5),
                    AppColors.primaryBlue.withValues(alpha: 0.3),
                  ]
                : [
                    AppColors.errorRed.withValues(alpha: 0.7),
                    AppColors.errorRed.withValues(alpha: 0.5),
                    AppColors.errorRed.withValues(alpha: 0.3),
                  ],
          ),
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          boxShadow: [
            BoxShadow(
              color: (isSuccess ? AppColors.primaryBlue : AppColors.errorRed)
                  .withValues(alpha: 0.3),
              blurRadius: AppDimens.SIZE_8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSuccess
                    ? AppColors.primaryBlue.withValues(alpha: 0.2)
                    : AppColors.errorRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimens.SIZE_12),
            Expanded(
              child: CustomTextLabel(
                mess,
                fontSize: fontSize ?? AppDimens.SIZE_14,
                color: textColor ?? AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppDimens.SIZE_20),
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: const Duration(milliseconds: 1400),
    );
  }
}
