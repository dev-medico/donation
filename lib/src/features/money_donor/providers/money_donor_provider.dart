import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/money_donor/models/money_donor.dart';
import 'package:donation/src/features/services/money_donor_service.dart';

final moneyDonorServiceProvider = Provider<MoneyDonorService>((ref) {
  return MoneyDonorService();
});

/// Provider for fetching paginated money donor list
final moneyDonorsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.getMoneyDonors(
    page: params['page'] ?? 0,
    limit: params['limit'] ?? 20,
    q: params['q'] ?? '',
  );
});

/// Provider for fetching single money donor by ID
final moneyDonorProvider = FutureProvider.family<MoneyDonor, int>((ref, id) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.getMoneyDonor(id);
});

/// Provider for creating a money donor
final createMoneyDonorProvider = FutureProvider.family<MoneyDonor, Map<String, dynamic>>((ref, data) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.createMoneyDonor(data);
});

/// Provider for updating a money donor
final updateMoneyDonorProvider = FutureProvider.family<MoneyDonor, Map<String, dynamic>>((ref, params) async {
  final service = ref.read(moneyDonorServiceProvider);
  final id = params['id'] as int;
  final data = Map<String, dynamic>.from(params)..remove('id');
  return service.updateMoneyDonor(id, data);
});

/// Provider for deleting a money donor
final deleteMoneyDonorProvider = FutureProvider.family<bool, int>((ref, id) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.deleteMoneyDonor(id);
});

/// Provider for searching money donors
final searchMoneyDonorsProvider = FutureProvider.family<List<MoneyDonor>, String>((ref, query) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.searchMoneyDonors(query);
});

/// Provider for money donor report
final moneyDonorReportProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final service = ref.read(moneyDonorServiceProvider);
  return service.getReport(id);
});

/// Notifier for managing money donor list state with pagination
class MoneyDonorNotifier extends StateNotifier<List<MoneyDonor>> {
  MoneyDonorNotifier() : super([]);

  final MoneyDonorService _service = MoneyDonorService();

  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String _currentQuery = '';

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<void> loadMoneyDonors({
    String query = '',
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
    _isLoading = true;

    try {
      final result = await _service.getMoneyDonors(
        page: _currentPage,
        limit: 20,
        q: query,
      );

      final donors = result['donors'] as List<MoneyDonor>;

      if (refresh) {
        state = donors;
      } else {
        state = [...state, ...donors];
      }

      _hasMore = result['hasMore'] ?? false;
      if (_hasMore) {
        _currentPage++;
      }
    } catch (e) {
      print('Error loading money donors: $e');
    } finally {
      _isLoading = false;
    }
  }

  void clearDonors() {
    state = [];
    _currentPage = 0;
    _hasMore = true;
    _currentQuery = '';
  }

  Future<void> refresh() async {
    await loadMoneyDonors(
      query: _currentQuery,
      refresh: true,
    );
  }
}

final moneyDonorNotifierProvider = StateNotifierProvider<MoneyDonorNotifier, List<MoneyDonor>>((ref) {
  return MoneyDonorNotifier();
});
