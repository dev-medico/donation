import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/data/response/login_response/login_response.dart';
import 'package:donation/realm/realm_provider.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/home/home.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulHookConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = "/login";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _passwordVisible = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late SharedPreferences prefs;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      color: Colors.black,
      progressIndicator: const SpinKitCircle(
        color: Colors.white,
        size: 60.0,
      ),
      dismissible: false,
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              ListView(
                  padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
                  shrinkWrap: true,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 42),
                        child: Image.asset(
                          "assets/images/round_icon.png",
                          height: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width / 3
                              : MediaQuery.of(context).size.height / 5,
                        )),
                    Padding(
                      padding: const EdgeInsets.only(top: 36),
                      child: Text(
                        "အကောင့်သို့ ၀င်ရောက်မည်",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.1,
                            fontSize: Responsive.isMobile(context) ? 16 : 19,
                            color: primaryColor),
                      ),
                    ),
                    Container(
                      decoration: shadowDecoration(const Color(0xfff1f1f1)),
                      margin: EdgeInsets.only(
                          left: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          right: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          top: MediaQuery.of(context).size.height / 13),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                                Responsive.isMobile(context) ? 12.0 : 20),
                            child: SvgPicture.asset(
                              "assets/images/email.svg",
                              width: Responsive.isMobile(context) ? 28 : 34,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isMobile(context) ? 28.0 : 50,
                                top: Responsive.isMobile(context) ? 1 : 16,
                                right: 8),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: email,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'အီးမေးလ် ဖြည့်သွင်းပေးပါ';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                height: 1.0,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "အီးမေးလ်",
                                labelStyle: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.black),
                                hintStyle: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.black),
                                contentPadding: const EdgeInsets.only(
                                  left: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: shadowDecoration(const Color(0xfff1f1f1)),
                      margin: EdgeInsets.only(
                          left: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          right: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          top: Responsive.isMobile(context) ? 20 : 30),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                                Responsive.isMobile(context) ? 12.0 : 20),
                            child: SvgPicture.asset(
                              "assets/images/password.svg",
                              width: Responsive.isMobile(context) ? 28 : 34,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isMobile(context) ? 28.0 : 50,
                                top: Responsive.isMobile(context) ? 4 : 16,
                                right: 8),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: password,
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'စကားဝှက် ဖြည့်သွင်းပေးပါ';
                                }
                                return null;
                              },
                              style: const TextStyle(
                                height: 1.0,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "စကားဝှက်",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: const Color(0xffE5E5E5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                                labelStyle: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.black),
                                hintStyle: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.black),
                                contentPadding:
                                    const EdgeInsets.only(left: 24, top: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 12,
                          left: Responsive.isMobile(context)
                              ? 12
                              : MediaQuery.of(context).size.width / 3.1,
                          right: Responsive.isMobile(context)
                              ? 12
                              : MediaQuery.of(context).size.width / 3.1,
                          bottom: 34),
                      child: MaterialButton(
                          child: Container(
                            height: Responsive.isMobile(context) ? 52 : 60,
                            decoration: shadowDecoration(secondColor),
                            child: Center(
                              child: Text(
                                "၀င််ရောက်မည်",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              realmLogin();
                            }
                          }),
                    ),
                  ]),
              // const Align(alignment: Alignment.bottomCenter, child: AppFooter()),
            ],
          ),
        ),
      ),
    );
  }

  firebaseLogin() async {
    setState(() {
      _isLoading = true;
    });

    // try {
    //   //Signed in with temporary account.
    //   final userCredential = await FirebaseAuth.instance.signInAnonymously();
    // } on FirebaseAuthException catch (e) {
    //   switch (e.code) {
    //     case "operation-not-allowed":
    //       print("Anonymous auth hasn't been enabled for this project.");
    //       break;
    //     default:
    //       print("Unknown error.");
    //   }
    // }
    CollectionReference admins = FirebaseFirestore.instance.collection('admin');
    bool auth = false;
    admins.get().then((value) {
      for (var element in value.docs) {
        log(element.data().toString());
        final data = element.data() as Map<String, dynamic>;
        log(data["email"]);
        log(data["password"]);
        if (data["email"] == email.text.toString() &&
            data["password"] == password.text.toString()) {
          prefs.setString("name", data["name"]);
          prefs.setString("email", data["email"]);
          prefs.setString("role", data["role"]);
          setState(() {
            auth = true;
          });
        }
      }

      if (auth) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushNamedAndRemoveUntil(context, MobileHomeScreen.routeName,
            (Route<dynamic> route) => false);
      } else {
        setState(() {
          _isLoading = false;
        });
        Utils.messageDialog(
            "အချက်အလက်မှားယွင်းနေပါသည်", context, "ပြင်ဆင်မည်", Colors.black);
      }
    });
  }

  realmLogin() async {
    setState(() {
      _isLoading = true;
    });
    var appServices = ref.read(appServiceProvider);
    try {
      await appServices.logInUserEmailPassword(
          email.text.toString(), password.text.toString());
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, MobileHomeScreen.routeName,
            (Route<dynamic> route) => false);
      }
    } catch (err) {
      Utils.messageDialog(err.toString(), context, "ပြင်ဆင်မည်", Colors.black);
    }
  }

  saveLogin(LoginResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", response.token.toString());
    prefs.setString("userName", response.user!.name!.toString());
    prefs.setString("userPhone", response.user!.phones![0].toString());
    Navigator.pushNamedAndRemoveUntil(
        context, MobileHomeScreen.routeName, (Route<dynamic> route) => false);
  }
}
