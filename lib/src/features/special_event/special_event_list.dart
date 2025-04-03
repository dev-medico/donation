// import 'dart:convert';
// import 'dart:developer';

// import 'package:donation/realm/realm_services.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:donation/src/features/home/mobile_home.dart';
// import 'package:donation/src/features/home/mobile_home/humberger.dart';
// import 'package:donation/src/features/special_event/special_event_list_chart.dart';
// import 'package:donation/src/features/special_event/special_event_list_table.dart';
// import 'package:donation/src/features/special_event/special_event_provider.dart';
// // import 'package:flutter_expandable_table/flutter_expandable_table.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:donation/data/repository/repository.dart';
// import 'package:donation/data/response/special_event_list_response.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/special_event/edit_special_event.dart';
// import 'package:donation/src/features/special_event/new_special_event.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:donation/utils/tool_widgets.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:realm/realm.dart';

// // final specialEventsProvider =
// //     FutureProvider<List<SpecialEventData>>((ref) async {
// //   var data = await getEventsFromXata();
// //   return data;
// // });

// class SpecialEventListScreen extends ConsumerStatefulWidget {
//   static const routeName = "/special_event_list";
//   final bool fromHome;
//   const SpecialEventListScreen({Key? key, this.fromHome = false})
//       : super(key: key);

//   @override
//   ConsumerState<SpecialEventListScreen> createState() =>
//       _SpecialEventListScreenState();
// }

// class _SpecialEventListScreenState
//     extends ConsumerState<SpecialEventListScreen> {
//   //List<SpecialEventData>? data = [];
//   bool notloaded = true;
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // var data = ref.watch(specialEventsProvider);
//     final results = ref.watch(specialEventsDataProvider);
//
//     if (notloaded) {
//       //
//       notloaded = false;
//     }

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
//           leading: widget.fromHome && Responsive.isMobile(context)
//               ? Padding(
//                   padding: const EdgeInsets.only(top: 4, left: 8),
//                   child: Humberger(
//                     onTap: () {
//                       ref.watch(drawerControllerProvider)!.toggle!.call();
//                     },
//                   ),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.only(top: 4, left: 8),
//                   child: IconButton(
//                     icon: Icon(Icons.arrow_back),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//           title: Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text("ထူးခြားဖြစ်စဥ်များ",
//                 textScaleFactor: 1.0,
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 15 : 16,
//                     color: Colors.white)),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: primaryColor,
//           onPressed: () async {
//             await Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const NewEventAddScreen(),
//               ),
//             );
//           },
//           child: const Icon(Icons.add),
//         ),
//         body: Container(
//           margin: EdgeInsets.only(
//               top: 20,
//               left: 10,
//               right: 20,
//               bottom: Responsive.isMobile(context) ? 20 : 0),
//           child: fluent.Button(
//             // style: NeumorphicStyle(
//             //   color: Colors.white,
//             //   boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(
//             //       Responsive.isMobile(context) ? 12 : 16)),
//             //   depth: 4,
//             //   intensity: 0.8,
//             //   shadowDarkColor: Colors.black,
//             //   shadowLightColor: Colors.white,
//             // ),
//             onPressed: () async {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SpecialEventListTableScreen(),
//                 ),
//               );
//             },
//             child: SpecialEventChartScreen(),
//           ),
//         )
//         // body: Padding(
//         //   padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
//         //   child: buildSimpleTable(results),
//         // ),
//         );
//   }
// }
