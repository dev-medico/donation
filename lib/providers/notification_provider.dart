import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/notification.dart';
import 'package:donation/repositories/notification_repository.dart';
import 'package:donation/services/notification_service.dart';

// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

// Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository: repository);
});

// All notifications provider
final notificationsProvider = FutureProvider<List<Notification>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  final response = await service.getAllNotifications();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected notification provider
final selectedNotificationProvider =
    FutureProvider.family<Notification, String>((ref, id) async {
  final service = ref.watch(notificationServiceProvider);
  final response = await service.getNotificationById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Notification search provider
final notificationSearchProvider =
    FutureProvider.family<List<Notification>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(notificationServiceProvider);
  final response = await service.searchNotifications(
    title: searchParams['title'] as String?,
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Notification creation state
final notificationCreationStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Notification update state
final notificationUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Notification deletion state
final notificationDeletionStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create notification provider
final createNotificationProvider =
    FutureProvider.family<void, Map<String, dynamic>>(
        (ref, notificationData) async {
  final service = ref.watch(notificationServiceProvider);
  final stateNotifier = ref.read(notificationCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createNotification(
      title: notificationData['title'] as String,
      body: notificationData['body'] as String,
      payload: notificationData['payload'] as String?,
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

// Update notification provider
final updateNotificationProvider =
    FutureProvider.family<void, Map<String, dynamic>>(
        (ref, notificationData) async {
  final service = ref.watch(notificationServiceProvider);
  final stateNotifier = ref.read(notificationUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateNotification(
      notificationData['id'] as String,
      title: notificationData['title'] as String?,
      body: notificationData['body'] as String?,
      payload: notificationData['payload'] as String?,
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

// Delete notification provider
final deleteNotificationProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(notificationServiceProvider);
  final stateNotifier = ref.read(notificationDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteNotification(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
