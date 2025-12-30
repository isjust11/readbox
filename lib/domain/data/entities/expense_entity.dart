import 'base_entity.dart';

class ExpenseEntity extends BaseEntity {
  int? id;
  String? description;
  double? amount;
  DateTime? expenseDate;
  String? category;
  String? note;
  DateTime? createdAt;
  DateTime? updatedAt;

  ExpenseEntity({
    this.id,
    this.description,
    this.amount,
    this.expenseDate,
    this.category,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  ExpenseEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null);
    description = json['description'];
    amount = json['amount'] is double 
        ? json['amount'] 
        : (json['amount'] != null ? double.tryParse(json['amount'].toString()) : null);
    
    try {
      expenseDate = json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'].toString())
          : null;
    } catch (e) {
      expenseDate = null;
    }
    
    category = json['category'];
    note = json['note'];
    
    try {
      createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null;
    } catch (e) {
      createdAt = null;
    }
    
    try {
      updatedAt = json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null;
    } catch (e) {
      updatedAt = null;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['amount'] = amount;
    data['expenseDate'] = expenseDate?.toIso8601String().split('T')[0]; // Only date
    data['category'] = category;
    data['note'] = note;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}

