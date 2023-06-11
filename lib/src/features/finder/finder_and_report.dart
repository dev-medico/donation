import 'package:donation/responsive.dart';
import 'package:donation/src/features/finder/donation_by_disease_chart.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

class FinderAndReportScreen extends StatefulWidget {
  const FinderAndReportScreen({super.key});

  @override
  State<FinderAndReportScreen> createState() => _FinderAndReportScreenState();
}

class _FinderAndReportScreenState extends State<FinderAndReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Text("Red Junior Dashboard",
              textScaleFactor: 1.0,
              style: TextStyle(
                  fontSize: Responsive.isMobile(context) ? 15 : 16,
                  color: Colors.white)),
        ),
      ),
      body: Column(
        children: [DonationByDiseaseScreen()],
      ),
    );
  }
}
