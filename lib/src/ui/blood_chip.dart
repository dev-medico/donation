import 'package:flutter/material.dart';

/// Compact blood-type badge used across phone list rows.
///
/// Staff scan lists for the blood group first, so every row leads with this
/// chip. Long stored labels like "B (Rh +)" render as "B+" to fit a 375px
/// screen; unknown/empty types render a neutral "—" chip so rows stay aligned.
class BloodChip extends StatelessWidget {
  final String? bloodType;
  final double size;

  const BloodChip({super.key, required this.bloodType, this.size = 40});

  static const Color _bg = Color(0xFFFDE7E7);
  static const Color _fg = Color(0xFFB00E0E);

  /// "B (Rh +)" -> "B+", "AB (Rh -)" -> "AB−", already-short values pass
  /// through. Returns "—" when unknown.
  static String short(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '—';
    final upper = v.toUpperCase();
    final group = RegExp(r'^(AB|A|B|O)').firstMatch(upper)?.group(0);
    if (group == null) {
      // Not a standard label; show first characters as-is (e.g. rare types).
      return v.length <= 3 ? v : v.substring(0, 3);
    }
    final isNegative = upper.contains('-');
    final hasSign = upper.contains('+') || isNegative;
    if (!hasSign) return group;
    return '$group${isNegative ? '−' : '+'}';
  }

  @override
  Widget build(BuildContext context) {
    final label = short(bloodType);
    final known = label != '—';
    return Container(
      width: size,
      height: size * 0.8,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: known ? _bg : const Color(0xFFF0EDED),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: known ? _fg : Colors.grey[500],
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}
