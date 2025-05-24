import 'package:donation/src/features/services/request_give_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Provider for fetching request give list
final requestGivesProvider = FutureProvider.family<List<dynamic>, int>((ref, page) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    final requestGives = await service.getRequestGives(
      page: page,
      limit: 50,
    );
    return requestGives;
  } catch (e) {
    print('Error fetching request gives: $e');
    throw e;
  }
});

// Provider for a single request give
final requestGiveProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    final requestGive = await service.getRequestGiveById(id);
    return requestGive;
  } catch (e) {
    print('Error fetching request give: $e');
    throw e;
  }
});

// Provider for searching request gives
final requestGiveSearchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    final requestGives = await service.getRequestGives(
      page: 0,
      limit: 100,
      q: query,
    );
    return requestGives;
  } catch (e) {
    print('Error searching request gives: $e');
    throw e;
  }
});

// State provider for managing request give form
class RequestGiveFormState {
  final String? id;
  final String request;
  final String give;
  final DateTime date;
  
  RequestGiveFormState({
    this.id,
    required this.request,
    required this.give,
    required this.date,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'request': request,
      'give': give,
      'date': date.toIso8601String().split('T')[0],
    };
  }
  
  factory RequestGiveFormState.fromJson(Map<String, dynamic> json) {
    return RequestGiveFormState(
      id: json['id']?.toString(),
      request: json['request'] ?? '',
      give: json['give'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
}

// Provider for creating request give
final createRequestGiveProvider = FutureProvider.family<Map<String, dynamic>, RequestGiveFormState>((ref, formState) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    final result = await service.createRequestGive(formState.toJson());
    // Invalidate the list to refresh
    ref.invalidate(requestGivesProvider);
    return result;
  } catch (e) {
    print('Error creating request give: $e');
    throw e;
  }
});

// Provider for updating request give
final updateRequestGiveProvider = FutureProvider.family<Map<String, dynamic>, RequestGiveFormState>((ref, formState) async {
  final service = ref.read(requestGiveServiceProvider);
  
  if (formState.id == null) {
    throw Exception('Request Give ID is required for update');
  }
  
  try {
    final result = await service.updateRequestGive(formState.id!, formState.toJson());
    // Invalidate the list and single item to refresh
    ref.invalidate(requestGivesProvider);
    ref.invalidate(requestGiveProvider(formState.id!));
    return result;
  } catch (e) {
    print('Error updating request give: $e');
    throw e;
  }
});

// Provider for deleting request give
final deleteRequestGiveProvider = FutureProvider.family<void, String>((ref, id) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    await service.deleteRequestGive(id);
    // Invalidate the list to refresh
    ref.invalidate(requestGivesProvider);
  } catch (e) {
    print('Error deleting request give: $e');
    throw e;
  }
});

// Provider for request give yearly stats
final requestGiveYearlyStatsProvider = FutureProvider.family<RequestGiveYearlyStats, int>((ref, year) async {
  final service = ref.read(requestGiveServiceProvider);
  
  try {
    final requestGives = await service.getRequestGives(page: 0, limit: 1000);
    
    // Filter by year and calculate stats
    final yearData = requestGives.where((item) {
      final date = DateTime.parse(item['date']);
      return date.year == year;
    }).toList();
    
    // Group by month
    Map<int, int> requestsByMonth = {};
    Map<int, int> givesByMonth = {};
    
    for (var item in yearData) {
      final date = DateTime.parse(item['date']);
      final month = date.month;
      
      requestsByMonth[month] = (requestsByMonth[month] ?? 0) + (int.tryParse(item['request'] ?? '0') ?? 0);
      givesByMonth[month] = (givesByMonth[month] ?? 0) + (int.tryParse(item['give'] ?? '0') ?? 0);
    }
    
    return RequestGiveYearlyStats(
      year: year,
      requestsByMonth: requestsByMonth,
      givesByMonth: givesByMonth,
      totalRequests: requestsByMonth.values.fold(0, (sum, value) => sum + value),
      totalGives: givesByMonth.values.fold(0, (sum, value) => sum + value),
    );
  } catch (e) {
    print('Error fetching request give yearly stats: $e');
    throw e;
  }
});

class RequestGiveYearlyStats {
  final int year;
  final Map<int, int> requestsByMonth;
  final Map<int, int> givesByMonth;
  final int totalRequests;
  final int totalGives;
  
  RequestGiveYearlyStats({
    required this.year,
    required this.requestsByMonth,
    required this.givesByMonth,
    required this.totalRequests,
    required this.totalGives,
  });
}