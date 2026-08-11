import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 11, 23, 30);

  group('DonorEligibility', () {
    test('manual switch off is red even with a remark and recent donation', () {
      final result = DonorEligibility.fromMember(
        Member(
          status: 'not_available',
          note: 'ဆေးသောက်နေပါသည်',
          lastDate: '2026-07-01 12:00:00',
        ),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.disabled);
      expect(result.hasRemark, isTrue);
      expect(result.isWaiting, isTrue);
    });

    test('explicit API can_donate flag takes priority over legacy status', () {
      final member = Member.fromJson({
        'status': 'available',
        'can_donate': false,
      });

      expect(member.canDonate, isFalse);
      expect(
        DonorEligibility.fromMember(member, now: now).level,
        DonorEligibilityLevel.disabled,
      );
    });

    test('a real remark is yellow and preserved for display', () {
      final result = DonorEligibility.fromMember(
        Member(
          status: 'available',
          note: 'ဖုန်းဆက်ပြီးမှ လှူဒါန်းရန်',
          lastDate: '2026-01-01',
        ),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.caution);
      expect(result.remark, 'ဖုန်းဆက်ပြီးမှ လှူဒါန်းရန်');
    });

    test('legacy dash notes are empty and do not turn a donor yellow', () {
      for (final note in [null, '', '   ', '-', '—', '–']) {
        final result = DonorEligibility.fromMember(
          Member(
            status: 'available',
            note: note,
            lastDate: '2026-01-01',
          ),
          now: now,
        );

        expect(result.level, DonorEligibilityLevel.eligible, reason: '$note');
        expect(result.hasRemark, isFalse, reason: '$note');
      }
    });

    test('less than four calendar months is yellow with eligible date', () {
      final result = DonorEligibility.fromMember(
        Member(status: 'available', lastDate: '2026-04-12'),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.caution);
      expect(result.isWaiting, isTrue);
      expect(result.nextEligibleDate, DateTime(2026, 8, 12));
      expect(result.remainingMonths, 0);
      expect(result.remainingDays, 1);
    });

    test('exactly four calendar months is green', () {
      final result = DonorEligibility.fromMember(
        Member(status: 'available', lastDate: '2026-04-11 23:59:59'),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.eligible);
      expect(result.isWaiting, isFalse);
      expect(result.nextEligibleDate, DateTime(2026, 8, 11));
      expect(result.remainingMonths, 0);
      expect(result.remainingDays, 0);
    });

    test('no last donation is green when the switch is on and note is empty',
        () {
      final result = DonorEligibility.fromMember(
        Member(status: 'available'),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.eligible);
      expect(result.lastDonationDate, isNull);
    });

    test('an invalid non-empty last date is safely yellow', () {
      final result = DonorEligibility.fromMember(
        Member(status: 'available', lastDate: 'not-a-date'),
        now: now,
      );

      expect(result.level, DonorEligibilityLevel.caution);
      expect(result.hasInvalidLastDonationDate, isTrue);
    });

    test('calendar month addition clamps the end of month', () {
      expect(
        DonorEligibility.addCalendarMonths(DateTime(2025, 10, 31), 4),
        DateTime(2026, 2, 28),
      );
      expect(
        DonorEligibility.addCalendarMonths(DateTime(2023, 10, 31), 4),
        DateTime(2024, 2, 29),
      );
    });

    test('remaining wait is shown as calendar months and days', () {
      final result = DonorEligibility.fromMember(
        Member(status: 'available', lastDate: '2026-06-20'),
        now: now,
      );

      expect(result.nextEligibleDate, DateTime(2026, 10, 20));
      expect(result.remainingMonths, 2);
      expect(result.remainingDays, 9);
    });
  });
}
