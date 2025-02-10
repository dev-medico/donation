// import 'package:donation/realm/schemas.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/call_multi_phone_dialog.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/remark_write_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class CallOrRemarkDialog extends StatelessWidget {
//   final String? title;
//   final Member? member;
//   const CallOrRemarkDialog(
//       {super.key, required this.title, required this.member});

//   @override
//   Widget build(BuildContext context) {
//     return CommonDialog(
//       title: title.toString(),
//       width: Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.width
//           : MediaQuery.of(context).size.width * 0.3,
//       child: Column(
//         children: [
//           SizedBox(
//             height: 20,
//           ),
//           Container(
//             width: Responsive.isMobile(context)
//                 ? MediaQuery.of(context).size.width
//                 : MediaQuery.of(context).size.width * 0.3,
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: const BorderRadius.all(Radius.circular(12.0))),
//             margin: const EdgeInsets.only(left: 15, bottom: 16, right: 15),
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 Navigator.pop(context);
//                 if (member!.phone!.contains(",")) {
//                   showDialog(
//                       context: context,
//                       builder: (context) => CallMultiPhoneDialog(
//                           title: "ဖုန်းခေါ်ဆိုမည်",
//                           phones: member!.phone!.split(",")));
//                 } else {
//                   launchUrl(Uri.parse("tel:" + member!.phone.toString()));
//                 }
//               },
//               child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                       padding: EdgeInsets.only(
//                           top: 8,
//                           bottom: 8,
//                           left: Responsive.isMobile(context) ? 20 : 30),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Image.asset(
//                             "assets/images/phone.png",
//                             width: 24,
//                             height: 24,
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                           Text(
//                             "ဖုန်းခေါ်ဆိုမည်",
//                             textScaleFactor: 1.0,
//                             style:
//                                 TextStyle(fontSize: 15.0, color: Colors.black),
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                         ],
//                       ))),
//             ),
//           ),
//           Container(
//             width: Responsive.isMobile(context)
//                 ? MediaQuery.of(context).size.width
//                 : MediaQuery.of(context).size.width * 0.3,
//             decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: const BorderRadius.all(Radius.circular(12.0))),
//             margin:
//                 const EdgeInsets.only(left: 15, bottom: 28, right: 15, top: 28),
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 Navigator.pop(context);
//                 showDialog(
//                     context: context,
//                     builder: (context) => RemarkWriteDialog(
//                           member: member,
//                         ));
//               },
//               child: Align(
//                   alignment: Alignment.center,
//                   child: Padding(
//                       padding: EdgeInsets.only(
//                           top: 8,
//                           bottom: 8,
//                           left: Responsive.isMobile(context) ? 20 : 30),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Image.asset(
//                             "assets/images/remark.png",
//                             width: 24,
//                             height: 24,
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                           Text(
//                             "မှတ်ချက်ရေးမည်",
//                             textScaleFactor: 1.0,
//                             style:
//                                 TextStyle(fontSize: 15.0, color: Colors.black),
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                         ],
//                       ))),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
