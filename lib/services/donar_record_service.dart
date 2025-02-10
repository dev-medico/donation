import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/donar_record.dart';
import 'package:donation/repositories/donar_record_repository.dart';

class DonarRecordService {
  final DonarRecordRepository _repository;

  DonarRecordService({DonarRecordRepository? repository})
      : _repository = repository ?? DonarRecordRepository();

  Future<ApiResponse<List<DonarRecord>>> getAllDonarRecords() async {
    return await _repository.getAllDonarRecords();
  }

  Future<ApiResponse<DonarRecord>> getDonarRecordById(String id) async {
    return await _repository.getDonarRecordById(id);
  }

  Future<ApiResponse<DonarRecord>> createDonarRecord({
    required String name,
    required int amount,
    required DateTime date,
  }) async {
    final record = DonarRecord(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      name: name,
      amount: amount,
      date: date,
    );

    return await _repository.createDonarRecord(record);
  }

  Future<ApiResponse<DonarRecord>> updateDonarRecord(
    String id, {
    String? name,
    int? amount,
    DateTime? date,
  }) async {
    final response = await _repository.getDonarRecordById(id);
    if (!response.success) {
      return response;
    }

    final updatedRecord = response.data!.copyWith(
      name: name,
      amount: amount,
      date: date,
    );

    return await _repository.updateDonarRecord(id, updatedRecord);
  }

  Future<ApiResponse<void>> deleteDonarRecord(String id) async {
    return await _repository.deleteDonarRecord(id);
  }

  Future<ApiResponse<List<DonarRecord>>> searchDonarRecords({
    String? name,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchDonarRecords(
      name: name,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<DonarRecord>>> getDonarRecordsByName(
      String name) async {
    return await searchDonarRecords(name: name);
  }

  Future<ApiResponse<List<DonarRecord>>> getDonarRecordsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchDonarRecords(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
