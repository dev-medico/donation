import 'package:donation/realm/realm_services.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/donation/blood_donation_list_new_style.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/utils/tool_widgets.dart';

final openDrawerProvider = StateProvider<bool>((ref) => false);

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
  List<NavigationPaneItem> items = [];
  List<String> icons = [
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/settings.png',
  ];
  @override
  void initState() {
    super.initState();
    setDrawerListArray(titles);
  }

  switchUI() async {
    var realmServices = ref.watch(realmProvider);
    await realmServices!.sessionSwitch();
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      onOpenSearch: () {
        switchUI();
        ref.read(openDrawerProvider.notifier).update((state) => true);
      },
      pane: NavigationPane(
        size: NavigationPaneSize(
            compactWidth: Responsive.isMobile(context) ? 46 : 56,
            openWidth: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.7
                : 240),
        selected: topIndex,
        onChanged: (index) => setState(() {
          topIndex = index;
        }),
        displayMode: PaneDisplayMode.compact,
        items: items,
        footerItems: [
          PaneItem(
            onTap: () {
              ref.watch(realmProvider)!.close();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            },
            icon: CustomIcon(
              icon: icons[5],
            ),
            title: Text(
              titles[5],
              style: smallTextStyle(context),
            ),
            body: const Text(
              'အပြင်အဆင်',
            ),
          ),
        ],
      ),
    );
  }

  setDrawerListArray(List<String> titles) {
    items = [
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[0],
        ),
        title: Text(
          titles[0],
          style: smallTextStyle(context),
        ),
        body: Center(
          child: Text("Search Blood"),
        ),
      ),
      PaneItemSeparator(),
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[1],
        ),
        //infoBadge: const InfoBadge(source: Text('8')),
        title: Text(
          titles[1],
          style: smallTextStyle(context),
        ),
        body: MemberListScreen(),
      ),
      PaneItemSeparator(),
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[2],
        ),
        title: Text(
          titles[2],
          style: smallTextStyle(context),
        ),
        body: BloodDonationListNewStyle(),
      ),
      PaneItemSeparator(),
      PaneItemExpander(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[3],
        ),
        title: Text(
          titles[3],
          style: smallTextStyle(context),
        ),
        body: const Text(
          'ကုန်ပစ္စည်း',
        ),
        items: [
          PaneItem(
            selectedTileColor: ButtonState.resolveWith((state) {
              if (state.isPressing)
                return const Color.fromARGB(39, 52, 46, 226);
              if (state.isHovering)
                return const Color.fromARGB(39, 52, 46, 226);

              return null;
            }),
            icon: CustomIcon(
              icon: icons[3],
            ),
            title: Text(
              "ကုန်ပစ္စည်းမျိုးကွဲ",
              style: smallTextStyle(context),
            ),
            body: const Text(
              'ကုန်ပစ္စည်း',
            ),
          ),
          PaneItem(
            selectedTileColor: ButtonState.resolveWith((state) {
              if (state.isPressing)
                return const Color.fromARGB(39, 52, 46, 226);
              if (state.isHovering)
                return const Color.fromARGB(39, 52, 46, 226);

              return null;
            }),
            icon: CustomIcon(
              icon: icons[3],
            ),
            title: Text(
              "ကုန်ပစ္စည်း စုစည်းမှု",
              style: smallTextStyle(context),
            ),
            body: const Text(
              'ကုန်ပစ္စည်း စုစည်းမှု"',
            ),
          ),
          PaneItem(
            selectedTileColor: ButtonState.resolveWith((state) {
              if (state.isPressing)
                return const Color.fromARGB(39, 52, 46, 226);
              if (state.isHovering)
                return const Color.fromARGB(39, 52, 46, 226);

              return null;
            }),
            icon: CustomIcon(
              icon: icons[3],
            ),
            title: Text(
              "လျှော့စျေး",
              style: smallTextStyle(context),
            ),
            body: const Text(
              'လျှော့စျေး',
            ),
          ),
        ],
      ),
      PaneItemSeparator(),
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[4],
        ),
        title: Text(
          titles.isEmpty ? "ရောင်းရငွေစာရင်း" : titles[4],
          style: smallTextStyle(context),
        ),
        body: const Text(
          'ရောင်းရငွေစာရင်း',
        ),
      ),
    ];
  }

// Return the NavigationView from `Widegt Build` function
}

class CustomIcon extends StatelessWidget {
  final String icon;
  const CustomIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      icon,
      width: 24,
    );
  }
}
