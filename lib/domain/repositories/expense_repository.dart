import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepository({required this.remoteDataSource});

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      return await remoteDataSource.createExpense(expense);
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<List<ExpenseModel>> getExpensesList({
    String? category,
    String? searchQuery,
  }) async {
    try {
      return await remoteDataSource.getExpensesList(
        category: category,
        searchQuery: searchQuery,
      );
    } catch (e) {
      throw Exception('Failed to get expenses list: $e');
    }
  }

  Future<ExpenseModel> getExpenseById(String id) async {
    try {
      return await remoteDataSource.getExpenseById(id);
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      return await remoteDataSource.updateExpense(expense);
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      return await remoteDataSource.deleteExpense(id);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
  
  Future<Map<String, dynamic>> getStatistics({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await remoteDataSource.getStatistics(
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}

