import 'package:donation/realm/realm_services.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final drawerIndexProvider = StateProvider<int?>((ref) => 0);

class HomeMenuScreen extends ConsumerStatefulWidget {
  const HomeMenuScreen({
    super.key,
  });

  @override
  ConsumerState<HomeMenuScreen> createState() => _HomeMenuScreenState();
}

class _HomeMenuScreenState extends ConsumerState<HomeMenuScreen> {
  List<String> titles = [
    'မူလစာမျက်နှာ',
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဉ်',
    'ရ/သုံး ငွေစာရင်း',
    'ထွက်မည်'
  ];
  List<String> icons = [
    'assets/images/dashboard.png',
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/log_out.png',
  ];

  @override
  Widget build(BuildContext context) {
    String? userName = '';
    String? role = '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with logo and user info
          Container(
            color: Colors.red.withOpacity(0.05),
            padding: const EdgeInsets.fromLTRB(16, 46, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/images/round_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName ?? "User",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role ?? "Member",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.withOpacity(0.3)),

          // Menu items
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: titles.length,
              itemBuilder: (BuildContext context, int index) {
                return menuItem(index);
              },
            ),
          ),

          // App version
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              'Version 1.4.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget menuItem(int index) {
    var selectedIndex = ref.watch(drawerIndexProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.red.withOpacity(0.1),
          highlightColor: Colors.transparent,
          onTap: () async {
            ref.watch(drawerControllerProvider)!.toggle!.call();

            // Handle log out separately
            if (index == 6) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('token');
              prefs.remove('name');

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            } else {
              ref.read(drawerIndexProvider.notifier).state = index;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selectedIndex == index
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  icons[index],
                  width: 24,
                  height: 24,
                  color: selectedIndex == index ? Colors.red : Colors.black54,
                ),
                const SizedBox(width: 16),
                Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: selectedIndex == index ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
