
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/donar/donar_list_screen.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:donation/src/features/finder/report_new.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/utils/Colors.dart';

final openDrawerProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  static const routeName = "/home";
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<String> titles = [
    'မူလစာမျက်နှာ',
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'Log Out(V 1.3.8)'
  ];
  
  final List<String> icons = [
    'assets/images/dashboard.png',
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/log_out.svg',
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
      const SpecialEventListScreen(), // Special Events
      const DonarListScreen(), // Finance - Donar List with tabs
      Container(), // Placeholder for logout
    ];
  }

  void _onDestinationSelected(int index) {
    if (index == titles.length - 1) {
      // Logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      return;
    }
    setState(() => selectedIndex = index);
    // Close drawer on mobile after selection
    if (Responsive.isMobile(context) && _scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'RED Juniors',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Blood Care Unit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...List.generate(
              titles.length,
              (index) => ListTile(
                leading: _buildIcon(icons[index]),
                title: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selectedIndex == index 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                    color: selectedIndex == index 
                        ? primaryColor 
                        : Colors.black87,
                  ),
                ),
                selected: selectedIndex == index,
                selectedTileColor: primaryColor.withValues(alpha: 0.1),
                onTap: () => _onDestinationSelected(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          selectedIndex == icons.indexOf(iconPath) 
              ? primaryColor 
              : Colors.black54,
          BlendMode.srcIn,
        ),
      );
    } else {
      return Image.asset(
        iconPath,
        width: 24,
        height: 24,
        color: selectedIndex == icons.indexOf(iconPath) 
            ? primaryColor 
            : Colors.black54,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);
    
    if (isMobile) {
      // Mobile layout with drawer
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            titles[selectedIndex],
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: _buildDrawer(),
        body: pages[selectedIndex],
      );
    } else {
      // Desktop and tablet layout with NavigationRail
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: !isTablet, // Collapsed on tablet, extended on desktop
              minWidth: isTablet ? 64 : 72,
              selectedIndex: selectedIndex,
              backgroundColor: Colors.white,
              selectedIconTheme: IconThemeData(color: primaryColor),
              selectedLabelTextStyle: TextStyle(
                color: primaryColor, 
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelTextStyle: const TextStyle(color: Colors.black87),
              unselectedIconTheme: const IconThemeData(color: Colors.black54),
              elevation: 4,
              onDestinationSelected: _onDestinationSelected,
              destinations: List.generate(
                titles.length,
                (index) => NavigationRailDestination(
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildIcon(icons[index]),
                  ),
                  label: Text(
                    titles[index], 
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: pages[selectedIndex],
            ),
          ],
        ),
      );
    }
  }
}
