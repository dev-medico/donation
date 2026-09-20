import 'package:donation/src/features/smart_search/presentation/widget/compact_donor_row.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatShortDate handles timestamps, dates and junk', () {
    expect(formatShortDate('2025-03-19 00:00:00'), '19 Mar 2025');
    expect(formatShortDate('2026-07-01'), '1 Jul 2026');
    expect(formatShortDate(null), '');
    expect(formatShortDate('  '), '');
    expect(formatShortDate('sometime'), 'sometime');
  });

  test('tierLabel covers every tier', () {
    expect(tierLabel('ward'), isNotEmpty);
    expect(tierLabel('hop2'), isNotEmpty);
    expect(tierLabel(''), '');
  });

  test('rankReasonCaption keeps the server wording and order', () {
    expect(
      rankReasonCaption(['လှူနိုင်', 'ရပ်ကွက်တူ', '5 ကြိမ်လှူပြီး']),
      'လှူနိုင် · ရပ်ကွက်တူ · 5 ကြိမ်လှူပြီး',
    );
    expect(rankReasonCaption(['ဖုန်းနံပါတ် မပြည့်စုံ']), 'ဖုန်းနံပါတ် မပြည့်စုံ');
    expect(rankReasonCaption(['  ', 'လှူနိုင်']), 'လှူနိုင်');
    expect(rankReasonCaption(const []), '');
  });
}
