import 'dart:async';
import 'dart:developer';
import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/feed/feed_main.dart';
import 'package:donation/src/features/new_features/member/member_detail_new_style.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String? phone;
  final Member? member;
  final String? verificationId;
  const OTPScreen(
      {Key? key,
      required this.phone,
      required this.verificationId,
      required this.member})
      : super(key: key);
  @override
  ConsumerState<OTPScreen> createState() => NewRegisterOTPState();
}

class NewRegisterOTPState extends ConsumerState<OTPScreen> {
  String enterOTP = "";

  String? fire_token;
  int requestTime = 2;
  String operatorImg = "";

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final _formKey = GlobalKey<FormState>();

  final controller3 = TextEditingController();
  final controller4 = TextEditingController();
  String? error1;
  String? verificationId;

  String? error2;
  String? error3;
  String? error4;

  bool isMyanmar = true;
  bool isLoading = false;
  String language = "";
  SharedPreferences? prefs;
  Timer? _timer;
  int _start = 300;
  String timeLeft = "-";

  @override
  void initState() {
    startTimer();
    super.initState();
    verificationId = widget.verificationId;
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            timeLeft = "Resend OTP Code";
          });
        } else {
          setState(() {
            _start--;
            Duration d = Duration(seconds: _start);
            timeLeft = d.toString().split(".").first;
            timeLeft = timeLeft.substring(2, timeLeft.length);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    final mqData = MediaQuery.of(context);
    final mqDataNew = mqData.copyWith(
        textScaleFactor:
            mqData.textScaleFactor > 1.0 ? 1.0 : mqData.textScaleFactor);

    return Form(
      key: _formKey,
      child: MediaQuery(
        data: mqDataNew,
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text("OTP Confirmation",
                    style: TextStyle(fontSize: 17, color: Colors.white)),
              ),
              centerTitle: true,
              backgroundColor: primaryColor,
            ),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                ListView(
                  shrinkWrap: true,
                  physics: Responsive.isMobile(context)
                      ? NeverScrollableScrollPhysics()
                      : ClampingScrollPhysics(),
                  children: [
                    Container(
                      width: double.infinity,
                      margin: Responsive.isMobile(context)
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 3,
                              right: MediaQuery.of(context).size.width / 3,
                              top: 80),
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 40, bottom: 8, left: 20, right: 20),
                            child: Text(
                              "ဖုန်းနံပါတ် \"${widget.phone}\" သို့ ပေးပို့လာသော OTP ကုဒ် ၆ လုံးအား ထည့်သွင်းပါ။",
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          InkWell(
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: 20, bottom: 8, left: 20, right: 20),
                                child: Center(
                                  child: Text(
                                    timeLeft,
                                    style: TextStyle(
                                        fontSize: timeLeft == "Resend OTP Code"
                                            ? 18
                                            : 22.0,
                                        color: primaryColor),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            onTap: () {
                              if (timeLeft == "Resend OTP Code") {
                                startTimer();
                                _requestOTP();
                              }
                            },
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 20, right: 20),
                              child: Container(
                                child: PinCodeTextField(
                                  appContext: context,
                                  length: 6,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onTap: () {
                                    _hideKeyboard();
                                  },
                                  animationDuration:
                                      Duration(milliseconds: 300),
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(5),
                                    fieldHeight: 40,
                                    fieldWidth: 40,
                                    selectedFillColor: Color(0xffe0e0e0),
                                    inactiveFillColor: Color(0xffe0e0e0),
                                    activeFillColor: Color(0xffe0e0e0),
                                    inactiveColor: Color(0xffe0e0e0),
                                    activeColor: Color(0xffe0e0e0),
                                    selectedColor: Color(0xffe0e0e0),
                                  ),
                                  enableActiveFill: true,
                                  onChanged: (value) {
                                    setState(() {
                                      enterOTP = value;
                                      debugPrint("otp -> $value");
                                    });
                                  },
                                ),
                              )),
                          Container(
                            margin: EdgeInsets.only(
                                left: 12,
                                right: 12,
                                top: MediaQuery.of(context).size.height * 0.1,
                                bottom: 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [primaryColor, primaryColor]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            height: 54,
                            child: MaterialButton(
                              padding: EdgeInsets.all(8.0),
                              textColor: Colors.white,
                              minWidth: MediaQuery.of(context).size.width,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(color: primaryColor)),
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0,
                                      right: 24.0,
                                      top: 2,
                                      bottom: 2),
                                  child: Text("အတည်ပြုမည်",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(fontSize: 16.0)),
                                ),
                              ),
                              onPressed: () {
                                debugPrint('Tapped');
                                _hideKeyboard();
                                confirm(enterOTP);
                              },
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> confirm(String otp) async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseAuth auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: otp,
    );
    try {
      await auth.signInWithCredential(credential).then((value) {
        setState(() {
          isLoading = false;
        });
        prefs.setString("memberPhone", widget.phone.toString());
        log(prefs.getString("memberPhone") ?? "");

        Future.delayed(const Duration(seconds: 1), () {
          ref.read(loginMemberProvider.notifier).state = widget.member!;
          // Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FeedMainScreen(data: widget.member!, isEditable: false),
            ),
          );
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.toString().contains('The sms code has expired.')) {
        prefs.setString("memberPhone", widget.phone.toString());
        log(prefs.getString("memberPhone") ?? "");

        Future.delayed(const Duration(seconds: 1), () {
          // Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MemberDetailScreen(data: widget.member!, isEditable: false),
            ),
          );
        });
      } else {
        Utils.messageDialog(e.toString(), context, "OK", Colors.black);
      }
    }
  }

  Future<void> _requestOTP() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber:
          "+95" + widget.phone.toString().replaceAll(" ", "").substring(1),
      verificationCompleted: (PhoneAuthCredential credential) async {
        var user = await auth.signInWithCredential(credential);
        user.user!.getIdToken(true).toString();
      },
      timeout: const Duration(seconds: 120),
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          Navigator.pop(context);
          const snackBar = SnackBar(
            content: Text('The Provided Phone No. is not valid!'),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          Navigator.pop(context);
          var snackBar = SnackBar(
            content: Text(e.message.toString()),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
