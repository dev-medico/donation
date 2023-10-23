import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation_member/presentation/member_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/blood_donation_edit.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                                  data.memberObj!.memberId.toString(),
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
                                  data.memberObj!.name.toString(),
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
                            children: const [
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
                                  "father_name",
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
                            children: const [
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
                                  "bolood type",
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
                                  data.memberObj!.birthDate.toString(),
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
                                  data.memberObj!.bloodBankCard.toString(),
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
                                      data.memberObj != null
                                          ? data.memberObj!.memberId.toString()
                                          : "-",
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
                                      data.memberObj != null
                                          ? data.memberObj!.name.toString()
                                          : "-",
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
                                      data.memberObj != null
                                          ? data.memberObj!.fatherName
                                              .toString()
                                          : "-",
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
                                      data.memberObj != null
                                          ? data.memberObj!.bloodType.toString()
                                          : "-",
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
                                      data.memberObj != null
                                          ? data.memberObj!.birthDate.toString()
                                          : "-",
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
                                      data.memberObj != null
                                          ? data.memberObj!.bloodBankCard
                                              .toString()
                                          : "-",
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BloodDonationEditScreen(
                                data: data,
                              ),
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
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  deleteDonation() {
    if (data.memberObj != null) {
      ref.watch(realmProvider)!.updateMember(
            data.memberObj!,
            memberCount: ((int.parse(data.memberObj!.memberCount ?? "0")) - 1)
                .toString(),
            totalCount:
                ((int.parse(data.memberObj!.totalCount ?? "0")) - 1).toString(),
          );
    }

    ref.watch(realmProvider)!.deleteDonation(data);

    Navigator.pop(context);
    // XataRepository().deleteDonationByID(data.id.toString()).then((value) {
    //   if (value.statusCode.toString().startsWith("2")) {
    //     XataRepository().getDonationsTotal().then((value) {
    //       var newMemberCount = int.parse(
    //               TotalDataResponse.fromJson(jsonDecode(value.body))
    //                   .records!
    //                   .first
    //                   .value
    //                   .toString()) -
    //           1;
    //       XataRepository().updateDonationsTotal(newMemberCount);

    //       int donationCount = data.memberObj!.memberCount == null ||
    //               data.memberObj!.memberCount == 0
    //           ? 0
    //           : int.parse(data.memberObj!.memberCount.toString()) - 1;
    //       int totalCount = data.memberObj!.totalCount == null ||
    //               data.memberObj!.totalCount == 0
    //           ? 0
    //           : int.parse(data.memberObj!.totalCount.toString()) - 1;
    //       XataRepository().updateMember(
    //           data.memberObj!.id.toString(), donationCount, totalCount);
    //     });
    //   } else {
    //     log(value.statusCode.toString());
    //     log(value.body);
    //   }
    // });
  }

  goToDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(data: data.memberObj!),
      ),
    );
  }
}
