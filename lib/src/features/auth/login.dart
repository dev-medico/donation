// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

import 'package:donation/realm/app_services.dart';
import 'package:donation/realm/realm_services.dart';
import 'package:donation/src/features/auth/otp.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/home/home.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/data/response/login_response/login_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:donation/src/features/auth/services/auth_service.dart';

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
  int groupValue = 0;

  @override
  void initState() {
    super.initState();
    initial();
  }

  initial() async {
    prefs = await SharedPreferences.getInstance();
    // var appServices = ref.read(appServiceProvider);
    // try {
    //   await appServices.logInUserEmailPassword("member@gmail.com", "12345678");
    // } catch (err) {}
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
                        "အကောင့်သို့ ဝင်ရောက်မည်",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1.1,
                            fontSize: Responsive.isMobile(context) ? 16 : 19,
                            color: primaryColor),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Container(
                    //     height: 60,
                    //     padding: EdgeInsets.only(
                    //         left: Responsive.isMobile(context) ? 0 : 30,
                    //         top: 20),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Radio(
                    //             value: 0,
                    //             fillColor:
                    //                 MaterialStateProperty.all(Colors.red),
                    //             groupValue: groupValue,
                    //             onChanged: (int? value) {
                    //               setState(() {
                    //                 groupValue = value!;
                    //               });
                    //             }),
                    //         InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 groupValue = 0;
                    //               });
                    //             },
                    //             child: Text("Admin")),
                    //         SizedBox(
                    //           width: 12,
                    //         ),
                    //         Radio(
                    //             value: 1,
                    //             fillColor:
                    //                 MaterialStateProperty.all(Colors.red),
                    //             groupValue: groupValue,
                    //             onChanged: (int? value) {
                    //               setState(() {
                    //                 groupValue = value!;
                    //               });
                    //             }),
                    //         InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 groupValue = 1;
                    //               });
                    //             },
                    //             child: Text("Member"))
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    Container(
                      decoration: shadowDecoration(const Color(0xfff1f1f1)),
                      margin: EdgeInsets.only(
                          left: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          right: Responsive.isMobile(context)
                              ? 30.0
                              : MediaQuery.of(context).size.width / 3,
                          top: 40),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(
                                Responsive.isMobile(context) ? 12.0 : 20),
                            child: SvgPicture.asset(
                              groupValue == 1
                                  ? "assets/images/phone.svg"
                                  : "assets/images/email.svg",
                              width: Responsive.isMobile(context) ? 28 : 34,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: Responsive.isMobile(context) ? 28.0 : 50,
                                top: Responsive.isMobile(context) ? 1 : 16,
                                right: 8),
                            child: TextFormField(
                              keyboardType: groupValue == 1
                                  ? TextInputType.number
                                  : TextInputType.text,
                              controller: email,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return groupValue == 1
                                      ? 'ဖုန်းနံပါတ် ဖြည့်သွင်းပေးပါ'
                                      : 'အီးမေးလ် ဖြည့်သွင်းပေးပါ';
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
                                hintText: groupValue == 1
                                    ? "ဖုန်းနံပါတ်"
                                    : "အီးမေးလ်",
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
                    groupValue == 1
                        ? Container(
                            margin: EdgeInsets.only(
                                left: Responsive.isMobile(context)
                                    ? 30.0
                                    : MediaQuery.of(context).size.width / 3,
                                right: Responsive.isMobile(context)
                                    ? 30.0
                                    : MediaQuery.of(context).size.width / 3,
                                top: Responsive.isMobile(context) ? 20 : 30),
                            height: 52,
                          )
                        : Container(
                            decoration:
                                shadowDecoration(const Color(0xfff1f1f1)),
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
                                    width:
                                        Responsive.isMobile(context) ? 28 : 34,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: Responsive.isMobile(context)
                                          ? 28.0
                                          : 50,
                                      top:
                                          Responsive.isMobile(context) ? 4 : 16,
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
                                            _passwordVisible =
                                                !_passwordVisible;
                                          });
                                        },
                                      ),
                                      labelStyle: TextStyle(
                                          fontSize: Responsive.isMobile(context)
                                              ? 16
                                              : 18,
                                          color: Colors.black),
                                      hintStyle: TextStyle(
                                          fontSize: Responsive.isMobile(context)
                                              ? 16
                                              : 18,
                                          color: Colors.black),
                                      contentPadding: const EdgeInsets.only(
                                          left: 24, top: 12),
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
                              ? 20
                              : MediaQuery.of(context).size.width / 3.1,
                          right: Responsive.isMobile(context)
                              ? 20
                              : MediaQuery.of(context).size.width / 3.1,
                          bottom: 34),
                      child: MaterialButton(
                          child: Container(
                            height: Responsive.isMobile(context) ? 52 : 60,
                            decoration: shadowDecoration(secondColor),
                            child: Center(
                              child: Text(
                                "ဝင်ရောက်မည်",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 16 : 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (groupValue == 1) {
                              // firebaseLogin();
                            } else {
                              if (_formKey.currentState!.validate()) {
                                realmLogin();
                              }
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

  // firebaseLogin() async {
  //   prefs.remove('name');
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   var member = ref.read(membersDataByPhoneProvider(email.text.toString()));
  //   if (member != null) {
  //     log("+95" + email.text.toString().replaceAll(" ", "").substring(1));

  //     FirebaseAuth auth = FirebaseAuth.instance;
  //     await auth.verifyPhoneNumber(
  //       phoneNumber:
  //           "+95" + email.text.toString().replaceAll(" ", "").substring(1),
  //       verificationCompleted: (PhoneAuthCredential credential) async {
  //         var user = await auth.signInWithCredential(credential);
  //         user.user!.getIdToken(true).toString();
  //       },
  //       timeout: const Duration(seconds: 120),
  //       verificationFailed: (FirebaseAuthException e) {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         if (e.code == 'invalid-phone-number') {
  //           Utils.messageDialog("The Provided Phone No. is not valid!", context,
  //               "ပြင်ဆင်မည်", Colors.black);
  //         } else {
  //           Utils.messageDialog(
  //               e.message.toString(), context, "OK", Colors.black);
  //         }
  //       },
  //       codeSent: (String verificationId, int? resendToken) async {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => OTPScreen(
  //                       phone: email.text.toString(),
  //                       member: member,
  //                       verificationId: verificationId,
  //                     )));
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {},
  //     );
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     Utils.messageDialog(
  //         "ဖုန်းနံပါတ်မှားနေပါသည်", context, "ပြင်ဆင်မည်", Colors.black);
  //   }
  // }

  realmLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(
        email.text.toString(),
        password.text.toString(),
      );

      setState(() {
        _isLoading = false;
      });

      await saveLogin(response);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });
      Utils.messageDialog(err.toString(), context, "ပြင်ဆင်မည်", Colors.black);
    }
  }

  saveLogin(LoginResponse response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", response.token.toString());
    prefs.setString("userName", response.user!.name!.toString());
    prefs.setString("userPhone", response.user!.phones![0].toString());
    Navigator.pushNamedAndRemoveUntil(
        context, HomeScreen.routeName, (Route<dynamic> route) => false);
  }
}
