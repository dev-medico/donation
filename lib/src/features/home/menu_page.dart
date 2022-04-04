import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuScreen extends StatefulWidget {
  final List<MenuItem> mainMenu;
  final Function(int)? callback;
  final int? current;

  const MenuScreen(
    this.mainMenu, {
    Key? key,
    this.callback,
    this.current,
  });

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final widthBox = const SizedBox(
    width: 16.0,
  );

  @override
  Widget build(BuildContext context) {
    const TextStyle androidStyle = TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);
    const TextStyle iosStyle = TextStyle(color: Colors.black);
    final style = kIsWeb
        ? androidStyle
        : Platform.isAndroid
            ? androidStyle
            : iosStyle;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 24.0, left: 44.0, right: 24.0),
                child: SizedBox(
                  width: 98,
                  height: 98,
                  child: SvgPicture.asset("assets/images/profile.svg"),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 36.0, left: 32.0, right: 24.0),
                child: Text(
                  "Super Staff",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // Selector<MenuProvider, int>(
              //   selector: (_, provider) => provider.currentPage,
              //   builder: (_, index, __) => Padding(
              //     padding: const EdgeInsets.only(left: 22.0),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: <Widget>[
              //         ...widget.mainMenu
              //             .map((item) => MenuItemWidget(
              //                   key: Key(item.index.toString()),
              //                   item: item,
              //                   callback: widget.callback,
              //                   widthBox: widthBox,
              //                   style: style,
              //                   selected: index == item.index,
              //                 ))
              //             .toList()
              //       ],
              //     ),
              //   ),
              // ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: OutlinedButton(
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "Log Out",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () => print("Pressed !"),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem? item;
  final Widget? widthBox;
  final TextStyle? style;
  final Function? callback;
  final bool? selected;

  const MenuItemWidget({
    Key? key,
    this.item,
    this.widthBox,
    this.style,
    this.callback,
    this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: TextButton(
        onPressed: () => callback!(item!.index),
        style: TextButton.styleFrom(
          primary: selected! ? const Color(0x44000000) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              item!.icon,
              width: 24,
            ),
            widthBox!,
            Expanded(
              child: Text(
                item!.title,
                style: style,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final String icon;
  final int index;

  const MenuItem(this.title, this.icon, this.index);
}
