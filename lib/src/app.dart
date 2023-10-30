import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donar/donar_list_new.dart';
import 'package:donation/src/features/donation/controller/donation_provider.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_list_back_up.dart';
import 'package:donation/src/features/home/desktop_home.dart';
import 'package:donation/src/features/home/home.dart';
import 'package:donation/src/features/special_event/special_event_list.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/auth/login.dart';
import 'package:donation/src/features/dashboard/dashboard.dart';
import 'package:donation/src/features/donar/donar_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/home/home_with_drawer.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/splash_screen/splash_screen.dart';
import 'package:donation/utils/custom_scroll.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   final realm = ref.read(realmProvider)!.realm;
    //   realm.write(() {
    //     realm.deleteAll<ExpensesRecord>();
    //     realm.deleteAll<DonarRecord>();
    //   });

      //   var donations = ref.watch(donationProvider);
      //   var members = ref.watch(membersDataProvider);
      //   int totalUpdate = 0;
      //   members.forEach(
      //     (element) {
      //       ref.watch(realmProvider)!.updateMember(element,
      //           memberCount: donations
      //               .where((member) =>
      //                   element.memberId.toString() == member.memberId.toString())
      //               .length
      //               .toString());
      //       totalUpdate++;
      //     },
      //   );
      //   log("Total Updated - " + totalUpdate.toString());

      //   log("ကို - " +
      //       members
      //           .where((element) =>
      //               element.name.toString().startsWith("ကို") ||
      //               element.name.toString().startsWith(" ကို") ||
      //               element.name.toString().startsWith("ဦး") ||
      //               element.name.toString().startsWith(" ဦး") ||
      //               element.name.toString().startsWith("စိုင်း") ||
      //               element.name.toString().startsWith("ဦး") ||
      //               element.name.toString().startsWith("နိုင်") ||
      //               element.name.toString().startsWith("အရှင်") ||
      //               element.name.toString().startsWith("စော"))
      //           .length
      //           .toString());

      //   log("မ - " +
      //       members
      //           .where((element) =>
      //               element.name.toString().startsWith("မ") ||
      //               element.name.toString().startsWith("ဒေါ်") ||
      //               element.name.toString().startsWith("နော်") ||
      //               element.name.toString().startsWith("ဒေါ်"))
      //           .length
      //           .toString());
      //   log("Other - " +
      //       members
      //           .where((element) =>
      //               (!(element.name.toString().startsWith("ကို") ||
      //                       element.name.toString().startsWith(" ကို") ||
      //                       element.name.toString().startsWith("ဦး") ||
      //                       element.name.toString().startsWith(" ဦး") ||
      //                       element.name.toString().startsWith("အရှင်") ||
      //                       element.name.toString().startsWith("စိုင်း") ||
      //                       element.name.toString().startsWith("ဦး") ||
      //                       element.name.toString().startsWith("နိုင်") ||
      //                       element.name.toString().startsWith("စော")) &&
      //                   !(element.name.toString().startsWith("မ") ||
      //                       element.name.toString().startsWith("ဒေါ်") ||
      //                       element.name.toString().startsWith("နော်") ||
      //                       element.name.toString().startsWith("ဒေါ်"))))
      //           .length
      //           .toString());

      //   members
      //       .where((element) =>
      //           element.name.toString().startsWith("ကို") ||
      //           element.name.toString().startsWith(" ကို") ||
      //           element.name.toString().startsWith("ဦး") ||
      //           element.name.toString().startsWith(" ဦး") ||
      //           element.name.toString().startsWith("စိုင်း") ||
      //           element.name.toString().startsWith("ဦး") ||
      //           element.name.toString().startsWith("နိုင်") ||
      //           element.name.toString().startsWith("အရှင်") ||
      //           element.name.toString().startsWith("စော"))
      //       .forEach((element) {
      //     ref.watch(realmProvider)!.updateMember(element, gender: "male");
      //   });
      //   members
      //       .where((element) =>
      //           element.name.toString().startsWith("မ") ||
      //           element.name.toString().startsWith("ဒေါ်") ||
      //           element.name.toString().startsWith("နော်") ||
      //           element.name.toString().startsWith("ဒေါ်"))
      //       .forEach((element) {
      //     ref.watch(realmProvider)!.updateMember(element, gender: "female");
      //   });
      //   members
      //       .where((element) => (!(element.name.toString().startsWith("ကို") ||
      //               element.name.toString().startsWith(" ကို") ||
      //               element.name.toString().startsWith("ဦး") ||
      //               element.name.toString().startsWith(" ဦး") ||
      //               element.name.toString().startsWith("အရှင်") ||
      //               element.name.toString().startsWith("စိုင်း") ||
      //               element.name.toString().startsWith("ဦး") ||
      //               element.name.toString().startsWith("နိုင်") ||
      //               element.name.toString().startsWith("စော")) &&
      //           !(element.name.toString().startsWith("မ") ||
      //               element.name.toString().startsWith("ဒေါ်") ||
      //               element.name.toString().startsWith("နော်") ||
      //               element.name.toString().startsWith("ဒေါ်"))))
      //       .forEach((element) {
      //     ref.watch(realmProvider)!.updateMember(element, gender: "female");
      //   });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = ref.watch(realmProvider);

    return FluentApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      theme: FluentThemeData(
        fontFamily: "MyanUni",
      ),
      themeMode: ThemeMode.light,
      home: SplashScreen(),
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

              case MobileHomeScreen.routeName:
                return const MobileHomeScreen();
              case HomeScreen.routeName:
                return const HomeScreen();
              case DesktopHomeScreen.routeName:
                return const DesktopHomeScreen();
              case MemberListScreen.routeName:
                return const MemberListScreen();

              case MemberListBackupScreen.routeName:
                return const MemberListBackupScreen();

              case DonationListScreen.routeName:
                return const DonationListScreen();

              case SpecialEventListScreen.routeName:
                return const SpecialEventListScreen();

              // case EventListScreen.routeName:
              //   return EventListScreen();

              case DonarListNewScreen.routeName:
                return DonarListNewScreen();
              default:
                return SplashScreen();
            }
          },
        );
      },
    );
  }
}
