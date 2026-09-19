import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:flutter/material.dart';

Color availabilityColor(String state) => switch (state) {
      'green' => const Color(0xFF2E7D32),
      'yellow' => const Color(0xFFF9A825),
      _ => const Color(0xFFC62828),
    };

/// One ranked donor: rank badge, identity, where they live, why they rank here.
class RankedDonorCard extends StatelessWidget {
  const RankedDonorCard({
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          key: ValueKey('smart-donor-${donor.identity}'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _RankBadge(rank: rank, muted: compatible),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  member.name ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _GroupPill(group: group, color: color),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              if (place.isNotEmpty)
                                _Meta(icon: Icons.place_outlined, text: place),
                              if (phone.isNotEmpty)
                                _Meta(icon: Icons.phone_outlined, text: phone),
                              if ((member.memberId ?? '').isNotEmpty)
                                _Meta(
                                  icon: Icons.badge_outlined,
                                  text: member.memberId!,
                                ),
                            ],
                          ),
                          if (donor.rankReasons.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              donor.rankReasons.join(' · '),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: color.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (donor.availabilityState == 'yellow' &&
                              (donor.eligibleAgainAt ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'ပြန်လှူနိုင်မည့်ရက် ${donor.eligibleAgainAt}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank, required this.muted});
  final int rank;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: muted ? const Color(0xFFF3F4F6) : const Color(0xFFFDECEC),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: muted ? Colors.black54 : const Color(0xFFA70507),
        ),
      ),
    );
  }
}

class _GroupPill extends StatelessWidget {
  const _GroupPill({required this.group, required this.color});
  final String group;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        group,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: color,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.black45),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
      ],
    );
  }
}
