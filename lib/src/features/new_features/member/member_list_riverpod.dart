// import 'dart:developer';

// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'package:donation/data/response/member_response.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
// import 'package:donation/src/features/member/member_detail.dart';
// import 'package:donation/src/features/donation_member/presentation/new_member.dart';
// import 'package:donation/src/features/new_features/member/member_data_source.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// class MemberListNewRiverpod extends ConsumerStatefulWidget {
//   static const routeName = "/members_riverpod";

//   const MemberListNewRiverpod({Key? key}) : super(key: key);

//   @override
//   _MemberListNewRiverpodState createState() => _MemberListNewRiverpodState();
// }

// class _MemberListNewRiverpodState extends ConsumerState<MemberListNewRiverpod>
//     with SingleTickerProviderStateMixin {
//   List<String> ranges = [];
//   List<String> bloodTypes = [
//     "A (Rh +)",
//     "B (Rh +)",
//     "O (Rh +)",
//     "AB (Rh +)",
//     "A (Rh -)",
//     "B (Rh -)",
//     "O (Rh -)",
//     "AB (Rh -)"
//   ];
//   String? selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
//   String? selectedRange;
//   List<MemberData> dataSegments = [];
//   TextStyle tabStyle = const TextStyle(fontSize: 16);
//   @override
//   void initState() {
//     super.initState();
//     // callAPI("");
//   }

