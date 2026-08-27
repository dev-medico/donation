import 'dart:math' as math;

import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  final store = _PreviewDonorStore(_buildPreviewMembers());
  runApp(
    ProviderScope(
      overrides: [
        searchMemberRepositoryProvider.overrideWithValue(
          _PreviewSearchMemberRepository(store),
        ),
        memberRepositoryProvider
            .overrideWithValue(_PreviewMemberRepository(store)),
      ],
      child: const _FindBloodPreviewApp(),
    ),
  );
}

class _FindBloodPreviewApp extends StatelessWidget {
  const _FindBloodPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA70507)),
        fontFamily: 'MyanUni',
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: Uri.base.queryParameters['screen'] == 'donation-detail'
          ? DonationDetailScreen(
              data: _buildPreviewDonation(),
              isPreview: true,
            )
          : const SearchMemberListScreen(),
    );
  }
}

class _PreviewSearchMemberRepository extends SearchMemberRepository {
  _PreviewSearchMemberRepository(this.store);

  final _PreviewDonorStore store;

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    final normalizedQuery = (query ?? '').trim().toLowerCase();
    final matchingSearch = store.members.where((member) {
      final matchesQuery = normalizedQuery.isEmpty ||
          (member.name ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.phone ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.memberId ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.fatherName ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.bloodBankCard ?? '').toLowerCase().contains(normalizedQuery);
      final matchesBlood = bloodType == null || member.bloodType == bloodType;
      return matchesQuery && matchesBlood;
    }).toList(growable: false);

    final analysis = _analyze(matchingSearch);
    final matchingAvailability = availability == null
        ? matchingSearch
        : matchingSearch
            .where(
              (member) =>
                  DonorEligibility.fromMember(member).level.apiValue ==
                  availability,
            )
            .toList(growable: false);
    final start = page * limit;
    final end = math.min(start + limit, matchingAvailability.length);
    final pageMembers = start >= matchingAvailability.length
        ? const <Member>[]
        : matchingAvailability.sublist(start, end);

    return SearchMemberPage(
      members: pageMembers,
      total: matchingAvailability.length,
      analysis: analysis,
      page: page,
      limit: limit,
    );
  }
}

class _PreviewMemberRepository extends MemberRepository {
  _PreviewMemberRepository(this.store);

  final _PreviewDonorStore store;

  @override
  Future<Member> updateMemberAvailability(
    String id, {
    required bool canDonate,
    required String note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return store.updateAvailability(id, canDonate: canDonate, note: note);
  }
}

class _PreviewDonorStore {
  _PreviewDonorStore(List<Member> members) : members = List.of(members);

  final List<Member> members;

