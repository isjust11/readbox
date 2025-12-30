import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<ExpenseModel> call(ExpenseModel expense) async {
    return await repository.createExpense(expense);
  }
}

