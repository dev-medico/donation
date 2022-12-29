import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';

class NewExpense extends StatefulWidget {

  NewExpense({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewDonarState createState() => NewDonarState();
}

class NewDonarState extends State<NewExpense> {
  final amountController = TextEditingController();
  bool isSwitched = false;
  String operatorImg = "";

  bool _isLoading = false;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    initial();
  }

  CollectionReference members =
      FirebaseFirestore.instance.collection('expenses');

  Future<void> addExpense(String amount, String date) {
    return members.add({
      'amount': amount,
      'date': date,
    }).then((value) {
      setState(() {
        _isLoading = true;
      });
      Utils.messageSuccessDialog(
          "ယခုလအတွက် အသုံးစာရင်း အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
          context,
          "အိုကေ",
          Colors.black);
      amountController.clear();
    }).catchError((error) {});
  }

  void initial() async {
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Center(
            child: Text("ယခုလ အသုံးစာရင်း ထည့်သွင်းမည်",
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 15, color: Colors.white)),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        color: Colors.black,
        progressIndicator: const SpinKitCircle(
          color: Colors.white,
          size: 60.0,
        ),
        dismissible: false,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width * 0.3,
                    margin: const EdgeInsets.only(
                        left: 12, top: 12, bottom: 15, right: 12),
                    child: Container(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 4, right: 4, top: 8),
                      decoration: shadowDecoration(Colors.white),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(
                                left: 20, top: 16, bottom: 8, right: 20),
                            child: Stack(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: amountController,
                                  decoration: inputBoxDecoration("ငွေပမာဏ"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: Responsive.isMobile(context)
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      margin: const EdgeInsets.only(
                          left: 15, bottom: 16, right: 15),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (amountController.text.isNotEmpty) {
                            var date = DateTime.now();
                            String expenseMonth =
                                DateFormat('MMM yyyy').format(date);
                            log(expenseMonth);
                            FirebaseFirestore.instance
                                .collection('expenses')
                                .where('date',
                                    isEqualTo: expenseMonth.toString())
                                .get()
                                .then((value) {
                              if (value.docs.isEmpty) {
                                addExpense(
                                  amountController.text.toString(),
                                  expenseMonth.toString(),
                                );
                              } else {
                                expenseExistDialog(context);
                              }
                            });
                          } else {
                            Utils.messageDialog(
                                "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
                                context,
                                "ပြင်ဆင်မည်",
                                Colors.black);
                          }
                        },
                        child: const Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "ထည့်သွင်းမည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ))),
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  static YYDialog expenseExistDialog(BuildContext context) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width * 0.6
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "assets/images/list_exist.png",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: const Text(
              "ယခုလအတွက် အသုံးစာရင်း ထည့်သွင်းပြီးသားဖြစ်ပါသည်။",
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.red),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: const EdgeInsets.all(12.0),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text("အိုကေ",
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }
}