//   tabCreate(List<MemberData> data) => Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             Responsive.isMobile(context)
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             width: MediaQuery.of(context).size.width / 2.22,
//                             margin: const EdgeInsets.only(top: 20, left: 20),
//                             child: DropdownButtonFormField2(
//                               decoration: InputDecoration(
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               isExpanded: true,
//                               hint: const Text(
//                                 "အမှတ်စဥ် အလိုက်ကြည့်မည်",
//                                 style: TextStyle(fontSize: 13),
//                               ),
//                               icon: const Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.black45,
//                               ),
//                               iconSize: 30,
//                               buttonHeight: 60,
//                               buttonPadding:
//                                   const EdgeInsets.only(left: 20, right: 10),
//                               dropdownDecoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               items: ranges
//                                   .map((item) => DropdownMenuItem<String>(
//                                         value: item,
//                                         child: Text(
//                                           item,
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ))
//                                   .toList(),
//                               validator: (value) {
//                                 if (value == null) {
//                                   return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
//                                 }
//                                 return null;
//                               },
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedRange = value.toString();
//                                 });
//                                 for (int i = 0; i < ranges.length; i++) {
//                                   if (value == ranges[i]) {
//                                     if (i != ranges.length - 1) {
//                                       setState(() {
//                                         dataSegments =
//                                             data.sublist(i * 50, (i + 1) * 50);
//                                       });
//                                     } else {
//                                       setState(() {
//                                         dataSegments = data.sublist(i * 50);
//                                       });
//                                     }
//                                   }
//                                 }
//                                 setState(() {
//                                   searchController.text = "";
//                                   selectedBloodType =
//                                       "သွေးအုပ်စု အလိုက်ကြည့်မည်";
//                                 });
//                                 log(selectedBloodType.toString());
//                               },
//                               onSaved: (value) {},
//                             ),
//                           ),
//                           Container(
//                             width: MediaQuery.of(context).size.width / 2.22,
//                             margin: const EdgeInsets.only(top: 20, left: 12),
//                             child: DropdownButtonFormField2(
//                               decoration: InputDecoration(
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.zero,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               isExpanded: true,
//                               hint: Text(
//                                 selectedBloodType!,
//                                 style: const TextStyle(fontSize: 13),
//                               ),
//                               icon: const Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.black45,
//                               ),
//                               iconSize: 30,
//                               buttonHeight: 60,
//                               buttonPadding:
//                                   const EdgeInsets.only(left: 20, right: 10),
//                               dropdownDecoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               items: bloodTypes
//                                   .map((item) => DropdownMenuItem<String>(
//                                         value: item,
//                                         child: Text(
//                                           item,
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                           ),
//                                         ),
//                                       ))
//                                   .toList(),
//                               validator: (value) {
//                                 if (value == null) {
//                                   return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
//                                 }
//                                 return null;
//                               },
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedBloodType = value.toString();
//                                 });
//                                 log(selectedBloodType.toString());
//                                 log(dataSegments.length.toString());
//                                 List<MemberData>? filterdata = [];
//                                 for (int i = 0; i < data.length; i++) {
//                                   //get memberdata from data only where bloodtype is equal to value
//                                   if (searchController.text.isNotEmpty) {
//                                     if (data[i].name!.toLowerCase().contains(
//                                             searchController.text
//                                                 .toString()
//                                                 .toLowerCase()) &&
//                                         data[i].bloodType ==
//                                             selectedBloodType) {
//                                       filterdata.add(data[i]);
//                                     }
//                                   } else {
//                                     if (data[i].bloodType ==
//                                         selectedBloodType) {
//                                       filterdata.add(data[i]);
//                                     }
//                                   }
//                                 }
//                                 setState(() {
//                                   dataSegments = filterdata.sublist(0);
//                                 });
//                                 log(filterdata.length.toString());
//                                 log(dataSegments.length.toString());
//                               },
//                               onSaved: (value) {},
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width - 40,
//                         margin:
//                             const EdgeInsets.only(right: 20, top: 12, left: 20),
//                         padding: const EdgeInsets.only(top: 8, bottom: 8),
//                         child: TextFormField(
//                           autofocus: false,
//                           controller: searchController,
//                           textAlign: TextAlign.start,
//                           style: const TextStyle(
//                               fontSize: 15, color: Colors.black),
//                           onChanged: (val) {
//                             List<MemberData>? filterdata = [];
//                             for (int i = 0; i < data.length; i++) {
//                               //get memberdata from data only where bloodtype is equal to value
//                               if (selectedBloodType !=
//                                   "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
//                                 if (data[i].name!.toLowerCase().contains(
//                                         searchController.text
//                                             .toString()
//                                             .toLowerCase()) &&
//                                     data[i].bloodType == selectedBloodType) {
//                                   filterdata.add(data[i]);
//                                 }
//                               } else {
//                                 if (data[i]
//                                     .name!
//                                     .toLowerCase()
//                                     .contains(val.toLowerCase())) {
//                                   filterdata.add(data[i]);
//                                 }
//                               }
//                             }
//                             setState(() {
//                               dataSegments = filterdata.sublist(0);
//                             });
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
//                             hintStyle: const TextStyle(
//                                 color: Colors.black, fontSize: 15.0),
//                             fillColor: Colors.white.withOpacity(0.2),
//                             filled: true,
//                             suffixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Icon(
//                                 Icons.search,
//                                 color: primaryColor,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.only(
//                                 left: 20, right: 20, top: 4, bottom: 4),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             disabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                           ),
//                           keyboardType: TextInputType.text,
//                         ),
//                       ),
//                     ],
//                   )
//                 : Row(
//                     children: [
//                       Container(
//                         width: MediaQuery.of(context).size.width / 5,
//                         margin: const EdgeInsets.only(top: 28, left: 24),
//                         child: DropdownButtonFormField2(
//                           decoration: InputDecoration(
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           isExpanded: true,
//                           hint: const Text(
//                             "အမှတ်စဥ် အလိုက်ကြည့်မည်",
//                             style: TextStyle(fontSize: 14),
//                           ),
//                           icon: const Icon(
//                             Icons.arrow_drop_down,
//                             color: Colors.black45,
//                           ),
//                           iconSize: 30,
//                           buttonHeight: 60,
//                           buttonPadding:
//                               const EdgeInsets.only(left: 20, right: 10),
//                           dropdownDecoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           items: ranges
//                               .map((item) => DropdownMenuItem<String>(
//                                     value: item,
//                                     child: Text(
//                                       item,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ))
//                               .toList(),
//                           validator: (value) {
//                             if (value == null) {
//                               return "အမှတ်စဥ် အလိုက်ကြည့်မည်";
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedRange = value.toString();
//                             });
//                             for (int i = 0; i < ranges.length; i++) {
//                               if (value == ranges[i]) {
//                                 if (i != ranges.length - 1) {
//                                   setState(() {
//                                     dataSegments =
//                                         data.sublist(i * 50, (i + 1) * 50);
//                                   });
//                                 } else {
//                                   setState(() {
//                                     dataSegments = data.sublist(i * 50);
//                                   });
//                                 }
//                               }
//                             }
//                             setState(() {
//                               searchController.text = "";
//                               selectedBloodType = "သွေးအုပ်စု အလိုက်ကြည့်မည်";
//                             });
//                             log(selectedBloodType.toString());
//                           },
//                           onSaved: (value) {},
//                         ),
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width / 5,
//                         margin: const EdgeInsets.only(top: 28, left: 20),
//                         child: DropdownButtonFormField2(
//                           decoration: InputDecoration(
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           isExpanded: true,
//                           hint: Text(
//                             selectedBloodType!,
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           icon: const Icon(
//                             Icons.arrow_drop_down,
//                             color: Colors.black45,
//                           ),
//                           iconSize: 30,
//                           buttonHeight: 60,
//                           buttonPadding:
//                               const EdgeInsets.only(left: 20, right: 10),
//                           dropdownDecoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           items: bloodTypes
//                               .map((item) => DropdownMenuItem<String>(
//                                     value: item,
//                                     child: Text(
//                                       item,
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ))
//                               .toList(),
//                           validator: (value) {
//                             if (value == null) {
//                               return "သွေးအုပ်စု အလိုက်ကြည့်မည်";
//                             }
//                             return null;
//                           },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedBloodType = value.toString();
//                             });
//                             log(selectedBloodType.toString());
//                             log(dataSegments.length.toString());
//                             List<MemberData>? filterdata = [];
//                             for (int i = 0; i < data.length; i++) {
//                               if (searchController.text.isNotEmpty) {
//                                 if (data[i].name!.toLowerCase().contains(
//                                         searchController.text
//                                             .toString()
//                                             .toLowerCase()) &&
//                                     data[i].bloodType == selectedBloodType) {
//                                   filterdata.add(data[i]);
//                                 }
//                               } else {
//                                 if (data[i].bloodType == selectedBloodType) {
//                                   filterdata.add(data[i]);
//                                 }
//                               }
//                             }
//                             setState(() {
//                               dataSegments = filterdata.sublist(0);
//                             });
//                           },
//                           onSaved: (value) {},
//                         ),
//                       ),
//                       Container(
//                         width: MediaQuery.of(context).size.width / 5,
//                         margin:
//                             const EdgeInsets.only(right: 40, top: 28, left: 20),
//                         padding: const EdgeInsets.only(top: 8, bottom: 8),
//                         child: TextFormField(
//                           autofocus: false,
//                           controller: searchController,
//                           textAlign: TextAlign.start,
//                           style: const TextStyle(
//                               fontSize: 15, color: Colors.black),
//                           onChanged: (val) {
//                             List<MemberData>? filterdata = [];
//                             for (int i = 0; i < data.length; i++) {
//                               //get memberdata from data only where bloodtype is equal to value
//                               if (selectedBloodType !=
//                                   "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
//                                 if (data[i].name!.toLowerCase().contains(
//                                         searchController.text
//                                             .toString()
//                                             .toLowerCase()) &&
//                                     data[i].bloodType == selectedBloodType) {
//                                   filterdata.add(data[i]);
//                                 }
//                               } else {
//                                 if (data[i]
//                                     .name!
//                                     .toLowerCase()
//                                     .contains(val.toLowerCase())) {
//                                   filterdata.add(data[i]);
//                                 }
//                               }
//                             }
//                             setState(() {
//                               dataSegments = filterdata.sublist(0);
//                             });
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'အမည်ဖြင့် ရှာဖွေမည်',
//                             hintStyle: const TextStyle(
//                                 color: Colors.black, fontSize: 15.0),
//                             fillColor: Colors.white.withOpacity(0.2),
//                             filled: true,
//                             suffixIcon: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Icon(
//                                 Icons.search,
//                                 color: primaryColor,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.only(
//                                 left: 20, right: 20, top: 4, bottom: 4),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             disabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                             enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey)),
//                           ),
//                           keyboardType: TextInputType.text,
//                         ),
//                       ),
//                     ],
//                   ),
//             dataFullLoad
//                 ? Container(
//                     padding: EdgeInsets.only(
//                         left: 20.0,
//                         top: Responsive.isMobile(context) ? 160 : 100,
//                         bottom: 12),
//                     child: buildSimpleTable(dataSegments),
//                   )
//                 : const Center(
//                     child: CircularProgressIndicator(),
//                   ),
//           ],
//         ),
//       );
//   final searchController = TextEditingController();
//   final memberController = TextEditingController();
//   List<String> membersSelected = <String>[];
//   List<String> allMembers = <String>[];
//   bool inputted = false;
//   bool dataFullLoad = false;
//   //List<MemberData>? data;

