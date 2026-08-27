/// Builds the daily Facebook post text for Red Juniors (စေတနာရှင်လူငယ်များ
/// သွေးလှူအသင်း) from the donation ledger.
///
/// The wording follows the group's established house style: one paragraph per
/// patient, listing every donor who gave for that patient, alternating between
/// a "continuing" clause (…ခဲ့ပြီး) and a "closing" clause (…ခဲ့ပါတယ်။) so the
/// paragraphs read as pairs.
///
/// Everything here is pure Dart so it can be unit tested without a widget tree.
library;

/// Complete time-of-day phrases. The ledger stores only a data-entry timestamp,
/// not the hour the donation actually happened, so this is chosen per patient
/// rather than derived from `donation_date`.
///
/// Some phrases intentionally include `ဒီနေ့` and others do not. Keep them as
/// complete display/output values instead of adding a common prefix in the UI
/// or post builder.
const List<String> kPostTimeOptions = <String>[
  'မနက်စောစော',
  'မနက်ပိုင်း',
  'ဒီနေ့မနက်',
  'နေ့လယ်ပိုင်း',
  'ဒီနေ့နေ့လယ်',
  'ညနေပိုင်း',
  'ဒီနေ့ညနေ',
  'ညနေစောင်း',
  'ဒီနေ့ည',
  kCustomNightTimeOption,
];

const String kCustomNightTimeOption = 'ည(--:--)';

const String kDefaultPostTime = 'ဒီနေ့နေ့လယ်';

const String kDefaultVolunteerHelpers =
    'Kyaw Myo Oo, Nyi Nyi , Myo Myo & Hay Mar Win';

const List<String> _myanmarDigits = <String>[
  '၀', '၁', '၂', '၃', '၄', '၅', '၆', '၇', '၈', '၉',
];

const Map<int, String> _burmeseWeekdays = <int, String>{
  DateTime.monday: 'တနင်္လာနေ့',
  DateTime.tuesday: 'အင်္ဂါနေ့',
  DateTime.wednesday: 'ဗုဒ္ဓဟူးနေ့',
  DateTime.thursday: 'ကြာသပတေးနေ့',
  DateTime.friday: 'သောကြာနေ့',
  DateTime.saturday: 'စနေနေ့',
  DateTime.sunday: 'တနင်္ဂနွေနေ့',
};

/// Converts the ASCII digits in [value] to Myanmar digits, leaving anything
/// else untouched.
String toMyanmarDigits(Object value) {
  final buffer = StringBuffer();
  for (final rune in value.toString().runes) {
    final char = String.fromCharCode(rune);
    final digit = int.tryParse(char);
    buffer.write(digit == null ? char : _myanmarDigits[digit]);
  }
  return buffer.toString();
}

String burmeseWeekday(DateTime date) =>
    _burmeseWeekdays[date.weekday] ?? '';

/// e.g. `၂၅၊ ၈၊ ၂၀၂၆ (အင်္ဂါနေ့)`
String formatPostDate(DateTime date) {
  final day = toMyanmarDigits(date.day);
  final month = toMyanmarDigits(date.month);
  final year = toMyanmarDigits(date.year);
  return '$day၊ $month၊ $year (${burmeseWeekday(date)})';
}

/// `A (Rh +)` -> `A`, `AB (Rh -)` -> `AB`. The post names only the group
/// letter, not the rhesus factor.
String bloodLetter(String? raw) {
  if (raw == null) return '';
  final match = RegExp(r'^\s*(AB|A|B|O)').firstMatch(raw.toUpperCase());
  return match?.group(1) ?? raw.trim();
}

/// Reorders a stored `patient_address` into the order the post uses.
///
/// The ledger stores the address narrowest-first:
///   `ဖာသိမ်ကျေးရွာ၊ကျိုက်မရောမြို့နယ်`             -> `ကျိုက်မရောမြို့နယ်၊ ဖာသိမ်ကျေးရွာ`
///   `ရွှေတောင်ရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်` -> `မော်လမြိုင်မြို့၊ ရွှေတောင်ရပ်ကွက်`
///
/// When a town sits between the ward and the township, the post names the town
/// rather than the township, so the broadest segment is dropped.
String patientLocation(String? raw) {
  if (raw == null) return '';
  final parts = raw
      .split('၊')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  final reversed = parts.reversed.toList();
  final kept = reversed.length >= 3 ? reversed.sublist(1) : reversed;
  return kept.join('၊ ');
}

