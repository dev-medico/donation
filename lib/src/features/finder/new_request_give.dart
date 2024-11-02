import 'dart:convert';
import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/finder/provider/request_give_provider.dart';
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
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:realm/realm.dart';

class NewRequestGiveScreen extends ConsumerStatefulWidget {
  NewRequestGiveScreen({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewDonarState createState() => NewDonarState();
}

class NewDonarState extends ConsumerState<NewRequestGiveScreen> {
  final giveController = TextEditingController();
  final requestController = TextEditingController();

  bool _isLoading = false;

  DateTime? donationDateDetail;
  String donationDate = "ရက်စွဲ ရွေးမည်";

  addRequestGive(int give, int request) {
    var logger = Logger(
      printer: PrettyPrinter(),
    );
    logger.i(donationDateDetail.toString());
    if (ref
        .read(requestGiveProvider)
        .where((element) => element.date == donationDateDetail)
        .isEmpty) {
      ref.watch(realmProvider)!.createRequestGive(RequestGive(
            ObjectId(),
            give: give,
            request: request,
            date: donationDateDetail!.toLocal(),
          ));
    } else {
      var requestGive = ref
          .read(requestGiveProvider)
          .where((element) => element.date == donationDateDetail)
          .first;
      ref.watch(realmProvider)!.updateRequestGive(
            requestGive,
            give: give,
            request: request,
            date: donationDateDetail!.toLocal(),
          );
    }

    Utils.messageSuccessSinglePopDialog(
        "သွေးတောင်းခံ/လှူဒါန်းမှု အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
        context,
        "အိုကေ",
        Colors.black);
    giveController.clear();
    requestController.clear();
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
            child: Text("သွေးတောင်းခံ/လှူဒါန်းမှု ထည့်သွင်းမည်",
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
                                left: 20, top: 16, bottom: 8, right: 20),
                            child: Stack(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: requestController,
                                  decoration: inputBoxDecoration(
                                      "တောင်းခံသည့် အရေအတွက်"),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 20, top: 16, bottom: 8, right: 20),
                            child: Stack(
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: giveController,
                                  decoration: inputBoxDecoration(
                                      "လှူဒါန်းခဲ့သည့် အရေအတွက်"),
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
                          if (giveController.text.isNotEmpty &&
                              requestController.text.isNotEmpty) {
                            setState(() {
                              _isLoading = true;
                            });
                            addRequestGive(
                                int.parse(giveController.text.toString()),
                                int.parse(requestController.text.toString()));
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

  showDatePicker() async {
    showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          donationDateDetail = date;
          donationDate = DateFormat('MMMM yyyy').format(date);
          log(donationDateDetail.toString());
        });
      }
    });
  }
}
