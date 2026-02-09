import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readbox/gen/assets.gen.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/res/app_size.dart';
import 'package:readbox/res/dimens.dart';
import 'package:readbox/ui/widget/widget.dart';

class RatingDialog extends StatefulWidget {
  final double? initialRating;
  final String? initialComment;
  final Function(double rating, String comment) onSubmit;

  const RatingDialog({
    super.key,
    this.initialRating,
    this.initialComment,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRating = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController.text = widget.initialComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _rating = 0;
    _commentController.clear();
    setState(() {
      _isSubmitting = false;
      _isRating = false;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }


    if (_rating == 0) {
      setState(() {
        _isRating = true;
      });
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_rating, _commentController.text.trim());

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.show(
          context,
          message: AppLocalizations.current.rating_submitted_successfully,
        );
      }
      resetForm();
    } catch (e) {
      setState(() => _isSubmitting = false);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: '${AppLocalizations.current.rating_submission_failed}: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.SIZE_12,
            horizontal: AppDimens.SIZE_24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.current.rate_and_review,
                        style: TextStyle(
                          fontSize: AppSize.fontSizeXXLarge,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.SIZE_12),

                // Rating title
                Text(
                  AppLocalizations.current.your_rating,
                  style: TextStyle(
                    fontSize: AppSize.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppDimens.SIZE_12),

                // Star rating
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return GestureDetector(
                          onTap:
                              _isSubmitting
                                  ? null
                                  : () {
                                    setState(() {
                                      _rating = starValue.toDouble();
                                    });
                                  },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SvgPicture.asset(
                              Assets.icons.icStar,
                              width: AppDimens.SIZE_32,
                              height: AppDimens.SIZE_32,
                              colorFilter: ColorFilter.mode(
                                _isRating && _rating == 0
                                    ? theme.colorScheme.error
                                    : _rating >= starValue
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                // Rating value display
                if (_rating > 0) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${_rating.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(
                        fontSize: AppSize.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppLocalizations.current.tap_to_rate,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: AppDimens.SIZE_12),

                // Comment title
                Text(
                  AppLocalizations.current.write_a_review,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppDimens.SIZE_8),

                // Comment text field
                CustomTextInput(
                  textController: _commentController,
                  title: AppLocalizations.current.write_your_review_here,
                  hintText: AppLocalizations.current.write_your_review_here,
                  isRequired: true,
                  maxLines: 3,
                  minLines: 3,
                  maxLength: 500,
                  validator:
                      (value) =>
                          value.isEmpty || value.length < 10
                              ? AppLocalizations.current.please_enter_review
                              : null,
                ),
                SizedBox(height: AppDimens.SIZE_12),
                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppDimens.SIZE_12),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                          : Text(AppLocalizations.current.submit_rating, style: TextStyle(fontSize: AppSize.fontSizeLarge, fontWeight: FontWeight.bold, color: colorScheme.onPrimary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
