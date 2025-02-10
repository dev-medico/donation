import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/message.dart';

class MessageRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/messages';

  MessageRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Message>>> getAllMessages() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_baseUrl);
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Message>> getMessageById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/$id');
      return ApiResponse.fromJson(
        response.data!,
        (json) => Message.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Message>>> getMessagesBySender(
      String senderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/sender/$senderId',
      );
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Message>>> getMessagesByReceiver(
      String receiverId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/receiver/$receiverId',
      );
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Message>> createMessage(Message message) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _baseUrl,
        data: message.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Message.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Message>> updateMessage(String id, Message message) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id',
        data: message.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Message.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteMessage(String id) async {
    try {
      await _apiClient.delete('$_baseUrl/$id');
      return ApiResponse(
          success: true, message: 'Message deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Message>> markMessageAsRead(String id) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id/read',
        data: {'isRead': true},
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Message.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Message>>> searchMessages({
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (content != null) 'content': content,
        if (senderId != null) 'sender_id': senderId,
        if (receiverId != null) 'receiver_id': receiverId,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
