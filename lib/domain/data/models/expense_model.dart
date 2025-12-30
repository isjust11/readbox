import 'package:readbox/domain/data/entities/entities.dart';
import 'package:intl/intl.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  // Helper methods
  String get displayDescription => description ?? 'No description';
  String get displayCategory => category ?? 'Uncategorized';
  String get displayAmount {
    if (amount == null) return '0 đ';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }
  
  String get expenseDateFormatted {
    if (expenseDate == null) return 'Unknown date';
    return DateFormat('dd/MM/yyyy').format(expenseDate!);
  }
  
  String get expenseDateShort {
    if (expenseDate == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(expenseDate!);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM').format(expenseDate!);
    }
  }
  
  bool get hasNote => note != null && note!.isNotEmpty;
}

