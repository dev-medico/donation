import 'package:donation/src/features/monthly_sponsor/models/monthly_sponsor.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_detail_screen.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_form.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/home/mobile_home.dart';

class MonthlySponsorListScreen extends ConsumerStatefulWidget {
  const MonthlySponsorListScreen({super.key, this.fromHome = false});
  final bool fromHome;
  static const routeName = '/monthly-sponsor-list';

  @override
  ConsumerState<MonthlySponsorListScreen> createState() =>
      _MonthlySponsorListScreenState();
}

class _MonthlySponsorListScreenState
    extends ConsumerState<MonthlySponsorListScreen> {
  late Future<List<MonthlySponsor>> _future;
  final _searchController = TextEditingController();
  final _money = NumberFormat.decimalPattern();
  String _q = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<MonthlySponsor>> _load() async {
    final res = await ref
        .read(monthlySponsorServiceProvider)
        .getSponsors(q: _q, limit: 200);
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => MonthlySponsor.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({MonthlySponsor? sponsor}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlySponsorFormScreen(sponsor: sponsor),
      ),
    );
    _refresh(); // pop back -> refresh the list (reflects create/edit)
  }

  Future<void> _openDetail(MonthlySponsor s) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => MonthlySponsorDetailScreen(sponsorId: s.id!)),
    );
    _refresh();
  }

  Future<void> _delete(MonthlySponsor s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('အတည်ပြုပါ'),
        content: Text('${s.name} ကို ဖျက်ရန် သေချာပါသလား?'),
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
        await ref.read(monthlySponsorServiceProvider).deleteSponsor(s.id!);
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
        leading: widget.fromHome && Responsive.isMobile(context)
            ? IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: 'မီနူး',
                onPressed: () =>
                    ref.read(drawerControllerProvider)?.toggle?.call(),
              )
            : null,
        centerTitle: true,
        title: const Text('လစဥ်ထောက်ပံ့သူများ',
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'အမည်/ဖုန်း ဖြင့် ရှာရန်',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => _q = v,
              onSubmitted: (_) => _refresh(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MonthlySponsor>>(
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
                final sponsors = snap.data ?? [];
                if (sponsors.isEmpty) {
                  return const Center(child: Text('ထောက်ပံ့သူ မရှိသေးပါ'));
                }
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: sponsors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _tile(sponsors[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(MonthlySponsor s) {
    if (MediaQuery.sizeOf(context).width <= 360) {
      return _buildNarrowTile(s);
    }

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _openDetail(s),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(s.name ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: (s.phone ?? '').isEmpty
            ? null
            : Row(
                children: [
                  Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                  const SizedBox(width: 3),
                  Text(s.phone!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_money.format(s.totalAmount ?? 0)} ကျပ်',
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') {
                  _openForm(sponsor: s);
                } else if (v == 'delete') {
                  _delete(s);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('ပြင်ဆင်မည်')),
                PopupMenuItem(value: 'delete', child: Text('ဖျက်မည်')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowTile(MonthlySponsor sponsor) {
    final phone = sponsor.phone?.trim() ?? '';

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(sponsor),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Text(
                        sponsor.name ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _sponsorMenu(sponsor),
                ],
              ),
              if (phone.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.phone, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
              ] else
                const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${_money.format(sponsor.totalAmount ?? 0)} ကျပ်',
                        textAlign: TextAlign.end,
                        softWrap: true,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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

  Widget _sponsorMenu(MonthlySponsor sponsor) {
    return PopupMenuButton<String>(
      tooltip: 'လုပ်ဆောင်ချက်များ',
      onSelected: (value) {
        if (value == 'edit') {
          _openForm(sponsor: sponsor);
        } else if (value == 'delete') {
          _delete(sponsor);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('ပြင်ဆင်မည်')),
        PopupMenuItem(value: 'delete', child: Text('ဖျက်မည်')),
      ],
    );
  }
}
