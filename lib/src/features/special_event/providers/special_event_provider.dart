import 'package:donation/src/features/services/special_event_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Provider for fetching special events list
final specialEventsProvider = FutureProvider.family<List<dynamic>, int>((ref, page) async {
  final service = ref.read(specialEventServiceProvider);
  
  try {
    final events = await service.getSpecialEvents(
      page: page,
      limit: 50,
    );
    return events;
  } catch (e) {
    print('Error fetching special events: $e');
    throw e;
  }
});

// Provider for a single special event
final specialEventProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final service = ref.read(specialEventServiceProvider);
  
  try {
    final event = await service.getSpecialEventById(id);
    return event;
  } catch (e) {
    print('Error fetching special event: $e');
    throw e;
  }
});

// Provider for searching special events
final specialEventSearchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  final service = ref.read(specialEventServiceProvider);
  
  try {
    final events = await service.getSpecialEvents(
      page: 0,
      limit: 100,
      q: query,
    );
    return events;
  } catch (e) {
    print('Error searching special events: $e');
    throw e;
  }
});

// State provider for managing special event form
class SpecialEventFormState {
  final String? id;
  final DateTime date;
  final String haemoglobin;
  final String hbsAg;
  final String hcvAb;
  final String mpIct;
  final String retroTest;
  final String vdrlTest;
  final String labName;
  final String total;
  
  SpecialEventFormState({
    this.id,
    required this.date,
    required this.haemoglobin,
    required this.hbsAg,
    required this.hcvAb,
    required this.mpIct,
    required this.retroTest,
    required this.vdrlTest,
    required this.labName,
    required this.total,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'haemoglobin': haemoglobin,
      'hbs_ag': hbsAg,
      'hcv_ab': hcvAb,
      'mp_ict': mpIct,
      'retro_test': retroTest,
      'vdrl_test': vdrlTest,
      'lab_name': labName,
      'total': total,
    };
  }
  
  factory SpecialEventFormState.fromJson(Map<String, dynamic> json) {
    return SpecialEventFormState(
      id: json['id']?.toString(),
      date: DateTime.parse(json['date']),
      haemoglobin: json['haemoglobin'] ?? '',
      hbsAg: json['hbs_ag'] ?? '',
      hcvAb: json['hcv_ab'] ?? '',
      mpIct: json['mp_ict'] ?? '',
      retroTest: json['retro_test'] ?? '',
      vdrlTest: json['vdrl_test'] ?? '',
      labName: json['lab_name'] ?? '',
      total: json['total'] ?? '',
    );
  }
}

// Provider for creating special event
final createSpecialEventProvider = FutureProvider.family<Map<String, dynamic>, SpecialEventFormState>((ref, formState) async {
  final service = ref.read(specialEventServiceProvider);
  
  try {
    final result = await service.createSpecialEvent(formState.toJson());
    // Invalidate the list to refresh
    ref.invalidate(specialEventsProvider);
    return result;
  } catch (e) {
    print('Error creating special event: $e');
    throw e;
  }
});

// Provider for updating special event
final updateSpecialEventProvider = FutureProvider.family<Map<String, dynamic>, SpecialEventFormState>((ref, formState) async {
  final service = ref.read(specialEventServiceProvider);
  
  if (formState.id == null) {
    throw Exception('Event ID is required for update');
  }
  
  try {
    final result = await service.updateSpecialEvent(formState.id!, formState.toJson());
    // Invalidate the list and single event to refresh
    ref.invalidate(specialEventsProvider);
    ref.invalidate(specialEventProvider(formState.id!));
    return result;
  } catch (e) {
    print('Error updating special event: $e');
    throw e;
  }
});

// Provider for deleting special event
final deleteSpecialEventProvider = FutureProvider.family<void, String>((ref, id) async {
  final service = ref.read(specialEventServiceProvider);
  
  try {
    await service.deleteSpecialEvent(id);
    // Invalidate the list to refresh
    ref.invalidate(specialEventsProvider);
  } catch (e) {
    print('Error deleting special event: $e');
    throw e;
  }
});