import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<ExpenseModel> call(ExpenseModel expense) async {
    return await repository.updateExpense(expense);
  }
}

