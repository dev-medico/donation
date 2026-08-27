import 'package:donation/src/features/home/mobile_home/home_main.dart';
import 'package:donation/src/features/home/mobile_home/home_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final openDrawerProvider = StateProvider<bool>((ref) => false);
final drawerControllerProvider =
    StateProvider<ZoomDrawerController?>((ref) => ZoomDrawerController());

class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});
  static const routeName = "/mobile_home";

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // flutter_zoom_drawer otherwise subtracts an internal offset from
    // slideWidth when sizing the menu. On a 320 px phone that left barely
    // enough room for the icons and clipped every Burmese label.
    final drawerWidth = (screenWidth * 0.86).clamp(280.0, 360.0).toDouble();

    return ZoomDrawer(
      controller: ref.watch(drawerControllerProvider),
      style: DrawerStyle.defaultStyle,
      menuScreen: HomeMenuScreen(),
      mainScreen: HomeMainScreen(),
      borderRadius: 5.0,
      showShadow: true,
      angle: 0,
      menuScreenTapClose: false,
      mainScreenTapClose: true,
      menuBackgroundColor: Colors.white,
      drawerShadowsBackgroundColor: Colors.grey,
      slideWidth: drawerWidth,
      menuScreenWidth: drawerWidth,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.fastLinearToSlowEaseIn,
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