  Member updateAvailability(
    String id, {
    required bool canDonate,
    required String note,
  }) {
    final index = members.indexWhere((member) => member.id.toString() == id);
    if (index < 0) throw StateError('Preview member $id was not found');
    final current = members[index];
    final updated = Member(
      id: current.id,
      memberId: current.memberId,
      name: current.name,
      fatherName: current.fatherName,
      bloodType: current.bloodType,
      phone: current.phone,
      nrc: current.nrc,
      address: current.address,
      gender: current.gender,
      birthDate: current.birthDate,
      bloodBankCard: current.bloodBankCard,
      note: note,
      status: canDonate ? 'available' : 'not_available',
      lastDate: current.lastDate,
      registerDate: current.registerDate,
      memberCount: current.memberCount,
      totalCount: current.totalCount,
      profileUrl: current.profileUrl,
      canDonateValue: canDonate,
    );
    members[index] = updated;
    return updated;
  }
}

SearchMemberAnalysis _analyze(List<Member> members) {
  var green = 0;
  var yellow = 0;
  var red = 0;
  for (final member in members) {
    switch (DonorEligibility.fromMember(member).level) {
      case DonorEligibilityLevel.eligible:
        green += 1;
      case DonorEligibilityLevel.caution:
        yellow += 1;
      case DonorEligibilityLevel.disabled:
        red += 1;
    }
  }
  final now = DateTime.now();
  return SearchMemberAnalysis(
    total: members.length,
    green: green,
    yellow: yellow,
    red: red,
    calculatedOn: DateTime(now.year, now.month, now.day),
  );
}

List<Member> _buildPreviewMembers() {
  const previewCount = int.fromEnvironment(
    'FIND_BLOOD_PREVIEW_COUNT',
    defaultValue: 4528,
  );
  final now = DateTime.now();
  final recent = now.subtract(const Duration(days: 35));
  final recentWithRemark = now.subtract(const Duration(days: 70));
  final old = now.subtract(const Duration(days: 220));

  final examples = <Member>[
    Member(
      id: 1,
      memberId: 'A-0041',
      name: 'မောင်သီဟအောင်',
      bloodType: 'O (Rh +)',
      phone: '09751123456, 09761544975',
      status: 'available',
    ),
    Member(
      id: 2,
      memberId: 'A-0118',
      name: 'မသန္တာလှိုင်',
      bloodType: 'A (Rh +)',
      phone: '09449254316',
      status: 'available',
      lastDate: old.toIso8601String(),
      note: '-',
    ),
    Member(
      id: 3,
      memberId: 'B-0207',
      name: 'ကိုကျော်ဖြိုး',
      bloodType: 'B (Rh +)',
      phone: '09679574167',
      status: 'available',
      note: 'အလုပ်မှ အဆင်ပြေမည့်ရက်ကို ဖုန်းဆက်မေးပြီးမှ အတည်ပြုရန်',
    ),
    Member(
      id: 4,
      memberId: 'AB-0032',
      name: 'မောင်ဇင်လင်းထက်',
      bloodType: 'AB (Rh +)',
      phone: '09256678012',
      status: 'available',
      lastDate: recent.toIso8601String(),
    ),
    Member(
      id: 5,
      memberId: 'O-0094',
      name: 'ဒေါ်ခင်မေသက်',
      bloodType: 'O (Rh -)',
      phone: '09889910442',
      status: 'available',
      lastDate: recentWithRemark.toIso8601String(),
      note:
          'သွေးအားနည်းနေသဖြင့် နောက်တစ်ကြိမ်မခေါ်မီ ကျန်းမာရေးအခြေအနေကို မေးမြန်းရန်',
    ),
    Member(
      id: 6,
      memberId: 'A-0316',
      name: 'ကိုအောင်မြင့်',
      bloodType: 'A (Rh -)',
      phone: '09770013016',
      status: 'not_available',
      note: 'ဆေးကုသမှု ခံယူနေသဖြင့် ယာယီပိတ်ထားသည်',
    ),
    Member(
      id: 7,
      memberId: 'B-0410',
      name: 'မနွယ်နွယ်ဝင်း',
      bloodType: 'B (Rh -)',
      status: 'not_available',
    ),
    Member(
      id: 8,
      memberId: 'AB-0511',
      name: 'ဦးဝင်းနိုင်',
      bloodType: 'AB (Rh -)',
      phone: '09511130888',
      status: 'available',
      lastDate: 'ရက်စွဲမပြည့်စုံ',
    ),
  ];

  const names = [
    'ကိုဇော်မင်းထွန်း',
    'မအေးအေးမိုး',
    'ဦးသန်းဝင်း',
    'ဒေါ်နွယ်နွယ်ဦး',
    'ကိုဟိန်းထက်',
    'မစုမြတ်နိုး',
    'ဦးကျော်စိုး',
    'မခင်သဇင်',
  ];
  const bloodTypes = [
    'A (Rh +)',
    'B (Rh +)',
    'AB (Rh +)',
    'O (Rh +)',
    'A (Rh -)',
    'B (Rh -)',
    'AB (Rh -)',
    'O (Rh -)',
  ];

  final additional = List<Member>.generate(
      math.max(0, previewCount - examples.length), (offset) {
    final number = offset + 9;
    final isDisabled = offset % 17 == 0;
    final hasRemark = offset % 11 == 0;
    final hasNoDonation = offset % 13 == 0;
    final lastDonation = now.subtract(Duration(days: 12 + (offset % 260)));

    return Member(
      id: number,
      memberId: 'P-${number.toString().padLeft(4, '0')}',
      name: '${names[offset % names.length]} $number',
      fatherName: 'ဦးမောင်မောင်',
      bloodType: bloodTypes[offset % bloodTypes.length],
      bloodBankCard: 'BB-${(1000 + number)}',
      phone: '09${700000000 + number}',
      status: isDisabled ? 'not_available' : 'available',
      lastDate: hasNoDonation ? null : lastDonation.toIso8601String(),
      note: hasRemark
          ? 'နောက်တစ်ကြိမ် မခေါ်မီ အချိန်နှင့် ကျန်းမာရေးအခြေအနေကို ဖုန်းဆက်အတည်ပြုရန်'
          : '-',
    );
  });

  return [...examples, ...additional];
}

Donation _buildPreviewDonation() {
  return Donation(
    id: 15233,
    member: '4007',
    donationDate: DateTime(2026, 8, 1),
    hospital: 'ငွေမိုးဆေးရုံ',
    patientName: 'အောင်ပြည့်သန်း',
    patientAge: '65 နှစ်',
    patientAddress: 'ထန်းတပင်မြို့နယ်၊ ရန်ကုန်',
    patientDisease: 'နှလုံးရောဂါ',
    memberId: '4007',
    memberObj: Member(
      id: 4007,
      memberId: 'E-0007',
      name: 'ကိုသက်အောင်လင်း',
      fatherName: 'ဦးမျိုးမင်းဦး',
      bloodType: 'B (Rh +)',
      birthDate: '07 May 2001',
      bloodBankCard: '07-',
      status: 'available',
    ),
  );
}
