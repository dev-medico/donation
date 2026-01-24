import 'package:donation/src/features/services/base_service.dart';
import 'package:donation/src/features/patient/models/patient.dart';

class PatientService extends BaseService {
  /// Get paginated list of patients
  Future<Map<String, dynamic>> getPatients({
    int page = 0,
    int limit = 20,
    String q = '',
    String? gender,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (q.isNotEmpty) {
      queryParams['q'] = q;
    }
    if (gender != null && gender.isNotEmpty) {
      queryParams['gender'] = gender;
    }

    final response = await apiClient.get(
      '/patient/index',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        final List<dynamic> patientsJson = data['data'] ?? [];
        final List<Patient> patients = patientsJson
            .map((json) => Patient.fromJson(json))
            .toList();

        return {
          'patients': patients,
          'total': data['total'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
          'page': data['page'] ?? page,
          'limit': data['limit'] ?? limit,
        };
      }
    }

    throw Exception('Failed to load patients');
  }

  /// Get single patient by ID
  Future<Patient> getPatient(int id) async {
    final response = await apiClient.get(
      '/patient/view',
      queryParameters: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return Patient.fromJson(data['data']);
      }
    }

    throw Exception('Failed to load patient');
  }

  /// Create new patient
  Future<Patient> createPatient(Map<String, dynamic> patientData) async {
    final response = await apiClient.post(
      '/patient/create',
      data: patientData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return Patient.fromJson(data['data']);
      }
    }

    throw Exception('Failed to create patient');
  }

  /// Update existing patient
  Future<Patient> updatePatient(int id, Map<String, dynamic> patientData) async {
    final response = await apiClient.post(
      '/patient/update/$id',
      data: patientData,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return Patient.fromJson(data['data']);
      }
    }

    throw Exception('Failed to update patient');
  }

  /// Delete patient
  Future<bool> deletePatient(int id) async {
    final response = await apiClient.post('/patient/delete/$id');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return data['status'] == 'ok';
    }

    return false;
  }

  /// Search patients for dropdown
  Future<List<Patient>> searchPatients(String query) async {
    final response = await apiClient.get(
      '/patient/search',
      queryParameters: {'q': query},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        final List<dynamic> patientsJson = data['data'] ?? [];
        return patientsJson
            .map((json) => Patient.fromJson(json))
            .toList();
      }
    }

    return [];
  }
}
