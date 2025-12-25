import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class AddNewsUseCase {
  final NewsRepository repository;

  AddNewsUseCase(this.repository);

  Future<NewsModel> call(NewsModel news) async {
    return await repository.createNews(news);
  }
}

