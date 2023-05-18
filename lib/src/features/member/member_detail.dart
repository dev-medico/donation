import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/data/response/xata_donation_search_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/member/member_edit.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';

class MemberDetailScreen extends StatefulWidget {
  static const routeName = '/member-detail';
  MemberData data;
  MemberDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState(data);
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  MemberData data;
  _MemberDetailScreenState(this.data);
  List<DonationSearchRecords> donationDatas = [];

  @override
  void initState() {
    super.initState();
    fetchCount();
  }

  fetchCount() {
    print("Fetch Count called");

    XataRepository()
        .getDonationsListByMemberId(data.memberId.toString())
        .then((value) {
      print("Donation List Response - ${value.body}");
      setState(() {
        donationDatas =
            DonationSearchListResponse.fromJson(jsonDecode(value.body))
                .records!;
        donationDatas.sort((a, b) {
          return DateTime.parse(b.date == null
                  ? "2020-01-01"
                  : b.date.toString().contains("T")
                      ? b.date.toString().split("T")[0]
                      : b.date.toString().contains(" ")
                          ? b.date.toString().split(" ")[0]
                          : "2020-01-01")
              .compareTo(DateTime.parse(a.date == null
                  ? "2020-01-01"
                  : b.date.toString().contains("T")
                      ? b.date.toString().split("T")[0]
                      : b.date.toString().contains(" ")
                          ? b.date.toString().split(" ")[0]
                          : "2020-01-01"));
        });
      });
    });
  }

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
      body: Responsive.isMobile(context)
          ? ListView(
              shrinkWrap: true,
              children: [
                Container(
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
                                          height: 12,
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
                                        height: 12,
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
                        height: 12,
                      ),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width - 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 12,
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
                        height: 12,
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
                        height: 12,
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
                        height: 12,
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
                        height: 12,
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
                        height: 12,
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
                        height: 12,
                      ),
                      const SizedBox(
                        height: 12,
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
                              "${Utils.strToMM(data.donationCounts.toString())} ကြိမ်",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
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
                        height: 12,
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
                        height: 12,
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
                              "${data.address}",
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
                                        MemberEditScreen(data: data),
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
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      children: [
                        SizedBox(
                          height: donationDatas.length > 8
                              ? MediaQuery.of(context).size.height *
                                  (donationDatas.length / 8)
                              : MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width * 2.5,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  header(),
                                  Column(
                                    // shrinkWrap: true,
                                    // scrollDirection: Axis.vertical,
                                    children: donationDatas
                                        .map((DonationSearchRecords document) {
                                      return blood_donationRow(document);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.9,
                    decoration: shadowDecoration(Colors.white),
                    margin: const EdgeInsets.only(
                      left: 20,
                      top: 30,
                      bottom: 20,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
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
                                Image.asset("assets/images/card.png",
                                    width: 54),
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
                                            height: 12,
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
                                          height: 12,
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
                          height: 12,
                        ),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width - 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.name!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.fatherName!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.birthDate!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black)),
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
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.bloodType!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.bloodBankCard!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                "${Utils.strToMM(data.donationCounts.toString())} ကြိမ်",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                "${Utils.strToMM(data.totalCount.toString())} ကြိမ်",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                                data.phone!,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
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
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "${data.address}",
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
                                top: 24, right: 12, bottom: 24),
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
                                          MemberEditScreen(data: data),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20, left: 8, bottom: 12),
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        ListView(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          children: [
                            SizedBox(
                              height: donationDatas.length > 8
                                  ? MediaQuery.of(context).size.height *
                                      (donationDatas.length / 8)
                                  : MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width * 0.575,
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      header(),
                                      Column(
                                        // shrinkWrap: true,
                                        // scrollDirection: Axis.vertical,
                                        children: donationDatas.map(
                                            (DonationSearchRecords document) {
                                          return blood_donationRow(document);
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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
          : MediaQuery.of(context).size.width * 0.575,
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
                    : MediaQuery.of(context).size.width / 13,
                child: Text(
                  "ရက်စွဲ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    : MediaQuery.of(context).size.width / 10,
                child: Text(
                  "လှူဒါန်းသည့်နေရာ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    : MediaQuery.of(context).size.width / 10,
                child: Text(
                  "လူနာအမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    : MediaQuery.of(context).size.width / 12,
                child: Text(
                  "လိပ်စာ",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    : MediaQuery.of(context).size.width / 22,
                child: Text(
                  "အသက်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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
                    : MediaQuery.of(context).size.width / 9,
                child: Text(
                  "ဖြစ်ပွားသည့်ရောဂါ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 14,
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

  Widget blood_donationRow(DonationSearchRecords data) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(
              data: data,
            ),
          ),
        );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 60 : 60,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 2
            : MediaQuery.of(context).size.width * 0.575,
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
              children: [
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 4.1
                      : MediaQuery.of(context).size.width / 13,
                  child: Text(
                    //data['date'].toString(),
                    data.date!.contains("T")
                        ? data.date!.split("T")[0].toString()
                        : data.date!.contains(" ")
                            ? data.date!.split(" ")[0]
                            : "-",
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
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data.hospital ?? "-",
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
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data.patientName == null || data.patientName == ""
                        ? "-"
                        : data.patientName!,
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
                      : MediaQuery.of(context).size.width / 12,
                  child: Text(
                    data.patientAddress == null ||
                            data.patientAddress == "၊" ||
                            data.patientAddress == ""
                        ? "-"
                        : data.patientAddress!,
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
                      : MediaQuery.of(context).size.width / 22,
                  child: Text(
                    data.patientAge == null || data.patientAge == ""
                        ? "-"
                        : data.patientAge!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 13 : 14,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.2
                      : MediaQuery.of(context).size.width / 9,
                  child: Text(
                    data.patientDisease == null || data.patientDisease == ""
                        ? "-"
                        : data.patientDisease!,
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
