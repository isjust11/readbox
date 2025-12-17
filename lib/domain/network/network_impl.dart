import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:readbox/utils/shared_preference.dart';

class Network {
  static const int DEFAULT_TIMEOUT = 15000;
  static BaseOptions options =
      BaseOptions(connectTimeout: DEFAULT_TIMEOUT, receiveTimeout: DEFAULT_TIMEOUT, baseUrl: ApiConstant.apiHost);
  static final Dio _dio = Dio(options);

  Network._internal() {
    // Bypass SSL certificate validation in debug mode only
    if (kDebugMode) {

      _dio.interceptors.add(LogInterceptor(responseBody: true, requestHeader: true));
    }
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions myOption, RequestInterceptorHandler handler) async {
      String token = await SharedPreferenceUtil.getToken();
      if (token.isNotEmpty) {
        myOption.headers["Authorization"] = "Bearer $token";
      }
      return handler.next(myOption);
    }));
  }

  static Network instance() {
    return Network._internal();
  }

  Dio get dio => _dio;

  Future<ApiResponse> get({required String url, Map<String, dynamic>? params}) async {
    try {
      Response response = await _dio.get(
        url,
        queryParameters: BaseParamRequest.request(params),
        options: Options(responseType: ResponseType.json),
      );
      return getApiResponse(response);
    } on DioError catch (e) {
      //handle error
      print("DioError: ${e.toString()}");
      return getError(e);
    }
  }

  Future<ApiResponse> post(
      {required String url,
      Map<String, dynamic>? body,
      Map<String, dynamic> params = const {},
      String contentType = Headers.jsonContentType}) async {
    try {
      Response response = await _dio.post(
        url,
        data: body,
        options: Options(responseType: ResponseType.json, contentType: contentType),
      );
      return getApiResponse(response);
    } catch (e) {
      print("===post =====${e}");
      return getError(e as DioError);
    }
  }
  Future<ApiResponse> postWithFormData(
      {required String url,
      FormData? formData,
      Map<String, dynamic> params = const {},
      String contentType = Headers.jsonContentType}) async {
    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(responseType: ResponseType.json, contentType: contentType),
      );
      return getApiResponse(response);
    } catch (e) {
      print("===postWithFormData =====${e}");
      return getError(e as DioError);
    }
  }

  ApiResponse getError(DioError e) {
    if (e.response?.statusCode == 401) {
      handleTokenExpired();
    }
    switch (e.type) {
      case DioErrorType.cancel:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.other:
        return ApiResponse.error(
          AppLocalizations.current.error_connection
        );
      default:
        return ApiResponse.error(e.message, data: getDataReplace(e.response?.data), code: e.response?.statusCode);
    }
  }

  ApiResponse getApiResponse(Response response) {
    return ApiResponse.success(
        data: response.data,
        code: response.statusCode,
        status: response.statusCode,
        errMessage: response.statusMessage ?? '');
  }

  void handleTokenExpired() async {
    NavigationService.instance.showDialogTokenExpired();
  }

  getDataReplace(data) {
    if (data is String) {
      return data.replaceAll("loi:", "").replaceAll(":loi", "").trim();
    }
    return data;
  }
}
