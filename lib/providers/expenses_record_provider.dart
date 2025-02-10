import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/expenses_record.dart';
import 'package:donation/repositories/expenses_record_repository.dart';
import 'package:donation/services/expenses_record_service.dart';

// Repository provider
final expensesRecordRepositoryProvider =
    Provider<ExpensesRecordRepository>((ref) {
  return ExpensesRecordRepository();
});

// Service provider
final expensesRecordServiceProvider = Provider<ExpensesRecordService>((ref) {
  final repository = ref.watch(expensesRecordRepositoryProvider);
  return ExpensesRecordService(repository: repository);
});

// All expenses records provider
final expensesRecordsProvider =
    FutureProvider<List<ExpensesRecord>>((ref) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final response = await service.getAllExpensesRecords();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected expenses record provider
final selectedExpensesRecordProvider =
    FutureProvider.family<ExpensesRecord, String>((ref, id) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final response = await service.getExpensesRecordById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Expenses record search provider
final expensesRecordSearchProvider =
    FutureProvider.family<List<ExpensesRecord>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final response = await service.searchExpensesRecords(
    category: searchParams['category'] as String?,
    description: searchParams['description'] as String?,
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Expenses record creation state
final expensesRecordCreationStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Expenses record update state
final expensesRecordUpdateStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Expenses record deletion state
final expensesRecordDeletionStateProvider =
    StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create expenses record provider
final createExpensesRecordProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final stateNotifier = ref.read(expensesRecordCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createExpensesRecord(
      amount: recordData['amount'] as int,
      date: recordData['date'] as DateTime,
      description: recordData['description'] as String,
      category: recordData['category'] as String,
      paymentMethod: recordData['paymentMethod'] as String?,
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

// Update expenses record provider
final updateExpensesRecordProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, recordData) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final stateNotifier = ref.read(expensesRecordUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateExpensesRecord(
      recordData['id'] as String,
      amount: recordData['amount'] as int?,
      date: recordData['date'] as DateTime?,
      description: recordData['description'] as String?,
      category: recordData['category'] as String?,
      paymentMethod: recordData['paymentMethod'] as String?,
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

// Delete expenses record provider
final deleteExpensesRecordProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(expensesRecordServiceProvider);
  final stateNotifier = ref.read(expensesRecordDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteExpensesRecord(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
 