//   @override
//   Widget build(BuildContext context) {
//     List<MemberData> data = ref.read(membersProvider);
//     log("Members " + ref.read(membersProvider).length.toString());
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
//         title: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text("အဖွဲ့၀င်များ",
//               textScaleFactor: 1.0,
//               style: TextStyle(
//                   fontSize: Responsive.isMobile(context) ? 15 : 16,
//                   color: Colors.white)),
//         ),
//       ),
//       body: data.isNotEmpty
//           ? tabCreate(data)
//           : const Center(
//               child: CircularProgressIndicator(),
//             ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NewMemberScreen(),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   addData(List<MemberData>? data) {
//     int tabLength = 0;
//     data!.sort((a, b) => a.memberId!.compareTo(b.memberId!));

//     if (data.length % 50 == 0) {
//       tabLength = data.length ~/ 50;
//     } else {
//       tabLength = data.length ~/ 50 + 1;
//     }

//     for (int i = 0; i < data.length; i = i + 50) {
//       if (i + 50 > data.length) {
//         ranges
//             .add("${data[i].memberId!} မှ ${data[data.length - 1].memberId!}");
//       } else {
//         ranges.add("${data[i].memberId!} မှ ${data[i + 49].memberId!}");
//       }
//     }
//     setState(() {
//       dataFullLoad = true;
//       dataSegments = data.sublist(0, 50);
//     });
//   }

