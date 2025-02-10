import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/special_event.dart';
import 'package:donation/repositories/special_event_repository.dart';

class SpecialEventService {
  final SpecialEventRepository _repository;

  SpecialEventService({SpecialEventRepository? repository})
      : _repository = repository ?? SpecialEventRepository();

  Future<ApiResponse<List<SpecialEvent>>> getAllSpecialEvents() async {
    return await _repository.getAllSpecialEvents();
  }

  Future<ApiResponse<SpecialEvent>> getSpecialEventById(String id) async {
    return await _repository.getSpecialEventById(id);
  }

  Future<ApiResponse<SpecialEvent>> createSpecialEvent({
    required String labName,
    required String date,
    int? haemoglobin,
    int? hbsAg,
    int? hcvAb,
    int? mpIct,
    int? retroTest,
    int? total,
  }) async {
    final event = SpecialEvent(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      labName: labName,
      date: date,
      haemoglobin: haemoglobin,
      hbsAg: hbsAg,
      hcvAb: hcvAb,
      mpIct: mpIct,
      retroTest: retroTest,
      total: total,
    );

    return await _repository.createSpecialEvent(event);
  }

  Future<ApiResponse<SpecialEvent>> updateSpecialEvent(
    String id, {
    String? labName,
    String? date,
    int? haemoglobin,
    int? hbsAg,
    int? hcvAb,
    int? mpIct,
    int? retroTest,
    int? total,
  }) async {
    final response = await _repository.getSpecialEventById(id);
    if (!response.success) {
      return response;
    }

    final updatedEvent = response.data!.copyWith(
      labName: labName,
      date: date,
      haemoglobin: haemoglobin,
      hbsAg: hbsAg,
      hcvAb: hcvAb,
      mpIct: mpIct,
      retroTest: retroTest,
      total: total,
    );

    return await _repository.updateSpecialEvent(id, updatedEvent);
  }

  Future<ApiResponse<void>> deleteSpecialEvent(String id) async {
    return await _repository.deleteSpecialEvent(id);
  }

  Future<ApiResponse<List<SpecialEvent>>> searchSpecialEvents({
    String? labName,
    String? date,
  }) async {
    return await _repository.searchSpecialEvents(
      labName: labName,
      date: date,
    );
  }

  Future<ApiResponse<List<SpecialEvent>>> getSpecialEventsByLabName(
      String labName) async {
    return await searchSpecialEvents(labName: labName);
  }

  Future<ApiResponse<List<SpecialEvent>>> getSpecialEventsByDate(
      String date) async {
    return await searchSpecialEvents(date: date);
  }
}
