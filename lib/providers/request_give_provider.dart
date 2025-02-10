import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/request_give.dart';
import 'package:donation/repositories/request_give_repository.dart';
import 'package:donation/services/request_give_service.dart';

// Repository provider
final requestGiveRepositoryProvider = Provider<RequestGiveRepository>((ref) {
  return RequestGiveRepository();
});

// Service provider
final requestGiveServiceProvider = Provider<RequestGiveService>((ref) {
  final repository = ref.watch(requestGiveRepositoryProvider);
  return RequestGiveService(repository: repository);
});

// All request/give records provider
final requestGivesProvider = FutureProvider<List<RequestGive>>((ref) async {
  final service = ref.watch(requestGiveServiceProvider);
  final response = await service.getAllRequestGives();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected request/give record provider
final selectedRequestGiveProvider =
    FutureProvider.family<RequestGive, String>((ref, id) async {
  final service = ref.watch(requestGiveServiceProvider);
  final response = await service.getRequestGiveById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Request/give record search provider
final requestGiveSearchProvider =
    FutureProvider.family<List<RequestGive>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(requestGiveServiceProvider);
  final response = await service.searchRequestGives(
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Request/give record creation state
final requestGiveCreationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Request/give record update state
final requestGiveUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Request/give record deletion state
final requestGiveDeletionStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create request/give record provider
final createRequestGiveProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(requestGiveServiceProvider);
  final stateNotifier = ref.read(requestGiveCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createRequestGive(
      request: recordData['request'] as int,
      give: recordData['give'] as int,
      date: recordData['date'] as DateTime,
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

// Update request/give record provider
final updateRequestGiveProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(requestGiveServiceProvider);
  final stateNotifier = ref.read(requestGiveUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateRequestGive(
      recordData['id'] as String,
      request: recordData['request'] as int?,
      give: recordData['give'] as int?,
      date: recordData['date'] as DateTime?,
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

// Delete request/give record provider
final deleteRequestGiveProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(requestGiveServiceProvider);
  final stateNotifier = ref.read(requestGiveDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteRequestGive(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
