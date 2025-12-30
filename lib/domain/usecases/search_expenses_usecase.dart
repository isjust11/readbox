import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class SearchExpensesUseCase {
  final ExpenseRepository repository;

  SearchExpensesUseCase(this.repository);

  Future<List<ExpenseModel>> call(String query) async {
    return await repository.getExpensesList(searchQuery: query);
  }
}

