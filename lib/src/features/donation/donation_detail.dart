import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donation/blood_donation_edit.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DonationDetailScreen extends StatefulWidget {
  Map<String, dynamic> data;
  String doc_id;
  DonationDetailScreen({Key? key, required this.data, required this.doc_id})
      : super(key: key);

  @override
  State<DonationDetailScreen> createState() =>
      _DonationDetailScreenState(data, doc_id);
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  Map<String, dynamic> data;
  String doc_id;
  _DonationDetailScreenState(this.data, this.doc_id);
  bool _isLoading = false;

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
      child: Scaffold(
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
          title: Padding(
            padding: const EdgeInsets.only(top: 4, right: 20),
            child: Center(
              child: Text("သွေးလှူဒါန်းမှု အချက်အလက်များ",
                  textScaleFactor: 1.0,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: Colors.white)),
            ),
          ),
        ),
        body: ListView(
          children: [
            Container(
              width: double.infinity,
              decoration: shadowDecoration(Colors.white),
              margin: EdgeInsets.only(
                left: 20,
                right: Responsive.isMobile(context)
                    ? 20
                    : MediaQuery.of(context).size.width * 0.5 + 20,
                top: 20,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text("လှူဒါန်းသည့် ရက်စွဲ",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 116, 112, 112))),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      const Text("-",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          data["date"] ?? "-",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 12,
                      ),
                      const Expanded(
                        flex: 3,
                        child: Text("လှူဒါန်းသည့် နေရာ",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 116, 112, 112))),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      const Text("-",
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          data["hospital"],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Responsive.isMobile(context)
                ? ListView(
                    shrinkWrap: true,
                    scrollDirection: Responsive.isMobile(context)
                        ? Axis.vertical
                        : Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Visibility(
                        visible: data["patient_name"] != null &&
                            data["patient_name"] != "",
                        child: Container(
                          width: Responsive.isMobile(context)
                              ? double.infinity
                              : MediaQuery.of(context).size.width * 0.5,
                          decoration: shadowDecoration(Colors.white),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 12, bottom: 12),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Image.asset("assets/images/donation.png",
                                      width: 38, color: primaryColor),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text("လူနာအချက်အလက်များ",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor)),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width - 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text("လူနာအမည်",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 116, 112, 112))),
                                  ),
                                  const Text("-",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black)),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data["patient_name"],
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text("အသက်",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 116, 112, 112))),
                                  ),
                                  const Text("-",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black)),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      Utils.strToMM(data["patient_age"]) +
                                          " နှစ်",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text("နေရပ်လိပ်စာ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 116, 112, 112))),
                                  ),
                                  const Text("-",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black)),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data["patient_address"],
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: Text("ဖြစ်ပွားသည့်ရောဂါ",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 116, 112, 112))),
                                  ),
                                  const Text("-",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black)),
                                  const SizedBox(
                                    width: 24,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      data["patient_disease"],
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: data["patient_name"] == null ||
                            data["patient_name"] == "",
                        child: const SizedBox(
                          height: 12,
                        ),
                      ),
                      Container(
                        width: Responsive.isMobile(context)
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.5,
                        decoration: shadowDecoration(Colors.white),
                        margin: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Image.asset(
                                      "assets/images/blood_bag.png",
                                      width: 32,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text("သွေးလှူဒါန်းသူအချက်အလက်များ",
                                        style: TextStyle(
                                            fontSize: 15, color: primaryColor)),
                                  ],
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    goToDetail();
                                  },
                                  child: Image.asset("assets/images/detail.png",
                                      width: 28, color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              height: 1,
                              width: MediaQuery.of(context).size.width - 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 3,
                                  child: Text("အဖွဲ့ဝင်အမှတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_id"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text("အမည်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_name"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text("အဖအမည်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_father_name"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text("သွေးအုပ်စု",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_blood_type"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text("မွေးသက္ကရာဇ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_birth_date"],
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: Text("သွေးဘဏ်ကတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data["member_blood_bank_card"] ?? "-",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4 - 20,
                    margin: const EdgeInsets.only(top: 20, right: 90),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Visibility(
                            visible: data["patient_name"] == null ||
                                data["patient_name"] == "",
                            child: Container(
                              width: Responsive.isMobile(context)
                                  ? double.infinity
                                  : MediaQuery.of(context).size.width * 0.47,
                              decoration: shadowDecoration(Colors.white),
                              margin: const EdgeInsets.only(
                                left: 20,
                                right: 8,
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Image.asset("assets/images/donation.png",
                                          width: 38, color: primaryColor),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Text("လူနာအချက်အလက်များ",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: primaryColor)),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    height: 1,
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text("လူနာအမည်",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 116, 112, 112))),
                                      ),
                                      const Text("-",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          data["patient_name"],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text("အသက်",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 116, 112, 112))),
                                      ),
                                      const Text("-",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          Utils.strToMM(data["patient_age"]) +
                                              " နှစ်",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text("နေရပ်လိပ်စာ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 116, 112, 112))),
                                      ),
                                      const Text("-",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          data["patient_address"],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text("ဖြစ်ပွားသည့်ရောဂါ",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 116, 112, 112))),
                                      ),
                                      const Text("-",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black)),
                                      const SizedBox(
                                        width: 24,
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          data["patient_disease"],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: Responsive.isMobile(context)
                                ? double.infinity
                                : MediaQuery.of(context).size.width * 0.47,
                            decoration: shadowDecoration(Colors.white),
                            margin: const EdgeInsets.only(
                              left: 8,
                              right: 20,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Image.asset(
                                          "assets/images/blood_bag.png",
                                          width: 32,
                                          color: primaryColor,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Text("သွေးလှူဒါန်းသူအချက်အလက်များ",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: primaryColor)),
                                      ],
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        goToDetail();
                                      },
                                      child: Image.asset(
                                          "assets/images/detail.png",
                                          width: 28,
                                          color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.width - 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("အဖွဲ့ဝင်အမှတ်",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_id"],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("အမည်",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_name"],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("အဖအမည်",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_father_name"],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("သွေးအုပ်စု",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_blood_type"],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("မွေးသက္ကရာဇ်",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_birth_date"],
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text("သွေးဘဏ်ကတ်",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 116, 112, 112))),
                                    ),
                                    const Text("-",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        data["member_blood_bank_card"] ?? "-",
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(
                  left: 16,
                  right: Responsive.isMobile(context)
                      ? 16
                      : MediaQuery.of(context).size.width * 0.54,
                  top: Responsive.isMobile(context) ? 0 : 26),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                      margin: const EdgeInsets.only(bottom: 16, right: 6),
                      width: double.infinity,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                size: 28,
                                color: primaryColor,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Text("ဖျက်မည်",
                                  style: TextStyle(
                                      fontSize: 15, color: primaryColor)),
                            ],
                          ),
                          onTap: () {
                            messageDialog(
                                "အချက်အလက် ပယ်ဖျက်မည်မှာ \nသေချာပါသလား ? ",
                                context,
                                "သေချာပါသည်",
                                Colors.black);
                          }),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0))),
                      margin: const EdgeInsets.only(
                        left: 6,
                        bottom: 16,
                      ),
                      width: double.infinity,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/edit.png",
                                width: 24,
                                color: Colors.green,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Text("ပြင်ဆင်မည်",
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.green)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BloodDonationEditScreen(
                                    data: data, doc_id: doc_id),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  messageDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    return YYDialog().build()
      ..width = Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 60
          : MediaQuery.of(context).size.width / 3
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          SvgPicture.asset(
            "assets/images/warn.svg",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              maxLines: 4,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: EdgeInsets.all(Responsive.isMobile(context) ? 12.0 : 24),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              deleteDonation();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(buttonMsg,
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..show();
  }

  Future<void> deleteDonation() {
    setState(() {
      _isLoading = true;
    });
    DocumentReference memberdocumentReference =
        FirebaseFirestore.instance.collection('members').doc(data['member_id']);
    FirebaseFirestore.instance
        .runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot =
              await transaction.get(memberdocumentReference);

          int newMemberCount;
          int newTotalCount;
          print(snapshot.data());
          Map<String, dynamic> memberData =
              snapshot.data()! as Map<String, dynamic>;
          print(memberData);
          newMemberCount = int.parse(memberData['member_count'].toString()) - 1;
          newTotalCount = int.parse(memberData['total_count'].toString()) - 1;
          // Perform an update on the document
          transaction.update(memberdocumentReference,
              {'member_count': newMemberCount.toString()});
          transaction.update(memberdocumentReference,
              {'total_count': newTotalCount.toString()});
          return newMemberCount;
        })
        .then((value) => print("Follower count updated to $value"))
        .catchError(
            (error) => print("Failed to update user followers: $error"));
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('blood_donations').doc(doc_id);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      // Perform an update on the document
      transaction.delete(documentReference);

      // Return the new count
      return true;
    }).then((value) {
      print("Member updated to $value");
      setState(() {
        _isLoading = false;
      });
      Utils.messageSuccessDialog("စာရင်း ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
          context, "အိုကေ", Colors.black);
    }).catchError((error) => print("Failed to update Member: $error"));
  }

  goToDetail() {
    print(data['member_id']);
    CollectionReference members =
        FirebaseFirestore.instance.collection('members');
    members.doc(data['member_id']).get().then((value) {
      if (value.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailScreen(
              data: value.data() as Map<String, dynamic>,
            ),
          ),
        );
      }
    });
    // DocumentReference documentReference =
    //     FirebaseFirestore.instance.collection('members').doc(data["member_id"]);
    // documentReference.get().then((datasnapshot) {
    //   if (datasnapshot.exists) {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //             builder: (context) => MemberDetailScreen(
    //                   data: datasnapshot.data as Map<String, dynamic>,
    //                 )));
    //   }
    // }).catchError((e) {
    //   print(e);
    // });
  }
}
