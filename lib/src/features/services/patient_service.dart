import 'package:donation/src/features/services/base_service.dart';
import 'package:donation/src/features/patient/models/patient.dart';

class PatientService extends BaseService {
  Future<Map<String, dynamic>> getPatients({
    int page = 0,
    int limit = 20,
    String q = '',
    String order = 'desc',
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'q': q,
      'order': order,
    };

    final response = await apiClient.get(
      '/donation/patient-list',
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
}