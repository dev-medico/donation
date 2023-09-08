import 'dart:developer';

import 'package:donation/responsive.dart';
import 'package:donation/src/features/home/desktop_home.dart';
import 'package:donation/src/features/home/mobile_home.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "/home";
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final _messageStreamController = BehaviorSubject<RemoteMessage>();
  String? _lastMessage;
  @override
  void initState() {
    // _messageStreamController.listen((message) {
    //   setState(() {
    //     if (message.notification != null) {
    //       _lastMessage = 'Received a notification message:'
    //           '\nTitle=${message.notification?.title},'
    //           '\nBody=${message.notification?.body},'
    //           '\nData=${message.data}';
    //     } else {
    //       _lastMessage = 'Received a data message: ${message.data}';
    //     }
    //     print("Last Message - " + _lastMessage!);
    //   });
    //});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return MobileHomeScreen();
    } else {
      return DesktopHomeScreen();
    }
  }
}
