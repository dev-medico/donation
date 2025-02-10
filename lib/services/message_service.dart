import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/message.dart';
import 'package:donation/models/member.dart';
import 'package:donation/repositories/message_repository.dart';

class MessageService {
  final MessageRepository _repository;

  MessageService({MessageRepository? repository})
      : _repository = repository ?? MessageRepository();

  Future<ApiResponse<List<Message>>> getAllMessages() async {
    return await _repository.getAllMessages();
  }

  Future<ApiResponse<Message>> getMessageById(String id) async {
    return await _repository.getMessageById(id);
  }

  Future<ApiResponse<List<Message>>> getMessagesBySender(
      String senderId) async {
    return await _repository.getMessagesBySender(senderId);
  }

  Future<ApiResponse<List<Message>>> getMessagesByReceiver(
      String receiverId) async {
    return await _repository.getMessagesByReceiver(receiverId);
  }

  Future<ApiResponse<Message>> createMessage({
    required String content,
    required Member sender,
    required Member receiver,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    final message = Message(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      content: content,
      sender: sender,
      receiver: receiver,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'sent',
    );

    return await _repository.createMessage(message);
  }

  Future<ApiResponse<Message>> updateMessage(
    String id, {
    String? content,
    String? attachmentUrl,
    String? attachmentType,
    String? status,
  }) async {
    final response = await _repository.getMessageById(id);
    if (!response.success) {
      return response;
    }

    final updatedMessage = response.data!.copyWith(
      content: content,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      status: status,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateMessage(id, updatedMessage);
  }

  Future<ApiResponse<void>> deleteMessage(String id) async {
    return await _repository.deleteMessage(id);
  }

  Future<ApiResponse<Message>> markMessageAsRead(String id) async {
    return await _repository.markMessageAsRead(id);
  }

  Future<ApiResponse<List<Message>>> searchMessages({
    String? content,
    String? senderId,
    String? receiverId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchMessages(
      content: content,
      senderId: senderId,
      receiverId: receiverId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Message>>> getMessagesByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchMessages(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Message>>> getConversation(
    String user1Id,
    String user2Id,
  ) async {
    final messages = await searchMessages(
      senderId: user1Id,
      receiverId: user2Id,
    );

    if (!messages.success) {
      return messages;
    }

    final reverseMessages = await searchMessages(
      senderId: user2Id,
      receiverId: user1Id,
    );

    if (!reverseMessages.success) {
      return reverseMessages;
    }

    final allMessages = [
      ...messages.data ?? [],
      ...reverseMessages.data ?? [],
    ]..sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    return ApiResponse(
      success: true,
      message: 'Conversation retrieved successfully',
      data: allMessages,
    );
  }
}
