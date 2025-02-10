import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/post.dart';

class PostRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/posts';

  PostRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Post>>> getAllPosts() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_baseUrl);
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> getPostById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/$id');
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> createPost(Post post) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _baseUrl,
        data: post.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> updatePost(String id, Post post) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id',
        data: post.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deletePost(String id) async {
    try {
      await _apiClient.delete('$_baseUrl/$id');
      return ApiResponse(success: true, message: 'Post deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Reaction related methods
  Future<ApiResponse<Post>> addReaction(
      String postId, Reaction reaction) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/$postId/reactions',
        data: reaction.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> removeReaction(
      String postId, String reactionId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_baseUrl/$postId/reactions/$reactionId',
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // Comment related methods
  Future<ApiResponse<Post>> addComment(String postId, Comment comment) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/$postId/comments',
        data: comment.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> updateComment(
      String postId, String commentId, Comment comment) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$postId/comments/$commentId',
        data: comment.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Post>> deleteComment(
      String postId, String commentId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '$_baseUrl/$postId/comments/$commentId',
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Post.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Post>>> searchPosts({
    String? text,
    String? postedBy,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (text != null) 'text': text,
        if (postedBy != null) 'posted_by': postedBy,
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
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
