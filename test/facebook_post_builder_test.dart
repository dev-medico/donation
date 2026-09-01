import 'package:donation/src/features/donation/facebook_post_builder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Real ledger rows for 2026-08-25, captured from /donation/by-month-year.
const List<Map<String, dynamic>> kAug25Rows = <Map<String, dynamic>>[
  {
    'id': 15415,
    'donation_date': '2026-08-25 22:15:58',
    'hospital': 'ရတနာမွန်ဆေးရုံ',
    'patient_id': 6470,
    'patient_name': 'ဦးခင်မောင်လွင်',
    'patient_address': 'ဖာသိမ်ကျေးရွာ၊ကျိုက်မရောမြို့နယ်',
    'memberObj': {'name': 'ကိုနိုင်းနိုင်းထက်', 'blood_type': 'A (Rh +)'}
  },
  {
    'id': 15416,
    'donation_date': '2026-08-25 22:16:41',
    'hospital': 'မေတ္တာရိပ်ဆေးခန်း',
    'patient_id': 6474,
    'patient_name': 'ဒေါ်လှဝင်း',
    'patient_address': 'ကော့ဘိန်းကျေးရွာ၊ကော့ကရိတ်မြို့နယ်',
    'memberObj': {
      'name': 'ကိုခိုင်မျိုးထွန်း(ခ)သဲကုန်း',
      'blood_type': 'O (Rh +)'
    }
  },
  {
    'id': 15417,
    'donation_date': '2026-08-25 22:17:11',
    'hospital': 'ရတနာမွန်ဆေးရုံ',
    'patient_id': 6470,
    'patient_name': 'ဦးခင်မောင်လွင်',
    'patient_address': 'ဖာသိမ်ကျေးရွာ၊ကျိုက်မရောမြို့နယ်',
    'memberObj': {'name': 'ကိုခိုင်လှထွန်းအောင်', 'blood_type': 'A (Rh +)'}
  },
  {
    'id': 15418,
    'donation_date': '2026-08-25 22:17:50',
    'hospital': 'မော်လမြိုင်ပြည်သူ့ဆေးရုံကြီး',
    'patient_id': 6473,
    'patient_name': 'ဦးသန်းဇော်',
    'patient_address': 'မုရစ်ကြီးကျေးရွာ၊ချောင်းဆုံမြို့နယ်',
    'memberObj': {'name': 'ကိုစိုးရာဇာ', 'blood_type': 'B (Rh +)'}
  },
  {
    'id': 15419,
    'donation_date': '2026-08-25 22:18:49',
    'hospital': 'မော်လမြိုင်ပြည်သူ့ဆေးရုံကြီး',
    'patient_id': 6475,
    'patient_name': 'ဦးအောင်ဝင်း',
    'patient_address': 'မုရစ်ကလေးကျေးရွာ၊ချောင်းဆုံမြို့နယ်',
    'memberObj': {'name': 'ကိုဝင်းကိုကို', 'blood_type': 'B (Rh +)'}
  },
  {
    'id': 15420,
    'donation_date': '2026-08-25 22:19:21',
    'hospital': 'ငွေမိုးဆေးရုံ',
    'patient_id': 6472,
    'patient_name': 'ဒေါ်ဝေဝေ',
    'patient_address': 'ရွှေတောင်ရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
    'memberObj': {'name': 'ကိုအောင်ကို', 'blood_type': 'A (Rh +)'}
  },
  {
    'id': 15421,
    'donation_date': '2026-08-25 22:20:00',
    'hospital': 'အောင်ရတနာဆေးရုံ(ရန်ကုန်)',
    'patient_id': 5082,
    'patient_name': 'ဦးနေလင်းထိုက်',
    'patient_address':
        'ရွှေမြိုင်သီရိရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
    'memberObj': {'name': 'မအိကေဖြိုး', 'blood_type': 'O (Rh +)'}
  },
  {
    'id': 15422,
    'donation_date': '2026-08-25 22:20:48',
    'hospital': 'အောင်ရတနာဆေးရုံ(ရန်ကုန်)',
    'patient_id': 5082,
    'patient_name': 'ဦးနေလင်းထိုက်',
    'patient_address':
        'ရွှေမြိုင်သီရိရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
    'memberObj': {'name': 'မင်းဖိုးသဇင်', 'blood_type': 'O (Rh +)'}
  },
  {
    'id': 15423,
    'donation_date': '2026-08-25 22:21:31',
    'hospital': 'ငွေမိုးဆေးရုံ',
    'patient_id': 6476,
    'patient_name': 'ဒေါ်ခင်မြတ်မွန်',
    'patient_address': 'ဖက်တန်းရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
    'memberObj': {'name': 'ကိုဝင်းဇော်ဦး', 'blood_type': 'A (Rh +)'}
  },
  {
    'id': 15424,
    'donation_date': '2026-08-25 22:21:58',
    'hospital': 'ငွေမိုးဆေးရုံ',
    'patient_id': 6476,
    'patient_name': 'ဒေါ်ခင်မြတ်မွန်',
    'patient_address': 'ဖက်တန်းရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
    'memberObj': {'name': 'ကိုမျိုးညွန့်ဦး', 'blood_type': 'A (Rh +)'}
  },
];

