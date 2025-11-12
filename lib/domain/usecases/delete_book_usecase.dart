import 'package:readbox/domain/repositories/repositories.dart';

class DeleteBookUseCase {
  final BookRepository repository;

  DeleteBookUseCase(this.repository);

  Future<bool> call(String bookId) async {
    return await repository.deleteBook(bookId);
  }
}

