import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:readbox/domain/network/network.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/services/secure_storage_service.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:readbox/utils/shared_preference.dart';

class Network {
  static const int DEFAULT_TIMEOUT = 15000;
  static BaseOptions options =
      BaseOptions(connectTimeout: DEFAULT_TIMEOUT, receiveTimeout: DEFAULT_TIMEOUT, baseUrl: ApiConstant.apiHost);
  static final Dio _dio = Dio(options);
  static final SecureStorageService _secureStorage = SecureStorageService();
    static bool _isRefreshing = false;
  static final List<RequestOptions> _requestQueue = [];
  static Completer<bool>? _refreshCompleter;
  Network._internal() {
    // Bypass SSL certificate validation in debug mode only
    if (kDebugMode) {

      _dio.interceptors.add(LogInterceptor(responseBody: true, requestHeader: true));
    }
    _dio.interceptors
        .add(InterceptorsWrapper(
          onRequest: (RequestOptions myOption, RequestInterceptorHandler handler) async {
      // Lấy token từ secure storage
      String? token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        myOption.headers["Authorization"] = "Bearer $token";
        print("===token =====");
        debugPrint(token);
      }
      return handler.next(myOption);
    }, onError: (DioError error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == 401) {
            // Nếu đang refresh token, thêm request vào queue và chờ
            if (_isRefreshing) {
              _requestQueue.add(error.requestOptions);
              // Chờ refresh token hoàn thành
              final bool refreshSuccess =
                  await _refreshCompleter?.future ?? false;
              if (refreshSuccess) {
                // Retry request với token mới
                try {
                  final String? newToken = await _secureStorage.getToken();
                  if (newToken == null || newToken.isEmpty) {
                    _forceLogout();
                    return handler.next(error);
                  }
                  error.requestOptions.headers["Authorization"] =
                      "Bearer $newToken";

                  final Dio retryDio = Dio(options);
                  final Response response = await retryDio.fetch(
                    error.requestOptions,
                  );
                  return handler.resolve(response);
                } catch (retryError) {
                  if (kDebugMode) {
                    print('Retry request failed: $retryError');
                  }
                  return handler.next(error);
                }
              } else {
                return handler.next(error);
              }
            }

            // Bắt đầu refresh token
            final bool refreshSuccess = await _refreshToken();

            if (refreshSuccess) {
              // Retry request gốc với token mới
              try {
                final String? newToken =
                    await _secureStorage.getToken();
                error.requestOptions.headers["Authorization"] =
                    "Bearer $newToken";
                if (newToken == null || newToken.isEmpty) {
                  _forceLogout();
                  return handler.next(error);
                }
                final Dio retryDio = Dio(options);
                final Response response = await retryDio.fetch(
                  error.requestOptions,
                );
                return handler.resolve(response);
              } catch (retryError) {
                if (kDebugMode) {
                  print('Retry request failed: $retryError');
                }
                return handler.next(error);
              }
            } else {
              // Refresh thất bại, logout
              _forceLogout();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
    
    ));
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
      String contentType = Headers.jsonContentType,
      Options? options,
      }) async {
    try {
      Response response = await _dio.post(
        url,
        data: formData,
        options: options ?? Options(responseType: ResponseType.bytes, contentType: contentType),
      );
      return getApiResponse(response);
    } catch (e) {
      return getError(e as DioError);
    }
  }

  Future<ApiResponse> put({required String url, Map<String, dynamic>? body}) async {
    try {
      Response response = await _dio.put(url, data: body, options: Options(responseType: ResponseType.json));
      return getApiResponse(response);
    } catch (e) {
      return getError(e as DioError);
    }
  }

  Future<ApiResponse> patch({required String url, Map<String, dynamic>? body}) async {
    try {
      Response response = await _dio.patch(url, data: body, options: Options(responseType: ResponseType.json));
      return getApiResponse(response);
    } catch (e) {
      return getError(e as DioError);
    }
  }

  Future<ApiResponse> delete({required String url, Map<String, dynamic>? body}) async {
    try {
      Response response = await _dio.delete(url, data: body, options: Options(responseType: ResponseType.json));
      return getApiResponse(response);
    } catch (e) {
      return getError(e as DioError);
    }
  }

  ApiResponse getError(DioError e) {
    if (e.response?.statusCode == 401) {
      // handleTokenExpired();
    }
    switch (e.type) {
      case DioErrorType.cancel:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return ApiResponse.error(
          AppLocalizations.current.error_connection
        );
      case DioErrorType.other:
        return ApiResponse.error(
          AppLocalizations.current.error_common
        );
      case DioErrorType.response:
        return ApiResponse.error(e.response?.data['message'] ?? '', data: getDataReplace(e.response?.data), code: e.response?.statusCode);
      }
  }

  ApiResponse getApiResponse(Response response) {
    return ApiResponse.success(
        data: response.data,
        code: response.statusCode,
        status: response.statusCode,
        errMessage: response.statusMessage ?? '');
  }

  // void handleTokenExpired() async {
  //   NavigationService.instance.showDialog(
  //     title: AppLocalizations.current.error,
  //     message: AppLocalizations.current.error_connection,
  //     onPressed: () {
  //       NavigationService.instance.pop();ß
  //     },
  //   );
  // }

   Future<bool> _refreshToken() async {
    if (_isRefreshing) {
      // Nếu đang refresh, chờ kết quả
      return await _refreshCompleter?.future ?? false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final String? refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _forceLogout();
        _refreshCompleter!.complete(false);
        return false;
      }

      // Sử dụng một Dio riêng không có interceptor để tránh vòng lặp 401
      final Dio refreshDio = Dio(options);
      final Response response = await refreshDio.post(
        ApiConstant.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data;
      final String newAccessToken = data['accessToken'] ?? '';
      final String newRefreshToken = data['refreshToken'] ?? '';
      if (newAccessToken.isEmpty || newRefreshToken.isEmpty) {
        _forceLogout();
        _refreshCompleter!.complete(false);
        return false;
      }

      await _secureStorage.saveToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);

      // Xử lý queue requests - không cần await vì đây là background task
      _processRequestQueue();

      _refreshCompleter!.complete(true);
      return true;
    } catch (err) {
      if (kDebugMode) {
        print('Refresh token failed: $err');
      }
      _forceLogout();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<void> _processRequestQueue() async {
    final List<RequestOptions> queue = List.from(_requestQueue);
    _requestQueue.clear();

    for (final requestOptions in queue) {
      try {
        final String? newToken = await _secureStorage.getToken();
        if (newToken == null || newToken.isEmpty) {
          _forceLogout();
          return;
        }
        requestOptions.headers["Authorization"] = "Bearer $newToken";

        // Sử dụng Dio instance chính với interceptor để đảm bảo xử lý đúng
        await _dio.fetch(requestOptions);

        if (kDebugMode) {
          print('Request retry successful for: ${requestOptions.path}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Retry request failed for ${requestOptions.path}: $e');
        }
      }
    }
  }

   Future<void> _forceLogout() async {
    await SharedPreferenceUtil.clearData();
    NavigationService.instance.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);
  }

  getDataReplace(data) {
    if (data is String) {
      return data.replaceAll("loi:", "").replaceAll(":loi", "").trim();
    }
    return data;
  }
}
