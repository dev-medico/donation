import 'package:donation/src/features/dashboard/dashboard.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation/facebook_post_screen.dart';
import 'package:donation/src/features/donar/donar_list_screen.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:donation/src/features/home/mobile_home/home_menu.dart';
import 'package:donation/src/features/money_donor/money_donor_list_screen.dart';
import 'package:donation/src/features/monthly_sponsor/monthly_sponsor_list_screen.dart';
import 'package:donation/src/features/patient/patient_list_screen.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeMainScreen extends ConsumerStatefulWidget {
  const HomeMainScreen({
    super.key,
  });

  @override
  ConsumerState<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends ConsumerState<HomeMainScreen> {
  // List of screens to display when menu items are selected
  final List<Widget> widgets = [
    // Dashboard/Home
    DashBoardScreen(),

    // Search Member
    SearchMemberListScreen(
      fromHome: true,
    ),

    // Member List
    MemberListScreen(
      fromHome: true,
    ),

    // Donation List
    DonationListScreen(
      fromHome: true,
    ),

    // Patient List
    const PatientListScreen(fromHome: true),

    // Special Events
    SpecialEventListScreen(
      fromHome: true,
    ),

    // Donar List with tabs
    DonarListScreen(
      fromHome: true,
    ),

    // Money Donors
    const MoneyDonorListScreen(fromHome: true),

    // Monthly Sponsors
    const MonthlySponsorListScreen(fromHome: true),

    // Facebook post generator
    const FacebookPostScreen(fromHome: true),
  ];

  @override
  Widget build(BuildContext context) {
    var selectedIndex = ref.watch(drawerIndexProvider);
    assert(widgets.length == mobileHomeMenuTitles.length - 1);
    return Scaffold(
      body: widgets[selectedIndex ?? 0],
      drawer: const SizedBox(width: 0), // Empty drawer to prevent errors
    );
  }
}
