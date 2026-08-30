import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_widgets/animated_widgets.dart';
import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/home/home.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/auth/login.dart';
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
  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    final prefs = await SharedPreferences.getInstance();
    // A stored token is the whole session: route on it alone, with no network
    // call and nothing that can clear it. (This used to fall into a dead
    // member re-login branch whenever the account had no phone number, which
    // wiped the session on every app start.) If the token was really revoked,
    // the first authenticated request 401s and returns to login as usual.
    final hasSession = (prefs.getString('token') ?? '').isNotEmpty;

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (hasSession) {
        // Restoring an existing session: open the same grace window used
        // after a fresh login so the home screen's first authenticated
        // request can't bounce us straight back to the login page.
        ApiClient.markLoggedIn();
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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
