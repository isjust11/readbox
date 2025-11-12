import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/models/models.dart';

class AddBookUseCase {
  final BookRepository repository;

  AddBookUseCase(this.repository);

  Future<BookModel> call(BookModel book) async {
    return await repository.addBook(book);
  }
}

