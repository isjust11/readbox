import 'package:readbox/domain/data/entities/entities.dart';

class BookmarkModel extends BookmarkEntity {
  BookmarkModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  String get displayTitle => title ?? 'Bookmark';
  String get displayNote => note ?? '';
  String get displayText => highlightedText ?? '';
  
  String get createdAtFormatted {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 7) {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

