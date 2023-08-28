import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:donation/realm/app_services.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/splash';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String name = "";
  String memberPhone = "";

  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      memberPhone = prefs.getString("memberPhone") ?? "";
    });
    log("Phone - " + memberPhone);
    log("name - " + memberPhone);
    Future.delayed(const Duration(seconds: 3), () async {
      if (memberPhone == "") {
        if (name == "") {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      } else {
        var appServices = ref.read(appServiceProvider);
        try {
          await appServices.logInUserEmailPassword(
              "member@gmail.com", "12345678");
        } catch (err) {}
        var member = ref.read(membersDataByPhoneProvider(memberPhone));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailScreen(
              data: member!,
            ),
          ),
        );
      }
    });
    print(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //animated zoom in image widget
          TranslationAnimatedWidget.tween(
            enabled: true,
            translationDisabled: const Offset(0, -200),
            translationEnabled: const Offset(0, 0),
            child: OpacityAnimatedWidget.tween(
              enabled: true,
              opacityDisabled: 0,
              opacityEnabled: 1,
              child: Center(
                child: Image.asset(
                  'assets/images/round_icon.png',
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.3
                      : MediaQuery.of(context).size.height / 5,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 30.0,
                  height: 1.8,
                  fontWeight: FontWeight.w400,
                  color: primaryColor,
                ),
                child: AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText(
                      'Heart To Blood\nBlood To Heart',
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  onTap: () {
                    print("Tap Event");
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
