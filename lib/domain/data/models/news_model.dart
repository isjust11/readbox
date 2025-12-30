import 'package:readbox/domain/data/entities/entities.dart';

class NewsModel extends NewsEntity {
  NewsModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  // Helper methods
  String get displayTitle => title ?? 'Untitled';
  String get displayAuthor => author ?? 'Unknown Author';
  String get displayCategory => category ?? 'Uncategorized';
  
  String get publishedDateFormatted {
    if (createdAt == null) return 'Unknown date';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }
  
  String get tagsDisplay {
    if (tags == null || tags!.isEmpty) return 'No tags';
    return tags!.join(', ');
  }
  
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}

