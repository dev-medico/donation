import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/src/features/donation_member/presentation/new_member.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';

class SearchMemberScreen extends StatefulWidget {
  static const routeName = "/member_search";

  @override
  _SearchMemberScreenState createState() => _SearchMemberScreenState();
}

class _SearchMemberScreenState extends State<SearchMemberScreen> {
  late Stream<QuerySnapshot> _usersStream;

  List<String> lastDates = [];
  String selectedBloodType = "သွေးအုပ်စု ရွေးချယ်ရန်";
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(
          value: "သွေးအုပ်စု ရွေးချယ်ရန်",
          child: Text("သွေးအုပ်စု ရွေးချယ်ရန်")),
      const DropdownMenuItem(value: "A (Rh +)", child: Text("A (Rh +)")),
      const DropdownMenuItem(value: "A (Rh -)", child: Text("A (Rh -)")),
      const DropdownMenuItem(value: "B (Rh +)", child: Text("B (Rh +)")),
      const DropdownMenuItem(value: "B (Rh -)", child: Text("B (Rh -)")),
      const DropdownMenuItem(value: "AB (Rh +)", child: Text("AB (Rh +)")),
      const DropdownMenuItem(value: "AB (Rh -)", child: Text("AB (Rh -)")),
      const DropdownMenuItem(value: "O (Rh +)", child: Text("O (Rh +)")),
      const DropdownMenuItem(value: "O (Rh -)", child: Text("O (Rh -)")),
    ];
    return menuItems;
  }

  @override
  void initState() {
    super.initState();
    var dateNow = DateTime.now();
    var newDate = DateTime(dateNow.year, dateNow.month - 4, dateNow.day);
    _usersStream = FirebaseFirestore.instance
        .collection('members_last_record')
        .where("last_date_detail", isLessThan: newDate)
        .orderBy("last_date_detail", descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 252, 231),
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
          child: Text("သွေးလှူရှင်ရှာဖွေမည်",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 17,
                  color: Colors.white)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitCircle(
                color: Colors.white,
                size: 60.0,
              ),
            );
          }

          return ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              SizedBox(
                height: snapshot.data!.docs.length > 8
                    ? MediaQuery.of(context).size.height *
                        (snapshot.data!.docs.length / 8)
                    : MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 1.9,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: Responsive.isMobile(context) ? 46 : 50,
                          width: Responsive.isMobile(context)
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width * 0.3,
                          margin: const EdgeInsets.only(
                              left: 16, top: 24, right: 16),
                          child: DropdownButtonFormField(
                              value: selectedBloodType,
                              style: const TextStyle(
                                  fontSize: 13.5, color: Colors.black),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.only(
                                    left: 20, right: 12, bottom: 4),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  selectedBloodType = val.toString();
                                  if (selectedBloodType ==
                                      "သွေးအုပ်စု ရွေးချယ်ရန်") {
                                    _usersStream = FirebaseFirestore.instance
                                        .collection('members')
                                        .snapshots();
                                  } else {
                                    _usersStream = FirebaseFirestore.instance
                                        .collection('members_last_record')
                                        .where("blood_type",
                                            isEqualTo: selectedBloodType)
                                        .snapshots();
                                  }
                                });
                              },
                              items: dropdownItems),
                        ),
                        header(),
                        Column(
                          // shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return memberRow(data);
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void setMember(String name) {
    print(name);
    setState(() {
      _usersStream = FirebaseFirestore.instance
          .collection('members')
          .where("name", isEqualTo: name)
          .snapshots();
    });
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 48 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width - 20
          : MediaQuery.of(context).size.width - 60,
      margin: const EdgeInsets.only(top: 24, left: 12, right: 20),
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
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 6.5,
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
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 6,
                child: Text(
                  "နောက်ဆုံးလှူခဲ့သည့်ရက်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 6
                    : MediaQuery.of(context).size.width / 9,
                child: Text(
                  "အခြေအနေ",
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

  Widget memberRow(Map<String, dynamic> data) {
    //get date difference
    bool available = true;
    if (data['last_date_detail'] != null) {
      DateTime now = DateTime.now();
      DateTime lastDate = (data['last_date_detail'] as Timestamp).toDate();
      Duration difference = now.difference(lastDate);
      int days = difference.inDays;
      if (days < 120) {
        available = false;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => MemberDetailScreen(data: data),
        //   ),
        // );
      },
      child: Container(
        height: Responsive.isMobile(context) ? 50 : 54,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width - 20
            : MediaQuery.of(context).size.width - 60,
        margin: const EdgeInsets.only(top: 4, left: 12, right: 20),
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
                      ? MediaQuery.of(context).size.width / 2.9
                      : MediaQuery.of(context).size.width / 6.5,
                  child: Text(
                    data['name'] ?? "-",
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
                      ? MediaQuery.of(context).size.width / 3.8
                      : MediaQuery.of(context).size.width / 7,
                  child: Text(
                    data['last_date'] != null &&
                            data['last_date'] != "01 Jan 1990"
                        ? data['last_date']
                        : "-",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                    width: Responsive.isMobile(context)
                        ? MediaQuery.of(context).size.width / 4.5
                        : MediaQuery.of(context).size.width / 7,
                    child: available
                        ? Image.asset(
                            "assets/images/checked.png",
                            width: 20,
                            height: 20,
                          )
                        : SvgPicture.asset(
                            "assets/images/warn.svg",
                            width: 20,
                          )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
