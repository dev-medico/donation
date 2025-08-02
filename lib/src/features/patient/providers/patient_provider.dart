import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/services/patient_service.dart';

final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

final patientListProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(patientServiceProvider);
  return service.getPatients(
    page: params['page'] ?? 0,
    limit: params['limit'] ?? 20,
    q: params['q'] ?? '',
    order: params['order'] ?? 'desc',
  );
});

class PatientNotifier extends StateNotifier<List<Patient>> {
  PatientNotifier() : super([]);
  
  final PatientService _service = PatientService();
  
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String _currentQuery = '';
  
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> loadPatients({String query = '', bool refresh = false}) async {
    if (_isLoading) return;
    
    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      state = [];
    }
    
    if (!_hasMore && !refresh) return;
    
    _currentQuery = query;
    _isLoading = true;
    
    try {
      final result = await _service.getPatients(
        page: _currentPage,
        limit: 20,
        q: query,
      );
      
      final patients = result['patients'] as List<Patient>;
      
      if (refresh) {
        state = patients;
      } else {
        state = [...state, ...patients];
      }
      
      _hasMore = result['hasMore'] ?? false;
      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      // Handle error
      print('Error loading patients: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  void clearPatients() {
    state = [];
    _currentPage = 0;
    _hasMore = true;
    _currentQuery = '';
  }
}

final patientNotifierProvider = StateNotifierProvider<PatientNotifier, List<Patient>>((ref) {
  return PatientNotifier();
});