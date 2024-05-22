import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:donation/utils/Colors.dart';

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
      backgroundColor: Colors.white,
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
              fluent.Button(
                child: Row(
                  children: [
                    Icon(
                      Icons.ac_unit_sharp,
                      color: Colors.black,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      "Change Theme",
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
                onPressed: () {
                  // if (!.isUsingDark) {
                  //   ?.themeMode = ThemeMode.light;
                  // } else {
                  //   ?.themeMode = ThemeMode.dark;
                  // }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
