import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donation/donation_detail.dart';
import 'package:merchant/src/features/donation/new_blood_donation.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:intl/intl.dart';
import 'package:merchant/utils/utils.dart';

class BloodDonationList extends StatefulWidget {
  static const routeName = "/blood_donation_list";

  @override
  _BloodDonationListState createState() => _BloodDonationListState();
}

class _BloodDonationListState extends State<BloodDonationList> {
  late Stream<QuerySnapshot> _usersStream;
  Stream<QuerySnapshot<Map<String, dynamic>>> memberRef =
      FirebaseFirestore.instance.collection('members').snapshots();
  String donationYear = "";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    var date = DateTime.now();
    _selectedDate = DateTime.now();

    donationYear = DateFormat('yyyy').format(date);
    // var start = DateTime.parse("01 Jan $donationYear");
    // var end = DateTime.parse("30 Dec $donationYear");
    _usersStream = FirebaseFirestore.instance
        .collection('blood_donations')
        .where('year', isEqualTo: int.parse(donationYear))
        .orderBy("date_detail")
        .snapshots();
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
          child: Text("သွေးလှူဒါန်းမှုစာရင်း",
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
            return Text('Something went wrong');
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
              Container(
                width: double.infinity,
                height: 54,
                margin: const EdgeInsets.only(left: 12, top: 20, right: 12),
                child: NeumorphicButton(
                  child: Center(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: Utils.strToMM(donationYear),
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 17,
                              color: primaryColor),
                        ),
                        TextSpan(
                          text: "   ခုနှစ်  သွေးလှူဒါန်းမှု မှတ်တမ်းများ",
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 17,
                              color: Colors.black),
                        ),
                      ]),
                    ),
                  ),
                  onPressed: () {
                    showYearPicker();
                  },
                ),
              ),
              Container(
                height: snapshot.data!.docs.length > 8
                    ? MediaQuery.of(context).size.height *
                        (snapshot.data!.docs.length / 8)
                    : MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 2.5,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    Column(
                      children: [
                        header(),
                        Column(
                          // shrinkWrap: true,
                          // scrollDirection: Axis.vertical,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return blood_donationRow(data, document.id);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewBloodDonationScreen(),
            ),
          );
          _usersStream = FirebaseFirestore.instance
              .collection('blood_donations')
              .where('year', isEqualTo: int.parse(donationYear))
              .orderBy("date_detail")
              .snapshots();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  showYearPicker() async {
    // DateTime? newDateTime = await showRoundedDatePicker(
    //   context: context,
    //   initialDatePickerMode: DatePickerMode.year,
    //   theme: ThemeData(primarySwatch: Colors.green),
    // );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ခုနှစ် ရွေးချယ်မည်"),
          content: Container(
            // Need to use container to add size constraint.
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 10, 1),
              lastDate: DateTime(DateTime.now().year),
              initialDate: DateTime.now(),
              // save the selected date to _selectedDate DateTime variable.
              // It's used to set the previous selected date when
              // re-showing the dialog.
              selectedDate: _selectedDate!,
              onChanged: (DateTime dateTime) {
                // close the dialog when year is selected.
                Navigator.pop(context);
                setState(() {
                  _selectedDate = dateTime;
                  String formattedDate = DateFormat('yyyy').format(dateTime);
                  donationYear = formattedDate;
                  // var start = DateTime.parse("01 Jan $donationYear");
                  // var end = DateTime.parse("30 Dec $donationYear");
                  _usersStream = FirebaseFirestore.instance
                      .collection('blood_donations')
                      .where('year', isEqualTo: int.parse(donationYear))
                      .orderBy("date_detail")
                      .snapshots();
                });

                // Do something with the dateTime selected.
                // Remember that you need to use dateTime.year to get the year
              },
            ),
          ),
        );
      },
    );
  }

  Widget header() {
    return Container(
      height: Responsive.isMobile(context) ? 60 : 60,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 2.8
          : MediaQuery.of(context).size.width - 60,
      margin: const EdgeInsets.only(top: 12, left: 12, right: 20),
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
                    ? MediaQuery.of(context).size.width / 4.1
                    : MediaQuery.of(context).size.width / 11,
                child: Text(
                  "ရက်စွဲ",
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
                    ? MediaQuery.of(context).size.width / 2.5
                    : MediaQuery.of(context).size.width / 8.4,
                child: Text(
                  "သွေးအလှူရှင်",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 5.4
                    : MediaQuery.of(context).size.width / 10,
                child: Text(
                  "သွေးအုပ်စု",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 24,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: Text(
                  "လှူဒါန်းသည့်နေရာ",
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 4
                    : MediaQuery.of(context).size.width / 9,
                child: Text(
                  "လူနာအမည်",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: Responsive.isMobile(context) ? 36 : 4,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 2.8
                    : MediaQuery.of(context).size.width / 6.8,
                child: Text(
                  "လိပ်စာ",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 17,
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
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: primaryColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 26,
              ),
              SizedBox(
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width / 2.8
                    : MediaQuery.of(context).size.width / 7,
                child: Text(
                  "ဖြစ်ပွားသည့်ရောဂါ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
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

  Widget blood_donationRow(Map<String, dynamic> data, String doc_id) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(
              data: data,
              doc_id: doc_id,
            ),
          ),
        );
        _usersStream = FirebaseFirestore.instance
            .collection('blood_donations')
            .where('year', isEqualTo: int.parse(donationYear))
            .orderBy("date_detail")
            .snapshots();
      },
      child: Container(
        height: Responsive.isMobile(context) ? 60 : 60,
        decoration: shadowDecoration(Colors.white),
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 2.8
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
                      ? MediaQuery.of(context).size.width / 4.1
                      : MediaQuery.of(context).size.width / 11,
                  child: Text(
                    //data['date'].toString(),
                    data['date_detail'] != null && data['date_detail'] != ""
                        ? DateFormat('dd MMM yyyy')
                            .format(data['date_detail'].toDate())
                        : data['date'].toString(),
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 2.5
                      : MediaQuery.of(context).size.width / 8.4,
                  child: Text(
                    data['member_name'] ?? "-",
                    style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                SizedBox(
                  width: Responsive.isMobile(context)
                      ? MediaQuery.of(context).size.width / 5.2
                      : MediaQuery.of(context).size.width / 10,
                  child: Text(
                    data['member_blood_type'] ?? "-",
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
                      ? MediaQuery.of(context).size.width / 3
                      : MediaQuery.of(context).size.width / 10,
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
                      : MediaQuery.of(context).size.width / 9,
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
                      : MediaQuery.of(context).size.width / 6.8,
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
                        fontSize: Responsive.isMobile(context) ? 15 : 17,
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
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
