import 'package:readbox/domain/data/datasources/datasource.dart';
import 'package:readbox/domain/data/models/models.dart';

class PageRepository {
  final PageRemoteDataSource pageRemoteDataSource;

  PageRepository({required this.pageRemoteDataSource});

  Future<PageModel> getPageBySlug(String slug) async {
    return await pageRemoteDataSource.getPageBySlug(slug);
  }
}
