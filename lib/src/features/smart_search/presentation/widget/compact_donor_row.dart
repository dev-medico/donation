import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/widget/ranked_donor_card.dart'
    show availabilityColor;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _primary = Color(0xFFA70507);
const _line = Color(0xFFF1F5F9);
const _border = Color(0xFFE5E7EB);
const _muted = Color(0xFF6B7280);
const _body = Color(0xFF374151);

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "2025-03-19 00:00:00" -> "19 Mar 2025"; anything unparseable comes back as is.
String formatShortDate(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) return '';
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
  if (m == null) return s;
  final month = int.tryParse(m.group(2)!) ?? 0;
  if (month < 1 || month > 12) return s;
  return '${int.parse(m.group(3)!)} ${_months[month - 1]} ${m.group(1)}';
}

/// Short Burmese label for a location tier; empty when the row has none.
String tierLabel(String tier) => switch (tier) {
      'ward' => 'ရပ်ကွက်တူ',
      'near1' => 'အနီးဆုံး (၁)',
      'near2' => 'အနီးအနား (၂)',
      'township' => 'မြို့နယ်တူ',
      'adjacent' => 'ကပ်လျက်မြို့နယ်',
      'hop2' => 'အနီးအနားမြို့နယ်',
      _ => '',
    };

Future<void> dial(String phone) async {
  final p = phone.trim();
  if (p.isEmpty) return;
  await launchUrl(Uri(scheme: 'tel', path: p));
}

/// Three-line row for phones: identity, place, latest donation.
class CompactDonorRow extends StatelessWidget {
  const CompactDonorRow({
    super.key,
    required this.rank,
    required this.donor,
    required this.onTap,
    this.compatible = false,
  });

  final int rank;
  final RankedDonor donor;
  final VoidCallback onTap;
  final bool compatible;

