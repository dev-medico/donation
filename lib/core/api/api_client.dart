import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donation/main.dart';
import 'package:donation/src/features/auth/login.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late String _baseUrl;
  late final Duration _timeout;
  late final Map<String, String> _defaultHeaders;

  /// Timestamp of the most recent successful login. Used to avoid bouncing the
  /// user back to the login screen when an early post-login request races
  /// session setup and returns 401. See the 401 handling in [_handleRequest].
  static DateTime? _lastLoginAt;

  /// Call right after a successful login + token persistence so the 401 handler
  /// can tell a genuine session expiry apart from a transient race during the
  /// first authenticated requests (e.g. the home dashboard load on iPad).
  static void markLoggedIn() {
    _lastLoginAt = DateTime.now();
  }

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // _baseUrl = 'http://donation_backend.test/';
    _baseUrl = 'https://207-180-244-55.sslip.io/';
    _timeout = const Duration(seconds: 30);
    _defaultHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Logging removed for performance
  }

  // Helper method to add auth token to headers
  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);

    // Add auth token if available
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Only attach the header when we actually have a token. Sending an empty
    // "Bearer " is guaranteed to be rejected with 401 by the backend.
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Helper for logging requests in debug mode
  void _logRequest(
      String method, String url, Map<String, dynamic>? queryParams) {
    // Only log for debugging blood donation report
    if (url.contains('report')) {
      print('API Request: $method $url');
      if (queryParams != null && queryParams.isNotEmpty) {
        print('Query params: $queryParams');
      }
    }
  }

  // Helper for logging responses in debug mode
  void _logResponse(http.Response response) {
    // Only log errors for debugging
    if (response.statusCode >= 400) {
      print('API Error: ${response.statusCode} - ${response.request?.url}');
      print('Response body: ${response.body}');
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
        throw NetworkException(
            'CORS error: Server is not allowing cross-origin requests. Status code: 0');
      }

      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        // If we *just* logged in, a 401 here is almost certainly an early
        // request racing session setup (e.g. the home dashboard load that
        // fires from initState). Do NOT wipe the session and bounce back to
        // the login screen — keep the session and let the calling screen show
        // its own empty/error state. This is the iPad "logs in, shows content
        // for a fraction of a second, then returns to login" App Store bug.
        final lastLogin = _lastLoginAt;
        final justLoggedIn = lastLogin != null &&
            DateTime.now().difference(lastLogin) < const Duration(seconds: 10);
        if (justLoggedIn) {
          throw ApiException(401, 'Session expired');
        }

        // Genuine session expiry: clear credentials and return to login.
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('name');
        await prefs.remove('phone');
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          LoginScreen.routeName,
          (route) => false,
        );
        throw ApiException(401, 'Session expired');
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
          responseData = response.body;
        }
      }

      return _convertResponse<T>(response, responseData as T?);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error occurred: ${e.message}');
    } on TimeoutException catch (e) {
      throw e;
    } catch (e) {
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
