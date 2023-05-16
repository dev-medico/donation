import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/realm/realm_provider.dart';
import 'package:merchant/src/features/auth/login.dart';
import 'package:merchant/src/features/dashboard/dashboard.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list_new_style.dart';
import 'package:merchant/src/features/donation_member/presentation/member_list.dart';
import 'package:merchant/src/features/home/home.dart';
import 'package:merchant/src/features/special_event/event_list.dart';
import 'package:merchant/src/features/splash_screen/splash_screen.dart';
import 'package:merchant/utils/custom_scroll.dart';

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
  Widget build(BuildContext context) {
    var currentUser = ref.watch(realmServiceProvider);

    return MaterialApp(
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
      themeMode: ThemeMode.light,
      home: currentUser == null ? const LoginScreen() : NavigationHomeScreen(),
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
              case MemberListScreen.routeName:
                return const MemberListScreen();

              case BloodDonationListNewStyle.routeName:
                return const BloodDonationListNewStyle();

              case EventListScreen.routeName:
                return EventListScreen();

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
