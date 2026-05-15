import 'package:readbox/domain/network/api_constant.dart';

class UrlBuilder {
  static String buildUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiConstant.apiHostStorage}$url';
  }
}