//   buildSimpleTable(List<MemberData> data) {
//     MemberDataSource memberDataDataSource = MemberDataSource(memberData: data);
//     return Container(
//       margin: EdgeInsets.only(right: Responsive.isMobile(context) ? 20 : 20),
//       child: SfDataGrid(
//         source: memberDataDataSource,
//         onCellTap: (details) async {
//           Logger logger = Logger();
//           logger.i(details.rowColumnIndex.rowIndex);
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => MemberDetailScreen(
//                 data: data[details.rowColumnIndex.rowIndex - 1],
//               ),
//             ),
//           );
//           ref.invalidate(memberListProvider);
//         },
//         gridLinesVisibility: GridLinesVisibility.both,
//         headerGridLinesVisibility: GridLinesVisibility.both,
//         columnWidthMode: Responsive.isMobile(context)
//             ? ColumnWidthMode.auto
//             : ColumnWidthMode.fitByCellValue,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'အမှတ်စဥ်',
//               label: Container(
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အမှတ်စဥ်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'အမည်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အမည်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'အဖအမည်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'အဖအမည်',
//                     style: TextStyle(color: Colors.white),
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'သွေးအုပ်စု',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'သွေးအုပ်စု',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'မှတ်ပုံတင်အမှတ်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'မှတ်ပုံတင်အမှတ်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'သွေးဘဏ်ကတ်',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'သွေးဘဏ်ကတ်',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//           GridColumn(
//               columnName: 'သွေးလှူမှုကြိမ်ရေ',
//               label: Container(
//                   color: primaryColor,
//                   padding: const EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: const Text(
//                     'သွေးလှူမှုကြိမ်ရေ',
//                     style: TextStyle(color: Colors.white),
//                   ))),
//         ],
//       ),
//     );
//   }
// }
