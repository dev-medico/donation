import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter_test/flutter_test.dart';

/// `total_count` is derived on the server (carried-over paper count plus the
/// recorded donations). Echoing the displayed value back on save wrote that
/// derived number into the stored column, so the update payload must not
/// carry it while the rest of the record still round-trips.
void main() {
  final member = Member(
    id: 7,
    memberId: 'A-0007',
    name: 'မတင်တင်',
    fatherName: 'ဦးဘသန်း',
    bloodType: 'B (Rh +)',
    phone: '09777000111',
    nrc: '10/မလမ(နိုင်)123456',
    address: 'ဇေယျာသီရိရပ်ကွက်၊မော်လမြိုင်',
    gender: 'female',
    birthDate: '1987-10-24',
    bloodBankCard: '07-007369',
    note: '-',
    status: 'available',
    lastDate: '2026-03-01',
    registerDate: '2021-05-17',
    memberCount: '2',
    totalCount: '5',
  );

  test('the update payload leaves out the server-computed total_count', () {
    final payload = member.toUpdateJson();

    expect(payload.containsKey('total_count'), isFalse);
    expect(payload['member_count'], '2');
    expect(payload['name'], 'မတင်တင်');
    expect(payload['phone'], '09777000111');
    expect(payload['nrc'], '10/မလမ(နိုင်)123456');
    expect(payload['birth_date'], '1987-10-24');
    expect(payload['status'], 'available');
  });

  test('every other field the full serialisation carries is still sent', () {
    final full = member.toJson();
    final payload = member.toUpdateJson();

    expect(full.keys.toSet().difference(payload.keys.toSet()),
        {'total_count'});
    for (final key in payload.keys) {
      expect(payload[key], full[key], reason: '$key changed');
    }
  });

  test('total_count is still read for display', () {
    final parsed = Member.fromJson(const {
      'id': 7,
      'name': 'မတင်တင်',
      'total_count': '5',
    });

    expect(parsed.totalCount, '5');
  });
}
