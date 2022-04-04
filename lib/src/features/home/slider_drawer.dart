import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:merchant/src/features/dashboard/dashboard.dart';
import 'package:merchant/src/features/home/menu_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = "/home";

  static List<MenuItem> mainMenu = [
    const MenuItem("လာယူရန်", "assets/images/pick_up.svg", 0),
    const MenuItem("အသိပေးချက်များ", "assets/images/noti_menu.svg", 1),
    const MenuItem("ဘာသာစကား", "assets/images/language.svg", 2),
    const MenuItem("အကူအညီ", "assets/images/help.svg", 3),
    const MenuItem("FAQ", "assets/images/faq.svg", 4),
  ];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drawerController = ZoomDrawerController();

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZoomDrawer(
        controller: _drawerController,
        style: DrawerStyle.Style7,
        menuScreen: MenuScreen(
          HomeScreen.mainMenu,
          callback: _updatePage,
          current: _currentPage,
        ),
        mainScreen: DashBoardScreen(),
        borderRadius: 24.0,
        showShadow: true,
        angle: 0.0,
        mainScreenScale: .1,
        slideWidth: MediaQuery.of(context).size.width * (0.1),
        isRtl: false,
        clipMainScreen: true,
        backgroundColor: Colors.white,
        // openCurve: Curves.fastOutSlowIn,
        // closeCurve: Curves.bounceIn,
      ),
    );
  }

  void _updatePage(index) {
    setState(() {
      _currentPage = index;
    });
    _drawerController.toggle!();
  }
}
