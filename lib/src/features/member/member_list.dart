import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/member/member_detail.dart';
import 'package:merchant/src/features/member/new_member.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class MemberList extends StatefulWidget {
  static const routeName = "/member_list";

  @override
  _MemberListState createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  // late Stream<QuerySnapshot> _usersStream;
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;

  @override
  void initState() {
    super.initState();
    // _usersStream = FirebaseFirestore.instance.collection('members').snapshots();
    // fetchMembers();
  }

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
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: _usersStream,
      //   builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      //     if (snapshot.hasError) {
      //       return Text('Something went wrong');
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
      //       scrollDirection: Axis.vertical,
      //       children: [
      //         Container(
      //           height: snapshot.data!.docs.length > 8
      //               ? MediaQuery.of(context).size.height *
      //                   (snapshot.data!.docs.length / 8)
      //               : MediaQuery.of(context).size.height,
      //           width: MediaQuery.of(context).size.width * 1.9,
      //           child: ListView(
      //             shrinkWrap: true,
      //             scrollDirection: Axis.horizontal,
      //             children: [
      //               Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Container(
      //                     height: Responsive.isMobile(context) ? 46 : 50,
      //                     width: Responsive.isMobile(context)
      //                         ? MediaQuery.of(context).size.width * 0.9
      //                         : MediaQuery.of(context).size.width * 0.3,
      //                     margin: const EdgeInsets.only(
      //                         left: 16, top: 24, right: 16),
      //                     child: TypeAheadField(
      //                       textFieldConfiguration: TextFieldConfiguration(
      //                         controller: memberController,
      //                         autofocus: false,
      //                         onChanged: (String value) {
      //                           if (value == "") {
      //                             _usersStream = FirebaseFirestore.instance
      //                                 .collection('members')
      //                                 .snapshots();
      //                           }
      //                         },
      //                         decoration: inputBoxDecoration("ရှာဖွေမည်"),
      //                       ),
      //                       suggestionsCallback: (pattern) {
      //                         membersSelected.clear();
      //                         membersSelected.addAll(allMembers);
      //                         membersSelected.retainWhere((s) => s
      //                             .toLowerCase()
      //                             .contains(pattern.toLowerCase()));
      //                         return membersSelected;
      //                       },
      //                       transitionBuilder:
      //                           (context, suggestionsBox, controller) {
      //                         return suggestionsBox;
      //                       },
      //                       itemBuilder: (context, suggestion) {
      //                         return ListTile(
      //                           title: Text(
      //                             suggestion.toString(),
      //                             textScaleFactor: 1.0,
      //                           ),
      //                         );
      //                       },
      //                       errorBuilder:
      //                           (BuildContext context, Object? error) => Text(
      //                               '$error',
      //                               style: TextStyle(
      //                                   color: Theme.of(context).errorColor)),
      //                       onSuggestionSelected: (suggestion) {
      //                         memberController.text = suggestion.toString();
      //                         setMember(suggestion.toString());
      //                       },
      //                     ),
      //                   ),
      //                   header(),
      //                   Column(
      //                     // shrinkWrap: true,
      //                     // scrollDirection: Axis.vertical,
      //                     children: snapshot.data!.docs
      //                         .map((DocumentSnapshot document) {
      //                       Map<String, dynamic> data =
      //                           document.data()! as Map<String, dynamic>;
      //                       return memberRow(data);
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
      // ),
      body: PaginateFirestore(
        // Use SliverAppBar in header to make it sticky
        // item builder type is compulsory.
        itemBuilderType:
            PaginateBuilderType.listView, 
        itemsPerPage: 50,
        //Change types accordingly
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>;
          
          return memberRow2(data);
        },
        // orderBy is compulsory to enable pagination
        query: FirebaseFirestore.instance
            .collection('members')
            .orderBy('member_id'),
        // to fetch real-time data
        isLive: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMemberScreen(),
            ),
          );
          // _usersStream =
          //     FirebaseFirestore.instance.collection('members').snapshots();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void setMember(String name) {
    print(name);
    setState(() {
      // _usersStream = FirebaseFirestore.instance
      //     .collection('members')
      //     .where("name", isEqualTo: name)
      //     .snapshots();
    });
  }

  fetchMembers() async {
    FirebaseFirestore.instance.collection('members').get().then((value) {
      value.docs.forEach((result) {
        print(result.data());
        setState(() {
          allMembers.add(result.data()['name']);
        });
      });
    });
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 48 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 2.4
          : MediaQuery.of(context).size.width - 40,
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

  Widget memberRow(Map<String, dynamic> data) {
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
              // scrollDirection: Axis.horizontal,
              // physics: const NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data['member_id'] ?? "-",
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
                    data['name'] ?? "-",
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
                    data['father_name'] ?? "-",
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
                    data['blood_type'] ?? "-",
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
                    data['nrc'] ?? "-",
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
                    data['blood_bank_card'] ?? "-",
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
                    data['total_count'] != null
                        ? Utils.strToMM(data['total_count'])
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
                // scrollDirection: Axis.horizontal,
                // physics: const NeverScrollableScrollPhysics(),
                children: [
                  Expanded(
                    
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['name'] ?? "-",
                              style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 15 : 17,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4,),
                            Text(
                             "( အဖ - " + data['father_name'] +
                                      ")" ,
                              style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 14 : 16,
                                  color: Colors.black),
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
                  Column(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
