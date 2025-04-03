// import 'dart:convert';
// import 'dart:developer';

// // import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart'; // import 'package:donation/data/repository/repository.dart';
// import 'package:donation/data/response/special_event_list_response.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/special_event/edit_special_event.dart';
// import 'package:donation/src/features/special_event/event_data_source.dart';
// import 'package:donation/src/features/special_event/new_special_event.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:donation/utils/tool_widgets.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'package:tab_container/tab_container.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';

// class EventListScreen extends StatefulWidget {
//   static const routeName = "/special_events";

//   const EventListScreen({Key? key}) : super(key: key);

//   @override
//   _EventListScreenState createState() => _EventListScreenState();
// }

// class _EventListScreenState extends State<EventListScreen> {
//   List<SpecialEventData> dataSegment1 = [];
//   List<String> ranges = [
//     "2023",
//     "2022",
//     "2021",
//     "2020",
//     "2019",
//     "2018",
//     "2017",
//     "2016",
//     "2015",
//     "2014",
//     "2013",
//     "2012",
//   ];

//   List<bool> rangesSelect = [
//     true,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//   ];
//   String selectedYear = "2023";

//   String dataMonth = "";
//   String expensedataMonth = "";
//   bool dataFullLoaded = false;

//   TabContainerController controller = TabContainerController(length: 12);

//   List<SpecialEventData> data = [];

//   tabCreate() => Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             ListView(
//               children: [
//                 Visibility(
//                   visible: Responsive.isMobile(context),
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: Container(
//                       width: 160,
//                       margin: const EdgeInsets.only(right: 12),
//                       padding: const EdgeInsets.only(top: 20, right: 12),
//                       child: GestureDetector(
//                         onTap: () {},
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: primaryColor,
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(12.0))),
//                           child: Row(
//                             children: const [
//                               SizedBox(
//                                 width: 12,
//                               ),
//                               Icon(Icons.calculate_outlined,
//                                   color: Colors.white),
//                               Padding(
//                                   padding: EdgeInsets.only(
//                                       top: 12, bottom: 12, left: 12),
//                                   child: Text(
//                                     "နှစ်ချုပ်စာရင်း",
//                                     textScaleFactor: 1.0,
//                                     style: TextStyle(
//                                         fontSize: 15.0, color: Colors.white),
//                                   )),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Stack(
//                   children: [
//                     Container(
//                       margin:
//                           const EdgeInsets.only(left: 20, top: 20, right: 20),
//                       height: 50,
//                       width: double.infinity,
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         physics: const BouncingScrollPhysics(),
//                         padding: const EdgeInsets.all(0.0),
//                         scrollDirection: Axis.horizontal,
//                         itemCount: ranges.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 rangesSelect.clear();
//                                 rangesSelect.addAll([
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false,
//                                   false
//                                 ]);
//                                 rangesSelect[index] = true;
//                                 selectedYear = ranges[index];
//                               });

//                               sortBySegments();
//                             },
//                             child: Container(
//                               width: Responsive.isMobile(context)
//                                   ? MediaQuery.of(context).size.width / 5
//                                   : MediaQuery.of(context).size.width / 14,
//                               height: 50,
//                               decoration: shadowDecorationOnlyTop(
//                                   rangesSelect[index]
//                                       ? Colors.red.withOpacity(0.6)
//                                       : const Color(0xffe3e3e3)),
//                               child: Center(
//                                   child: Text(
//                                 ranges[index],
//                                 style: TextStyle(
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w700,
//                                     color: rangesSelect[index]
//                                         ? Colors.white
//                                         : primaryColor),
//                               )),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Visibility(
//                       visible: !Responsive.isMobile(context),
//                       child: Align(
//                         alignment: Alignment.topRight,
//                         child: Container(
//                           width: 160,
//                           margin: const EdgeInsets.only(right: 12),
//                           padding: const EdgeInsets.only(top: 20, right: 12),
//                           child: GestureDetector(
//                             onTap: () {},
//                             child: Container(
//                               decoration: BoxDecoration(
//                                   color: primaryColor,
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(12.0))),
//                               child: Row(
//                                 children: const [
//                                   SizedBox(
//                                     width: 12,
//                                   ),
//                                   Icon(Icons.calculate_outlined,
//                                       color: Colors.white),
//                                   Padding(
//                                       padding: EdgeInsets.only(
//                                           top: 12, bottom: 12, left: 12),
//                                       child: Text(
//                                         "နှစ်ချုပ်စာရင်း",
//                                         textScaleFactor: 1.0,
//                                         style: TextStyle(
//                                             fontSize: 15.0,
//                                             color: Colors.white),
//                                       )),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
//                   width: double.infinity,
//                   height: MediaQuery.of(context).size.height * 0.81,
//                   child: Container(
//                     color: Colors.white,
//                     width: double.infinity,
//                     height: double.infinity,
//                     child: Container(
//                       margin: const EdgeInsets.only(top: 20),
//                       padding: EdgeInsets.only(
//                           left: 0.0,
//                           top: Responsive.isMobile(context) ? 20 : 0,
//                           bottom: 12),
//                       child: buildSimpleTable(
//                         dataSegment1,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );

