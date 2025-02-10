import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/post.dart';
import 'package:donation/models/member.dart';
import 'package:donation/repositories/post_repository.dart';

class PostService {
  final PostRepository _repository;

  PostService({PostRepository? repository})
      : _repository = repository ?? PostRepository();

  Future<ApiResponse<List<Post>>> getAllPosts() async {
    return await _repository.getAllPosts();
  }

  Future<ApiResponse<Post>> getPostById(String id) async {
    return await _repository.getPostById(id);
  }

  Future<ApiResponse<Post>> createPost({
    required String text,
    required List<String> images,
    required String postedBy,
    String? posterProfileUrl,
  }) async {
    final post = Post(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      text: text,
      images: images,
      reactions: [],
      comments: [],
      createdAt: DateTime.now(),
      postedBy: postedBy,
      posterProfileUrl: posterProfileUrl,
    );

    return await _repository.createPost(post);
  }

  Future<ApiResponse<Post>> updatePost(
    String id, {
    String? text,
    List<String>? images,
  }) async {
    final response = await _repository.getPostById(id);
    if (!response.success) {
      return response;
    }

    final updatedPost = response.data!.copyWith(
      text: text,
      images: images,
    );

    return await _repository.updatePost(id, updatedPost);
  }

  Future<ApiResponse<void>> deletePost(String id) async {
    return await _repository.deletePost(id);
  }

  // Reaction methods
  Future<ApiResponse<Post>> addReaction({
    required String postId,
    required String emoji,
    required String type,
    required Member member,
  }) async {
    final reaction = Reaction(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      emoji: emoji,
      type: type,
      member: member,
      createdAt: DateTime.now(),
    );

    return await _repository.addReaction(postId, reaction);
  }

  Future<ApiResponse<Post>> removeReaction({
    required String postId,
    required String reactionId,
  }) async {
    return await _repository.removeReaction(postId, reactionId);
  }

  // Comment methods
  Future<ApiResponse<Post>> addComment({
    required String postId,
    required String text,
    required Member member,
  }) async {
    final comment = Comment(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      text: text,
      member: member,
      reactions: [],
      comments: [],
      createdAt: DateTime.now(),
    );

    return await _repository.addComment(postId, comment);
  }

  Future<ApiResponse<Post>> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final postResponse = await _repository.getPostById(postId);
    if (!postResponse.success) {
      return postResponse;
    }

    final post = postResponse.data!;
    Comment? targetComment;
    for (final comment in post.comments) {
      if (comment.id == commentId) {
        targetComment = comment;
        break;
      }
    }

    if (targetComment == null) {
      return ApiResponse.error('Comment not found');
    }

    final updatedComment = targetComment.copyWith(text: text);
    return await _repository.updateComment(postId, commentId, updatedComment);
  }

  Future<ApiResponse<Post>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    return await _repository.deleteComment(postId, commentId);
  }

  Future<ApiResponse<List<Post>>> searchPosts({
    String? text,
    String? postedBy,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchPosts(
      text: text,
      postedBy: postedBy,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Post>>> getPostsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchPosts(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Post>>> getPostsByUser(String userId) async {
    return await searchPosts(postedBy: userId);
  }
}
