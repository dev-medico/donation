import 'package:donation/responsive.dart';
import 'package:donation/src/features/finder/report_desktop.dart';
import 'package:donation/src/features/finder/report_mobile.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ReportNewScreen extends ConsumerStatefulWidget {
  const ReportNewScreen({
    super.key,
  });

  @override
  ConsumerState<ReportNewScreen> createState() => _ReportNewScreenState();
}

class _ReportNewScreenState extends ConsumerState<ReportNewScreen> {
  @override
  void initState() {
    checkInternetConnection();
    super.initState();
  }

  checkInternetConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == false) {
      Utils.messageDialog(
          "Poor Internet Connection! Please check with your Internet",
          context,
          "အိုကေ",
          Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        leading: Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Humberger(
                  onTap: () {
                    ref.watch(drawerControllerProvider)!.toggle!.call();
                  },
                ),
              )
            : null,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("RED Juniors Blood Care Unit",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: Responsive.isDesktop(context)
          ? ReportDesktopScreen()
          : ReportMobileScreen(),
    );
  }
}
