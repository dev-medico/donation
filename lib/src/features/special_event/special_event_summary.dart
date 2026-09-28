import 'package:flutter/material.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';

class SpecialEventSummary {
  const SpecialEventSummary({required this.recordCount, required this.counts});

  static const labels = {
    'haemoglobin': 'Haemoglobin (Hb)',
    'hbs_ag': 'HBs Ag',
    'hcv_ab': 'HCV Ab',
    'mp_ict': 'MP ICT',
    'retro_test': 'Retro Test',
    'vdrl_test': 'VDRL Test',
  };

  factory SpecialEventSummary.fromJson(Map<String, dynamic> json) {
    int number(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
    return SpecialEventSummary(
      recordCount: number(json['recordCount']),
      counts: Map.unmodifiable({
        for (final key in labels.keys) key: number(json[key]),
      }),
    );
  }

  final int recordCount;
  final Map<String, int> counts;
  int get totalFindings => counts.values.fold(0, (sum, count) => sum + count);
}

/// All-time totals are supplied by the server, never summed from a list page.
class SpecialEventSummaryView extends StatelessWidget {
  const SpecialEventSummaryView(
      {super.key, required this.summary, required this.onRefresh});

  final SpecialEventSummary? summary;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final data = summary;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey('special-event-all-time-summary'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The selected tab already reads မှတ်တမ်းချုပ်; say what
                  // the numbers cover instead of repeating it.
                  Text('ကာလအားလုံး၊ ဓာတ်ခွဲခန်းအားလုံး',
                      style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  const SizedBox(height: 12),
                  if (data == null) ...[
                    const Text(
                        'မှတ်တမ်းချုပ် ရယူ၍ မရသေးပါ။ ပြန်လည်ကြိုးစားပါ။'),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('ပြန်ယူမည်')),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: primaryColor.withValues(alpha: 0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('တွေ့ရှိချက် စုစုပေါင်း',
                              style: TextStyle(
                                  color: primaryDark,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(Utils.strToMM(data.totalFindings.toString()),
                                  key: const ValueKey(
                                      'special-event-findings-total'),
                                  style: TextStyle(
                                      fontSize: 34,
                                      height: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark)),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                    'မှတ်တမ်း ${Utils.strToMM(data.recordCount.toString())} ခုမှ',
                                    key: const ValueKey(
                                        'special-event-all-time-record-count'),
                                    style: TextStyle(color: Colors.grey[800])),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('စစ်ဆေးချက်အလိုက်',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    for (final entry in SpecialEventSummary.labels.entries)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey.shade200))),
                        child: Row(children: [
                          Expanded(
                              child: Text(entry.value,
                                  style: const TextStyle(fontSize: 15))),
                          const SizedBox(width: 12),
                          Text(
                              Utils.strToMM(
                                  (data.counts[entry.key] ?? 0).toString()),
                              key: ValueKey('special-event-total-${entry.key}'),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    const SizedBox(height: 12),
                    Text(
                        'မှတ်တမ်းတစ်ခုတွင် တွေ့ရှိချက်တစ်ခုထက်ပို၍ ပါဝင်နိုင်ပါသည်။',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
