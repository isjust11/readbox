import 'package:readbox/domain/repositories/repositories.dart';

class DeleteNewsUseCase {
  final NewsRepository repository;

  DeleteNewsUseCase(this.repository);

  Future<bool> call(String newsId) async {
    return await repository.deleteNews(newsId);
  }
}

