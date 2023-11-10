import 'dart:ffi';

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
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'ပို့စ်/အသိပေးချက်များ',
    'Log Out(V 1.3.1)'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(0.0),
                itemCount: titles.length,
                itemBuilder: (BuildContext context, int index) {
                  return inkwell(index);
                },
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget inkwell(int index) {
    var selectedIndex = ref.watch(drawerIndexProvider);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.grey.withOpacity(0.1),
          highlightColor: Colors.transparent,
          onTap: () async {
            ref.watch(drawerControllerProvider)!.toggle!.call();
            ref.read(drawerIndexProvider.notifier).state = index;
            if (index == 7) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('token');
              prefs.remove('name');

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            }
          },
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    top: Responsive.isMobile(context) ? 8.0 : 18,
                    bottom: Responsive.isMobile(context) ? 8.0 : 18,
                    left: Responsive.isMobile(context) ? 8 : 12),
                child: Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                    ),
                    Image.asset(
                      icons[index],
                      width: Responsive.isMobile(context) ? 26 : 30,
                    ),
                    SizedBox(
                      width: Responsive.isMobile(context) ? 16.0 : 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        titles[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: Responsive.isMobile(context) ? 14.5 : 15,
                          color: selectedIndex == index
                              ? Colors.red
                              : Colors.black,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              selectedIndex == index
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75 - 64,
                        height: Responsive.isMobile(context) ? 46 : 60,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
