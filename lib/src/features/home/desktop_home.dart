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
import 'package:fluent_ui/fluent_ui.dart';
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
  int topIndex = 0;
  List<String> titles = [
    'သွေးလှူရှင် ရှာမည်',
    'အဖွဲ့ဝင် စာရင်း',
    'သွေးလှူမှု မှတ်တမ်း',
    'ထူးခြားဖြစ်စဥ်',
    'ရ/သုံး ငွေစာရင်း',
    'ပို့စ်/အသိပေးချက်များ',
    'Log Out(V 1.3.7)'
  ];
  List<NavigationPaneItem> items = [];
  List<String> icons = [
    'assets/images/search_list.png',
    'assets/images/members.png',
    'assets/images/donations.png',
    'assets/images/special_case.png',
    'assets/images/finance.png',
    'assets/images/post.png',
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
    return SafeArea(
      top: true,
      child: NavigationView(
        onOpenSearch: () {
          switchUI();
          ref.read(openDrawerProvider.notifier).update((state) => true);
        },
        pane: NavigationPane(
          size: NavigationPaneSize(
              compactWidth: Responsive.isMobile(context) ? 80 : 64,
              openWidth: Responsive.isMobile(context)
                  ? MediaQuery.of(context).size.width * 0.7
                  : 250),
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
                icon: icons[6],
              ),
              title: Text(
                titles[6],
                style: smallTextStyle(context),
              ),
              body: const Text(
                'အပြင်အဆင်',
              ),
            ),
          ],
        ),
      ),
    );
  }

  setDrawerListArray(List<String> titles) {
    items = [
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return Color.fromARGB(39, 103, 103, 111);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: "assets/images/dashboard.png",
        ),
        title: Text(
          "ပင်မစာမျက်နှာ",
          style: smallTextStyle(context),
        ),
        body: ReportNewScreen(),
      ),
      PaneItemSeparator(),
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
        body: SearchMemberListScreen(),
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
        body: DonationListScreen(),
      ),
      PaneItemSeparator(),
      PaneItem(
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
        body: SpecialEventListScreen(),
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
          titles[4],
          style: smallTextStyle(context),
        ),
        body: DonarListNewScreen(),
      ),
      PaneItemSeparator(),
      PaneItem(
        selectedTileColor: ButtonState.resolveWith((state) {
          if (state.isPressing) return const Color.fromARGB(39, 52, 46, 226);
          if (state.isHovering) return const Color.fromARGB(39, 52, 46, 226);

          return null;
        }),
        icon: CustomIcon(
          icon: icons[5],
        ),
        title: Text(
          titles[5],
          style: smallTextStyle(context),
        ),
        body: FeedAdminScreen(),
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
      width: 32,
    );
  }
}
