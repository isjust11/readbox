import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class GetBookListUseCase {
  final BookRepository repository;

  GetBookListUseCase(this.repository);

  Future<List<BookModel>> call({
    bool? isFavorite,
    bool? isArchived,
    String? searchQuery,
  }) async {
    return await repository.getAllBooks(
      isFavorite: isFavorite,
      isArchived: isArchived,
      searchQuery: searchQuery,
    );
  }
}

