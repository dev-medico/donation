import 'package:donation/src/features/monthly_sponsor/models/monthly_sponsor.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class MonthlySponsorDetailScreen extends ConsumerStatefulWidget {
  final int sponsorId;
  const MonthlySponsorDetailScreen({super.key, required this.sponsorId});
  static const routeName = '/monthly-sponsor-detail';

  @override
  ConsumerState<MonthlySponsorDetailScreen> createState() =>
      _MonthlySponsorDetailScreenState();
}

class _MonthlySponsorDetailScreenState
    extends ConsumerState<MonthlySponsorDetailScreen> {
  late Future<MonthlySponsor> _future;
  final _money = NumberFormat.decimalPattern();
  // Set to true whenever a donation is added/edited/removed so the previous
  // screen (the list) can refresh the totals on back-press.
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<MonthlySponsor> _load() =>
      ref.read(monthlySponsorServiceProvider).getSponsor(widget.sponsorId);

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  String _fmtFullDate(String? raw) {
    final d = DateTime.tryParse(raw ?? '');
    return d == null ? (raw ?? '-') : DateFormat('dd MMM yyyy').format(d);
  }

  Future<void> _addOrEditDonation({MonthlySponsorDonation? donation}) async {
    final amountController =
        TextEditingController(text: donation?.amount?.toString() ?? '');
    final noteController = TextEditingController(text: donation?.note ?? '');
    DateTime selectedDate =
        DateTime.tryParse(donation?.date ?? '') ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(donation == null ? 'လစဥ်လှူဒါန်းမှု ထည့်ရန်' : 'ပြင်ဆင်ရန်',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'ပမာဏ',
                    suffixText: 'ကျပ်',
                    prefixIcon: Icon(Icons.payments_outlined, color: primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'ပမာဏ ထည့်ပါ';
                    if (int.tryParse(v.trim()) == null) {
                      return 'ကိန်းဂဏန်းသာ ထည့်ပါ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setSt(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'ရက်စွဲ',
                      prefixIcon:
                          Icon(Icons.event_outlined, color: primaryColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'မှတ်ချက်',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('မလုပ်ပါ')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'sponsor_id': widget.sponsorId,
                  'amount': int.parse(amountController.text.trim()),
                  'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  'note': noteController.text.trim(),
                };
                try {
                  final service = ref.read(monthlySponsorServiceProvider);
                  if (donation == null) {
                    await service.addDonation(data);
                  } else {
                    await service.updateDonation(donation.id!, data);
                  }
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('မအောင်မြင်ပါ — $e')));
                  }
                }
              },
              child:
                  const Text('သိမ်းမည်', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      _changed = true;
      _refresh(); // reflect the new donation + total immediately
    }
  }

  Future<void> _deleteDonation(MonthlySponsorDonation d) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: const Text('ဤလှူဒါန်းမှု မှတ်တမ်းကို ဖျက်မလား?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('မလုပ်ပါ')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ဖျက်မည်')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(monthlySponsorServiceProvider).deleteDonation(d.id!);
        _changed = true;
        _refresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('ဖျက်၍ မရပါ — $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Tell the list whether anything changed, so it can refresh totals.
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
        backgroundColor: const Color(0xfff4f4f6),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [primaryColor, primaryDark],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _changed),
          ),
          title: const Text('ထောက်ပံ့သူ အသေးစိတ်',
              style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: primaryColor,
          onPressed: () => _addOrEditDonation(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('လှူဒါန်းမှု ထည့်ရန်',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: FutureBuilder<MonthlySponsor>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('ရယူ၍ မရပါ — ${snap.error}',
                      textAlign: TextAlign.center),
                ),
              );
            }
            final s = snap.data!;
            final donations = s.donations ?? [];
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 96),
                children: [
                  _heroCard(s),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        Text('လစဥ်လှူဒါန်းမှုများ',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[850])),
                        const SizedBox(width: 6),
                        Text('(${donations.length})',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  if (donations.isEmpty)
                    _emptyState()
                  else
                    ...donations.map(_donationTile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroCard(MonthlySponsor s) {
    final name = (s.name ?? '').trim();
    final initial = name.isNotEmpty ? name.characters.first : '•';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: primaryColor.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white.withOpacity(0.4))),
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name ?? '-',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold)),
                    if ((s.phone ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(children: [
                          const Icon(Icons.phone,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(s.phone!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if ((s.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(s.note!,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 13)),
            ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('စုစုပေါင်း ထောက်ပံ့ငွေ',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('${_money.format(s.totalAmount ?? 0)} ကျပ်',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${s.donationCount ?? 0} လ',
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _donationTile(MonthlySponsorDonation d) {
    final date = DateTime.tryParse(d.date ?? '');
    final monthAbbr = date != null ? DateFormat('MMM').format(date) : '—';
    final year = date != null ? DateFormat('yyyy').format(date) : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(monthAbbr,
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(year,
                    style: TextStyle(
                        color: primaryColor.withOpacity(0.7), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_money.format(d.amount ?? 0)} ကျပ်',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  [
                    _fmtFullDate(d.date),
                    if ((d.note ?? '').isNotEmpty) d.note!,
                  ].join('  •  '),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[500], size: 20),
            onSelected: (v) {
              if (v == 'edit') {
                _addOrEditDonation(donation: d);
              } else if (v == 'delete') {
                _deleteDonation(d);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('ပြင်ဆင်မည်')),
              PopupMenuItem(value: 'delete', child: Text('ဖျက်မည်')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.06),
                  shape: BoxShape.circle),
              child: Icon(Icons.volunteer_activism,
                  size: 42, color: primaryColor.withOpacity(0.55)),
            ),
            const SizedBox(height: 16),
            Text('လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700])),
            const SizedBox(height: 6),
            Text('အောက်ခြေက "လှူဒါန်းမှု ထည့်ရန်" ဖြင့် စတင်ထည့်ပါ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
