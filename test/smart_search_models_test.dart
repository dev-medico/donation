import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmartSearchPage.fromJson', () {
    final json = <String, dynamic>{
      'status': 'ok',
      'mode': 'smart',
      'query': 'B ရှိလား',
      'parsed': {
        'chips': [
          {
            'field': 'blood_group',
            'value': 'B',
            'label': 'B (Rh ?)',
            'confidence': 0.97
          },
        ],
        'questions': [
          {
            'field': 'blood_group',
            'prompt': 'Rh factor?',
            'options': ['B+', 'B-']
          },
        ],
        'flags': <String>[],
        'urgent': false,
        'intent': 'find_donor',
        'fallback': false,
        'name_lookup': false,
        'from_cache': true,
        'model': 'jev-1.13.0',
      },
      'filters': {
        'q': '',
        'blood_groups': ['B+', 'B-'],
        'township': null,
        'township_label': '',
        'ward': 'ဇေယျာသီရိရပ်ကွက်',
        'ward_mode': 'prefer',
        'ward_kind': 'ward',
        'gender': null,
        'urgent': false,
        'availability': 'green',
        'age_min': 18,
        'age_max': 30,
        'donor_kind': 'regular',
        'hospital': 'ငွေမိုးဆေးရုံ',
        'needed': 2,
      },
      'data': [
        {
          'id': 7,
          'member_id': 'A-0007',
          'name': 'မတင်တင်',
          'blood_type': 'B (Rh +)',
          'blood_group': 'B+',
          'phone': '09777000111',
          'address': 'ဇေယျာသီရိရပ်ကွက်၊မော်လမြိုင်',
          'gender': 'female',
          'note': '-',
          'status': 'available',
          'member_count': '2',
          'total_count': '5',
          'last_date': '2026-03-01 00:00:00',
          'can_donate': true,
          'availability_state': 'green',
          'eligible_again_at': '2026-07-01',
          'township_key': 'mawlamyine',
          'township_label': 'မော်လမြိုင်',
          'ward_key': 'ဇေယျာသီရိရပ်ကွက်',
          'rank_score': 137,
          'rank_reasons': ['လှူနိုင်', 'မြို့နယ်တူ', '5 ကြိမ်လှူပြီး'],
        },
      ],
      'total': 1326,
      'analysis': {
        'total': 1326,
        'green': 1300,
        'yellow': 20,
        'red': 6,
        'calculated_on': '2026-09-19',
        'location': {
          'same_ward': 12,
          'same_ward_green': 11,
          'same_township': 455,
          'neighbour': 0
        }
      },
      'page': 0,
      'limit': 50,
      'loaded': 1,
      'has_more': true,
      'compatible': [
        {
          'id': 9,
          'member_id': 'A-0009',
          'name': 'ကိုဝင်း',
          'blood_type': 'O (Rh -)',
          'blood_group': 'O-',
          'availability_state': 'green',
          'rank_score': 120,
          'rank_reasons': ['လှူနိုင်'],
          'compatible_only': true,
        },
      ],
      'classification': {
        'as_of_date': '2026-09-19',
        'waiting_period_months': 4,
        'weights': 'normal'
      },
    };

    test('parses chips, questions, filters, donors, and compatible rows', () {
      final page = SmartSearchPage.fromJson(json);
      expect(page.mode, 'smart');
      expect(page.parsed, isNotNull);
      expect(page.parsed!.chips.single.label, 'B (Rh ?)');
      expect(page.parsed!.questions.single.options, ['B+', 'B-']);
      expect(page.parsed!.fromCache, isTrue);
      expect(page.filters.bloodGroups, ['B+', 'B-']);
      expect(page.filters.bloodGroupParam, 'B');
      expect(page.donors.single.member.name, 'မတင်တင်');
      expect(page.donors.single.member.canDonateValue, isTrue);
      expect(page.donors.single.rankScore, 137);
      expect(page.donors.single.rankReasons.length, 3);
      expect(page.donors.single.townshipLabel, 'မော်လမြိုင်');
      expect(page.compatible.single.compatibleOnly, isTrue);
      expect(page.total, 1326);
      expect(page.analysis!.green, 1300);
      expect(page.hasMore, isTrue);
      expect(page.weights, 'normal');
      expect(page.filters.ward, 'ဇေယျာသီရိရပ်ကွက်');
      expect(page.filters.wardMode, 'prefer');
      expect(page.location!.sameWard, 12);
      expect(page.location!.sameTownship, 455);
      expect(page.filters.availability, 'green');
      expect(page.filters.ageMin, 18);
      expect(page.filters.ageMax, 30);
      expect(page.filters.donorKind, 'regular');
      expect(page.filters.hospital, 'ငွေမိုးဆေးရုံ');
      expect(page.filters.needed, 2);
      final cleared =
          page.filters.copyWith(clearAge: true, clearHospital: true);
      expect(cleared.ageMin, isNull);
      expect(cleared.hospital, isNull);
      expect(cleared.donorKind, 'regular');
    });

    test('copyWith drops the quarter when the township changes', () {
      const f = SmartFilters(township: 'mawlamyine', ward: 'ဇေယျာသီရိရပ်ကွက်');
      expect(f.copyWith(township: 'mudon').ward, isNull);
      expect(f.copyWith(gender: 'female').ward, 'ဇေယျာသီရိရပ်ကွက်');
      expect(f.copyWith(clearWard: true).ward, isNull);
    });

    test('tolerates a fallback response without parsed data', () {
      final page = SmartSearchPage.fromJson({
        'status': 'ok',
        'mode': 'fallback',
        'query': 'xyz',
        'parsed': null,
        'filters': {'q': 'xyz', 'blood_groups': <String>[], 'urgent': false},
        'data': <dynamic>[],
        'total': 0,
        'analysis': null,
        'page': 0,
        'limit': 50,
        'has_more': false,
        'compatible': <dynamic>[],
        'parse_error': 'jev not configured',
      });
      expect(page.parsed, isNull);
      expect(page.parseError, 'jev not configured');
      expect(page.donors, isEmpty);
      expect(page.filters.bloodGroupParam, isNull);
    });

    test('copyWith clears and keeps filters as asked', () {
      const f = SmartFilters(
          bloodGroups: ['A+'], township: 'mudon', gender: 'male', urgent: true);
      final cleared = f.copyWith(clearTownship: true, urgent: false);
      expect(cleared.township, isNull);
      expect(cleared.gender, 'male');
      expect(cleared.urgent, isFalse);
      expect(cleared.bloodGroups, ['A+']);
    });
  });
}
