import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/expenses_record.dart';
import 'package:donation/repositories/expenses_record_repository.dart';

class ExpensesRecordService {
  final ExpensesRecordRepository _repository;

  ExpensesRecordService({ExpensesRecordRepository? repository})
      : _repository = repository ?? ExpensesRecordRepository();

  Future<ApiResponse<List<ExpensesRecord>>> getAllExpensesRecords() async {
    return await _repository.getAllExpensesRecords();
  }

  Future<ApiResponse<ExpensesRecord>> getExpensesRecordById(String id) async {
    return await _repository.getExpensesRecordById(id);
  }

  Future<ApiResponse<ExpensesRecord>> createExpensesRecord({
    required int amount,
    required DateTime date,
    required String description,
    required String category,
    String? paymentMethod,
  }) async {
    final record = ExpensesRecord(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      amount: amount,
      date: date,
      description: description,
      category: category,
      paymentMethod: paymentMethod,
    );

    return await _repository.createExpensesRecord(record);
  }

  Future<ApiResponse<ExpensesRecord>> updateExpensesRecord(
    String id, {
    int? amount,
    DateTime? date,
    String? description,
    String? category,
    String? paymentMethod,
  }) async {
    final response = await _repository.getExpensesRecordById(id);
    if (!response.success) {
      return response;
    }

    final updatedRecord = response.data!.copyWith(
      amount: amount,
      date: date,
      description: description,
      category: category,
      paymentMethod: paymentMethod,
    );

    return await _repository.updateExpensesRecord(id, updatedRecord);
  }

  Future<ApiResponse<void>> deleteExpensesRecord(String id) async {
    return await _repository.deleteExpensesRecord(id);
  }

  Future<ApiResponse<List<ExpensesRecord>>> searchExpensesRecords({
    String? category,
    String? description,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchExpensesRecords(
      category: category,
      description: description,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<ExpensesRecord>>> getExpensesRecordsByCategory(
      String category) async {
    return await searchExpensesRecords(category: category);
  }

  Future<ApiResponse<List<ExpensesRecord>>> getExpensesRecordsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchExpensesRecords(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