/// Burmese member records often carry an alias after `(ခ)`. The post uses the
/// primary name only: `ကိုခိုင်မျိုးထွန်း(ခ)သဲကုန်း` -> `ကိုခိုင်မျိုးထွန်း`
String donorDisplayName(String raw) {
  final index = raw.indexOf('(ခ)');
  return (index > 0 ? raw.substring(0, index) : raw).trim();
}

final RegExp _hospitalPlace = RegExp(r'^(.+?)\s*\((.+?)\)\s*$');

/// Drops a trailing place qualifier: `အောင်ရတနာဆေးရုံ(ရန်ကုန်)` -> `အောင်ရတနာဆေးရုံ`
String hospitalShortName(String raw) {
  final match = _hospitalPlace.firstMatch(raw.trim());
  return match == null ? raw.trim() : match.group(1)!.trim();
}

/// Moves the place qualifier in front, the way the post introduces an
/// out-of-town hospital: `အောင်ရတနာဆေးရုံ(ရန်ကုန်)` -> `ရန်ကုန်မြို့၊ အောင်ရတနာဆေးရုံ`
String hospitalFullName(String raw) {
  final match = _hospitalPlace.firstMatch(raw.trim());
  if (match == null) return raw.trim();
  var place = match.group(2)!.trim();
  if (!place.contains('မြို့')) place = '${place}မြို့';
  return '$place၊ ${match.group(1)!.trim()}';
}

/// `X က` for one donor, `X နဲ့ Y တို့က` for two, `X၊ Y နဲ့ Z တို့က` for more.
String donorPhrase(List<String> names) {
  final cleaned =
      names.map((n) => n.trim()).where((n) => n.isNotEmpty).toList();
  if (cleaned.isEmpty) return '';
  if (cleaned.length == 1) return '${cleaned.first}က';
  final head = cleaned.sublist(0, cleaned.length - 1).join('၊ ');
  return '$head နဲ့ ${cleaned.last} တို့က';
}

/// One paragraph of the post: a single patient and everyone who gave for them.
class DonationPostGroup {
  DonationPostGroup({
    required this.key,
    required this.patientName,
    required this.location,
    required this.hospital,
    required this.bloodType,
    required this.donorNames,
    this.timeOfDay = kDefaultPostTime,
  });

  final String key;
  final String patientName;
  final String location;
  final String hospital;
  final String bloodType;
  final List<String> donorNames;
  String timeOfDay;

  /// One donor gives one unit, so the unit count is the donor count.
  int get unitCount => donorNames.length;
}

/// Groups the raw `/donation/by-month-year` rows for [date] by patient,
/// preserving the order in which each patient first appears.
List<DonationPostGroup> groupDonationsForPost(
  List<dynamic> rows,
  DateTime date,
) {
  final dateKey = '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  final ordered = <String>[];
  final grouped = <String, DonationPostGroup>{};

  for (final row in rows) {
    if (row is! Map) continue;
    final rawDate = row['donation_date']?.toString() ?? '';
    if (!rawDate.startsWith(dateKey)) continue;

    final patientName = (row['patient_name'] ?? '').toString().trim();
    final hospital = (row['hospital'] ?? '').toString().trim();
    if (patientName.isEmpty) continue;

    // A patient treated at two hospitals on the same day is two paragraphs.
    final patientId = row['patient_id']?.toString();
    final key = '${patientId?.isNotEmpty == true ? patientId : patientName}'
        '|$hospital';

    final member = row['memberObj'] ?? row['member0'];
    final donorName = member is Map
        ? donorDisplayName((member['name'] ?? '').toString())
        : '';
    final donorBlood = member is Map ? member['blood_type']?.toString() : null;

    final existing = grouped[key];
    if (existing == null) {
      ordered.add(key);
      grouped[key] = DonationPostGroup(
        key: key,
        patientName: patientName,
        location: patientLocation(row['patient_address']?.toString()),
        hospital: hospital,
        bloodType: bloodLetter(donorBlood),
        donorNames: donorName.isEmpty ? <String>[] : <String>[donorName],
      );
    } else {
      if (donorName.isNotEmpty) existing.donorNames.add(donorName);
      // Fill in the blood group if the first row of the group had no member.
      if (existing.bloodType.isEmpty && donorBlood != null) {
        grouped[key] = DonationPostGroup(
          key: existing.key,
          patientName: existing.patientName,
          location: existing.location,
          hospital: existing.hospital,
          bloodType: bloodLetter(donorBlood),
          donorNames: existing.donorNames,
          timeOfDay: existing.timeOfDay,
        );
      }
    }
  }

  return ordered.map((key) => grouped[key]!).toList();
}

