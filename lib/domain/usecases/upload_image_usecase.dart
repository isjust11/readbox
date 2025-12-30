import 'dart:io';

import 'package:readbox/domain/repositories/repositories.dart';

class UploadImageUseCase {
  final NewsRepository repository;

  UploadImageUseCase(this.repository);

  Future<dynamic> call(File file) async {
    return await repository.uploadImage(file);
  }
}


