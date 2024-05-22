import 'dart:convert';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:intl/intl.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  ExpensesRecord? expense;
  EditExpenseScreen({Key? key, required this.expense}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewExpenseState createState() => NewExpenseState();
}

class NewExpenseState extends ConsumerState<EditExpenseScreen> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  bool isSwitched = false;
  String operatorImg = "";

  bool _isLoading = false;
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];
  List<String> townshipsSelected = <String>[];
  List<Datum> datas = <Datum>[];
  DateTime? donationDateDetail;
  String? oldDate;
  String donationDate = "ရက်စွဲ ရွေးမည်";

  @override
  void initState() {
    super.initState();
    initial();
  }

  editexpense(String name, String amount) {
    var logger = Logger(
      printer: PrettyPrinter(),
    );
    logger.i(donationDateDetail.toString());
    ref.watch(realmProvider)!.updateExpenseRecord(
          widget.expense!,
          name: name,
          amount: int.parse(amount),
          date: donationDateDetail!.toLocal(),
        );
    Utils.messageSuccessSinglePopDialog(
        "အသုံးစရိတ် ပြင်ဆင်ခြင်း \nအောင်မြင်ပါသည်။",
        context,
        "အိုကေ",
        Colors.black);
    nameController.clear();
    amountController.clear();
    // XataRepository()
    //     .updateDonor(
    //         widget.expense!.id.toString(),
    //         jsonEncode(<String, dynamic>{
    //           "name": name,
    //           "amount": int.parse(amount),
    //           "date": donationDateDetail.toString().replaceAll(" ", "T"),
    //         }))
    //     .then((value) {
    //   if (value.statusCode.toString().startsWith("2")) {
    //     setState(() {
    //       _isLoading = false;
    //     });

    //   } else {
    //     logger.i(value.statusCode.toString());
    //     logger.i(value.body);
    //   }
    // });
  }

  void initial() async {
    if (widget.expense!.date != null) {
      donationDateDetail = widget.expense!.date!.toLocal();
      donationDate =
          DateFormat('dd MMM yyyy').format(donationDateDetail!.toLocal());
    } else {
      donationDateDetail = DateTime.now().toLocal();
      donationDate =
          DateFormat('dd MMM yyyy').format(donationDateDetail!.toLocal());
    }

    nameController.text = widget.expense!.name!;
    amountController.text = widget.expense!.amount.toString();

    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }
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
            child: Text("အသုံးစရိတ် ပြင်ဆင်မည်",
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
                            width: double.infinity,
                            height: 50,
                            margin: const EdgeInsets.only(
                                left: 20, top: 16, bottom: 4, right: 20),
                            child: fluent.Button(
                              child: Text(
                                donationDate,
                                style: TextStyle(
                                    fontSize: 14, color: primaryColor),
                              ),
                              onPressed: () {
                                showDatePicker();
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 20, top: 24, bottom: 8, right: 20),
                            child: TextFormField(
                              controller: nameController,
                              decoration: inputBoxDecoration("အမည်"),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 20, top: 16, bottom: 8, right: 20),
                            child: Stack(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                          if (nameController.text.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            editexpense(nameController.text.toString(),
                                amountController.text.toString());
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
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  "ပြင်ဆင်မည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                ))),
                      ),
                    )),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: Responsive.isMobile(context)
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width * 0.3,
                      decoration:
                          shadowDecorationWithBorder(Colors.white, Colors.red),
                      margin: const EdgeInsets.only(
                          left: 15, bottom: 16, right: 15),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          confirmDeleteDialog(
                              "ဖျက်မည်မှာ သေချာပါသလား?",
                              "အသုံးစရိတ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
                              context,
                              "အိုကေ",
                              Colors.black, () {
                            ref.watch(realmProvider)!.deleteExpenseRecord(
                                  widget.expense!,
                                );
                            Utils.messageSuccessSinglePopDialog(
                                "အသုံးစရိတ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
                                context,
                                "အိုကေ",
                                Colors.black);

                            // XataRepository()
                            //     .deleteExpenseByID(widget.expense!.id.toString())
                            //     .then((value) {
                            //   if (value.statusCode.toString().startsWith("2")) {

                            //   }
                            // });
                          });
                        },
                        child: Align(
                            alignment: Alignment.center,
                            child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 8),
                                child: Text(
                                  "ဖျက်သိမ်းမည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 16.0, color: primaryColor),
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

  YYDialog confirmDeleteDialog(String title, String msg, BuildContext context,
      String buttonMsg, Color color, Function onTap) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.8
          : MediaQuery.of(context).size.width * 0.3
//      ..height = 110
      ..backgroundColor =
          Colors.white //Colors.black.withOpacity(0.8)//main_theme_color
      ..borderRadius = 10.0
      ..barrierColor = const Color(0xDD000000)
      ..showCallBack = () {
        debugPrint("showCallBack invoke");
      }
      ..dismissCallBack = () {
        debugPrint("dismissCallBack invoke");
      }
      ..widget(Container(
        color: Colors.red,
        padding: const EdgeInsets.only(top: 8),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, left: 20, bottom: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      right: 12,
                      bottom: 12,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Padding(
        padding: EdgeInsets.only(
            top: Responsive.isMobile(context) ? 26 : 42, bottom: 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 8,
                right: 18,
              ),
              child: Image.asset(
                'assets/images/question_mark.png',
                height: 56,
                width: 56,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: 12,
                right: 20,
              ),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ))
      ..widget(Align(
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration:
                    shadowDecorationWithBorder(Colors.white, Colors.black),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  left: 20,
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 20,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "မလုပ်တော့ပါ",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                onTap.call();
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
              child: Container(
                decoration: shadowDecoration(const Color(0xffFF5F17)),
                height: 50,
                width: 120,
                margin: EdgeInsets.only(
                  bottom: 30,
                  right: Responsive.isMobile(context) ? 12 : 30,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "ဖျက်မည်",
                    textScaleFactor: 1.0,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.isMobile(context) ? 12 : 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  Widget buildOperator() {
    if (operatorImg == "") {
      return Container(child: null);
    } else {
      return Opacity(
        opacity: 0.6,
        child: SvgPicture.asset(
          operatorImg,
          height: 34,
        ),
      );
    }
  }

  String checkPhone(String phone) {
    var operator = "";

    RegExp ooredoo = RegExp(
      "(09|\\+?959)9(5|6|7|8)\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp telenor = RegExp(
      "(09|\\+?959)7([5-9])\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mytel = RegExp(
      "(09|\\+?959)6([6-9])\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mec = RegExp(
      "(09|\\+?959)3([0-9])\\d{6}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mpt = RegExp(
      "(09|\\+?959)(5\\d{6}|4\\d{7}|4\\d{8}|2\\d{6}|2\\d{7}|2\\d{8}|3\\d{7}|3\\d{8}|6\\d{6}|8\\d{6}|8\\d{7}|8\\d{8}|7\\d{7}|9(0|1|9)\\d{5}|9(0|1|9)\\d{6}|2([0-4])\\d{5}|5([0-6])\\d{5}|8([3-7])\\d{5}|3([0-369])\\d{6}|34\\d{7}|4([1379])\\d{6}|73\\d{6}|91\\d{6}|25\\d{7}|26([0-5])d{6}|40([0-4])\\d{6}|42\\d{7}|45\\d{7}|89([6789])\\d{6})",
      caseSensitive: false,
      multiLine: false,
    );

    if (ooredoo.hasMatch(phone)) {
      operator = "Ooredoo";
    } else if (telenor.hasMatch(phone)) {
      operator = "Telenor";
    } else if (mytel.hasMatch(phone)) {
      operator = "Mytel";
    } else if (mec.hasMatch(phone)) {
      operator = "MEC";
    } else if (mpt.hasMatch(phone)) {
      operator = "MPT";
    } else {
      operator = "Not_Valid";
    }

    return operator;
  }

  showDatePicker() async {
    Utils.showCupertinoDatePicker(
      context,
      (DateTime newDateTime) {
        setState(() {
          String formattedDate = DateFormat('dd MMM yyyy').format(newDateTime);
          donationDateDetail = newDateTime;
          donationDate = formattedDate;
        });
      },
    );
  }
}
