import 'package:donation/responsive.dart';
import 'package:donation/src/features/home/desktop_home.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/mobile_home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileHomeScreen();
    } else {
      return DesktopHomeScreen();
    }
  }
}
