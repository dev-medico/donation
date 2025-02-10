// import 'package:donation/realm/schemas.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
// import 'package:donation/src/features/donation/donation_chart_by_desease.dart';
// import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
// import 'package:donation/utils/Colors.dart';

// class BloodDonationReportScreen extends StatefulWidget {
//   final List<Donation> data;
//   final int month;
//   final String year;
//   final bool isYearly;
//   const BloodDonationReportScreen(
//       {Key? key,
//       required this.data,
//       required this.month,
//       required this.year,
//       required this.isYearly})
//       : super(key: key);

//   @override
//   State<BloodDonationReportScreen> createState() =>
//       _BloodDonationReportScreenState();
// }

// class _BloodDonationReportScreenState extends State<BloodDonationReportScreen> {
//   @override
//   void initState() {
//     super.initState();
//     print(widget.data.length);
//   }

//   List<String> months = [
//     "January",
//     "February",
//     "March",
//     "April",
//     "May",
//     "June",
//     "July",
//     "August",
//     "September",
//     "October",
//     "November",
//     "December"
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           flexibleSpace: Container(
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//             colors: [primaryColor, primaryDark],
//           ))),
//           centerTitle: true,
//           title: Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//                 widget.isYearly
//                     ? "${widget.year} ခုနှစ် သွေးလှူဒါန်းမှုမှတ်တမ်း"
//                     : "${widget.year} ${months[widget.month]} လ သွေးလှူဒါန်းမှုမှတ်တမ်း",
//                 textScaleFactor: 1.0,
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 15 : 16,
//                     color: Colors.white)),
//           ),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Responsive.isMobile(context)
//               ? ListView(
//                   children: [
//                     DonationChartByBlood(
//                       data: widget.data,
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     DonationChartByHospital(data: widget.data),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     DonationChartByDisease(data: widget.data)
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                         flex: 1,
//                         child: DonationChartByBlood(
//                           data: widget.data,
//                         )),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                         flex: 1,
//                         child: DonationChartByHospital(data: widget.data)),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                         flex: 1,
//                         child: DonationChartByDisease(data: widget.data)),
//                   ],
//                 ),
//         ));
//   }
// }
