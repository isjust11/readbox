import 'package:readbox/domain/repositories/repositories.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<bool> call(String id) async {
    return await repository.deleteExpense(id);
  }
}

