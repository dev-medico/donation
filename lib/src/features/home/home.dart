import 'package:flutter/material.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/dashboard/dashboard.dart';
import 'package:merchant/src/features/donation/blood_donation_list_new_style.dart';
import 'package:merchant/src/features/home/custom_drawer/drawer_user_controller.dart';
import 'package:merchant/src/features/home/custom_drawer/home_drawer.dart';
import 'package:merchant/src/features/member/search_member.dart';
import 'package:merchant/src/features/new_features/member/member_list_new_style.dart';
import 'package:merchant/src/features/setttings/settings.dart';

class NavigationHomeScreen extends StatefulWidget {
  const NavigationHomeScreen({Key? key}) : super(key: key);
  static const routeName = "/home_drawer";

  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  Widget? screenView;
  DrawerIndex? drawerIndex;

  @override
  void initState() {
    drawerIndex = DrawerIndex.DASHBOARD;
    screenView = const DashBoardScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width * 0.68
                : MediaQuery.of(context).size.width * 0.25,
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
              //callback from drawer for replace screen as user need with passing DrawerIndex(Enum index)
            },
            screenView: screenView,
            //we replace screen view as we need on navigate starting screens like MyHomePage, HelpScreen, FeedbackScreen, etc...
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.DASHBOARD) {
        setState(() {
          screenView = const DashBoardScreen();
        });
      } else if (drawerIndex == DrawerIndex.NEWMEMBER) {
        setState(() {
          screenView = const MemberListNewStyle();
        });
      } else if (drawerIndex == DrawerIndex.RECORDS) {
        setState(() {
          animationController = AnimationController(
              duration: const Duration(milliseconds: 600), vsync: this);
          screenView = const BloodDonationListNewStyle();
        });
      } else if (drawerIndex == DrawerIndex.SEARCH) {
        setState(() {
          screenView = SearchMemberScreen();
        });
      } else {
        setState(() {
          screenView = const SettingsScreen();
        });
        //do in your way......
      }
    }
  }
}
