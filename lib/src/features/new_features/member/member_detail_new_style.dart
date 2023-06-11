import 'package:flutter/material.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/new_features/member/member_edit_new_style.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:intl/intl.dart';

class MemberDetailNewStyleScreen extends StatefulWidget {
  static const routeName = '/member-detail';
  MemberData data;
  MemberDetailNewStyleScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<MemberDetailNewStyleScreen> createState() =>
      _MemberDetailNewStyleScreenState(data);
}

class _MemberDetailNewStyleScreenState
    extends State<MemberDetailNewStyleScreen> {
  MemberData data;
  _MemberDetailNewStyleScreenState(this.data);
  int groupTotalCount = 0;

  @override
  Widget build(BuildContext context) {
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
        title: Padding(
          padding: const EdgeInsets.only(top: 4, right: 20),
          child: Center(
            child: Text("အဖွဲ့၀င် အချက်အလက်များ",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 14 : 17,
                    color: Colors.white)),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Responsive.isMobile(context)
              ? Container(
                  width: double.infinity,
                  decoration: shadowDecoration(Colors.white),
                  margin: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              Image.asset("assets/images/card.png", width: 54),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("အဖွဲ့၀င်အမှတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                  Responsive.isMobile(context)
                                      ? const SizedBox(
                                          height: 0,
                                        )
                                      : const SizedBox(
                                          height: 8,
                                        ),
                                  Text(
                                    data.memberId!,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("အဖွဲ့ဝင်သည့်ရက်စွဲ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
                                Responsive.isMobile(context)
                                    ? const SizedBox(
                                        height: 0,
                                      )
                                    : const SizedBox(
                                        height: 8,
                                      ),
                                Text(
                                  data.registerDate!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
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
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("အမည်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.name!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("အဖအမည်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.fatherName!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("မွေးသက္ကရာဇ်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.birthDate!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("နိုင်ငံသားစီစစ်ရေး\nကတ်ပြားအမှတ်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112),
                                    height: 1.8)),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.nrc!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("သွေးအုပ်စု",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.bloodType!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("သွေးဘဏ်ကတ်နံပါတ်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.bloodBankCard!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("အဖွဲ့နှင့်သွေးလှူဒါန်းမှု",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "${Utils.strToMM(groupTotalCount.toString())} ကြိမ်",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("စုစုပေါင်းသွေးလှူဒါန်းမှု",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "${Utils.strToMM(data.totalCount.toString())} ကြိမ်",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("ဖုန်းနံပါတ်",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const Text("-",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          const SizedBox(
                            width: 24,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.phone!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text("နေရပ်လိပ်စာ   - ",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              data.address!,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width - 80,
                        color: Colors.grey,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            right: 12,
                          ),
                          child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("ပြင်ဆင်မည်",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor)),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Image.asset(
                                    "assets/images/edit.png",
                                    width: 24,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MemberEditNewStyleScreen(data: data),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: 120,
                  decoration: shadowDecoration(Colors.white),
                  margin: EdgeInsets.only(
                      top: 40,
                      bottom: 20,
                      left: 52,
                      right: MediaQuery.of(context).size.width * 0.072),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 8,
                              ),
                              Image.asset("assets/images/card.png", width: 54),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("အဖွဲ့၀င်အမှတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                  Text(
                                    data.memberId!,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("အဖွဲ့ဝင်သည့်ရက်စွဲ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
                                Text(
                                  data.registerDate!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
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
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 4,
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
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data.name!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 7,
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
                                  flex: 6,
                                  child: Text(
                                    data.fatherName!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(flex: 1, child: Container())
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 4,
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
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data.birthDate!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 7,
                                  child: Text("နိုင်ငံသားစီစစ်ရေး ကတ်ပြားအမှတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112),
                                          height: 1.8)),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 24,
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    data.nrc!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 4,
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
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data.bloodType!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 7,
                                  child: Text("သွေးဘဏ်ကတ်နံပါတ်",
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
                                  flex: 6,
                                  child: Text(
                                    data.bloodBankCard!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 4,
                                  child: Text("အဖွဲ့နှင့်သွေးလှူဒါန်းမှု",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "${Utils.strToMM(groupTotalCount.toString())} ကြိမ်",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 7,
                                  child: Text("စုစုပေါင်းသွေးလှူဒါန်းမှု",
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
                                  flex: 6,
                                  child: Text(
                                    "${Utils.strToMM(data.totalCount.toString())} ကြိမ်",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(flex: 1, child: Container()),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 4,
                                  child: Text("ဖုန်းနံပါတ်",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const Text("-",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black)),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    data.phone!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Expanded(
                                  flex: 3,
                                  child: Text("နေရပ်လိပ်စာ - ",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Expanded(
                                  flex: 11,
                                  child: Text(
                                    data.address!,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width - 80,
                        color: Colors.grey,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            right: 12,
                          ),
                          child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("ပြင်ဆင်မည်",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor)),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Image.asset(
                                    "assets/images/edit.png",
                                    width: 24,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MemberEditNewStyleScreen(data: data),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, left: 18, bottom: 12),
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: Responsive.isMobile(context) ? 8.0 : 40),
                child: const Text("အဖွဲ့နှင့် သွေးလှူဒါန်းမှုများ",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              const SizedBox(
                height: 12,
              ),
              // StreamBuilder<QuerySnapshot>(
              //   stream: _usersStream,
              //   builder: (BuildContext context,
              //       AsyncSnapshot<QuerySnapshot> snapshot) {
              //     if (snapshot.hasError) {
              //       return const Text('Something went wrong');
              //     }

              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(
              //         child: SpinKitCircle(
              //           color: Colors.white,
              //           size: 60.0,
              //         ),
              //       );
              //     }

              //     return ListView(
              //       shrinkWrap: true,
              //       physics: const NeverScrollableScrollPhysics(),
              //       scrollDirection: Axis.vertical,
              //       children: [
              //         SizedBox(
              //           height: snapshot.data!.docs.length > 8
              //               ? MediaQuery.of(context).size.height *
              //                   (snapshot.data!.docs.length / 8)
              //               : MediaQuery.of(context).size.height,
              //           width: MediaQuery.of(context).size.width * 2.5,
              //           child: ListView(
              //             shrinkWrap: true,
              //             scrollDirection: Axis.horizontal,
              //             children: [
              //               Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   header(),
              //                   Column(
              //                     // shrinkWrap: true,
              //                     // scrollDirection: Axis.vertical,
              //                     children: snapshot.data!.docs
              //                         .map((DocumentSnapshot document) {
              //                       Map<String, dynamic> data = document.data()!
              //                           as Map<String, dynamic>;

              //                       return blood_donationRow(data, document.id);
              //                     }).toList(),
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // )
            ],
          )
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 60 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 2
          : MediaQuery.of(context).size.width * 0.89,
      margin: EdgeInsets.only(
          top: Responsive.isMobile(context) ? 0 : 12,
          left: Responsive.isMobile(context) ? 4 : 32,
          right: Responsive.isMobile(context) ? 20 : 32),
      padding: const EdgeInsets.only(left: 20, top: 0, right: 20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Colors.red[100],
      ),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 4.3
                    : MediaQuery.of(context).size.width / 11,
                child: Text(
                  "ရက်စွဲ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 8,
                child: Text(
                  "လှူဒါန်းသည့်နေရာ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 8,
                child: Text(
                  "လူနာအမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 12 : 4,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 2.8
                    : MediaQuery.of(context).size.width / 6,
                child: Text(
                  "လိပ်စာ",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 7.4
                    : MediaQuery.of(context).size.width / 18,
                child: Text(
                  "အသက်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "ဖြစ်ပွားသည့်ရောဂါ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget blood_donationRow(Map<String, dynamic> data, String docId) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        // await Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => DonationDetailScreen(
        //       data: data,
        //       doc_id: docId,
        //     ),
        //   ),
        // );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 60 : 60,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 2
            : MediaQuery.of(context).size.width * 0.89,
        margin: EdgeInsets.only(
            top: 4,
            left: Responsive.isMobile(context) ? 4 : 32,
            right: Responsive.isMobile(context) ? 20 : 32),
        padding: const EdgeInsets.only(left: 18, right: 20),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            Row(
              // scrollDirection: Axis.horizontal,
              // physics: const NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 4.1
                      : MediaQuery.of(context).size.width / 11,
                  child: Text(
                    //data['date'].toString(),
                    data['date_detail'] != null && data['date_detail'] != ""
                        ? DateFormat('dd MMM yyyy')
                            .format(data['date_detail'].toDate())
                        : data['date'].toString(),
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 13 : 14,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.2
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data['hospital'] ?? "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data["patient_name"] == null || data["patient_name"] == ""
                        ? "-"
                        : data['patient_name'],
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 12 : 4,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.8
                      : MediaQuery.of(context).size.width / 6,
                  child: Text(
                    data["patient_address"] == null ||
                            data["patient_address"] == "၊" ||
                            data["patient_address"] == ""
                        ? "-"
                        : data['patient_address'],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        height: 1.5,
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 7.4
                      : MediaQuery.of(context).size.width / 18,
                  child: Text(
                    data["patient_age"] == null || data["patient_age"] == ""
                        ? "-"
                        : data['patient_age'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 15 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.2
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data["patient_disease"] == null ||
                            data["patient_disease"] == ""
                        ? "-"
                        : data['patient_disease'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
