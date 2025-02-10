// import 'package:donation/realm/schemas.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/call_multi_phone_dialog.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
// import 'package:donation/src/features/donation_member/presentation/widget/remark_write_dialog.dart';
// import 'package:donation/src/features/feed/new_noti.dart';
// import 'package:donation/src/features/feed/new_post.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FeedOrNotiDialog extends StatelessWidget {
//   const FeedOrNotiDialog({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CommonDialog(
//       title: "Please choose Social Type",
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
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => NewNotiScreen(),
//                   ),
//                 );
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
//                             "assets/images/noti.png",
//                             width: 24,
//                             height: 24,
//                           ),
//                           SizedBox(
//                             width: 30,
//                           ),
//                           Text(
//                             "အသိပေးချက်",
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
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => NewPostScreen(),
//                   ),
//                 );
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
//                             "ပို့စ် တင်မည်",
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
