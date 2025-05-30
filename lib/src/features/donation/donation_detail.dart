// import 'package:donation/models/donation.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation/blood_donation_edit.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/donation_service.dart';

class DonationDetailScreen extends ConsumerStatefulWidget {
  Donation data;
  DonationDetailScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  ConsumerState<DonationDetailScreen> createState() =>
      _DonationDetailScreenState(data);
}

class _DonationDetailScreenState extends ConsumerState<DonationDetailScreen> {
  Donation data;
  _DonationDetailScreenState(this.data);

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
            child: Text("သွေးလှူဒါန်းမှု အချက်အလက်များ",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
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
                  : MediaQuery.of(context).size.width * 0.5 + 40,
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
                        data.donationDate != null
                            ? data.donationDate!.toLocal().string("dd-MM-yyyy")
                            : "",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
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
                        data.hospital.toString(),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
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
                      visible:
                          data.patientName != null && data.patientName != "",
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
                                    data.patientName.toString(),
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
                                    "${Utils.strToMM(data.patientAge.toString())} နှစ်",
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
                                    data.patientAddress.toString(),
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
                                    data.patientDisease.toString(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: data.patientName.toString() == "",
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
                                  data.memberObj?.memberId?.toString() ?? "-",
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
                                  data.memberObj?.name?.toString() ?? "-",
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
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Text("အဖအမည်",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
                              ),
                              Text("-",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  data.memberObj?.fatherName?.toString() ?? "-",
                                  style: TextStyle(
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
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Text("သွေးအုပ်စု",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
                              ),
                              Text("-",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(
                                width: 24,
                              ),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  data.memberObj?.bloodType?.toString() ?? "-",
                                  style: TextStyle(
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
                                  data.memberObj?.birthDate?.toString() ?? "-",
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
                                  data.memberObj?.bloodBankCard?.toString() ??
                                      "-",
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
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
                                      data.patientName.toString(),
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
                                      "${Utils.strToMM(data.patientAge.toString())} နှစ်",
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
                                      data.patientAddress.toString(),
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
                                      data.patientDisease.toString(),
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                            ],
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
                                      data.memberObj?.memberId?.toString() ??
                                          "-",
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
                                      data.memberObj?.name?.toString() ?? "-",
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
                                      data.memberObj?.fatherName?.toString() ??
                                          "-",
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
                                      data.memberObj?.bloodType?.toString() ??
                                          "-",
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
                                      data.memberObj?.birthDate?.toString() ??
                                          "-",
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
                                      data.memberObj?.bloodBankCard
                                              ?.toString() ??
                                          "-",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
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
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                        borderRadius: BorderRadius.all(Radius.circular(12.0))),
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
                                data: data,
                              ),
                            ),
                          ).then((_) {
                            // Refresh data when returning from edit screen
                            ref.refresh(donationsByMonthYearProvider((
                              month: int.parse(DateTime.now().month.toString()),
                              year: int.parse(DateTime.now().year.toString())
                            )));
                          });
                        }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  messageDialog(
      String msg, BuildContext context, String buttonMsg, Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: Responsive.isMobile(context)
                ? 30
                : MediaQuery.of(context).size.width / 3,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                SvgPicture.asset(
                  "assets/images/warn.svg",
                  height: 50,
                  width: 50,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(5, 24, 5, 12),
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
                Padding(
                  padding: const EdgeInsets.only(
                      top: 24, left: 20, right: 20, bottom: 30),
                  child: MaterialButton(
                      padding: EdgeInsets.all(
                          Responsive.isMobile(context) ? 12.0 : 24),
                      textColor: Colors.white,
                      splashColor: primaryColor,
                      color: primaryColor,
                      elevation: 2.0,
                      minWidth: 155,
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
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
                                  textScaler: const TextScaler.linear(1.0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white))
                            ]),
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  deleteDonation() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("သွေးလှူဒါန်းမှု ဖျက်နေသည်..."),
              ],
            ),
          ),
        );
      },
    );

    // Get the donation date to refresh the correct month/year list after deletion
    final donationDate = data.donationDate;
    final month =
        donationDate != null ? donationDate.month : DateTime.now().month;
    final year = donationDate != null ? donationDate.year : DateTime.now().year;

    // Call the donation provider to delete the donation
    if (data.id != null) {
      final donationService = ref.read(donationServiceProvider);

      donationService.deleteDonation(data.id.toString()).then((_) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Refresh specific month/year data
        final params = (month: month, year: year);
        ref.invalidate(donationsByMonthYearProvider(params));
        ref.invalidate(donationsByYearProvider(year));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('သွေးလှူဒါန်းမှု ဖျက်ပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to previous screen
        Navigator.pop(context);
      }).catchError((error) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('သွေးလှူဒါန်းမှု ဖျက်၍မရပါ: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } else {
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show error message if donation ID is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('သွေးလှူဒါန်းမှု အိုင်ဒီ မရှိပါ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void goToDetail() {
    if (data.memberObj != null && data.memberObj!.id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberDetailScreen(
            memberId: data.memberObj!.id.toString(),
          ),
        ),
      );
    } else if (data.memberId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemberDetailScreen(
            memberId: data.memberId!,
          ),
        ),
      );
    } else {
      // Show a message if member data is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အဖွဲ့ဝင်အချက်အလက် မရှိပါ။'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
