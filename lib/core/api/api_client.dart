import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late String _baseUrl;
  late final Duration _timeout;
  late final Map<String, String> _defaultHeaders;
  static bool _useLocalhost = true;

  // Allow switching between localhost and production server
  static void useLocalhost(bool value) {
    _useLocalhost = value;
    _instance._updateBaseUrl();
  }

  factory ApiClient() {
    return _instance;
  }

  void _updateBaseUrl() {
    _baseUrl = _useLocalhost
        ? 'http://donation_backend.test/'
        : 'https://redjuniors.mooo.com/';

    if (kDebugMode) {
      print('ApiClient baseUrl updated to: $_baseUrl');
    }
  }

  ApiClient._internal() {
    // Default to production URL unless explicitly set to use localhost
    _baseUrl = kDebugMode && _useLocalhost
        ? 'http://donation_backend.test/'
        : 'https://redjuniors.mooo.com/';
    _timeout = const Duration(seconds: 30);
    _defaultHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Log instance creation in debug mode
    if (kDebugMode) {
      print('ApiClient initialized with baseUrl: $_baseUrl');
    }
  }

  // Helper method to add auth token to headers
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);

    // Add auth token if available
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        print('Using auth token: $token');
      }
    } else {
      if (kDebugMode) {
        print('No auth token found');
      }
    }

    return headers;
  }

  // Helper for logging requests in debug mode
  void _logRequest(String method, String url, Map<String, dynamic>? queryParams) {
    if (kDebugMode) {
      print('Making $method request to: $url');
      if (queryParams != null) {
        print('Query parameters: $queryParams');
      }
    }
  }

  // Helper for logging responses in debug mode
  void _logResponse(http.Response response) {
    if (kDebugMode) {
      print('Received response from: ${response.request?.url}');
      print('Status code: ${response.statusCode}');
      print('Response data: ${response.body}');
    }
  }

  // Convert HTTP response to Dio-like Response format
  Response<T> _convertResponse<T>(http.Response response, T? data) {
    return Response<T>(
      data: data,
      statusCode: response.statusCode,
      requestOptions: RequestOptions(
        path: response.request?.url.path ?? '',
        uri: response.request?.url,
      ),
      headers: {
        for (var entry in response.headers.entries) entry.key: entry.value,
      },
    );
  }

  // Generic request handler
  Future<Response<T>> _handleRequest<T>(
    Future<http.Response> Function() requestFunc,
    String method,
    String url,
    Map<String, dynamic>? queryParams,
  ) async {
    try {
      _logRequest(method, url, queryParams);

      final response = await requestFunc().timeout(_timeout);
      _logResponse(response);

      // Handle CORS errors - typically shown in preflight responses
      if (response.statusCode == 0) {
        if (kDebugMode) {
          print('CORS error detected - status code 0. This usually means the server is not allowing cross-origin requests.');
        }
        throw NetworkException('CORS error: Server is not allowing cross-origin requests. Status code: 0');
      }

      // Check for error status codes
      if (response.statusCode >= 400) {
        throw _createApiException(response);
      }

      // Parse JSON response
      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          if (kDebugMode) {
            print('Failed to parse JSON response: $e');
          }
          responseData = response.body;
        }
      }

      return _convertResponse<T>(response, responseData as T?);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('HTTP client exception: $e');
        if (e.message.contains('XMLHttpRequest error')) {
          print('Possible CORS issue: XMLHttpRequest error detected');
        }
      }
      throw NetworkException('Network error occurred: ${e.message}');
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('Request timeout: $e');
      }
      throw e;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in $method request: $e');
      }
      rethrow;
    }
  }

  Exception _createApiException(http.Response response) {
    try {
      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Unknown error occurred';
      return ApiException(response.statusCode, message);
    } catch (e) {
      return ApiException(response.statusCode, 'Unknown error occurred');
    }
  }

  // Builds the full URL with query parameters
  Uri _buildUri(String path, Map<String, dynamic>? queryParameters) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final fullUrl = '$_baseUrl$cleanPath';

    // Clean up query parameters - remove null values
    final cleanParams = queryParameters?.entries
        .where((e) => e.value != null)
        .fold<Map<String, String>>({}, (map, entry) {
          map[entry.key] = entry.value.toString();
          return map;
        });

    // Parse the URL with query parameters
    return Uri.parse(fullUrl).replace(queryParameters: cleanParams);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _getHeaders();

    return _handleRequest<T>(
      () => http.get(uri, headers: headers),
      'GET',
      uri.toString(),
      queryParameters,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _getHeaders();
    final body = data != null ? jsonEncode(data) : null;

    return _handleRequest<T>(
      () => http.post(uri, headers: headers, body: body),
      'POST',
      uri.toString(),
      queryParameters,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _getHeaders();
    final body = data != null ? jsonEncode(data) : null;

    return _handleRequest<T>(
      () => http.put(uri, headers: headers, body: body),
      'PUT',
      uri.toString(),
      queryParameters,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final headers = await _getHeaders();
    final body = data != null ? jsonEncode(data) : null;

    return _handleRequest<T>(
      () => http.delete(uri, headers: headers, body: body),
      'DELETE',
      uri.toString(),
      queryParameters,
    );
  }

  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return error;
    } else if (error is ApiException) {
      return error;
    } else if (error is NetworkException) {
      return error;
    } else {
      return NetworkException('Unknown error occurred: $error');
    }
  }
}

// To provide compatibility with the previous Dio implementation
class Response<T> {
  final T? data;
  final int? statusCode;
  final RequestOptions? requestOptions;
  final Map<String, String>? headers;

  Response({
    this.data,
    this.statusCode,
    this.requestOptions,
    this.headers,
  });
}

class RequestOptions {
  final String path;
  final Uri? uri;

  RequestOptions({
    required this.path,
    this.uri,
  });
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
