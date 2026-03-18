import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/domain/network/network_impl.dart';

class AiRepository {
  final Network _network = Network.instance();

  /// Tra cứu / giải thích từ hoặc khái niệm bằng Gemini AI
  Future<String> lookup({
    required String query,
    String language = 'vi',
  }) async {
    final response = await _network.post(
      url: ApiConstant.aiLookup,
      body: {'query': query, 'language': language},
    );
    if (response.status == 200 || response.status == 201) {
      final data = response.data;
      if (data is Map && data['status'] == true) {
        return data['data']?.toString() ?? '';
      }
      return data?['message']?.toString() ?? 'Không có kết quả';
    }
    throw Exception(response.errMessage.isNotEmpty ? response.errMessage : 'Lỗi khi tra cứu');
  }

  /// Dịch văn bản sang ngôn ngữ đích bằng Gemini AI
  Future<String> translate({
    required String text,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    final body = <String, dynamic>{
      'text': text,
      'targetLanguage': targetLanguage,
    };
    if (sourceLanguage != null) {
      body['sourceLanguage'] = sourceLanguage;
    }
    final response = await _network.post(
      url: ApiConstant.aiTranslate,
      body: body,
    );
    if (response.status == 200 || response.status == 201) {
      final data = response.data;
      if (data is Map && data['status'] == true) {
        return data['data']?.toString() ?? '';
      }
      return data?['message']?.toString() ?? 'Không có kết quả';
    }
    throw Exception(response.errMessage.isNotEmpty ? response.errMessage : 'Lỗi khi dịch thuật');
  }
}
