import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/notification.dart';
import 'package:donation/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;

  NotificationService({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository();

  Future<ApiResponse<List<Notification>>> getAllNotifications() async {
    return await _repository.getAllNotifications();
  }

  Future<ApiResponse<Notification>> getNotificationById(String id) async {
    return await _repository.getNotificationById(id);
  }

  Future<ApiResponse<Notification>> createNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final notification = Notification(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      title: title,
      body: body,
      payload: payload,
      createdAt: DateTime.now(),
    );

    return await _repository.createNotification(notification);
  }

  Future<ApiResponse<Notification>> updateNotification(
    String id, {
    String? title,
    String? body,
    String? payload,
  }) async {
    final response = await _repository.getNotificationById(id);
    if (!response.success) {
      return response;
    }

    final updatedNotification = response.data!.copyWith(
      title: title,
      body: body,
      payload: payload,
    );

    return await _repository.updateNotification(id, updatedNotification);
  }

  Future<ApiResponse<void>> deleteNotification(String id) async {
    return await _repository.deleteNotification(id);
  }

  Future<ApiResponse<List<Notification>>> searchNotifications({
    String? title,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchNotifications(
      title: title,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Notification>>> getNotificationsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchNotifications(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