//   var logger = Logger(
//     printer: PrettyPrinter(),
//   );

//   @override
//   void initState() {
//     super.initState();
//     callAPI("");
//   }

//   callAPI(String after) {
//     if (after.isEmpty) {
//       setState(() {
//         data = [];
//       });
//     }
//     XataRepository().getEventsList(after).then((response) {
//       logger.i(response.body);

//       setState(() {
//         data.addAll(SpecialEventListResponse.fromJson(jsonDecode(response.body))
//             .specialEventData!);
//       });

//       if (SpecialEventListResponse.fromJson(jsonDecode(response.body))
//               .meta!
//               .page!
//               .more ??
//           false) {
//         callAPI(SpecialEventListResponse.fromJson(jsonDecode(response.body))
//             .meta!
//             .page!
//             .cursor!);
//       } else {
//         setState(() {
//           dataFullLoaded = true;
//         });
//         sortBySegments();
//         log("Data Full");
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         flexibleSpace: Container(
//             decoration: BoxDecoration(
//                 gradient: LinearGradient(
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//           colors: [primaryColor, primaryDark],
//         ))),
//         centerTitle: true,
//         title: const Padding(
//           padding: EdgeInsets.only(top: 4),
//           child: Text("ထူးခြားဖြစ်စဥ်များ",
//               textScaleFactor: 1.0,
//               style: TextStyle(fontSize: 15, color: Colors.white)),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const NewEventAddScreen(),
//             ),
//           );
//           callAPI("");
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: dataFullLoaded
//           ? tabCreate()
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//     );
//   }

//   sortBySegments() {
//     List<SpecialEventData> filterData1 = [];

//     for (int i = 0; i < data.length; i++) {
//       var tempDate =
//           "${data[i].date!.split(" ")[1]} ${data[i].date!.split(" ")[2]}";
//       if (tempDate.split(" ")[1] == selectedYear) {
//         filterData1.add(data[i]);
//       }
//     }

//     setState(() {
//       dataSegment1 = filterData1;
//     });
//   }

//   YYDialog confirmDeleteDialog(String title, String msg, BuildContext context,
//       String buttonMsg, Color color, Function onTap) {
//     return YYDialog().build()
//       ..width = Responsive.isMobile(context)
//           ? MediaQuery.of(context).size.width * 0.8
//           : MediaQuery.of(context).size.width * 0.3
//       ..backgroundColor = Colors.white
//       ..borderRadius = 10.0
//       ..barrierColor = const Color(0xDD000000)
//       ..showCallBack = () {
//         debugPrint("showCallBack invoke");
//       }
//       ..dismissCallBack = () {
//         debugPrint("dismissCallBack invoke");
//       }
//       ..widget(Container(
//         color: Colors.red,
//         padding: const EdgeInsets.only(top: 8),
//         child: Stack(
//           children: [
//             Align(
//               alignment: Alignment.topLeft,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 4, left: 20, bottom: 12),
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 17,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             Align(
//               alignment: Alignment.topRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.of(context, rootNavigator: true).pop('dialog');
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(
//                       right: 12,
//                       bottom: 12,
//                     ),
//                     child: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 26,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ))
//       ..widget(Padding(
//         padding: EdgeInsets.only(
//             top: Responsive.isMobile(context) ? 26 : 42, bottom: 26),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               margin: const EdgeInsets.only(
//                 left: 8,
//                 right: 18,
//               ),
//               child: Image.asset(
//                 'assets/images/question_mark.png',
//                 height: 56,
//                 width: 56,
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.only(
//                 left: 12,
//                 right: 20,
//               ),
//               child: Text(
//                 msg,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: color,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ))
//       ..widget(Align(
//         alignment: Alignment.bottomRight,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context, rootNavigator: true).pop('dialog');
//               },
//               child: Container(
//                 decoration:
//                     shadowDecorationWithBorder(Colors.white, Colors.black),
//                 height: 50,
//                 width: 120,
//                 margin: EdgeInsets.only(
//                   left: 20,
//                   bottom: 30,
//                   right: Responsive.isMobile(context) ? 12 : 20,
//                 ),
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     "မလုပ်တော့ပါ",
//                     textScaleFactor: 1.0,
//                     style: TextStyle(
//                         color: Colors.red,
//                         fontSize: Responsive.isMobile(context) ? 12 : 14),
//                   ),
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onTap: () async {
//                 onTap.call();
//                 Navigator.of(context, rootNavigator: true).pop('dialog');
//               },
//               child: Container(
//                 decoration: shadowDecoration(const Color(0xffFF5F17)),
//                 height: 50,
//                 width: 120,
//                 margin: EdgeInsets.only(
//                   bottom: 30,
//                   right: Responsive.isMobile(context) ? 12 : 30,
//                 ),
//                 child: Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     "ဖျက်မည်",
//                     textScaleFactor: 1.0,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: Responsive.isMobile(context) ? 12 : 14),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ))
//       ..animatedFunc = (child, animation) {
//         return ScaleTransition(
//           scale: Tween(begin: 0.0, end: 1.0).animate(animation),
//           child: child,
//         );
//       }
//       ..show();
//   }

//   buildSimpleTable(List<SpecialEventData> data) {
//     EventDataSource memberDataDataSource = EventDataSource(specialEvent: data);
//     return Container(
//       margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
//       child: SfDataGrid(
//         headerRowHeight: 82,
//         source: memberDataDataSource,
//         onCellTap: (details) async {
//           Logger logger = Logger();
//           logger.i(details.rowColumnIndex.rowIndex);
//           await Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => EditSpecialEventScreen(
//                         event: data[details.rowColumnIndex.rowIndex - 1],
//                       )));
//           callAPI("");
//         },
//         gridLinesVisibility: GridLinesVisibility.both,
//         headerGridLinesVisibility: GridLinesVisibility.both,
//         columnWidthMode: Responsive.isMobile(context)
//             ? ColumnWidthMode.auto
//             : ColumnWidthMode.fitByColumnName,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'စဥ်',
//               label: Container(
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'စဥ်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: '        ရက်စွဲ        ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     '        ရက်စွဲ        ',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'Retro Test\n ခုခံအားကျဆင်းမှု \nကူးစက်ရောဂါ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Retro Test\n ခုခံအားကျဆင်းမှု \nကူးစက်ရောဂါ',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'Hbs Ag\n အသည်းရောင် \nအသားဝါ(ဘီ)ပိုး',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Hbs Ag\n အသည်းရောင် \nအသားဝါ(ဘီ)ပိုး',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'HCV Ab\n အသည်းရောင် \nအသားဝါ(စီ)ပိုး',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'HCV Ab\n အသည်းရောင် \nအသားဝါ(စီ)ပိုး',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'VDRL Test\n ကာလသားရောဂါ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'VDRL Test\n ကာလသားရောဂါ',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'M.P ( I.C.T )\n ငှက်ဖျားရောဂါ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'M.P ( I.C.T )\n ငှက်ဖျားရောဂါ',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'Lab Name\n ဓါတ်ခွဲခန်းအမည်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Lab Name\n ဓါတ်ခွဲခန်းအမည်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'Total\n စုစုပေါင်း',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'Total\n စုစုပေါင်း',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//         ],
//       ),
//     );
//   }

//   // ExpandableTable buildSimpleTable(List<SpecialEventData> data) {
//   //   const int COLUMN_COUNT = 11;
//   //   int ROWCOUNT = data.length;
//   //   List<String> titles = [
//   //     "ရက်စွဲ",
//   //     "Retro Test\n ခုခံအားကျဆင်းမှု ကူးစက်ရောဂါ",
//   //     "Hbs Ag\n အသည်းရောင် အသားဝါ(ဘီ)ပိုး",
//   //     "HCV Ab\n အသည်းရောင် အသားဝါ(စီ)ပိုး",
//   //     "VDRL Test\n ကာလသားရောဂါ",
//   //     "M.P ( I.C.T )\n ငှက်ဖျားရောဂါ",
//   //     "Haemoglobin ( Hb% )\n သွေးအားရာခိုင်နှုန်း",
//   //     "Lab Name\n ဓါတ်ခွဲခန်းအမည်",
//   //     "Total\n စုစုပေါင်း",
//   //     "လုပ်ဆောင်ချက်"
//   //   ];

//   //   ExpandableTableHeader header = ExpandableTableHeader(
//   //       firstCell: Container(
//   //           width: 26,
//   //           color: primaryColor,
//   //           height: 74,
//   //           margin: const EdgeInsets.all(1),
//   //           child: const Center(
//   //               child: Text(
//   //             'စဥ်',
//   //             style: TextStyle(fontSize: 15, color: Colors.white),
//   //           ))),
//   //       children: List.generate(
//   //           COLUMN_COUNT - 1,
//   //           (index) => Container(
//   //               color: primaryColor,
//   //               height: 74,
//   //               margin: const EdgeInsets.all(1),
//   //               child: Center(
//   //                   child: Text(
//   //                 titles[index],
//   //                 textAlign: TextAlign.center,
//   //                 style: TextStyle(
//   //                     fontSize: Responsive.isMobile(context) ? 13 : 15,
//   //                     color: Colors.white),
//   //               )))));

//   //   List<ExpandableTableRow> rows = List.generate(
//   //       ROWCOUNT,
//   //       (rowIndex) => ExpandableTableRow(
//   //             height: 50,
//   //             firstCell: Container(
//   //                 color: const Color(0xffe1e1e1),
//   //                 margin: const EdgeInsets.all(1),
//   //                 child: Center(
//   //                     child: Text(
//   //                   Utils.strToMM((rowIndex + 1).toString()),
//   //                   style: const TextStyle(fontSize: 15, color: Colors.black),
//   //                 ))),
//   //             children: List<Widget>.generate(
//   //                 COLUMN_COUNT - 1,
//   //                 (columnIndex) => GestureDetector(
//   //                       behavior: HitTestBehavior.translucent,
//   //                       onTap: () async {
//   //                         await Navigator.push(
//   //                             context,
//   //                             MaterialPageRoute(
//   //                                 builder: (context) => EditSpecialEventScreen(
//   //                                       event: data[rowIndex],
//   //                                     )));
//   //                         callAPI("");
//   //                       },
//   //                       child: columnIndex == 9
//   //                           ? Container(
//   //                               decoration:
//   //                                   borderDecorationNoRadius(Colors.grey),
//   //                               margin: const EdgeInsets.all(1),
//   //                               child: Row(
//   //                                 mainAxisAlignment: MainAxisAlignment.center,
//   //                                 children: [
//   //                                   IconButton(
//   //                                       icon: const Icon(
//   //                                         Icons.edit,
//   //                                         color: Colors.black,
//   //                                       ),
//   //                                       onPressed: () async {
//   //                                         await Navigator.push(
//   //                                             context,
//   //                                             MaterialPageRoute(
//   //                                                 builder: (context) =>
//   //                                                     EditSpecialEventScreen(
//   //                                                       event: data[rowIndex],
//   //                                                     )));
//   //                                         callAPI("");
//   //                                       }),
//   //                                   const SizedBox(
//   //                                     width: 4,
//   //                                   ),
//   //                                   IconButton(
//   //                                       icon: const Icon(
//   //                                         Icons.delete,
//   //                                         color: Colors.red,
//   //                                       ),
//   //                                       onPressed: () {
//   //                                         confirmDeleteDialog(
//   //                                             "ဖျက်မည်မှာ သေချာပါသလား?",
//   //                                             "ထူးခြားဖြစ်စဥ်အား ဖျက်မည်မှာ \nသေချာပါသလား?",
//   //                                             context,
//   //                                             "အိုကေ",
//   //                                             Colors.black, () {
//   //                                           XataRepository()
//   //                                               .deleteSpecialEventByID(
//   //                                             data[rowIndex].id.toString(),
//   //                                           )
//   //                                               .then((value) {
//   //                                             if (value.statusCode
//   //                                                 .toString()
//   //                                                 .startsWith("2")) {
//   //                                               Utils.messageSuccessNoPopDialog(
//   //                                                   "ထူးခြားဖြစ်စဥ် ပယ်ဖျက်ခြင်း \nအောင်မြင်ပါသည်။",
//   //                                                   context,
//   //                                                   "အိုကေ",
//   //                                                   Colors.black);
//   //                                               callAPI("");
//   //                                             }
//   //                                           });
//   //                                         });
//   //                                       }),
//   //                                 ],
//   //                               ),
//   //                             )
//   //                           : Container(
//   //                               decoration:
//   //                                   borderDecorationNoRadius(Colors.grey),
//   //                               margin: const EdgeInsets.all(1),
//   //                               child: Padding(
//   //                                 padding: const EdgeInsets.only(
//   //                                     left: 20.0, top: 14),
//   //                                 child: Text(
//   //                                   columnIndex == 0
//   //                                       ? data[rowIndex].date.toString()
//   //                                       : columnIndex == 1
//   //                                           ? data[rowIndex].retroTest == 0
//   //                                               ? "-"
//   //                                               : Utils.strToMM(data[rowIndex]
//   //                                                   .retroTest
//   //                                                   .toString())
//   //                                           : columnIndex == 2
//   //                                               ? data[rowIndex].hbsAg == 0
//   //                                                   ? "-"
//   //                                                   : Utils.strToMM(
//   //                                                       data[rowIndex]
//   //                                                           .hbsAg
//   //                                                           .toString())
//   //                                               : columnIndex == 3
//   //                                                   ? data[rowIndex].hcvAb == 0
//   //                                                       ? "-"
//   //                                                       : Utils.strToMM(
//   //                                                           data[rowIndex]
//   //                                                               .hcvAb
//   //                                                               .toString())
//   //                                                   : columnIndex == 4
//   //                                                       ? data[rowIndex]
//   //                                                                   .vdrlTest ==
//   //                                                               0
//   //                                                           ? "-"
//   //                                                           : Utils.strToMM(
//   //                                                               data[rowIndex]
//   //                                                                   .vdrlTest
//   //                                                                   .toString())
//   //                                                       : columnIndex == 5
//   //                                                           ? data[rowIndex]
//   //                                                                       .mpIct ==
//   //                                                                   0
//   //                                                               ? "-"
//   //                                                               : Utils.strToMM(
//   //                                                                   data[rowIndex]
//   //                                                                       .mpIct
//   //                                                                       .toString())
//   //                                                           : columnIndex == 6
//   //                                                               ? data[rowIndex]
//   //                                                                           .haemoglobin ==
//   //                                                                       0
//   //                                                                   ? "-"
//   //                                                                   : Utils.strToMM(data[rowIndex]
//   //                                                                       .haemoglobin
//   //                                                                       .toString())
//   //                                                               : columnIndex == 7
//   //                                                                   ? data[rowIndex].labName != null
//   //                                                                       ? data[rowIndex].labName.toString()
//   //                                                                       : "-"
//   //                                                                   : columnIndex == 8
//   //                                                                       ? data[rowIndex].total != null
//   //                                                                           ? Utils.strToMM(data[rowIndex].total.toString())
//   //                                                                           : "-"
//   //                                                                       : "",
//   //                                   textAlign: TextAlign.center,
//   //                                   style: TextStyle(
//   //                                       fontSize: Responsive.isMobile(context)
//   //                                           ? 16
//   //                                           : 17,
//   //                                       color: Colors.black,
//   //                                       fontWeight: FontWeight.bold),
//   //                                 ),
//   //                               )),
//   //                     )),
//   //           ));

//   //   return ExpandableTable(
//   //     rows: rows,
//   //     header: header,
//   //     cellWidth: Responsive.isMobile(context)
//   //         ? MediaQuery.of(context).size.width * 0.23
//   //         : MediaQuery.of(context).size.width * 0.135,
//   //     cellHeight: 48,
//   //     headerHeight: 74,
//   //     firstColumnWidth: 50,
//   //     scrollShadowColor: Colors.grey,
//   //   );
//   // }

//   convertToMonthName(int month) {
//     return DateFormat("MMM").format(DateTime(2021, month + 1, 1));
//   }

//   convertToMMMonthName(int month) {
//     if (month == 0) return "ဇန်နဝါရီ";
//     if (month == 1) return "ဖေဖော်ဝါရီ";
//     if (month == 2) return "မတ်";
//     if (month == 3) return "ဧပြီ";
//     if (month == 4) return "မေ";
//     if (month == 5) return "ဇွန်";
//     if (month == 6) return "ဇူလိုင်";
//     if (month == 7) return "ဩဂုတ်";
//     if (month == 8) return "စက်တင်ဘာ";
//     if (month == 9) return "အောက်တိုဘာ";
//     if (month == 10) return "နိုဝင်ဘာ";
//     if (month == 11) return "ဒီဇင်ဘာ";
//   }
// }
