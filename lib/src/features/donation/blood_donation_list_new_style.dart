import 'dart:developer';

import 'package:donation/realm/schemas.dart';
import 'package:donation/src/features/donation/blood_donation_report.dart';
import 'package:donation/src/features/donation/controller/donation_provider.dart';
import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/home/mobile_home.dart';
import 'package:donation/src/features/home/mobile_home/humberger.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/donation_data_source.dart';
import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:tab_container/tab_container.dart';

class BloodDonationListNewStyle extends ConsumerStatefulWidget {
  static const routeName = "/donations_old";
  final bool fromHome;

  const BloodDonationListNewStyle({Key? key, this.fromHome = false})
      : super(key: key);

  @override
  _BloodDonationListNewStyleState createState() =>
      _BloodDonationListNewStyleState();
}

class _BloodDonationListNewStyleState
    extends ConsumerState<BloodDonationListNewStyle>
    with SingleTickerProviderStateMixin {
  late TextTheme textTheme;
  List<String> ranges = [
    "2023",
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
  List<bool> rangesSelect = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  String selectedYear = "2023";
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];

  List<String> monthsMobile = [
    "01",
    "02",
    "03",
    "04",
    "05",
    "06",
    "07",
    "08",
    "09",
    "10",
    "11",
    "12",
  ];
  List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "O (Rh +)",
    "AB (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "O (Rh -)",
    "AB (Rh -)"
  ];
  List<Donation> dataSegments1 = [];
  List<Donation> dataSegments2 = [];
  List<Donation> dataSegments3 = [];
  List<Donation> dataSegments4 = [];
  List<Donation> dataSegments5 = [];
  List<Donation> dataSegments6 = [];
  List<Donation> dataSegments7 = [];
  List<Donation> dataSegments8 = [];
  List<Donation> dataSegments9 = [];
  List<Donation> dataSegments10 = [];
  List<Donation> dataSegments11 = [];
  List<Donation> dataSegments12 = [];
  TextStyle tabStyle = const TextStyle(fontSize: 16);
  bool dataFullLoaded = false;
  TabContainerController controller = TabContainerController(length: 12);

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // callAPI("");
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        data = [];
      });
    }
    // XataRepository().getDonationsList(after).then((response) {
    //   setState(() {
    //     oldData.addAll(
    //         XataDonationListResponse.fromJson(jsonDecode(response.body))
    //             .records!);
    //   });

    //   if (XataDonationListResponse.fromJson(jsonDecode(response.body))
    //           .meta!
    //           .page!
    //           .more ??
    //       false) {
    //     callAPI(XataDonationListResponse.fromJson(jsonDecode(response.body))
    //         .meta!
    //         .page!
    //         .cursor!);
    //   } else {
    //     log("Data Fully Loaded");
    //     setState(() {
    //       dataFullLoaded = true;
    //     });
    //     // ref.watch(donationsProvider).forEach((element) {
    //     //   ref.watch(realmProvider)!.deleteDonation(element);
    //     // });

    //     //Old Data Loaded

    //     log("Data Length: ${oldData.length}");

    //     var count = 0;
    //     var existCount = 0;
    //     oldData.forEach((element) {
    //       existCount++;
    //       var donationDate = element.date.toString() != "null"
    //           ? DateTime.parse(element.date!.replaceAll("Z", ""))
    //           : DateTime.now();
    //       bool noMember = ref
    //           .read(membersProvider)
    //           .where((data) =>
    //               data.memberId.toString() ==
    //               element.member!.memberId.toString())
    //           .isEmpty;
    //       var member = !noMember
    //           ? ref
    //               .read(membersProvider)
    //               .where((data) =>
    //                   data.memberId.toString() ==
    //                   element.member!.memberId.toString())
    //               .first
    //           : null;
    //       ref.watch(realmProvider)!.createDonation(
    //             member: !noMember ? member!.id : null,
    //             date: DateFormat('MM/dd/yyyy').format(donationDate),
    //             donationDate: donationDate,
    //             hospital: element.hospital,
    //             memberObj: member,
    //             memberId: noMember ? "" : member!.memberId.toString(),
    //             patientAddress: element.patientAddress.toString(),
    //             patientAge: element.patientAge.toString(),
    //             patientDisease: element.patientDisease.toString(),
    //             patientName: element.patientName.toString(),
    //           );

    //       //edit Member
    //       if (!noMember) {
    //         log(DateFormat('MM/dd/yyyy').format(member!.lastDate!).toString());

    //         if (DateFormat('MM/dd/yyyy').format(member.lastDate!).toString() ==
    //             "5/18/2023") {
    //           ref
    //               .watch(realmProvider)!
    //               .updateMember(member, lastDate: donationDate);
    //           count++;
    //         } else if (member.lastDate == null ||
    //             donationDate.compareTo(member.lastDate!) > 0) {
    //           ref
    //               .watch(realmProvider)!
    //               .updateMember(member, lastDate: donationDate);
    //           count++;
    //         }
    //       }
    //     });
    //     log("Editted Count - $count");
    //     log("Added Count - $existCount");

    //     sortBySegments();
    //   }
    // });
  }

  tabCreate() => Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            ListView(
              children: [
                Visibility(
                  visible: Responsive.isMobile(context),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0))),
                      margin:
                          const EdgeInsets.only(left: 15, top: 12, right: 30),
                      width: 120,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          int selectedMonth = controller.index;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder:
                                      (context) => BloodDonationReportScreen(
                                            month: selectedMonth,
                                            year: selectedYear,
                                            data: selectedMonth == 0
                                                ? dataSegments1
                                                : selectedMonth == 1
                                                    ? dataSegments2
                                                    : selectedMonth == 2
                                                        ? dataSegments3
                                                        : selectedMonth == 3
                                                            ? dataSegments4
                                                            : selectedMonth == 4
                                                                ? dataSegments5
                                                                : selectedMonth ==
                                                                        5
                                                                    ? dataSegments6
                                                                    : selectedMonth ==
                                                                            6
                                                                        ? dataSegments7
                                                                        : selectedMonth ==
                                                                                7
                                                                            ? dataSegments8
                                                                            : selectedMonth == 8
                                                                                ? dataSegments9
                                                                                : selectedMonth == 9
                                                                                    ? dataSegments10
                                                                                    : selectedMonth == 10
                                                                                        ? dataSegments11
                                                                                        : dataSegments12,
                                          )));
                        },
                        child: Align(
                            alignment: Alignment.center,
                            child: Row(
                              children: const [
                                SizedBox(
                                  width: 12,
                                ),
                                Icon(Icons.list_alt_outlined,
                                    color: Colors.white),
                                Padding(
                                    padding: EdgeInsets.only(
                                        top: 12, bottom: 12, left: 12),
                                    child: Text(
                                      "Report",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    )),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      margin:
                          const EdgeInsets.only(left: 20, top: 20, right: 40),
                      height: 50,
                      width: double.infinity,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(0.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: ranges.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rangesSelect.clear();
                                rangesSelect.addAll([
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false
                                ]);
                                rangesSelect[index] = true;
                                selectedYear = ranges[index];
                              });
                              sortBySegments();
                            },
                            child: Container(
                              width: Responsive.isMobile(context)
                                  ? MediaQuery.of(context).size.width / 5
                                  : MediaQuery.of(context).size.width / 17,
                              height: 42,
                              decoration: shadowDecorationOnlyTop(
                                  rangesSelect[index]
                                      ? Colors.red.withOpacity(0.6)
                                      : const Color(0xffe3e3e3)),
                              child: Center(
                                  child: Text(
                                ranges[index],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: rangesSelect[index]
                                        ? Colors.white
                                        : primaryColor),
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: !Responsive.isMobile(context),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          margin: const EdgeInsets.only(
                              left: 15, top: 24, right: 30),
                          width: 120,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              int selectedMonth = controller.index;
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BloodDonationReportScreen(
                                            month: selectedMonth,
                                            year: selectedYear,
                                            data: selectedMonth == 0
                                                ? dataSegments1
                                                : selectedMonth == 1
                                                    ? dataSegments2
                                                    : selectedMonth == 2
                                                        ? dataSegments3
                                                        : selectedMonth == 3
                                                            ? dataSegments4
                                                            : selectedMonth == 4
                                                                ? dataSegments5
                                                                : selectedMonth ==
                                                                        5
                                                                    ? dataSegments6
                                                                    : selectedMonth ==
                                                                            6
                                                                        ? dataSegments7
                                                                        : selectedMonth ==
                                                                                7
                                                                            ? dataSegments8
                                                                            : selectedMonth == 8
                                                                                ? dataSegments9
                                                                                : selectedMonth == 9
                                                                                    ? dataSegments10
                                                                                    : selectedMonth == 10
                                                                                        ? dataSegments11
                                                                                        : dataSegments12,
                                          )));
                            },
                            child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 12,
                                    ),
                                    Icon(Icons.list_alt_outlined,
                                        color: Colors.white),
                                    Padding(
                                        padding: EdgeInsets.only(
                                            top: 12, bottom: 12, left: 12),
                                        child: Text(
                                          "Report",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.white),
                                        )),
                                  ],
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.82,
                  child: TabContainer(
                    controller: controller,
                    color: const Color(0xffe3e3e3),
                    radius: 8,
                    tabEdge: TabEdge.top,
                    tabCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      animation = CurvedAnimation(
                          curve: Curves.easeIn, parent: animation);
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(0.2, 0.0),
                          end: const Offset(0.0, 0.0),
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    selectedTextStyle: TextStyle(
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                    unselectedTextStyle:
                        const TextStyle(fontSize: 13, color: Colors.black),
                    tabs: Responsive.isMobile(context) ? monthsMobile : months,
                    children: [
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments1),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments2),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments3),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments4),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments5),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments6),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments7),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments8),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments9),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments10),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments11),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: Responsive.isMobile(context) ? 0 : 12,
                              top: Responsive.isMobile(context) ? 20 : 12,
                              bottom: 12),
                          child: buildSimpleTable(dataSegments12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  final searchController = TextEditingController();
  final memberController = TextEditingController();
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  bool inputted = false;
  List<Donation>? data;
  // List<DonationRecord> oldData = [];

  @override
  Widget build(BuildContext context) {
    final streamAsyncValue = ref.watch(donationStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ))),
        leading: widget.fromHome && Responsive.isMobile(context)
            ? Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Humberger(
                  onTap: () {
                    ref.watch(drawerControllerProvider)!.toggle!.call();
                  },
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("သွေးလှူဒါန်းမှုစာရင်း",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: streamAsyncValue.when(
        data: (savedData) {
          final results = savedData.results;
          log("Data " + results.length.toString());

          List<Donation> donations = [];
          for (int i = 0; i < results.length; i++) {
            donations.add(results[i]);
          }
          setState(() {
            data = donations;
          });
          sortBySegments();

          if (data!.isNotEmpty) {
            return tabCreate();
          } else {
            return Container();
          }
        },
        error: (Object error, StackTrace stackTrace) {
          return Text(error.toString());
        },
        loading: () {
          return Container();
        },
      ),
      // body: data != null && data!.isNotEmpty
      //     ? tabCreate()
      //     : const Center(
      //         child: CircularProgressIndicator(),
      //       ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
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

  sortBySegments() {
    List<Donation> filterData1 = [];
    List<Donation> filterData2 = [];
    List<Donation> filterData3 = [];
    List<Donation> filterData4 = [];
    List<Donation> filterData5 = [];
    List<Donation> filterData6 = [];
    List<Donation> filterData7 = [];
    List<Donation> filterData8 = [];
    List<Donation> filterData9 = [];
    List<Donation> filterData10 = [];
    List<Donation> filterData11 = [];
    List<Donation> filterData12 = [];
    for (int i = 0; i < data!.length; i++) {
      if (data![i].date.toString() != "null" && data![i].date != null) {
        DateTime dateTime = data![i].donationDate!.toLocal();
        // if (data![i].date!.contains("T")) {
        //   dateTime = DateTime.parse(data![i].date!.split("T")[0].toString());
        // } else if (data![i].date!.contains(" ")) {
        //   dateTime = DateTime.parse(data![i].date!.split(" ")[0].toString());
        // }
        // if (dateTime!.year == int.parse(selectedYear) && dateTime.month == 1) {
        //   filterData1.add(data![i]);
        // }

        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 2) {
          filterData2.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 3) {
          filterData3.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 4) {
          filterData4.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 5) {
          filterData5.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 6) {
          filterData6.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 7) {
          filterData7.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 8) {
          filterData8.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 9) {
          filterData9.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 10) {
          filterData10.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 11) {
          filterData11.add(data![i]);
        }
        if (dateTime.year == int.parse(selectedYear) && dateTime.month == 12) {
          filterData12.add(data![i]);
        }
      } else {
        filterData11.add(data![i]);
      }
    }
    filterData1.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData1 = filterData1.reversed.toList();
    filterData2.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData2 = filterData2.reversed.toList();
    filterData3.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData3 = filterData3.reversed.toList();
    filterData4.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData4 = filterData4.reversed.toList();
    filterData5.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData5 = filterData5.reversed.toList();
    filterData6.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData6 = filterData6.reversed.toList();
    filterData7.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData7 = filterData7.reversed.toList();
    filterData8.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData8 = filterData8.reversed.toList();
    filterData9.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData9 = filterData9.reversed.toList();
    filterData10.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData10 = filterData10.reversed.toList();
    filterData11.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    // filterData11 = filterData11.reversed.toList();
    filterData12.sort((a, b) {
      return a.donationDate!.toLocal().compareTo(b.donationDate!.toLocal());
    });
    //filterData12 = filterData12.reversed.toList();

    setState(() {
      dataSegments1 = filterData1;
      dataSegments2 = filterData2;
      dataSegments3 = filterData3;
      dataSegments4 = filterData4;
      dataSegments5 = filterData5;
      dataSegments6 = filterData6;
      dataSegments7 = filterData7;
      dataSegments8 = filterData8;
      dataSegments9 = filterData9;
      dataSegments10 = filterData10;
      dataSegments11 = filterData11;
      dataSegments12 = filterData12;
    });
  }

  buildSimpleTable(List<Donation> data) {
    // const int COLUMN_COUNT = 8;
    // int ROWCOUNT = data.length;
    // List<String> titles = [
    //   "သွေးအလှူရှင်",
    //   "သွေးအုပ်စု",
    //   "လှူဒါန်းသည့်နေရာ",
    //   "လူနာအမည်",
    //   "လိပ်စာ",
    //   "အသက်",
    //   "ဖြစ်ပွားသည့်ရောဂါ"
    // ];

    // ExpandableTableHeader header = ExpandableTableHeader(
    //     firstCell: Container(
    //         width: Responsive.isMobile(context) ? 90 : 120,
    //         color: primaryColor,
    //         height: 60,
    //         margin: const EdgeInsets.all(1),
    //         child: const Center(
    //             child: Text(
    //           'ရက်စွဲ',
    //           style: TextStyle(fontSize: 15, color: Colors.white),
    //         ))),
    //     children: List.generate(
    //         COLUMN_COUNT - 1,
    //         (index) => Container(
    //             color: primaryColor,
    //             margin: const EdgeInsets.all(1),
    //             child: Center(
    //                 child: Text(
    //               titles[index],
    //               style: TextStyle(
    //                   fontSize: Responsive.isMobile(context) ? 13 : 14,
    //                   color: Colors.white),
    //             )))));

    // List<ExpandableTableRow> rows = List.generate(
    //     ROWCOUNT,
    //     (rowIndex) => ExpandableTableRow(
    //           height: 50,
    //           firstCell: Container(
    //               color: const Color(0xffe1e1e1),
    //               margin: const EdgeInsets.all(1),
    //               child: Center(
    //                   child: Text(
    //                 data[details.rowColumnIndex.rowIndex - 1].date!.contains("T")
    //                     ? data[details.rowColumnIndex.rowIndex - 1].date.toString().split("T")[0]
    //                     : data[details.rowColumnIndex.rowIndex - 1].date!.contains(" ")
    //                         ? data[details.rowColumnIndex.rowIndex - 1].date.toString().split(" ")[0]
    //                         : data[details.rowColumnIndex.rowIndex - 1].date.toString(),
    //                 style: const TextStyle(fontSize: 15, color: Colors.black),
    //               ))),
    //           children: List<Widget>.generate(
    //               COLUMN_COUNT - 1,
    //               (columnIndex) => GestureDetector(
    //                     behavior: HitTestBehavior.translucent,
    //                     onTap: () async {
    // Member member = Member(
    //   address: data[details.rowColumnIndex.rowIndex - 1].member!.address,
    //   birthDate: data[details.rowColumnIndex.rowIndex - 1].member!.birthDate,
    //   bloodBankCard: data[details.rowColumnIndex.rowIndex - 1].member!.bloodBankCard,
    //   bloodType: data[details.rowColumnIndex.rowIndex - 1].member!.bloodType,
    //   donationCounts:
    //       data[details.rowColumnIndex.rowIndex - 1].member!.donationCounts,
    //   fatherName: data[details.rowColumnIndex.rowIndex - 1].member!.fatherName,
    //   id: data[details.rowColumnIndex.rowIndex - 1].member!.id,
    //   lastDonationDate:
    //       data[details.rowColumnIndex.rowIndex - 1].member!.lastDonationDate,
    //   memberId: data[details.rowColumnIndex.rowIndex - 1].member!.memberId,
    //   name: data[details.rowColumnIndex.rowIndex - 1].member!.name,
    //   note: data[details.rowColumnIndex.rowIndex - 1].member!.note,
    //   nrc: data[details.rowColumnIndex.rowIndex - 1].member!.nrc,
    //   phone: data[details.rowColumnIndex.rowIndex - 1].member!.phone,
    //   registerDate: data[details.rowColumnIndex.rowIndex - 1].member!.registerDate,
    //   totalCount: data[details.rowColumnIndex.rowIndex - 1].member!.totalCount,
    // );
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => DonationDetailScreen(
    //               data: DonationSearchRecords(
    //                 date: data[details.rowColumnIndex.rowIndex - 1].date,
    //                 hospital: data[details.rowColumnIndex.rowIndex - 1].hospital,
    //                 id: data[details.rowColumnIndex.rowIndex - 1].id,
    //                 member: member,
    //                 patientAddress:
    //                     data[details.rowColumnIndex.rowIndex - 1].patientAddress,
    //                 patientAge: data[details.rowColumnIndex.rowIndex - 1].patientAge,
    //                 patientDisease:
    //                     data[details.rowColumnIndex.rowIndex - 1].patientDisease,
    //                 patientName:
    //                     data[details.rowColumnIndex.rowIndex - 1].patientName,
    //               ),
    //             )));
    // callAPI("");
    //                     },
    //                     child: Container(
    //                         decoration: borderDecorationNoRadius(Colors.grey),
    //                         margin: const EdgeInsets.all(1),
    //                         child: Padding(
    //                           padding: EdgeInsets.only(
    //                               left: columnIndex == 4 ? 12 : 20.0,
    //                               top: columnIndex == 4 || columnIndex == 6
    //                                   ? 4
    //                                   : 14),
    //                           child: Text(
    //                             columnIndex == 0
    //                                 ? data[details.rowColumnIndex.rowIndex - 1].member!.name.toString()
    //                                 : columnIndex == 1
    //                                     ? data[details.rowColumnIndex.rowIndex - 1]
    //                                         .member!
    //                                         .bloodType
    //                                         .toString()
    //                                     : columnIndex == 2
    //                                         ? data[details.rowColumnIndex.rowIndex - 1].hospital.toString()
    //                                         : columnIndex == 3
    //                                             ? data[details.rowColumnIndex.rowIndex - 1]
    //                                                 .patientName
    //                                                 .toString()
    //                                             : columnIndex == 4
    //                                                 ? data[details.rowColumnIndex.rowIndex - 1]
    //                                                     .patientAddress
    //                                                     .toString()
    //                                                 : columnIndex == 5
    //                                                     ? Utils.strToMM(
    //                                                         data[details.rowColumnIndex.rowIndex - 1]
    //                                                             .patientAge
    //                                                             .toString())
    //                                                     : columnIndex == 6
    //                                                         ? data[details.rowColumnIndex.rowIndex - 1]
    //                                                             .patientDisease
    //                                                             .toString()
    //                                                         : "",
    //                             textAlign: columnIndex == 5 || columnIndex == 2
    //                                 ? TextAlign.center
    //                                 : TextAlign.start,
    //                             style: TextStyle(
    //                                 fontSize:
    //                                     Responsive.isMobile(context) ? 13 : 14,
    //                                 color: Colors.black),
    //                           ),
    //                         )),
    //                   )),
    //         ));

    DonationDataSource memberDataDataSource =
        DonationDataSource(donationData: data, ref: ref);
    return Container(
      margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
      child: SfDataGrid(
        source: memberDataDataSource,
        onCellTap: (details) async {
          // Logger logger = Logger();
          // logger.i(details.rowColumnIndex.rowIndex);
          // MemberOldData member = MemberOldData(
          //   address:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.address,
          //   birthDate:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.birthDate,
          //   bloodBankCard: data[details.rowColumnIndex.rowIndex - 1]
          //       .member!
          //       .bloodBankCard,
          //   bloodType:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.bloodType,
          //   donationCounts: data[details.rowColumnIndex.rowIndex - 1]
          //       .member!
          //       .donationCounts,
          //   fatherName:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.fatherName,
          //   id: data[details.rowColumnIndex.rowIndex - 1].member!.id,
          //   lastDonationDate: data[details.rowColumnIndex.rowIndex - 1]
          //       .member!
          //       .lastDonationDate,
          //   memberId:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.memberId,
          //   name: data[details.rowColumnIndex.rowIndex - 1].member!.name,
          //   note: data[details.rowColumnIndex.rowIndex - 1].member!.note,
          //   nrc: data[details.rowColumnIndex.rowIndex - 1].member!.nrc,
          //   phone: data[details.rowColumnIndex.rowIndex - 1].member!.phone,
          //   registerDate: data[details.rowColumnIndex.rowIndex - 1]
          //       .member!
          //       .registerDate,
          //   totalCount:
          //       data[details.rowColumnIndex.rowIndex - 1].member!.totalCount,
          // );
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DonationDetailScreen(
                        data: data[details.rowColumnIndex.rowIndex - 1],
                      )));

          sortBySegments();
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
              columnName: 'သွေးအလှူရှင်',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'သွေးအလှူရှင်',
                    style: TextStyle(color: Colors.white),
                  ))),
          GridColumn(
              columnName: 'သွေးအုပ်စု',
              label: Container(
                  color: primaryColor,
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'သွေးအုပ်စု',
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
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
