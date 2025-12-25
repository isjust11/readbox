import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class UpdateNewsUseCase {
  final NewsRepository repository;

  UpdateNewsUseCase(this.repository);

  Future<NewsModel> call(NewsModel news) async {
    return await repository.updateNews(news);
  }
}

