import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/message.dart';
import 'package:donation/models/member.dart';
import 'package:donation/repositories/message_repository.dart';
import 'package:donation/services/message_service.dart';

// Repository provider
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// Service provider
final messageServiceProvider = Provider<MessageService>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return MessageService(repository: repository);
});

// All messages provider
final messagesProvider = FutureProvider<List<Message>>((ref) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.getAllMessages();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected message provider
final selectedMessageProvider =
    FutureProvider.family<Message, String>((ref, id) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.getMessageById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Messages by sender provider
final messagesBySenderProvider =
    FutureProvider.family<List<Message>, String>((ref, senderId) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.getMessagesBySender(senderId);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Messages by receiver provider
final messagesByReceiverProvider =
    FutureProvider.family<List<Message>, String>((ref, receiverId) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.getMessagesByReceiver(receiverId);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Conversation provider
final conversationProvider =
    FutureProvider.family<List<Message>, ({String user1Id, String user2Id})>(
        (ref, params) async {
  final service = ref.watch(messageServiceProvider);
  final response =
      await service.getConversation(params.user1Id, params.user2Id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Message search provider
final messageSearchProvider =
    FutureProvider.family<List<Message>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.searchMessages(
    content: searchParams['content'] as String?,
    senderId: searchParams['senderId'] as String?,
    receiverId: searchParams['receiverId'] as String?,
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Message creation state
final messageCreationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Message update state
final messageUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Message deletion state
final messageDeletionStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create message provider
final createMessageProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, messageData) async {
  final service = ref.watch(messageServiceProvider);
  final stateNotifier = ref.read(messageCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createMessage(
      content: messageData['content'] as String,
      sender: messageData['sender'] as Member,
      receiver: messageData['receiver'] as Member,
      attachmentUrl: messageData['attachmentUrl'] as String?,
      attachmentType: messageData['attachmentType'] as String?,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Update message provider
final updateMessageProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, messageData) async {
  final service = ref.watch(messageServiceProvider);
  final stateNotifier = ref.read(messageUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateMessage(
      messageData['id'] as String,
      content: messageData['content'] as String?,
      attachmentUrl: messageData['attachmentUrl'] as String?,
      attachmentType: messageData['attachmentType'] as String?,
      status: messageData['status'] as String?,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Delete message provider
final deleteMessageProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(messageServiceProvider);
  final stateNotifier = ref.read(messageDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteMessage(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Mark message as read provider
final markMessageAsReadProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(messageServiceProvider);
  final response = await service.markMessageAsRead(id);
  if (!response.success) {
    throw Exception(response.message);
  }
});
