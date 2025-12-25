import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class GetNewsListUseCase {
  final NewsRepository repository;

  GetNewsListUseCase(this.repository);

  Future<List<NewsModel>> call({
    String? category,
    bool? isPublished,
    bool? isFeatured,
    String? searchQuery,
  }) async {
    return await repository.getNewsList(
      category: category,
      isPublished: isPublished,
      isFeatured: isFeatured,
      searchQuery: searchQuery,
    );
  }
}

