import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/auth/login.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer(
      {Key? key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;
  String? userName;
  String? role;

  @override
  void initState() {
    setDrawerListArray();
    super.initState();
    initial();
  }

  initial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("name");
      role = prefs.getString("role");
    });
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.DASHBOARD,
        labelName: 'မူလ စာမျက်နှာ',
        isAssetsImage: true,
        imageName: 'assets/images/home.svg',
      ),
      DrawerList(
        index: DrawerIndex.NEWMEMBER,
        labelName: 'အဖွဲ့၀င် စာရင်း',
        isAssetsImage: true,
        imageName: 'assets/images/record.svg',
      ),
      DrawerList(
        index: DrawerIndex.RECORDS,
        labelName: 'သွေးလှူမှု မှတ်တမ်း',
        isAssetsImage: true,
        imageName: 'assets/images/record.svg',
      ),
      DrawerList(
        index: DrawerIndex.SEARCH,
        labelName: 'သွေးလှူရှင် ရှာမည်',
        isAssetsImage: true,
        imageName: 'assets/images/search.svg',
      ),
      // DrawerList(
      //   index: DrawerIndex.REPORT,
      //   labelName: 'အစီရင်ခံစာများ',
      //   isAssetsImage: true,
      //   imageName: 'assets/images/report.svg',
      // ),
      // DrawerList(
      //   index: DrawerIndex.SETTINGS,
      //   labelName: 'Settings',
      //   isAssetsImage: true,
      //   imageName: 'assets/images/setting.svg',
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            color: const Color(0xffF4F4F4),
            padding: const EdgeInsets.fromLTRB(0, 46, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                AnimatedBuilder(
                  animation: widget.iconAnimationController!,
                  builder: (BuildContext context, Widget? child) {
                    return ScaleTransition(
                      scale: AlwaysStoppedAnimation<double>(
                          1.0 - (widget.iconAnimationController!.value) * 0.2),
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation<double>(
                            Tween<double>(begin: 0.0, end: 24.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.iconAnimationController!,
                                        curve: Curves.fastOutSlowIn))
                                    .value /
                                360),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: SvgPicture.asset(
                            'assets/images/profile.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20),
                  child: Text(
                    userName ?? "-",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 20),
                  child: Text(
                    role ?? "-",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(
            height: 12,
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.6),
          ),
          Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  onTapped();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/log_out.svg",
                            width: 28,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          const Text(
                            'ထွက်မည်',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          'V 1.0.3',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              )
            ],
          ),
        ],
      ),
    );
  }

  void onTapped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index!);
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
                  listData.isAssetsImage
                      ? SvgPicture.asset(
                          listData.imageName,
                          color: widget.screenIndex == listData.index
                              ? Colors.red
                              : Colors.black,
                          width: Responsive.isMobile(context) ? 26 : 30,
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index
                              ? Colors.red
                              : Colors.black),
                  SizedBox(
                    width: Responsive.isMobile(context) ? 16.0 : 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      listData.labelName,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: Responsive.isMobile(context) ? 14.5 : 16,
                        color: widget.screenIndex == listData.index
                            ? Colors.red
                            : Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) *
                                (1.0 -
                                    widget.iconAnimationController!.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 64,
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
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex {
  DASHBOARD,
  NEWMEMBER,
  RECORDS,
  SEARCH,
  // REPORT,
  // SETTINGS,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
