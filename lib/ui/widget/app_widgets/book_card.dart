import 'package:flutter/material.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/res/resources.dart';
import 'package:readbox/routes.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final UserInteractionCubit userInteractionCubit;
  const BookCard({super.key, required this.book, required this.userInteractionCubit});

  void _openPdfViewer(BuildContext context, BookModel book) {
    if (book.fileUrl != null) {
      Navigator.pushNamed(
        context,
        Routes.pdfViewerWithSelectionScreen,
        arguments: {
          'fileUrl': '${ApiConstant.apiHostStorage}${book.fileUrl}',
          'title': book.displayTitle,
          'bookId': book.id!,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File ebook không tồn tại'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showBookOptions(BuildContext context, BookModel book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),
                
                // Book info
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _getImageUrl(book.coverImageUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.book, color: Colors.grey);
                                },
                              ),
                            )
                          : Icon(Icons.book, color: Colors.grey),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            book.displayAuthor,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Action buttons
                _buildActionButton(
                  icon: Icons.menu_book_rounded,
                  label: 'Đọc sách',
                  color: Theme.of(context).primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    _openPdfViewer(context, book);
                  },
                ),
                
                SizedBox(height: 12),
                
                _buildActionButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Xem chi tiết',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.bookDetailScreen, arguments: book);
                  },
                ),
                
                SizedBox(height: 12),
                
                _buildActionButton(
                  icon: book.isFavorite == true 
                      ? Icons.favorite_rounded 
                      : Icons.favorite_border_rounded,
                  label: book.isFavorite == true 
                      ? 'Bỏ yêu thích' 
                      : 'Yêu thích',
                  color: Theme.of(context).colorScheme.error,
                  onTap: () async {
                    Navigator.pop(context);
                   await userInteractionCubit.toggleFavorite(targetType: 'book', targetId: book.id!);
                  },
                ),
                
                SizedBox(height: 12),
                
                _buildActionButton(
                  icon: Icons.close_rounded,
                  label: 'Đóng',
                  color: Colors.grey[700]!,
                  onTap: () => Navigator.pop(context),
                  isOutlined: true,
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    
    // Otherwise, it's from our backend
    return '${ApiConstant.apiHostStorage}$imagePath';
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: isOutlined 
              ? Border.all(color: Colors.grey[300]!, width: 1.5)
              : Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isOutlined 
                    ? Colors.grey[100]
                    : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isOutlined ? Colors.grey[700] : color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isOutlined ? Colors.grey[400] : color.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
        child: InkWell(
          onTap: () {
            // Tap thường: Đọc ebook trực tiếp
            _openPdfViewer(context, book);
          },
          onLongPress: () {
            // Long press: Hiển thị menu options
            _showBookOptions(context, book);
          },
          borderRadius: BorderRadius.circular(AppDimens.SIZE_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.SIZE_16)),
                        gradient: LinearGradient(
                          colors: [Theme.of(context).colorScheme.surface.withValues(alpha: 0.1), Theme.of(context).colorScheme.surface.withValues(alpha: 0.1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: book.coverImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.SIZE_16)),
                              child: Image.network(
                                _getImageUrl(book.coverImageUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.book, size: 48, 
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(Icons.book, size: 48, 
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                            ),
                    ),
                    // Favorite badge
                    if (book.isFavorite == true)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Book Info
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            book.displayAuthor,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Rating
                      Flexible(
                        child: Row(
                          children: [
                            if (book.rating != null && book.rating! > 0) ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                                    SizedBox(width: 4),
                                    Text(
                                      book.rating!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber[900],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Mới',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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