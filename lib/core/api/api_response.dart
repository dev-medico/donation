class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? fromJson(json['data'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.fromJsonList(
    Map<String, dynamic> json,
    T Function(List<dynamic> json) fromJsonList,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? fromJsonList(json['data'] as List<dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse<T>(
      success: false,
      message: message,
    );
  }
}
