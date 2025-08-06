import 'package:donation/src/features/services/base_service.dart';
import 'package:donation/src/features/patient/models/patient.dart';

class PatientService extends BaseService {
  Future<Map<String, dynamic>> getPatients({
    int page = 0,
    int limit = 20,
    String q = '',
    String order = 'desc',
  }) async {
    print('PatientService.getPatients called with:');
    print('  page: $page, limit: $limit, q: "$q", order: $order');
    
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      'q': q,
      'order': order,
    };
    
    print('Making API call to: /donation/patient-list');
    print('Query params: $queryParams');

    try {
      final response = await apiClient.get(
        '/donation/patient-list',
        queryParameters: queryParams,
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        if (data['status'] == 'ok') {
          final List<dynamic> patientsJson = data['data'] ?? [];
          print('Number of patients in response: ${patientsJson.length}');
          
          final List<Patient> patients = patientsJson
              .map((json) => Patient.fromJson(json))
              .toList();
          
          final result = {
            'patients': patients,
            'total': data['total'] ?? 0,
            'hasMore': data['hasMore'] ?? false,
            'page': data['page'] ?? page,
            'limit': data['limit'] ?? limit,
          };
          
          print('Returning result with ${patients.length} patients');
          return result;
        } else {
          print('ERROR: API returned status != ok: ${data['status']}');
        }
      } else {
        print('ERROR: API returned status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('ERROR in PatientService.getPatients: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
    
    throw Exception('Failed to load patients');
  }
}