void main() {
  final date = DateTime(2026, 8, 25);

  group('formatting helpers', () {
    test('converts ASCII digits to Myanmar digits', () {
      expect(toMyanmarDigits(2026), '၂၀၂၆');
      expect(toMyanmarDigits(10), '၁၀');
    });

    test('formats the date header with the Burmese weekday', () {
      // 2026-08-25 is a Tuesday.
      expect(formatPostDate(date), '၂၅၊ ၈၊ ၂၀၂၆ (အင်္ဂါနေ့)');
    });

    test('reduces a blood type to its group letter', () {
      expect(bloodLetter('A (Rh +)'), 'A');
      expect(bloodLetter('AB (Rh -)'), 'AB');
      expect(bloodLetter('O (Rh +)'), 'O');
    });

    test('reorders a village address broadest-first', () {
      expect(
        patientLocation('ဖာသိမ်ကျေးရွာ၊ကျိုက်မရောမြို့နယ်'),
        'ကျိုက်မရောမြို့နယ်၊ ဖာသိမ်ကျေးရွာ',
      );
    });

    test('names the town, not the township, for a ward address', () {
      expect(
        patientLocation(
            'ရွှေတောင်ရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်'),
        'မော်လမြိုင်မြို့၊ ရွှေတောင်ရပ်ကွက်',
      );
    });

    test('drops the (ခ) alias from a donor name', () {
      expect(donorDisplayName('ကိုခိုင်မျိုးထွန်း(ခ)သဲကုန်း'),
          'ကိုခိုင်မျိုးထွန်း');
      expect(donorDisplayName('ကိုစိုးရာဇာ'), 'ကိုစိုးရာဇာ');
    });

    test('moves a hospital place qualifier to the front on first mention', () {
      expect(
        hospitalFullName('အောင်ရတနာဆေးရုံ(ရန်ကုန်)'),
        'ရန်ကုန်မြို့၊ အောင်ရတနာဆေးရုံ',
      );
      expect(hospitalShortName('အောင်ရတနာဆေးရုံ(ရန်ကုန်)'), 'အောင်ရတနာဆေးရုံ');
      expect(hospitalShortName('ငွေမိုးဆေးရုံ'), 'ငွေမိုးဆေးရုံ');
    });

    test('joins donor names the way the post does', () {
      expect(donorPhrase(['ကိုစိုးရာဇာ']), 'ကိုစိုးရာဇာက');
      expect(
        donorPhrase(['မအိကေဖြိုး', 'မင်းဖိုးသဇင်']),
        'မအိကေဖြိုး နဲ့ မင်းဖိုးသဇင် တို့က',
      );
      expect(
        donorPhrase(['က', 'ခ', 'ဂ']),
        'က၊ ခ နဲ့ ဂ တို့က',
      );
    });
  });

  group('grouping', () {
    test('collapses 10 donations into 7 patient paragraphs', () {
      final groups = groupDonationsForPost(kAug25Rows, date);
      expect(groups.length, 7);
      expect(groups.first.patientName, 'ဦးခင်မောင်လွင်');
      expect(groups.first.donorNames,
          ['ကိုနိုင်းနိုင်းထက်', 'ကိုခိုင်လှထွန်းအောင်']);
      expect(groups.first.donationIds, [15415, 15417]);
      expect(groups.first.unitCount, 2);
      expect(groups.first.bloodType, 'A');
    });

    test('hydrates a persisted time for every donation in one paragraph', () {
      final rows = kAug25Rows
          .map<Map<String, dynamic>>(Map<String, dynamic>.from)
          .toList();
      rows[0]['facebook_post_time'] = 'ည(၇:၃၀)';
      rows[2]['facebook_post_time'] = 'ည(၇:၃၀)';

      final groups = groupDonationsForPost(rows, date);

      expect(groups.first.donationIds, [15415, 15417]);
      expect(groups.first.timeOfDay, 'ည(၇:၃၀)');
      expect(groups[1].timeOfDay, kDefaultPostTime);
    });

    test('ignores donations from other days', () {
      final groups = groupDonationsForPost(kAug25Rows, DateTime(2026, 8, 24));
      expect(groups, isEmpty);
    });
  });

  group('post text', () {
    List<DonationPostGroup> groupsWithTimes(List<String> times) {
      final groups = groupDonationsForPost(kAug25Rows, date);
      for (var i = 0; i < groups.length; i++) {
        groups[i].timeOfDay = times[i];
      }
      return groups;
    }

    test('reproduces the paragraph for a two-donor patient verbatim', () {
      final text = buildFacebookPostText(
        date: date,
        groups: groupsWithTimes(const [
          'ဒီနေ့နေ့လယ်',
          'နေ့လယ်ပိုင်း',
          'ဒီနေ့နေ့လယ်',
          'နေ့လယ်ပိုင်း',
          'ဒီနေ့ညနေ',
          'ဒီနေ့ညနေ',
          'ညနေစောင်း',
        ]),
      );
      expect(
        text,
        contains(
          'ရတနာမွန်ဆေးရုံမှာ ဆေးကုသမှုခံယူနေတဲ့ ကျိုက်မရောမြို့နယ်၊ '
          'ဖာသိမ်ကျေးရွာက ဦးခင်မောင်လွင်အတွက် လိုအပ်နေတဲ့(A)သွေး(၂)လုံးကို '
          'ကိုနိုင်းနိုင်းထက် နဲ့ ကိုခိုင်လှထွန်းအောင် တို့က ဒီနေ့နေ့လယ်မှာ '
          'ရတနာမွန်ဆေးရုံကို သွားရောက်လှူဒါန်းပေးခဲ့ပြီး',
        ),
      );
    });

    test('pairs paragraphs: odd ones close with ကိုတော့/မှာပဲ', () {
      final text = buildFacebookPostText(
        date: date,
        groups: groupsWithTimes(List.filled(7, 'ဒီနေ့နေ့လယ်')),
      );
      final paragraphs = text
          .split('\n\n')
          .where((p) => p.contains('သွားရောက်လှူဒါန်းပေး'))
          .toList();
      expect(paragraphs.length, 7);
      // 0,2,4 hand off; 1,3,5 close the pair; 6 is unpaired and closes plainly.
      for (final i in [0, 2, 4]) {
        expect(paragraphs[i], endsWith('ခဲ့ပြီး'));
        expect(paragraphs[i], contains('လုံးကို '));
      }
      for (final i in [1, 3, 5]) {
        expect(paragraphs[i], endsWith('ခဲ့ပါတယ်။'));
        expect(paragraphs[i], contains('လုံးကိုတော့ '));
        expect(paragraphs[i], contains('မှာပဲ '));
      }
      expect(paragraphs[6], endsWith('ခဲ့ပါတယ်။'));
      expect(paragraphs[6], contains('လုံးကို '));
      expect(paragraphs[6], isNot(contains('မှာပဲ')));
    });

    test('keeps the fixed header, sign-off and hashtags', () {
      final text = buildFacebookPostText(
        date: date,
        groups: groupsWithTimes(List.filled(7, 'ဒီနေ့နေ့လယ်')),
        volunteerHelpers: 'Kyaw Myo Oo, Nyi Nyi',
      );
      expect(text, startsWith('၂၅၊ ၈၊ ၂၀၂၆ (အင်္ဂါနေ့)'));
      expect(text, contains('Volunteer Helper  Kyaw Myo Oo, Nyi Nyi'));
      expect(text, contains('❤️❤️  Heart To Blood 🩸🩸'));
      expect(
          text, endsWith('#RED_Juniors\n#Blood_Care_Unit\n#Tel: 09 756119611'));
    });

    test('a day with no donations still renders header and sign-off', () {
      final text = buildFacebookPostText(date: date, groups: const []);
      expect(text, startsWith('၂၅၊ ၈၊ ၂၀၂၆'));
      expect(text, contains('#RED_Juniors'));
      expect(text, isNot(contains('သွားရောက်လှူဒါန်းပေး')));
    });
  });

  test('time choices are complete phrases in the requested order', () {
    expect(kPostTimeOptions, const [
      'မနက်စောစော',
      'မနက်ပိုင်း',
      'ဒီနေ့မနက်',
      'နေ့လယ်ပိုင်း',
      'ဒီနေ့နေ့လယ်',
      'ညနေပိုင်း',
      'ဒီနေ့ညနေ',
      'ညနေစောင်း',
      'ဒီနေ့ည',
      'ည(--:--)',
    ]);
  });

  test('only real supported time values can be restored', () {
    expect(isSavedPostTime('ဒီနေ့ညနေ'), isTrue);
    expect(isSavedPostTime('ည(၇:၃၀)'), isTrue);
    expect(isSavedPostTime(kCustomNightTimeOption), isFalse);
    expect(isSavedPostTime('ည(၁၃:၀၀)'), isFalse);
    expect(isSavedPostTime('ည(၁၀:၆၀)'), isFalse);
  });
}
