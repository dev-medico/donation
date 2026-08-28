import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/ui/blood_chip.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class DonationsByDateScreen extends ConsumerStatefulWidget {
  const DonationsByDateScreen({
    super.key,
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  ConsumerState<DonationsByDateScreen> createState() =>
      _DonationsByDateScreenState();
}

class _DonationsByDateScreenState extends ConsumerState<DonationsByDateScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(widget.initialDate);
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _selectAnotherDate() async {
    final today = _dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2010),
      lastDate: today,
      helpText: 'လှူဒါန်းသည့်ရက် ရွေးပါ',
      cancelText: 'မရွေးတော့ပါ',
      confirmText: 'ရှာမည်',
    );

    if (!mounted || selectedDate == null) return;
    setState(() => _selectedDate = _dateOnly(selectedDate));
  }

  Future<void> _refresh() async {
    ref.invalidate(donationsByDateProvider(_selectedDate));
    await ref.read(donationsByDateProvider(_selectedDate).future);
  }

  @override
  Widget build(BuildContext context) {
    final donations = ref.watch(donationsByDateProvider(_selectedDate));
    final displayDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          '$displayDate လှူဒါန်းမှုများ',
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.isMobile(context) ? 15 : 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            key: const Key('change-donation-date'),
            tooltip: 'အခြားရက် ရွေးရန်',
            onPressed: _selectAnotherDate,
            icon: const Icon(Icons.calendar_month, color: Colors.white),
          ),
        ],
      ),
      body: donations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ErrorState(
          onRetry: () => ref.invalidate(
            donationsByDateProvider(_selectedDate),
          ),
        ),
        data: (records) => RefreshIndicator(
          onRefresh: _refresh,
          child: records.isEmpty
              ? _EmptyState(date: displayDate)
              : _DonationResults(
                  records: records,
                  date: displayDate,
                  onDonationUpdated: _refresh,
                ),
        ),
      ),
    );
  }
}

class _DonationResults extends StatelessWidget {
  const _DonationResults({
    required this.records,
    required this.date,
    required this.onDonationUpdated,
  });

  final List<Donation> records;
  final String date;
  final Future<void> Function() onDonationUpdated;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const Key('donations-by-date-list'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        Responsive.isMobile(context) ? 12 : 24,
        16,
        Responsive.isMobile(context) ? 12 : 24,
        32,
      ),
      itemCount: records.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '$date တွင် လှူဒါန်းမှု ${records.length} ကြိမ်',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          );
        }

        final donation = records[index - 1];
        return _DonationCard(
          donation: donation,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonationDetailScreen(data: donation),
              ),
            );
            await onDonationUpdated();
          },
        );
      },
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({required this.donation, required this.onTap});

  final Donation donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final member = donation.memberObj;
    final donorName = member?.name?.trim();
    final patientName = donation.patientName?.trim();
    final hospital = donation.hospital?.trim();
    final disease = donation.patientDisease?.trim();
    final memberDetails = [
      if (member?.memberId?.trim().isNotEmpty == true) member!.memberId!.trim(),
      if (member?.phone?.trim().isNotEmpty == true) member!.phone!.trim(),
    ].join(' · ');
    final donationTime = donation.donationDate == null
        ? null
        : DateFormat('hh:mm a').format(donation.donationDate!);

    return Card(
      elevation: 0,
      color: const Color(0xfff7fff9),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xff8be5a8)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BloodChip(bloodType: member?.bloodType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donorName?.isNotEmpty == true
                          ? donorName!
                          : 'အမည်မသိ အလှူရှင်',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (memberDetails.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        memberDetails,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                      ),
                    ],
                    if (patientName?.isNotEmpty == true)
                      _DetailLine(
                          icon: Icons.person_outline, text: patientName!),
                    if (hospital?.isNotEmpty == true)
                      _DetailLine(
                          icon: Icons.local_hospital_outlined, text: hospital!),
                    if (disease?.isNotEmpty == true)
                      _DetailLine(
                          icon: Icons.medical_information_outlined,
                          text: disease!),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  if (donationTime != null)
                    Text(
                      donationTime,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, size: 20, color: Colors.grey[500]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('donations-by-date-empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
        Icon(Icons.event_busy, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 14),
        Text(
          '$date တွင် လှူဒါန်းမှုမှတ်တမ်း မရှိပါ။',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          const Text('လှူဒါန်းမှုစာရင်း ရယူ၍မရပါ။'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('ပြန်လည်ကြိုးစားမည်'),
          ),
        ],
      ),
    );
  }
}
