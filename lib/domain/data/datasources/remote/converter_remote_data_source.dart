import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:readbox/domain/network/network.dart';

class ConverterRemoteDataSource {
  final Network network;

  ConverterRemoteDataSource({required this.network});

  /// Convert Word document to PDF
  /// Returns the PDF file bytes
  Future<List<int>> convertWordToPdf({
    required File file,
    Function(double)? onProgress,
  }) async {
    final fileName = file.path.split(RegExp(r'[/\\]')).last;

    // Validate file extension
    final extension = fileName.toLowerCase().split('.').last;

    // Determine contentType based on file extension
    final MediaType contentType =
        extension == 'docx'
            ? MediaType(
              'application',
              'vnd.openxmlformats-officedocument.wordprocessingml.document',
            )
            : MediaType('application', 'msword');
    // Create FormData with file
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: contentType,
      ),
    });

    final response = await network.postWithFormData(
      url: '${ApiConstant.apiHost}${ApiConstant.converterWordToPdf}',
      formData: formData,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.isSuccess) {
      return response.data as List<int>;
    }
    return Future.error(response.errMessage);
  }
}
