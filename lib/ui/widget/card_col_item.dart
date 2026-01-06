import 'package:flutter/material.dart';
import 'package:scale_size/scale_size.dart';
import 'package:readbox/res/colors.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/ui/widget/base_network_image.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class CardColItemWidget extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final String? thumbnail;
  final String? category;
  final String? createdAt;
  final String? summary;
  final String? estimatedTime;
  final String? difficulty;
  final int? views;
  final String? author;
  final bool? isLiked;
  final bool? isBookmarked;
  final Widget? actionButtons;
  final EdgeInsets? margin;

  const CardColItemWidget({
    super.key,
    required this.onTap,
    required this.title,
    this.thumbnail,
    this.createdAt,
    this.summary,
    this.actionButtons,
    this.margin,
    this.category,
    this.estimatedTime,
    this.difficulty,
    this.views,
    this.author,
    this.isLiked,
    this.isBookmarked,
  });

  @override
  State<CardColItemWidget> createState() => _CardColItemWidgetState();
}

class _CardColItemWidgetState extends State<CardColItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.sw),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.sw),
                topRight: Radius.circular(12.sw),
              ),
              child: BaseNetworkImage(
                height: 200.sw,
                width: double.infinity,
                url: "${ApiConstant.storageHost}/${widget.thumbnail}",
                fit: BoxFit.cover,
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(16.sw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  widget.category != null
                      ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.sw,
                            vertical: 4.sw,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.sw),
                          ),
                          child: CustomTextLabel(
                            widget.category,
                            fontSize: 10.sw,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox.shrink(),
                  SizedBox(height: 8.sw),
                  // Title
                  CustomTextLabel(
                    widget.title,
                    fontSize: 16.sw,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    maxLines: 2,
                  ),
                  SizedBox(height: 8.sw),
                  // Summary
                  CustomTextLabel(
                    widget.summary,
                    fontSize: 14.sw,
                    color: AppColors.textMediumGrey,
                    maxLines: 3,
                  ),
                  SizedBox(height: 12.sw),
                  // Meta info
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Wrap(
                          spacing: 16.sw,
                          runSpacing: 8.sw,
                          children: [
                            _buildMetaInfo(
                              Icons.schedule,
                              widget.estimatedTime ?? '',
                              AppColors.textMediumGrey,
                            ),
                            _buildMetaInfo(
                              Icons.trending_up,
                              widget.difficulty ?? '',
                              AppColors.textMediumGrey,
                            ),
                            _buildMetaInfo(
                              Icons.visibility,
                              widget.views?.toString() ?? '0',
                              AppColors.textMediumGrey,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.sw),
                      widget.actionButtons != null
                          ? widget.actionButtons!
                          : Container(),
                    ],
                  ),
                  SizedBox(height: 8.sw),
                  // Author
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14.sw,
                        color: AppColors.textMediumGrey,
                      ),
                      SizedBox(width: 4.sw),
                      CustomTextLabel(
                        widget.author ?? '',
                        fontSize: 12.sw,
                        color: AppColors.textMediumGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sw, color: color),
        SizedBox(width: 4.sw),
        Flexible(
          child: CustomTextLabel(text, fontSize: 12.sw, color: color),
        ),
      ],
    );
  }
}