  @override
  Widget build(BuildContext context) {
    final member = donor.member;
    final color = availabilityColor(donor.availabilityState);
    final group = donor.bloodGroup ?? member.bloodType ?? '';
    final place = [
      if ((donor.wardKey ?? '').isNotEmpty) donor.wardKey!,
      if ((donor.townshipLabel ?? '').isNotEmpty) donor.townshipLabel!,
    ].join(' · ');
    final phone = (member.phone ?? '').trim();
    final date = formatShortDate(donor.lastDonationDate);
    final hospital = (donor.lastHospital ?? '').trim();
    final tier = tierLabel(donor.locationTier);
    final count = donor.donationTotal;
    final waiting = donor.availabilityState == 'yellow' &&
        (donor.eligibleAgainAt ?? '').isNotEmpty;

    return Material(
      color: rank.isOdd ? Colors.white : const Color(0xFFFAFAFA),
      child: InkWell(
        key: ValueKey('smart-donor-${donor.identity}'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
              bottom: const BorderSide(color: _line),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: compatible ? _muted : _primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            member.name ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GroupPill(group: group),
                        if (tier.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          TierChip(label: tier, reasons: donor.rankReasons),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    _Line(
                      icon: Icons.place_outlined,
                      children: [
                        Flexible(
                          child: Text(
                            place.isEmpty ? '-' : place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontSize: 11.5, color: _body),
                          ),
                        ),
                        if ((member.memberId ?? '').isNotEmpty)
                          Text(
                            ' · ${member.memberId}',
                            style:
                                const TextStyle(fontSize: 11.5, color: _muted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    _Line(
                      icon: Icons.history,
                      children: [
                        if (date.isEmpty)
                          const Text('မှတ်တမ်းမရှိ',
                              style: TextStyle(fontSize: 11.5, color: _muted))
                        else
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        if (hospital.isNotEmpty)
                          Flexible(
                            child: Text(
                              ' · $hospital',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontSize: 11.5, color: _body),
                            ),
                          ),
                        if (count > 0)
                          Text(
                            ' · $count×',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                      ],
                    ),
                    if (waiting)
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 1),
                        child: Text(
                          'ပြန်လှူနိုင် ${formatShortDate(donor.eligibleAgainAt)}',
                          style: TextStyle(fontSize: 11, color: color),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _RoundIcon(
                icon: Icons.phone_outlined,
                tooltip:
                    phone.isEmpty ? 'ဖုန်းနံပါတ် မရှိ' : 'ဖုန်းခေါ်ရန် $phone',
                onTap: phone.isEmpty ? null : () => dial(phone),
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Column widths for the table layout; the two optional columns drop out on
/// narrower screens.
class DonorTableLayout {
  const DonorTableLayout({required this.width});

  final double width;

  bool get wide => width >= 900;
  double get rank => 34;
  double get phone => 110;
  double get id => wide ? 64 : 0;
  double get count => 44;
  double get tier => wide ? 112 : 0;
  double get actions => 74;
  int get nameFlex => 12;
  int get placeFlex => 15;
  int get lastFlex => wide ? 15 : 13;
}

class DonorTableHeader extends StatelessWidget {
  const DonorTableHeader({super.key, required this.layout});

  final DonorTableLayout layout;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7F1D1D));
    Widget cell(String text, {double? width, int? flex, TextAlign? align}) {
      final child = Text(text, style: style, textAlign: align, maxLines: 1);
      if (width != null) return SizedBox(width: width, child: child);
      return Expanded(flex: flex ?? 1, child: child);
    }

    return Container(
      height: 30,
      padding: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFDECEC),
        border: Border(bottom: BorderSide(color: Color(0xFFF5C2C2))),
      ),
      child: Row(
        children: [
          cell('#', width: layout.rank + 4, align: TextAlign.center),
          cell('အမည် · သွေးအုပ်စု', flex: layout.nameFlex),
          const SizedBox(width: 8),
          cell('နေရပ်', flex: layout.placeFlex),
          const SizedBox(width: 8),
          cell('ဖုန်း', width: layout.phone),
          if (layout.wide) ...[
            const SizedBox(width: 8),
            cell('အမှတ်', width: layout.id),
          ],
          const SizedBox(width: 8),
          cell('နောက်ဆုံး လှူခဲ့သည့်နေ့ · နေရာ', flex: layout.lastFlex),
          const SizedBox(width: 8),
          cell('အကြိမ်', width: layout.count, align: TextAlign.right),
          if (layout.wide) ...[
            const SizedBox(width: 8),
            cell('အနီးအဝေး', width: layout.tier),
          ],
          const SizedBox(width: 8),
          SizedBox(width: layout.actions),
        ],
      ),
    );
  }
}

/// One-line row for tablets and desktops; about thirteen fit on a laptop screen.
class DonorTableRow extends StatelessWidget {
  const DonorTableRow({
    super.key,
    required this.rank,
    required this.donor,
    required this.layout,
    required this.onTap,
    this.compatible = false,
  });

  final int rank;
  final RankedDonor donor;
  final DonorTableLayout layout;
  final VoidCallback onTap;
  final bool compatible;

  @override
  Widget build(BuildContext context) {
    final member = donor.member;
    final color = availabilityColor(donor.availabilityState);
    final group = donor.bloodGroup ?? member.bloodType ?? '';
    final ward = (donor.wardKey ?? '').trim();
    final township = (donor.townshipLabel ?? '').trim();
    final phone = (member.phone ?? '').trim();
    final date = formatShortDate(donor.lastDonationDate);
    final hospital = (donor.lastHospital ?? '').trim();
    final tier = tierLabel(donor.locationTier);
    final count = donor.donationTotal;
    final waiting = donor.availabilityState == 'yellow' &&
        (donor.eligibleAgainAt ?? '').isNotEmpty;

    const small = TextStyle(fontSize: 12, color: _body);

    return Material(
      color: rank.isOdd ? Colors.white : const Color(0xFFFAFAFA),
      child: InkWell(
        key: ValueKey('smart-donor-${donor.identity}'),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
              bottom: const BorderSide(color: _line),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: layout.rank,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: compatible ? _muted : _primary,
                  ),
                ),
              ),
              Expanded(
                flex: layout.nameFlex,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name ?? '-',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GroupPill(group: group),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: layout.placeFlex,
                child: Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 13, color: _muted),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        ward.isEmpty ? township : ward,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: small,
                      ),
                    ),
                    if (ward.isNotEmpty && township.isNotEmpty)
                      Text(' · $township',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: _muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: layout.phone,
                child: Text(
                  phone.isEmpty ? '-' : phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
              if (layout.wide) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: layout.id,
                  child: Text(
                    member.memberId ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: _muted),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                flex: layout.lastFlex,
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 13, color: _muted),
                    const SizedBox(width: 3),
                    if (date.isEmpty)
                      const Text('မှတ်တမ်းမရှိ',
                          style: TextStyle(fontSize: 12, color: _muted))
                    else
                      Text(date,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87)),
                    if (hospital.isNotEmpty)
                      Flexible(
                        child: Text(
                          ' · $hospital',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small,
                        ),
                      ),
                    if (waiting)
                      Flexible(
                        child: Text(
                          ' · ပြန်လှူနိုင် ${formatShortDate(donor.eligibleAgainAt)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5, color: color),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: layout.count,
                child: Text(
                  count > 0 ? '$count×' : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87),
                ),
              ),
              if (layout.wide) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: layout.tier,
                  child: tier.isEmpty
                      ? const SizedBox.shrink()
                      : Align(
                          alignment: Alignment.centerLeft,
                          child:
                              TierChip(label: tier, reasons: donor.rankReasons),
                        ),
                ),
              ],
              const SizedBox(width: 8),
              SizedBox(
                width: layout.actions,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _RoundIcon(
                      icon: Icons.phone_outlined,
                      tooltip: phone.isEmpty
                          ? 'ဖုန်းနံပါတ် မရှိ'
                          : 'ဖုန်းခေါ်ရန် $phone',
                      onTap: phone.isEmpty ? null : () => dial(phone),
                    ),
                    const SizedBox(width: 4),
                    _RoundIcon(
                      icon: Icons.edit_note_outlined,
                      tooltip: 'မှတ်ချက် / လှူနိုင်မှု ပြင်ရန်',
                      onTap: onTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupPill extends StatelessWidget {
  const GroupPill({super.key, required this.group});
  final String group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        group,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: _primary),
      ),
    );
  }
}

class TierChip extends StatelessWidget {
  const TierChip({super.key, required this.label, this.reasons = const []});
  final String label;
  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10.5, color: Color(0xFF1B5E20)),
      ),
    );
    if (reasons.isEmpty) return chip;
    return Tooltip(message: reasons.join(' · '), child: chip);
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.children});
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        children: [
          Icon(icon, size: 12, color: _muted),
          const SizedBox(width: 3),
          ...children,
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.size = 30,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(side: BorderSide(color: _border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon,
                size: size * 0.45,
                color: onTap == null ? Colors.black26 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
