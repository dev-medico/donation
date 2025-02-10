import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/request_give.dart';
import 'package:donation/repositories/request_give_repository.dart';

class RequestGiveService {
  final RequestGiveRepository _repository;

  RequestGiveService({RequestGiveRepository? repository})
      : _repository = repository ?? RequestGiveRepository();

  Future<ApiResponse<List<RequestGive>>> getAllRequestGives() async {
    return await _repository.getAllRequestGives();
  }

  Future<ApiResponse<RequestGive>> getRequestGiveById(String id) async {
    return await _repository.getRequestGiveById(id);
  }

  Future<ApiResponse<RequestGive>> createRequestGive({
    required int request,
    required int give,
    required DateTime date,
  }) async {
    final record = RequestGive(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      request: request,
      give: give,
      date: date,
    );

    return await _repository.createRequestGive(record);
  }

  Future<ApiResponse<RequestGive>> updateRequestGive(
    String id, {
    int? request,
    int? give,
    DateTime? date,
  }) async {
    final response = await _repository.getRequestGiveById(id);
    if (!response.success) {
      return response;
    }

    final updatedRecord = response.data!.copyWith(
      request: request,
      give: give,
      date: date,
    );

    return await _repository.updateRequestGive(id, updatedRecord);
  }

  Future<ApiResponse<void>> deleteRequestGive(String id) async {
    return await _repository.deleteRequestGive(id);
  }

  Future<ApiResponse<List<RequestGive>>> searchRequestGives({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchRequestGives(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<RequestGive>>> getRequestGivesByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchRequestGives(
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
