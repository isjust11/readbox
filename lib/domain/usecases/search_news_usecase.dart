import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class SearchNewsUseCase {
  final NewsRepository repository;

  SearchNewsUseCase(this.repository);

  Future<List<NewsModel>> call(String query) async {
    if (query.isEmpty) {
      return await repository.getNewsList();
    }
    return await repository.getNewsList(searchQuery: query);
  }
}

