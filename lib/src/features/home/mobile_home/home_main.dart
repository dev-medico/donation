import 'package:donation/realm/realm_services.dart';
import 'package:donation/src/features/donar/donar_list.dart';
import 'package:donation/src/features/donar/donar_list_new.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:donation/src/features/feed/feed_admin.dart';
import 'package:donation/src/features/finder/report_new.dart';
import 'package:donation/src/features/home/mobile_home/home_menu.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/src/features/special_event/special_event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeMainScreen extends ConsumerStatefulWidget {
  const HomeMainScreen({
    super.key,
  });

  @override
  ConsumerState<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends ConsumerState<HomeMainScreen> {
  List<String> titles = [
    'မူလစာမျက်နှာ',
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'အပြင်အဆင်'
  ];

  List<Widget> widgets = [
    ReportNewScreen(),
    // Todo
    // SearchMemberListScreen(
    //   fromHome: true,
    // ),
    // MemberListScreen(
    //   fromHome: true,
    // ),
    // DonationListScreen(
    //   fromHome: true,
    // ),
    // SpecialEventListScreen(
    //   fromHome: true,
    // ),
    // DonarListNewScreen(
    //   fromHome: true,
    // ),
    // Todo
    // FeedAdminScreen(
    //   fromHome: true,
    // ),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    var selectedIndex = ref.watch(drawerIndexProvider);
    return widgets[selectedIndex ?? 0];
  }
}
