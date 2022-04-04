import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/utils/Colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = "/settings";

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
        children: [
          Row(
            children: [
              NeumorphicButton(
                child: Row(
                  children: [
                    Icon(
                      Icons.ac_unit_sharp,
                      color: NeumorphicTheme.of(context)
                          ?.current!
                          .defaultTextColor,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Change Theme",
                      style: TextStyle(
                          color: NeumorphicTheme.of(context)
                              ?.current!
                              .defaultTextColor),
                    )
                  ],
                ),
                onPressed: () {
                  if (NeumorphicTheme.of(context)!.isUsingDark) {
                    NeumorphicTheme.of(context)?.themeMode = ThemeMode.light;
                  } else {
                    NeumorphicTheme.of(context)?.themeMode = ThemeMode.dark;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