/// How a paragraph joins to its neighbour. Paragraphs pair up: the first of a
/// pair hands off with `ခဲ့ပြီး`, the second closes it with `ကိုတော့`/`မှာပဲ`.
/// A final paragraph with no partner closes plainly.
enum _ParagraphMode { continuing, closing, standalone }

String _paragraph(DonationPostGroup group, _ParagraphMode mode) {
  final where = group.location.isEmpty ? '' : '${group.location}က ';
  final closing = mode == _ParagraphMode.closing;
  final objectParticle = closing ? 'ကိုတော့' : 'ကို';
  final timeParticle = closing ? 'မှာပဲ' : 'မှာ';
  final ending =
      mode == _ParagraphMode.continuing ? 'ခဲ့ပြီး' : 'ခဲ့ပါတယ်။';

  return '${hospitalFullName(group.hospital)}မှာ ဆေးကုသမှုခံယူနေတဲ့ $where'
      '${group.patientName}အတွက် လိုအပ်နေတဲ့'
      '(${group.bloodType})သွေး(${toMyanmarDigits(group.unitCount)})လုံး'
      '$objectParticle ${donorPhrase(group.donorNames)} '
      '${group.timeOfDay}$timeParticle '
      '${hospitalShortName(group.hospital)}ကို သွားရောက်လှူဒါန်းပေး$ending';
}

/// Renders the complete, copy-ready post.
String buildFacebookPostText({
  required DateTime date,
  required List<DonationPostGroup> groups,
  String volunteerHelpers = kDefaultVolunteerHelpers,
}) {
  final blocks = <String>[formatPostDate(date)];

  for (var i = 0; i < groups.length; i++) {
    final isLast = i == groups.length - 1;
    final mode = i.isOdd
        ? _ParagraphMode.closing
        : (isLast ? _ParagraphMode.standalone : _ParagraphMode.continuing);
    blocks.add(_paragraph(groups[i], mode));
  }

  blocks.add(
    'လူနာများသွေးလိုအပ်နေတဲ့အချိန်မှာ စိတ်အားထက်ထက်သန်သန်၊ '
    'စေတနာအားကောင်းကောင်း နဲ့ အချိန်ပေးပြီး တက်တက်ကြွကြွ သွေးလှူပေးခဲ့တဲ့ '
    'သွေးလှူရှင်များကို စေတနာရှင်လူငယ်များ သွေးလှူအသင်းက ဂုဏ်ယူစွာနဲ့ '
    'ကျေးဇူးတင်ရှိပါကြောင်း ပြောလိုပါတယ်။',
  );
  blocks.add(
    'ဆေးကုသမှုခံယူနေတဲ့ လူနာတွေလည်း ဝေဒနာတွေသက်သာပျောက်ကင်းပြီး '
    'ဆေးရုံကအမြန်ဆင်းနိုင်ပါစေလို့ ဆုမွန်တောင်းပေးလိုက်ပါတယ်။',
  );
  blocks.add('Volunteer Helper  ${volunteerHelpers.trim()}');
  blocks.add(
    '❤️❤️  Heart To Blood 🩸🩸\n'
    '🩸🩸  Blood To Heart  ❤️❤️\n'
    '❤️❤️ နှလုံးသားဆီကလာတဲ့ သွေး 🩸🩸\n'
    '🩸🩸နှလုံးသားဆီကိုအရောက်ပို့ပေး   ❤️❤️',
  );
  blocks.add('#RED_Juniors\n#Blood_Care_Unit\n#Tel: 09 756119611');

  return blocks.join('\n\n');
}
