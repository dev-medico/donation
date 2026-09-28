// Local visual QA with fictional data. Not used by the production entrypoint.
import 'package:donation/src/features/donation/facebook_post_screen.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/src/features/services/special_event_service.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:donation/src/features/special_event/special_event_summary.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(
    overrides: [
      specialEventServiceProvider.overrideWithValue(_Events()),
      donationServiceProvider.overrideWithValue(_Donations()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA70507)),
        fontFamily: 'MyanUni',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: Uri.base.queryParameters['screen'] == 'post'
          ? const FacebookPostScreen()
          : const SpecialEventListScreen(),
    ),
  ));
}

class _Events extends SpecialEventService {
  @override
  Future<SpecialEventPage> getSpecialEvents(
      {int page = 0, int limit = 50, String? q}) async {
    final events = List.generate(
            12,
            (i) => <String, dynamic>{
                  'id': 12 - i,
                  'date': '2026-09-${(27 - i).toString().padLeft(2, '0')}',
                  'lab_name': i.isEven
                      ? 'နမူနာ ဓာတ်ခွဲခန်း (၁)'
                      : 'နမူနာ ဓာတ်ခွဲခန်း (၂)',
                  'haemoglobin': 1,
                  'hbs_ag': 2,
                  'hcv_ab': 1,
                  'mp_ict': 0,
                  'retro_test': 0,
                  'vdrl_test': 1,
                  'total': 5,
                })
        .where((e) => q == null || e['lab_name'].toString().contains(q))
        .toList();
    return SpecialEventPage(
        events: events,
        page: 0,
        limit: limit,
        total: events.length,
        hasMore: false,
        summary: SpecialEventSummary.fromJson({
          'recordCount': 124,
          'haemoglobin': 48,
          'hbs_ag': 96,
          'hcv_ab': 37,
          'mp_ict': 2,
          'retro_test': 9,
          'vdrl_test': 24,
        }));
  }
}

class _Donations extends DonationService {
  @override
  Future<List<dynamic>> getDonationsByMonthYear(int month, int year,
          {int limit = 500}) async =>
      [
        for (var i = 0; i < 4; i++)
          {
            'id': i + 1,
            'donation_date': DateTime.now().toIso8601String(),
            'patient_id': i + 1,
            'patient_name': 'နမူနာ လူနာ ${i + 1}',
            'patient_address': 'နမူနာ ရပ်ကွက်၊မော်လမြိုင်မြို့နယ်',
            'hospital': 'နမူနာ ဆေးရုံ',
            'memberObj': {
              'name': 'နမူနာ အလှူရှင် ${i + 1}',
              'blood_type': '${['O', 'A', 'B', 'AB'][i]} (Rh -)'
            },
          },
      ];

  @override
  Future<void> saveFacebookPostTime(
      List<int> donationIds, String timeOfDay) async {}
}
