import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/src/features/member/new_member.dart';
import 'package:merchant/src/features/new_features/member/member_detail_new_style.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';

class MemberListNewStyle extends StatefulWidget {
  static const routeName = "/member_list";

  const MemberListNewStyle({Key? key}) : super(key: key);

  @override
  _MemberListNewStyleState createState() => _MemberListNewStyleState();
}

class _MemberListNewStyleState extends State<MemberListNewStyle>
    with SingleTickerProviderStateMixin {
  List<String> categories = [];
  TabController? tabController;
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("member_string")
        .get()
        .then((value) {
      var members = value['members'];
      int tabLength = 0;
      setState(() {
        data = MemberListResponse.fromJson(jsonDecode(members)).data!;

        if (data!.length % 50 == 0) {
          tabLength = data!.length ~/ 50;
        } else {
          tabLength = data!.length ~/ 50 + 1;
        }

        tabController =
            TabController(length: tabLength, vsync: this, initialIndex: 0);
        for (int i = 0; i < data!.length; i = i + 50) {
          if (i + 50 > data!.length) {
            categories.add(data![i].memberId! +
                " မှ " +
                data![data!.length - 1].memberId!);
          } else {
            categories
                .add(data![i].memberId! + " မှ " + data![i + 49].memberId!);
          }
        }
      });
    });
  }

  tabCreate() => Scaffold(
        backgroundColor: Colors.white70,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: Responsive.isMobile(context) ? 10 : 20,
                  right: Responsive.isMobile(context) ? 10 : 20,
                  top: 20,
                  bottom: 20),
              child: TabBar(
                indicatorColor: primaryDark,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                controller: tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.deepOrange),
                isScrollable: true,
                tabs: List<Widget>.generate(categories.length, (int index) {
                  return Container(
                    padding: EdgeInsets.only(
                        left: 2,
                        right: 2,
                        bottom: Responsive.isMobile(context) ? 4 : 12,
                        top: Responsive.isMobile(context) ? 4 : 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(categories[index],
                        style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 14 : 16)),
                  );
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: Responsive.isMobile(context) ? 80 : 100.0),
              child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children:
                      List<Widget>.generate(categories.length, (int index) {
                    var dataSegments = data!.sublist(
                        index * 50,
                        index * 50 +
                            (index == categories.length - 1
                                ? data!.length - index * 50
                                : 50));
                    return ListView(
                      padding:  EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 8,
                          width: MediaQuery.of(context).size.width * 2.5,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              Column(
                                children: [
                                  header(),
                                  Column(
                                    children:
                                        dataSegments.map((MemberData document) {
                                      return memberRow(document);
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // child: ListView.builder(
                          //     padding: const EdgeInsets.only(top: 20, bottom: 20),
                          //     itemBuilder: (context, index) {
                          //       return memberRow(dataSegments[index]);
                          //     },
                          //     itemCount: dataSegments.length),
                        ),
                      ],
                    );
                  })),
            ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  List<MemberData>? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.of(context)?.current!.accentColor,
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
          padding: const EdgeInsets.only(top: 4),
          child: Text("အဖွဲ့၀င်များ",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 17,
                  color: Colors.white)),
        ),
      ),
      body: data != null && data!.isNotEmpty
          ? tabCreate()
          : const Center(
              child: CircularProgressIndicator(),
            ),
      // body: data != null && data!.isNotEmpty
      //     ? ListView.builder(
      //         itemBuilder: (context, index) {
      //           return memberRow(data![index]);
      //         },
      //         itemCount: data!.length)
      //     : const Center(
      //         child: CircularProgressIndicator(),
      //       ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  fetchMembers() async {
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("member_string")
        .get()
        .then((value) {
      var members = value['members'];
      var data = MemberListResponse.fromJson(jsonDecode(members)).data!;
      for (var element in data) {
        setState(() {
          allMembers.add(element.name!);
        });
      }
    });
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 48 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 2.4
          : MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.only(left: 12, right: 20),
      padding: const EdgeInsets.only(left: 20, right: 20),
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
                    ? MediaQuery.of(context).size.width / 5
                    : MediaQuery.of(context).size.width / 12,
                child: Text(
                  "အမှတ်စဉ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 4 : 8,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 6.2,
                child: Text(
                  "အမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3.5
                    : MediaQuery.of(context).size.width / 8,
                child: Text(
                  "အဖအမည်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 2 : 26,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 5
                    : MediaQuery.of(context).size.width / 9,
                child: Text(
                  "သွေးအုပ်စု",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "မှတ်ပုံတင်အမှတ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3.5
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "သွေးဘဏ်ကတ်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "သွေးလှူမှုကြိမ်ရေ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget memberRow(MemberData data) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailNewStyleScreen(data: data),
          ),
        );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 60 : 64,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 2.4
            : MediaQuery.of(context).size.width - 40,
        margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
        padding: const EdgeInsets.only(left: 18, right: 20),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            Row(
              children: [
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data.memberId ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.8
                      : MediaQuery.of(context).size.width / 6.5,
                  child: Text(
                    data.name ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data.fatherName ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 4 : 0,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 4
                      : MediaQuery.of(context).size.width / 9,
                  child: Text(
                    data.bloodType ?? "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width / 8,
                  child: Text(
                    data.nrc ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 18 : 54,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.5
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data.bloodBankCard ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: Responsive.isMobile(context) ? 12 : 0,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 3.5
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data.totalCount != null
                        ? Utils.strToMM(data.totalCount!)
                        : "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget memberRow2(Map<String, dynamic> data) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberDetailScreen(data: data),
          ),
        );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 98 : 102,
        decoration: shadowDecoration(Colors.white),
        margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
        padding: const EdgeInsets.only(left: 18, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 12.0, bottom: 8, left: 6, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data['member_id'] ?? "-",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data['total_count'] != null
                        ? Utils.strToMM(data['total_count']) + " ကြိမ်"
                        : "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                data['name'] ?? "-",
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 15 : 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "( အဖ - " + data['father_name'] + ")",
                                style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 16,
                                    color: Colors.black),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          data['nrc'] ?? "-",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          data['blood_type'] ?? "-",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 15 : 17,
                              color: Colors.red),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          data['blood_bank_card'] ?? "-",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
