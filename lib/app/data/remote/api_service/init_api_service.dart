import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:path/path.dart' as path;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../ui/components/app_snackbar.dart';
import '../../config/encryption.dart';
import '../../config/env_config.dart';
import '../../config/logger.dart';
import '../../local/user_provider.dart';

part '../../../utils/api_extensions.dart';

/// Cancel token
CancelToken? cancelToken;

/// DIO interceptor to add the authentication token
InterceptorsWrapper addAuthToken({String authTokenHeader = 'authorization'}) =>
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        options.headers.addAll(<String, dynamic>{
          authTokenHeader: 'Bearer ${UserProvider.authToken}',
        });
        handler.next(options); //continue
      },
    );

/// Add cancel token to the request
InterceptorsWrapper onCancelToken() => InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    cancelToken = CancelToken();
    options.cancelToken = cancelToken;
    handler.next(options); //continue
  },
  onError: (DioException e, ErrorInterceptorHandler handler) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.badResponse:
        if (e.response?.data['status'] == 401) {
          UserProvider.onLogout();
          appSnackbar(
            message: 'Session expired! Please login again',
            snackbarState: SnackbarState.danger,
          );
          return;
        }
        return handler.next(e);
      case DioExceptionType.unknown:
        handler.next(e);
        break;
      case DioExceptionType.cancel:
        handler.reject(e);
        break;
      case DioExceptionType.badCertificate:
        handler.reject(e);
        break;
      case DioExceptionType.connectionError:
        handler.reject(e);
        break;
    }
  },
);

/// Dio interceptor to encrypt the request body
InterceptorsWrapper encryptBody() => InterceptorsWrapper(
  onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
    final String method = options.method.toUpperCase();

    if (options.headers['encrypt'] as bool) {
      switch (method) {
        case 'POST':
        case 'PUT':
        case 'PATCH':
          logW('encrypting $method method');
          if (options.data.runtimeType.toString() ==
              '_InternalLinkedHashMap<String, dynamic>') {
            logI('Data will be encrypted before sending request');
            options.data = <String, dynamic>{
              'data': AppEncryption.encrypt(
                  plainText: jsonEncode(options.data)),
            };
          } else {
            logI(
                'Skipping encryption for ${options.data.runtimeType} type');
          }

          break;
        default:
          logWTF('Skipping encryption for $method method');
          break;
      }
    }
    handler.next(options); //continue
  },
);

/// API service of the application. To use Get, POST, PUT and PATCH rest methods
class APIService {
  static final Dio _dio = Dio();

  /// Base URL of the API
  static String get _baseUrl => EnvConfig.baseUrl;

  /// Initialize the API service
  static void initializeAPIService({
    bool encryptData = false,
    String authHeader = 'authorization',
    String xAPIKeyHeader = 'x-api-key',
    String xAPIKeyValue = 'x-api-key',
  }) {
    _dio.options.headers.addAll(<String, dynamic>{
      xAPIKeyHeader: xAPIKeyValue,
    });
    /*if (UserProvider.isLoggedIn) {
      _dio.options.headers.addAll(<String, dynamic>{
        authHeader: UserProvider.authToken,
      });
    }*/
    _dio.interceptors.add(addAuthToken(authTokenHeader: authHeader));
    //Add interceptor for encryption layer
    if (encryptData) {
      logI('Data will be encrypted for POST / PUT / PATCH');
      _dio.interceptors.add(encryptBody());
    }
    if (kDebugMode) {
      //Add interceptor for console logs
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
      ));
    }

    _dio.interceptors.add(onCancelToken());
  }

  /// GET rest API call
  /// Used to get data from backend
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<T>?> get<T>({
    required String path,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.get<T>(
        (forcedBaseUrl ?? _baseUrl) + path,
        queryParameters: params,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// POST rest API call
  /// Used to send any data to server and get a response
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<T>?> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.post<T>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: data,
        queryParameters: params,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// POST rest API call
  /// Used to send any data to server and get a response
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<Map<String, dynamic>?>?> postFormData({
    required String path,
    FormData? data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.post<Map<String, dynamic>?>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: data,
        queryParameters: params,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// PUT rest API call
  /// Usually used to create new record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<T>?> put<T>({
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? params,
    bool encrypt = true,
    String? forcedBaseUrl,
    Map<String, dynamic>? headers,
  }) async =>
      _dio.put<T>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: data,
        queryParameters: params,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// PATCH rest API call
  /// Usually used to update any record
  ///
  /// Use [forcedBaseUrl] when want to use specific baseurl other
  /// than configured
  ///
  /// The updated data to be passed in [data]
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the body needs to be encrypted. Make sure the
  /// encryption keys in the backend matches with the one in frontend
  static Future<Response<T>?> patch<T>({
    required String path,
    FormData? data,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    String? forcedBaseUrl,
  }) async =>
      _dio.patch<T>(
        (forcedBaseUrl ?? _baseUrl) + path,
        data: data,
        queryParameters: params,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// DELETE rest API call
  /// Usually used to delete a record
  ///
  /// Use [forcedBaseUrl] when you want to use a specific base URL other
  /// than the configured one.
  ///
  /// [params] are query parameters
  ///
  /// [path] is the part of the path after the base URL
  ///
  /// set [encrypt] to true if the request needs to be encrypted.
  static Future<Response<T>?> delete<T>({
    required String path,
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    bool encrypt = true,
    Map<String, dynamic>? data,
    String? forcedBaseUrl,
  }) async =>
      _dio.delete<T>(
        (forcedBaseUrl ?? _baseUrl) + path,
        queryParameters: params,
        data: data,
        options: Options(
          headers: headers ??
              <String, dynamic>{
                'encrypt': encrypt,
              },
        ),
      );

  /// Upload file to the server. You will get the URL in the response if the
  /// [file] was uploaded successfully. Else you will get null in response.
  ///
  static Future<String?> uploadFile({
    required File file,
    required String folder,
  }) async {
    final MultipartFile multipartFile = MultipartFile.fromBytes(
      await file.readAsBytes(),
      contentType: http_parser.MediaType(
        'image',
        path.extension(file.path).replaceFirst('.', ''),
      ),
      filename: path.basename(file.path),
    );

    final FormData formData = FormData.fromMap(<String, dynamic>{
      'image': multipartFile,
    });

    final Response<Map<String, dynamic>?>? response = await APIService.post(
      path: 'uploader/$folder/image',
      data: formData,
      encrypt: false,
    );

    if (response?.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic>? data = response?.data;

    if (data != null)  {
      logE(data['file']);
      return data['file'] as String?;
    } else {
      return null;
    }
  }
}
