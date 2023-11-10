import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation/donation_by_member_data_source.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_edit.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/member-detail';
  Member data;
  bool isEditable;
  MemberDetailScreen({Key? key, required this.data, this.isEditable = true})
      : super(key: key);

  @override
  ConsumerState<MemberDetailScreen> createState() =>
      _MemberDetailScreenState(data);
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  Member data;
  _MemberDetailScreenState(this.data);
  List<Donation> donationDatas = [];

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    var donations = ref
        .watch(donationsSortedByDateProvider(widget.data.memberId.toString()));
    if (donationDatas.isEmpty) {
      donations.forEach((element) {
        donationDatas.add(element);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: widget.isEditable
          ? AppBar(
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
            )
          : null,
      body: Responsive.isMobile(context)
          ? ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                Container(
                  width: double.infinity,
                  decoration: shadowDecoration(Colors.white),
                  margin: const EdgeInsets.only(
                      top: 8, left: 20, right: 20, bottom: 20),
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
                                Text(
                                    Responsive.isMobile(context)
                                        ? "ရက်စွဲ"
                                        : "အဖွဲ့ဝင်သည့်ရက်စွဲ",
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
                                  data.registerDate!.string("dd MMM yyyy"),
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
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const Expanded(
                            flex: 4,
                            child: Text("လိင်အမျိုးအစား",
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
                              data.gender.toString().toUpperCase(),
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
                              data.memberCount.toString(),
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
                              data.totalCount.toString(),
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
                      widget.isEditable
                          ? Align(
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
                                                fontSize: 15,
                                                color: primaryColor)),
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
                            )
                          : Container(),
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
                    buildSimpleTable(donationDatas)
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
                    height: MediaQuery.of(context).size.height * 0.8,
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
                                    data.registerDate.toString(),
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
                        Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            const Expanded(
                              flex: 4,
                              child: Text("လိင်အမျိုးအစား",
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
                                data.gender.toString().toUpperCase(),
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
                                data.memberCount.toString(),
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
                                data.totalCount.toString(),
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
                                "${data.address.toString().replaceAll(" ", "")}",
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text("ဖျက်မည်",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: primaryColor)),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Icon(
                                          Icons.delete,
                                          size: 24,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      confirmDeleteDialog(
                                          "ဖျက်မည်မှာ သေချာပါသလား?",
                                          "အဖွဲ့ဝင် စာရင်းအား ဖျက်မည်မှာ \nသေချာပါသလား?",
                                          context,
                                          "အိုကေ",
                                          Colors.black, () {
                                        ref
                                            .watch(realmProvider)!
                                            .deleteMember(data);
                                        ref.invalidate(membersProvider);
                                        ref.invalidate(memberStreamProvider);
                                        ref.invalidate(membersDataProvider);
                                        Navigator.pop(context);
                                      });
                                    }),
                                SizedBox(
                                  width: 24,
                                ),
                                widget.isEditable
                                    ? GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text("ပြင်ဆင်မည်",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: primaryColor)),
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
                                          // ref.watch(realmProvider)!.deleteMember(data);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MemberEditScreen(data: data),
                                            ),
                                          );
                                        })
                                    : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: shadowDecoration(Colors.white),
                      padding: EdgeInsets.only(top: 4, left: 18, bottom: 12),
                      margin: const EdgeInsets.only(
                        left: 20,
                        top: 30,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        // padding:
                        //     const EdgeInsets.only(top: 4, left: 18, bottom: 12),
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: const Text("အဖွဲ့နှင့် သွေးလှူဒါန်းမှုများ",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Expanded(
                            child: buildSimpleTable(donationDatas),
                          )
                        ],
                      ),
                    ))
              ],
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

  buildSimpleTable(List<Donation> data) {
    DonationByMemberDataSource memberDataDataSource =
        DonationByMemberDataSource(donationData: data, ref: ref);
    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: memberDataDataSource,
        onCellTap: (details) async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailScreen(
                data: data[details.rowColumnIndex.rowIndex - 1],
              ),
            ),
          );
          ref.invalidate(membersProvider);
        },
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: Responsive.isMobile(context)
            ? ColumnWidthMode.auto
            : ColumnWidthMode.fitByCellValue,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'ရက်စွဲ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ရက်စွဲ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'လှူဒါန်းသည့်နေရာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လှူဒါန်းသည့်နေရာ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'လူနာအမည်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လူနာအမည်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'လိပ်စာ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'လိပ်စာ',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'အသက်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'အသက်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'ဖြစ်ပွားသည့်ရောဂါ',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'ဖြစ်ပွားသည့်ရောဂါ',
                    style: TextStyle(color: Colors.white),
                  ))),
        ],
      ),
    );
  }
}
