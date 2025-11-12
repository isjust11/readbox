import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class SearchBooksUseCase {
  final BookRepository repository;

  SearchBooksUseCase(this.repository);

  Future<List<BookModel>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getAllBooks();
    }
    return await repository.getAllBooks(searchQuery: query);
  }
}

