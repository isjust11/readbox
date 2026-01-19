import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/res/enum.dart';

class GetBookListUseCase {
  final BookRepository repository;

  GetBookListUseCase(this.repository);

  Future<List<BookModel>> call({
    FilterType? filterType,
    String? searchQuery,
    int? page,
    int? limit,
    String? categoryId,
    bool isDiscover = false,
  }) async {
    return await repository.getPublicBooks(
      filterType: filterType,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
      categoryId: categoryId,
      isDiscover: isDiscover,
    );
  }
}

