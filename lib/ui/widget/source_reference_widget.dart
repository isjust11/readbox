import 'package:flutter/material.dart';
import 'package:scale_size/scale_size.dart';
import 'package:readbox/domain/data/models/data_source_model.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/ui/widget/custom_text_label.dart';

class SourceReferenceWidget extends StatelessWidget {
  final DataSourceModel? dataSource;

  const SourceReferenceWidget({super.key, this.dataSource});

  @override
  Widget build(BuildContext context) {
    if (dataSource == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: AppDimens.SIZE_24),
      padding: EdgeInsets.all(AppDimens.SIZE_16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_12),
        border: Border.all(color: AppColors.lightDividingLine, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề
          Row(
            children: [
              Icon(Icons.source, size: 20.sw, color: AppColors.primaryBlue),
              SizedBox(width: AppDimens.SIZE_8),
              CustomTextLabel(
                'Nguồn tham khảo',
                fontSize: AppDimens.SIZE_18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ],
          ),

          SizedBox(height: AppDimens.SIZE_16),

          // Tên/Tiêu đề nguồn
          if (dataSource!.title != null && dataSource!.title!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.title,
              label: 'Tiêu đề',
              value: dataSource!.title!,
            ),

          if (dataSource!.name != null &&
              dataSource!.name!.isNotEmpty &&
              dataSource!.name != dataSource!.title)
            _buildInfoRow(
              icon: Icons.label,
              label: 'Tên nguồn',
              value: dataSource!.name!,
            ),

          // Tác giả
          if (dataSource!.author != null && dataSource!.author!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.person,
              label: 'Tác giả',
              value: dataSource!.author!,
            ),

          // Nhà xuất bản
          if (dataSource!.publisher != null &&
              dataSource!.publisher!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.business,
              label: 'Nhà xuất bản',
              value: dataSource!.publisher!,
            ),

          // Ngày xuất bản
          if (dataSource!.publishDate != null &&
              dataSource!.publishDate!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Ngày xuất bản',
              value: dataSource!.publishDate!,
            ),

          // Loại nguồn
          _buildInfoRow(
            icon: _getTypeIcon(dataSource!.type),
            label: 'Loại nguồn',
            value: _getTypeLabel(dataSource!.type),
          ),

          // URL
          if (dataSource!.url != null && dataSource!.url!.isNotEmpty)
            _buildClickableUrl(context, dataSource!.url!),

          // ISBN
          if (dataSource!.isbn != null && dataSource!.isbn!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.book,
              label: 'ISBN',
              value: dataSource!.isbn!,
            ),

          // DOI
          if (dataSource!.doi != null && dataSource!.doi!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.science,
              label: 'DOI',
              value: dataSource!.doi!,
            ),

          // Mô tả
          if (dataSource!.description != null &&
              dataSource!.description!.isNotEmpty) ...[
            SizedBox(height: AppDimens.SIZE_12),
            CustomTextLabel(
              dataSource!.description!,
              fontSize: AppDimens.SIZE_14,
              color: AppColors.textMediumGrey,
              maxLines: 10,
            ),
          ],

          // Ghi chú
          if (dataSource!.notes != null && dataSource!.notes!.isNotEmpty) ...[
            SizedBox(height: AppDimens.SIZE_12),
            Container(
              padding: EdgeInsets.all(AppDimens.SIZE_12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimens.SIZE_8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16.sw, color: AppColors.primaryBrand),
                  SizedBox(width: AppDimens.SIZE_8),
                  Expanded(
                    child: CustomTextLabel(
                      dataSource!.notes!,
                      fontSize: AppDimens.SIZE_13,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.SIZE_12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sw, color: AppColors.textMediumGrey),
          SizedBox(width: AppDimens.SIZE_8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  label,
                  fontSize: AppDimens.SIZE_12,
                  color: AppColors.textMediumGrey,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: AppDimens.SIZE_4),
                CustomTextLabel(
                  value,
                  fontSize: AppDimens.SIZE_14,
                  color: AppColors.textDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableUrl(BuildContext context, String url) {
    return _buildInfoRow(icon: Icons.link, label: 'Liên kết', value: url);
  }

  IconData _getTypeIcon(DataSourceType type) {
    switch (type) {
      case DataSourceType.website:
        return Icons.language;
      case DataSourceType.ebook:
        return Icons.menu_book;
      case DataSourceType.book:
        return Icons.menu_book;
      case DataSourceType.journal:
        return Icons.article;
      case DataSourceType.researchPaper:
        return Icons.description;
      case DataSourceType.interview:
        return Icons.mic;
      case DataSourceType.document:
        return Icons.description;
      case DataSourceType.other:
        return Icons.source;
    }
  }

  String _getTypeLabel(DataSourceType type) {
    switch (type) {
      case DataSourceType.website:
        return 'Website';
      case DataSourceType.ebook:
        return 'Sách điện tử';
      case DataSourceType.book:
        return 'Sách';
      case DataSourceType.journal:
        return 'Tạp chí';
      case DataSourceType.researchPaper:
        return 'Bài nghiên cứu';
      case DataSourceType.interview:
        return 'Phỏng vấn';
      case DataSourceType.document:
        return 'Tài liệu';
      case DataSourceType.other:
        return 'Khác';
    }
  }
}
