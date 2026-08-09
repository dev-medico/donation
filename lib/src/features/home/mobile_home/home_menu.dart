import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:flutter/material.dart';
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
  String _userName = '';

  List<String> titles = [
    'မူလစာမျက်နှာ',
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဉ်',
    'ရ/သုံး ငွေစာရင်း',
    'လစဥ်ထောက်ပံ့သူများ',
    'ထွက်မည်'
  ];
  List<IconData> icons = const [
    Icons.dashboard_outlined,
    Icons.person_search_outlined,
    Icons.groups_outlined,
    Icons.bloodtype_outlined,
    Icons.event_note_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.volunteer_activism_outlined,
    Icons.logout_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('name')?.trim() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                if (_userName.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              'Version 1.5.1',
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
            if (index == 7) {
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
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: selectedIndex == index
                  ? Colors.red.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.red.withValues(alpha: 0.14)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icons[index],
                    size: 22,
                    color: selectedIndex == index ? Colors.red : Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titles[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selectedIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color:
                          selectedIndex == index ? Colors.red : Colors.black87,
                    ),
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
