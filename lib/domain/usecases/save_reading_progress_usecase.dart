import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class SaveReadingProgressUseCase {
  final BookRepository repository;

  SaveReadingProgressUseCase(this.repository);

  Future<ReadingProgressModel> call(ReadingProgressModel progress) async {
    return await repository.saveReadingProgress(progress);
  }
}

