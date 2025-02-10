import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/donar_record.dart';
import 'package:donation/repositories/donar_record_repository.dart';
import 'package:donation/services/donar_record_service.dart';

// Repository provider
final donarRecordRepositoryProvider = Provider<DonarRecordRepository>((ref) {
  return DonarRecordRepository();
});

// Service provider
final donarRecordServiceProvider = Provider<DonarRecordService>((ref) {
  final repository = ref.watch(donarRecordRepositoryProvider);
  return DonarRecordService(repository: repository);
});

// All donar records provider
final donarRecordsProvider = FutureProvider<List<DonarRecord>>((ref) async {
  final service = ref.watch(donarRecordServiceProvider);
  final response = await service.getAllDonarRecords();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected donar record provider
final selectedDonarRecordProvider =
    FutureProvider.family<DonarRecord, String>((ref, id) async {
  final service = ref.watch(donarRecordServiceProvider);
  final response = await service.getDonarRecordById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Donar record search provider
final donarRecordSearchProvider =
    FutureProvider.family<List<DonarRecord>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(donarRecordServiceProvider);
  final response = await service.searchDonarRecords(
    name: searchParams['name'] as String?,
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Donar record creation state
final donarRecordCreationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Donar record update state
final donarRecordUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Donar record deletion state
final donarRecordDeletionStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create donar record provider
final createDonarRecordProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(donarRecordServiceProvider);
  final stateNotifier = ref.read(donarRecordCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createDonarRecord(
      name: recordData['name'] as String,
      amount: recordData['amount'] as int,
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

// Update donar record provider
final updateDonarRecordProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(donarRecordServiceProvider);
  final stateNotifier = ref.read(donarRecordUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateDonarRecord(
      recordData['id'] as String,
      name: recordData['name'] as String?,
      amount: recordData['amount'] as int?,
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

// Delete donar record provider
final deleteDonarRecordProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(donarRecordServiceProvider);
  final stateNotifier = ref.read(donarRecordDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteDonarRecord(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
