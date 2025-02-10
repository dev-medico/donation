import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/special_event.dart';
import 'package:donation/repositories/special_event_repository.dart';
import 'package:donation/services/special_event_service.dart';

// Repository provider
final specialEventRepositoryProvider = Provider<SpecialEventRepository>((ref) {
  return SpecialEventRepository();
});

// Service provider
final specialEventServiceProvider = Provider<SpecialEventService>((ref) {
  final repository = ref.watch(specialEventRepositoryProvider);
  return SpecialEventService(repository: repository);
});

// All special events provider
final specialEventsProvider = FutureProvider<List<SpecialEvent>>((ref) async {
  final service = ref.watch(specialEventServiceProvider);
  final response = await service.getAllSpecialEvents();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected special event provider
final selectedSpecialEventProvider =
    FutureProvider.family<SpecialEvent, String>((ref, id) async {
  final service = ref.watch(specialEventServiceProvider);
  final response = await service.getSpecialEventById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Special event search provider
final specialEventSearchProvider =
    FutureProvider.family<List<SpecialEvent>, Map<String, String?>>(
        (ref, searchParams) async {
  final service = ref.watch(specialEventServiceProvider);
  final response = await service.searchSpecialEvents(
    labName: searchParams['labName'],
    date: searchParams['date'],
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Special event creation state
final specialEventCreationStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Special event update state
final specialEventUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Special event deletion state
final specialEventDeletionStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create special event provider
final createSpecialEventProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, eventData) async {
  final service = ref.watch(specialEventServiceProvider);
  final stateNotifier = ref.read(specialEventCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createSpecialEvent(
      labName: eventData['labName'] as String,
      date: eventData['date'] as String,
      haemoglobin: eventData['haemoglobin'] as int?,
      hbsAg: eventData['hbsAg'] as int?,
      hcvAb: eventData['hcvAb'] as int?,
      mpIct: eventData['mpIct'] as int?,
      retroTest: eventData['retroTest'] as int?,
      total: eventData['total'] as int?,
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

// Update special event provider
final updateSpecialEventProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, eventData) async {
  final service = ref.watch(specialEventServiceProvider);
  final stateNotifier = ref.read(specialEventUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateSpecialEvent(
      eventData['id'] as String,
      labName: eventData['labName'] as String?,
      date: eventData['date'] as String?,
      haemoglobin: eventData['haemoglobin'] as int?,
      hbsAg: eventData['hbsAg'] as int?,
      hcvAb: eventData['hcvAb'] as int?,
      mpIct: eventData['mpIct'] as int?,
      retroTest: eventData['retroTest'] as int?,
      total: eventData['total'] as int?,
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

// Delete special event provider
final deleteSpecialEventProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(specialEventServiceProvider);
  final stateNotifier = ref.read(specialEventDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteSpecialEvent(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
