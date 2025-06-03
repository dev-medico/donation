import 'package:donation/realm/schemas.dart' hide Donation;
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation/blood_donation_report_widget_v2.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/utils/Colors.dart';

class BloodDonationReportScreen extends StatefulWidget {
  final List<Donation> data;
  final int month;
  final String year;
  final bool isYearly;
  const BloodDonationReportScreen(
      {Key? key,
      required this.data,
      required this.month,
      required this.year,
      required this.isYearly})
      : super(key: key);

  @override
  State<BloodDonationReportScreen> createState() =>
      _BloodDonationReportScreenState();
}

class _BloodDonationReportScreenState extends State<BloodDonationReportScreen> {
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  Widget build(BuildContext context) {
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
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text("သွေးလှူဒါန်းမှုမှတ်တမ်း စာရင်းချုပ်",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: BloodDonationReportWidget(
        year: int.tryParse(widget.year),
        month: widget.isYearly ? null : widget.month + 1,
        isYearly: widget.isYearly,
      ),
    );
  }
}
