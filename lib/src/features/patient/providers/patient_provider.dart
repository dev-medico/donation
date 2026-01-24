import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/services/patient_service.dart';

final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

/// Provider for fetching paginated patient list
final patientListProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(patientServiceProvider);
  return service.getPatients(
    page: params['page'] ?? 0,
    limit: params['limit'] ?? 20,
    q: params['q'] ?? '',
    gender: params['gender'],
  );
});

/// Provider for fetching single patient by ID
final patientDetailProvider = FutureProvider.family<Patient, int>((ref, id) async {
  final service = ref.read(patientServiceProvider);
  return service.getPatient(id);
});

/// Provider for creating a patient
final createPatientProvider = FutureProvider.family<Patient, Map<String, dynamic>>((ref, data) async {
  final service = ref.read(patientServiceProvider);
  return service.createPatient(data);
});

/// Provider for updating a patient
final updatePatientProvider = FutureProvider.family<Patient, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(patientServiceProvider);
  final id = params['id'] as int;
  final data = Map<String, dynamic>.from(params)..remove('id');
  return service.updatePatient(id, data);
});

/// Provider for deleting a patient
final deletePatientProvider = FutureProvider.family<bool, int>((ref, id) async {
  final service = ref.read(patientServiceProvider);
  return service.deletePatient(id);
});

/// Provider for searching patients
final searchPatientsProvider = FutureProvider.family<List<Patient>, String>((ref, query) async {
  final service = ref.read(patientServiceProvider);
  return service.searchPatients(query);
});

/// Notifier for managing patient list state with pagination
class PatientNotifier extends StateNotifier<List<Patient>> {
  PatientNotifier() : super([]);

  final PatientService _service = PatientService();

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String _currentQuery = '';
  String? _currentGender;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> loadPatients({
    String query = '',
    String? gender,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      state = [];
    }

    if (!_hasMore && !refresh) return;

    _currentQuery = query;
    _currentGender = gender;
    _isLoading = true;

    try {
      final result = await _service.getPatients(
        page: _currentPage,
        limit: 20,
        q: query,
        gender: gender,
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
    _currentGender = null;
  }

  Future<void> refresh() async {
    await loadPatients(
      query: _currentQuery,
      gender: _currentGender,
      refresh: true,
    );
  }
}

final patientNotifierProvider = StateNotifierProvider<PatientNotifier, List<Patient>>((ref) {
  return PatientNotifier();
});
