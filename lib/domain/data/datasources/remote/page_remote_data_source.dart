import 'package:readbox/domain/network/network.dart';
import 'package:readbox/domain/data/models/models.dart';

class PageRemoteDataSource {
  final Network network;

  PageRemoteDataSource({required this.network});

  Future<PageModel> getPageBySlug(String slug) async {
    ApiResponse apiResponse = await network.get(
      url: '${ApiConstant.apiHost}${ApiConstant.getPage}/slug/$slug',
    );
    if (apiResponse.isSuccess) {
      return PageModel.fromJson(apiResponse.data);
    }
    return Future.error(apiResponse.errMessage);
  }
}
