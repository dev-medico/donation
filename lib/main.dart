import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
// import 'package:donation/firebase_options.dart';
import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/home/home.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

int id = 0;

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
// final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
//     StreamController<ReceivedNotification>.broadcast();

// final StreamController<String?> selectNotificationStream =
//     StreamController<String?>.broadcast();

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   // ignore: avoid_print
//   print('notification(${notificationResponse.id}) action tapped: '
//       '${notificationResponse.actionId} with'
//       ' payload: ${notificationResponse.payload}');
//   if (notificationResponse.input?.isNotEmpty ?? false) {
//     // ignore: avoid_print
//     print(
//         'notification action tapped with input: ${notificationResponse.input}');
//   }
// }

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (kDebugMode) {
//     print("Handling a background message: ${message.messageId}");
//     print('Message data: ${message.data}');
//     print('Message notification: ${message.notification?.title}');
//     print('Message notification: ${message.notification?.body}');
//   }
//   // _showNotification(message.data['title'] ?? '', message.data['body'] ?? '');
// }

// Future<void> _showNotification(String title, String body) async {
//   const AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails('notification', 'Notification',
//           channelDescription: 'Notification Channel',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker');
//   const NotificationDetails notificationDetails =
//       NotificationDetails(android: androidNotificationDetails);
//   await flutterLocalNotificationsPlugin
//       .show(id++, title, body, notificationDetails, payload: '');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // Configure API client for development/production environment
  if (kDebugMode) {
    // Set this to true to use localhost during development
    ApiClient.useLocalhost(false);
  }

  // if ((Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
  //   await DesktopWindow.setFullScreen(true);
  //   await DesktopWindow.setMinWindowSize(const Size(1280, 800));
  //   await DesktopWindow.setMaxWindowSize(const Size(6000, 6000));
  // }
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  usePathUrlStrategy();
  runApp(ProviderScope(child: MyApp(settingsController: settingsController)));
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
