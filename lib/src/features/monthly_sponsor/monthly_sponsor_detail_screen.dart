import 'package:donation/src/features/monthly_sponsor/models/monthly_sponsor.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<MonthlySponsor> _load() =>
      ref.read(monthlySponsorServiceProvider).getSponsor(widget.sponsorId);

  void _refresh() => setState(() => _future = _load());

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    final d = DateTime.tryParse(raw);
    return d == null ? raw : DateFormat('dd MMM yyyy').format(d);
  }

  Future<void> _addOrEditDonation({MonthlySponsorDonation? donation}) async {
    final amountController =
        TextEditingController(text: donation?.amount?.toString() ?? '');
    final noteController = TextEditingController(text: donation?.note ?? '');
    DateTime selectedDate = DateTime.tryParse(donation?.date ?? '') ?? DateTime.now();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(donation == null ? 'လစဥ်လှူဒါန်းမှု ထည့်ရန်' : 'ပြင်ဆင်ရန်'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'ပမာဏ (ကျပ်)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'ပမာဏ ထည့်ပါ';
                    if (int.tryParse(v.trim()) == null) return 'ကိန်းဂဏန်းသာ ထည့်ပါ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InkWell(
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
                    decoration: const InputDecoration(
                        labelText: 'ရက်စွဲ', border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                      labelText: 'မှတ်ချက်', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('မလုပ်ပါ')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
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
              child: const Text('သိမ်းမည်', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (saved == true) _refresh();
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
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ထောက်ပံ့သူ အသေးစိတ်',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _addOrEditDonation(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('လှူဒါန်းမှု ထည့်ရန်',
            style: TextStyle(color: Colors.white)),
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              children: [
                _headerCard(s),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text('လစဥ်လှူဒါန်းမှုများ (${donations.length})',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800])),
                ),
                if (donations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('လှူဒါန်းမှု မှတ်တမ်း မရှိသေးပါ')),
                  )
                else
                  ...donations.map(_donationTile),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerCard(MonthlySponsor s) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: shadowDecoration(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.name ?? '-',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if ((s.phone ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(s.phone!, style: TextStyle(color: Colors.grey[700])),
              ]),
            ),
          if ((s.note ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(s.note!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('စုစုပေါင်း',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              Text('${_money.format(s.totalAmount ?? 0)} ကျပ်',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _donationTile(MonthlySponsorDonation d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 4),
        title: Text('${_money.format(d.amount ?? 0)} ကျပ်',
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(
          [
            _fmtDate(d.date),
            if ((d.note ?? '').isNotEmpty) d.note!,
          ].join('  •  '),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
              onPressed: () => _addOrEditDonation(donation: d),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.red),
              onPressed: () => _deleteDonation(d),
            ),
          ],
        ),
      ),
    );
  }
}
