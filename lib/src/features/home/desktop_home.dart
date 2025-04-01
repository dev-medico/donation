import 'package:donation/realm/realm_services.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/donar/donar_list.dart';
import 'package:donation/src/features/donar/donar_list_new.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:donation/src/features/feed/feed.dart';
import 'package:donation/src/features/feed/feed_admin.dart';
import 'package:donation/src/features/feed/feed_main.dart';
import 'package:donation/src/features/finder/report_new.dart';
import 'package:donation/src/features/special_event/special_event_list.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/utils/tool_widgets.dart';

final openDrawerProvider = StateProvider<bool>((ref) => false);

class DesktopHomeScreen extends ConsumerStatefulWidget {
  const DesktopHomeScreen({super.key});
  static const routeName = "/desktop_home";

  @override
  ConsumerState<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends ConsumerState<DesktopHomeScreen> {
  int selectedIndex = 0;
  List<String> titles = [
    'မူလစာမျက်နှာ',
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'ပို့စ်/အသိပေးချက်များ',
    'Log Out(V 1.3.8)'
  ];
  List<String> icons = [
    'assets/images/dashboard.png',
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/post.png',
    'assets/images/settings.png',
  ];

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    pages = [
      ReportNewScreen(), // Home/Dashboard
      SearchMemberListScreen(), // Search Blood Donors
      MemberListScreen(), // Member List
      const DonationListScreen(), // Donation List
      Container(), // Special Events
      Container(), // Finance
      Container(), // Posts/Notifications
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: !Responsive.isMobile(context),
            minWidth: Responsive.isMobile(context) ? 80 : 64,
            selectedIndex: selectedIndex,
            backgroundColor: Colors.white,
            selectedIconTheme: IconThemeData(color: Colors.red),
            selectedLabelTextStyle:
                TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Colors.black87),
            unselectedIconTheme: IconThemeData(color: Colors.black54),
            elevation: 6,
            onDestinationSelected: (index) {
              if (index == titles.length - 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
                return;
              }
              setState(() => selectedIndex = index);
            },
            destinations: List.generate(
              titles.length,
              (index) => NavigationRailDestination(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: CustomIcon(icon: icons[index]),
                ),
                label: Text(titles[index], style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
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
