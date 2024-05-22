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
import 'package:realm/realm.dart';

class NewExpenseRecordScreen extends ConsumerStatefulWidget {
  NewExpenseRecordScreen({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewDonarState createState() => NewDonarState();
}

class NewDonarState extends ConsumerState<NewExpenseRecordScreen> {
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
  String donationDate = "ရက်စွဲ ရွေးမည်";

  @override
  void initState() {
    super.initState();
    initial();
  }

  addDonor(String name, String amount) {
    var logger = Logger(
      printer: PrettyPrinter(),
    );
    logger.i(donationDateDetail.toString());
    ref.watch(realmProvider)!.createExpenseRecord(ExpensesRecord(
          ObjectId(),
          name: name,
          amount: int.parse(amount),
          date: donationDateDetail!.toLocal(),
        ));
    Utils.messageSuccessSinglePopDialog(
        "အသုံးစရိတ် အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
        context,
        "အိုကေ",
        Colors.black);
    nameController.clear();
    amountController.clear();
    // XataRepository()
    //     .uploadNewExpense(jsonEncode(<String, dynamic>{
    //   "name": name,
    //   "amount": int.parse(amount),
    //   "date": "${donationDateDetail.toString().replaceAll(" ", "T")}Z",
    // }))
    //     .then((value) {
    //   if (value.statusCode.toString().startsWith("2")) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //     Utils.messageSuccessSinglePopDialog(
    //         "အသုံးစရိတ် အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
    //         context,
    //         "အိုကေ",
    //         Colors.black);
    //     nameController.clear();
    //     amountController.clear();
    //   } else {
    //     logger.i(value.statusCode.toString());
    //     logger.i(value.body);
    //   }
    // });
  }

  void initial() async {
    donationDateDetail = DateTime.now().toLocal();
    donationDate = DateFormat('dd MMM yyyy').format(donationDateDetail!);

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
            child: Text("အသုံးစရိတ် ထည့်သွင်းမည်",
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
                              decoration: inputBoxDecoration("အကြောင်းအရာ"),
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
                            addDonor(nameController.text.toString(),
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
