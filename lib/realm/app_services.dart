import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

final appServiceProvider = ChangeNotifierProvider<AppServices>((ref) {
  String appId = "application-0-yjtha";
  Uri baseUrl = Uri.parse("https://realm.mongodb.com");
  return AppServices(appId, baseUrl);
});

class AppServices with ChangeNotifier {
  String id;
  Uri baseUrl;
  App app;
  User? currentUser;
  AppServices(this.id, this.baseUrl)
      : app = App(AppConfiguration(id, baseUrl: baseUrl));

  Future<User> logInUserEmailPassword(String email, String password) async {
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));
    currentUser = loggedInUser;
    log("Custom User Data - ${currentUser!.customData}");
   
    final customUserData = await currentUser!.refreshCustomData();
     notifyListeners();
    return loggedInUser;
  }

  Future<User> registerUserEmailPassword(
      String email, String password, String name) async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(app);
    await authProvider.registerUser(email, password);
    User loggedInUser =
        await app.logIn(Credentials.emailPassword(email, password));
    currentUser = loggedInUser;
    notifyListeners();
    return loggedInUser;
  }

  Future<void> logOut() async {
    await currentUser?.logOut();
    currentUser = null;
  }
}
