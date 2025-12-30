import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';

class GetExpenseListUseCase {
  final ExpenseRepository repository;

  GetExpenseListUseCase(this.repository);

  Future<List<ExpenseModel>> call({
    String? category,
    String? searchQuery,
  }) async {
    return await repository.getExpensesList(
      category: category,
      searchQuery: searchQuery,
    );
  }
}

