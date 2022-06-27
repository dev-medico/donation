import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_expandable_table/flutter_expandable_table.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/donation_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donation/new_blood_donation.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';

class BloodDonationListNewStyle extends StatefulWidget {
  static const routeName = "/new_blood_donation_list";

  const BloodDonationListNewStyle({Key? key}) : super(key: key);

  @override
  _BloodDonationListNewStyleState createState() =>
      _BloodDonationListNewStyleState();
}

class _BloodDonationListNewStyleState extends State<BloodDonationListNewStyle>
    with SingleTickerProviderStateMixin {
  List<String> ranges = [
    "2022",
    "2021",
    "2020",
    "2019",
    "2018",
    "2017",
    "2016",
    "2015",
    "2014",
    "2013",
    "2012",
  ];
  List<String> bloodTypes = [
    "A (Rh +)",
    "A (Rh -)",
    "B (Rh +)",
    "B (Rh -)",
    "AB (Rh +)",
    "AB (Rh -)",
    "O (Rh +)",
    "O (Rh -)"
  ];
  List<DonationData> dataSegments = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('member_count')
        .doc("donation_string")
        .get()
        .then((value) {
      var members = value['donations'];
      int tabLength = 0;
      setState(() {
        data = DonationListResponse.fromJson(jsonDecode(members)).data!;

        if (data!.length % 50 == 0) {
          tabLength = data!.length ~/ 50;
        } else {
          tabLength = data!.length ~/ 50 + 1;
        }

        List<DonationData> filterData = [];
        for (int i = 0; i < data!.length; i++) {
          filterData.add(data![i]);
        }
        filterData.sort((a, b) {
          //sorting in ascending order
          return DateTime.parse(b.dateDetail == null
                  ? "2020-01-01"
                  : b.dateDetail.toString().split("T")[0])
              .compareTo(DateTime.parse(a.dateDetail == null
                  ? "2020-01-01"
                  : a.dateDetail.toString().split("T")[0]));
        });

        setState(() {
          dataSegments = filterData;
        });
      });
    });
  }

  tabCreate() => Scaffold(
        backgroundColor: Colors.white70,
        body: Stack(
          children: [
            Responsive.isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2.22,
                            margin: const EdgeInsets.only(top: 20, left: 20),
                            child: DropdownButtonFormField2(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text(
                                "နှစ် အလိုက်ကြည့်မည်",
                                style: TextStyle(fontSize: 13),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 30,
                              buttonHeight: 60,
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              items: ranges
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return "နှစ် အလိုက်ကြည့်မည်";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                List<DonationData> filterData = [];
                                for (int i = 0; i < data!.length; i++) {
                                  if (data![i].date!.split(" ")[2] == value) {
                                    filterData.add(data![i]);
                                  }
                                }
                                filterData.sort((a, b) {
                                  //sorting in ascending order
                                  return DateTime.parse(b.dateDetail == null
                                          ? "2020-01-01"
                                          : b.dateDetail
                                              .toString()
                                              .split("T")[0])
                                      .compareTo(DateTime.parse(
                                          a.dateDetail == null
                                              ? "2020-01-01"
                                              : a.dateDetail
                                                  .toString()
                                                  .split("T")[0]));
                                });

                                setState(() {
                                  dataSegments = filterData;
                                });
                              },
                              onSaved: (value) {},
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.22,
                            margin: const EdgeInsets.only(top: 20, left: 12),
                            child: DropdownButtonFormField2(
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              isExpanded: true,
                              hint: const Text(
                                "သွေးအုပ်စု အလိုက်ကြည့်မည်",
                                style: TextStyle(fontSize: 13),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              iconSize: 30,
                              buttonHeight: 60,
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              items: bloodTypes
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                              validator: (value) {
                                if (value == null) {
                                  return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                                }
                                return null;
                              },
                              onChanged: (value) {
                                List<DonationData>? filterdata = [];
                                for (int i = 0; i < data!.length; i++) {
                                  //get DonationData from data only where bloodtype is equal to value
                                  if (data![i].memberBloodType == value) {
                                    filterdata.add(data![i]);
                                  }
                                }
                                filterdata.sort((a, b) {
                                  //sorting in ascending order
                                  return DateTime.parse(b.dateDetail == null
                                          ? "2020-01-01"
                                          : b.dateDetail
                                              .toString()
                                              .split("T")[0])
                                      .compareTo(DateTime.parse(
                                          a.dateDetail == null
                                              ? "2020-01-01"
                                              : a.dateDetail
                                                  .toString()
                                                  .split("T")[0]));
                                });

                                setState(() {
                                  dataSegments = filterdata.sublist(0);
                                });
                              },
                              onSaved: (value) {},
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 40,
                        margin:
                            const EdgeInsets.only(right: 20, top: 12, left: 20),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: TextFormField(
                          autofocus: false,
                          controller: searchController,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          onChanged: (val) {
                            List<DonationData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get DonationData from data only where bloodtype is equal to value
                              if (data![i]
                                  .memberName!
                                  .toLowerCase()
                                  .contains(val.toString().toLowerCase())) {
                                filterdata.add(data![i]);
                              }
                            }
                            setState(() {
                              dataSegments = filterdata.sublist(0);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                            hintStyle: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            fillColor: Colors.white.withOpacity(0.2),
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 20, right: 20, top: 4, bottom: 4),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 28, left: 24),
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          isExpanded: true,
                          hint: const Text(
                            "နှစ် အလိုက်ကြည့်မည်",
                            style: TextStyle(fontSize: 14),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          buttonHeight: 60,
                          buttonPadding:
                              const EdgeInsets.only(left: 20, right: 10),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          items: ranges
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return "နှစ် အလိုက်ကြည့်မည်";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            List<DonationData> filterData = [];
                            for (int i = 0; i < data!.length; i++) {
                              if (data![i].date!.split(" ")[2] == value) {
                                filterData.add(data![i]);
                              }
                            }

                            filterData.sort((a, b) {
                              //sorting in ascending order
                              return DateTime.parse(b.dateDetail == null
                                      ? "2020-01-01"
                                      : b.dateDetail.toString().split("T")[0])
                                  .compareTo(DateTime.parse(a.dateDetail == null
                                      ? "2020-01-01"
                                      : a.dateDetail.toString().split("T")[0]));
                            });

                            setState(() {
                              dataSegments = filterData;
                            });
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin: const EdgeInsets.only(top: 28, left: 20),
                        child: DropdownButtonFormField2(
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          isExpanded: true,
                          hint: const Text(
                            "သွေးအုပ်စု အလိုက်ကြည့်မည်",
                            style: TextStyle(fontSize: 14),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black45,
                          ),
                          iconSize: 30,
                          buttonHeight: 60,
                          buttonPadding:
                              const EdgeInsets.only(left: 20, right: 10),
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          items: bloodTypes
                              .map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          validator: (value) {
                            if (value == null) {
                              return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            List<DonationData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get DonationData from data only where bloodtype is equal to value
                              if (data![i].memberBloodType == value) {
                                filterdata.add(data![i]);
                              }
                            }
                            filterdata.sort((a, b) {
                              //sorting in ascending order
                              return DateTime.parse(b.dateDetail == null
                                      ? "2020-01-01"
                                      : b.dateDetail.toString().split("T")[0])
                                  .compareTo(DateTime.parse(a.dateDetail == null
                                      ? "2020-01-01"
                                      : a.dateDetail.toString().split("T")[0]));
                            });
                            setState(() {
                              dataSegments = filterdata.sublist(0);
                            });
                          },
                          onSaved: (value) {},
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        margin:
                            const EdgeInsets.only(right: 40, top: 28, left: 20),
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: TextFormField(
                          autofocus: false,
                          controller: searchController,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          onChanged: (val) {
                            List<DonationData>? filterdata = [];
                            for (int i = 0; i < data!.length; i++) {
                              //get DonationData from data only where bloodtype is equal to value
                              if (data![i].memberName!.contains(val)) {
                                filterdata.add(data![i]);
                              }
                            }
                            setState(() {
                              dataSegments = filterdata.sublist(0);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
                            hintStyle: const TextStyle(
                                color: Colors.black, fontSize: 15.0),
                            fillColor: Colors.white.withOpacity(0.2),
                            filled: true,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.search,
                                color: primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.only(
                                left: 20, right: 20, top: 4, bottom: 4),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.grey)),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
            Container(
              padding: EdgeInsets.only(
                  left: 20.0,
                  top: Responsive.isMobile(context) ? 160 : 100,
                  bottom: 12),
              child: buildSimpleTable(dataSegments),
            ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  List<DonationData>? data;

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
          child: Text("သွေးလှူဒါန်းမှုစာရင်း",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewBloodDonationScreen(),
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
        .doc("donation_string")
        .get()
        .then((value) {
      var members = value['donations'];
      var data = DonationListResponse.fromJson(jsonDecode(members)).data!;
      // order by date in descending order
      // data.sort((a, b) => DateTime(int.parse(b.date!.split(" ")[2])).compareTo(DateTime(int.parse(a.date!.split(" ")[2]))));
      for (var element in data) {
        setState(() {
          allMembers.add(element.memberName!);
        });
      }
      allMembers.sort((a, b) => b.compareTo(a));
    });
  }

  ExpandableTable buildSimpleTable(List<DonationData> data) {
    const int COLUMN_COUNT = 8;
    int ROWCOUNT = data.length;
    List<String> titles = [
      "သွေးအလှူရှင်",
      "သွေးအုပ်စု",
      "လှူဒါန်းသည့်နေရာ",
      "လူနာအမည်",
      "လိပ်စာ",
      "အသက်",
      "ဖြစ်ပွားသည့်ရောဂါ"
    ];

    //Creation header
    ExpandableTableHeader header = ExpandableTableHeader(
        firstCell: Container(
            width: Responsive.isMobile(context) ? 80 : 120,
            color: primaryColor,
            height: 60,
            margin: const EdgeInsets.all(1),
            child: const Center(
                child: Text(
              'ရက်စွဲ',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ))),
        children: List.generate(
            COLUMN_COUNT - 1,
            (index) => Container(
                color: primaryColor,
                margin: const EdgeInsets.all(1),
                child: Center(
                    child: Text(
                  titles[index],
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.white),
                )))));
    //Creation rows
    List<ExpandableTableRow> rows = List.generate(
        ROWCOUNT,
        (rowIndex) => ExpandableTableRow(
              height: 50,
              firstCell: Container(
                  color: const Color(0xffe1e1e1),
                  margin: const EdgeInsets.all(1),
                  child: Center(
                      child: Text(
                    data[rowIndex].date.toString(),
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ))),
              children: List<Widget>.generate(
                  COLUMN_COUNT - 1,
                  (columnIndex) => Container(
                      decoration: borderDecorationNoRadius(Colors.grey),
                      margin: const EdgeInsets.all(1),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: columnIndex == 4 ? 12 : 20.0,
                            top: columnIndex == 4 ? 4 : 14),
                        child: Text(
                          columnIndex == 0
                              ? data[rowIndex].memberName.toString()
                              : columnIndex == 1
                                  ? data[rowIndex].memberBloodType.toString()
                                  : columnIndex == 2
                                      ? data[rowIndex].hospital.toString()
                                      : columnIndex == 3
                                          ? data[rowIndex]
                                              .patientName
                                              .toString()
                                          : columnIndex == 4
                                              ? data[rowIndex]
                                                  .patientAddress
                                                  .toString()
                                              : columnIndex == 5
                                                  ? data[rowIndex]
                                                      .patientAge
                                                      .toString()
                                                  : columnIndex == 6
                                                      ? data[rowIndex]
                                                          .patientDisease
                                                          .toString()
                                                      : "",
                          textAlign: columnIndex == 5 || columnIndex == 2
                              ? TextAlign.center
                              : TextAlign.start,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 15,
                              color: Colors.black),
                        ),
                      ))),
            ));

    return ExpandableTable(
      rows: rows,
      header: header,
      cellWidth: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.14,
      cellHeight: 52,
      headerHeight: 52,
      firstColumnWidth: Responsive.isMobile(context) ? 94 : 200,
      scrollShadowColor: Colors.grey,
    );
  }
}
