import 'package:donation/realm/realm_services.dart';
import 'package:donation/src/features/donar/donar_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:donation/src/features/finder/report.dart';
import 'package:donation/src/features/home/mobile_home/home_main.dart';
import 'package:donation/src/features/home/mobile_home/home_menu.dart';
import 'package:donation/src/features/special_event/special_event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/utils/tool_widgets.dart';

final openDrawerProvider = StateProvider<bool>((ref) => false);
final drawerControllerProvider =
    StateProvider<ZoomDrawerController?>((ref) => ZoomDrawerController());

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});
  static const routeName = "/mobile_home";

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int topIndex = 0;
  List<String> titles = [
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'အပြင်အဆင်'
  ];

  List<String> icons = [
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/settings.png',
  ];

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: ref.watch(drawerControllerProvider),
      style: DrawerStyle.defaultStyle,
      menuScreen: HomeMenuScreen(),
      mainScreen: HomeMainScreen(),
      borderRadius: 5.0,
      showShadow: true,
      angle: 0,
      menuScreenTapClose: false,
      mainScreenTapClose: true,
      menuBackgroundColor: Colors.white,
      drawerShadowsBackgroundColor: Colors.grey,
      slideWidth: MediaQuery.of(context).size.width * .70,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.fastLinearToSlowEaseIn,
    );
  }
}

class CustomIcon extends StatelessWidget {
  final String icon;
  const CustomIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      width: 32,
    );
  }
}
