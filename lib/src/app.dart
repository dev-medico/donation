import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/src/features/auth/login.dart';
import 'package:merchant/src/features/dashboard/dashboard.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list_new_style.dart';
import 'package:merchant/src/features/home/home.dart';
import 'package:merchant/src/features/new_features/member/member_list_new_style.dart';
import 'package:merchant/src/features/special_event/special_event_list.dart';
import 'package:merchant/src/features/splash_screen/splash_screen.dart';
import 'package:merchant/utils/custom_scroll.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],
      themeMode: ThemeMode.light, //or dark / system
      darkTheme: ThemeData(
        //fontFamily: 'MS',
        // baseColor: Color(0xff555555),
        accentColor: const Color(0xff333333),
        // variantColor: Colors.white,
        // defaultTextColor: Colors.white,
        // lightSource: LightSource.topLeft,
        // depth: 4,
        // intensity: 0.3,
      ),
      theme: ThemeData(
        //fontFamily: 'MS',
        // baseColor: Color(0xffDDDDDD),
        accentColor: Colors.white,
        // variantColor: Color(0xffA70507),
        // defaultTextColor: Colors.black,
        // lightSource: LightSource.topLeft,
        // depth: 6,
        // intensity: 0.5,
      ),

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case SettingsView.routeName:
                return SettingsView(controller: widget.settingsController);

              case LoginScreen.routeName:
                return const LoginScreen();
              case DashBoardScreen.routeName:
                return const DashBoardScreen();

              case NavigationHomeScreen.routeName:
                return const NavigationHomeScreen();
              case MemberListNewStyle.routeName:
                return const MemberListNewStyle();

              case BloodDonationListNewStyle.routeName:
                return const BloodDonationListNewStyle();

              case SpecialEventListScreen.routeName:
                return const SpecialEventListScreen();

              case DonarList.routeName:
                return DonarList();
              default:
                return SplashScreen();
            }
          },
        );
      },
    );
  }
}
