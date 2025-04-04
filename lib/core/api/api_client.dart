import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl:
          'https://redjuniors.mooo.com/', //'http://54.206.49.166/', //'http://donation_backend.test/', //'http://16.176.19.197/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('Making request to: ${options.baseUrl}${options.path}');
          print('Query parameters: ${options.queryParameters}');

          // Add auth token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Using auth token: $token');
          } else {
            print('No auth token found');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response from: ${response.requestOptions.uri}');
          print('Status code: ${response.statusCode}');
          print('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Error making request to: ${e.requestOptions.uri}');
          print('Error type: ${e.type}');
          print('Error message: ${e.message}');
          print('Error response: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            print('Unauthorized: ${e.response?.data?['message']}');
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Clean up query parameters - remove null values
      final cleanParams = queryParameters?.entries
          .where((e) => e.value != null)
          .fold<Map<String, dynamic>>({}, (map, entry) {
        map[entry.key] = entry.value;
        return map;
      });

      final fullPath = path.startsWith('/') ? path.substring(1) : path;

      print('URL: ${_dio.options.baseUrl}$fullPath');
      print('Query parameters: $cleanParams');

      return await _dio.get(
        fullPath,
        queryParameters: cleanParams,
        options: options,
      );
    } on DioException catch (e) {
      print('GET request failed: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
      print('Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in GET request: $e');
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timeout');
      case DioExceptionType.badResponse:
        return ApiException(
          error.response?.statusCode ?? 500,
          error.response?.data?['message'] ?? 'Unknown error occurred',
        );
      case DioExceptionType.cancel:
        return RequestCancelledException();
      default:
        return NetworkException('Network error occurred');
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class RequestCancelledException implements Exception {
  @override
  String toString() => 'RequestCancelledException: Request was cancelled';
}
