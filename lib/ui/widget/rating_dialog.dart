import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController.text = widget.initialComment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_rating == 0) {
      AppSnackBar.show(
        context,
        message: AppLocalizations.current.please_select_rating,
      );
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.SIZE_12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.SIZE_12, horizontal: AppDimens.SIZE_24),
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
                        child: Icon(
                          _rating >= starValue
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 48,
                          color:
                              _rating >= starValue
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Rating value display
              if (_rating > 0) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${_rating.toStringAsFixed(1)} / 5.0',
                    style: TextStyle(
                      fontSize: 18,
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

              const SizedBox(height: 24),

              // Comment title
              Text(
                AppLocalizations.current.write_a_review,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Comment text field
              TextField(
                controller: _commentController,
                enabled: !_isSubmitting,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: AppLocalizations.current.write_your_review_here,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
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
                            color: colorScheme.onPrimary,
                          ),
                        )
                        : Text(
                          AppLocalizations.current.submit_rating,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
