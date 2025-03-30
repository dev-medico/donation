import 'dart:developer';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/feed/feed_main.dart';
import 'package:donation/src/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donation/src/features/services/auth_service.dart';

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
      memberPhone = prefs.getString("phone") ?? "";
    });
    log("Phone - " + memberPhone);
    log("name - " + name);

    Future.delayed(const Duration(seconds: 5), () async {
      if (memberPhone != "") {
        if (name == "") {
          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        }
      } else {
        final authService = ref.read(authServiceProvider);
        try {
          // Re-authenticate member
          await authService.memberLogin(memberPhone);

          // Get member data
          final memberFuture =
              ref.read(membersDataByPhoneProvider(memberPhone).future);
          final member = await memberFuture;

          if (member != null) {
            ref.read(loginMemberProvider.notifier).state = member;
            if (mounted) {
              // Todo
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => FeedMainScreen(
              //       data: member,
              //       isEditable: false,
              //     ),
              //   ),
              // );
            }
          } else {
            // Member not found, logout and go to login screen
            await authService.logout();
            if (mounted) {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            }
          }
        } catch (err) {
          log("Login error: $err");
          // Error in login, clear data and go to login screen
          await authService.logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          }
        }
      }
    });
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
            height: MediaQuery.of(context).size.height / 3,
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
                      'Heart To Blood\nBlood To Heart\nနှလုံးသားဆီက လာတဲ့သွေး\nနှလုံးသားဆီကို အရောက်ပို့ပေး',
                      textAlign: TextAlign.center,
                      speed: const Duration(milliseconds: 70),
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
