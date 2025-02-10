// import 'dart:convert';
// import 'dart:developer';

// import 'package:donation/realm/realm_services.dart';
// import 'package:donation/realm/schemas.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
// import 'package:fluent_ui/fluent_ui.dart' as fluent;
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:donation/data/response/township_response/datum.dart';
// import 'package:donation/data/response/township_response/township_response.dart';
// import 'package:donation/responsive.dart';
// import 'package:donation/utils/Colors.dart';
// import 'package:donation/utils/tool_widgets.dart';
// import 'package:donation/utils/utils.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';

// class BloodDonationEditScreen extends ConsumerStatefulWidget {
//   Donation data;
//   BloodDonationEditScreen({
//     Key? key,
//     required this.data,
//   }) : super(key: key);
//   int selectedIndex = 0;

//   @override
//   BloodDonationEditState createState() => BloodDonationEditState(data);
// }

// class BloodDonationEditState extends ConsumerState<BloodDonationEditScreen> {
//   Donation data;
//   BloodDonationEditState(this.data);
//   final nameController = TextEditingController();
//   final ageController = TextEditingController();
//   final quarterController = TextEditingController();
//   final townController = TextEditingController();
//   final hospitalController = TextEditingController();
//   final diseaseController = TextEditingController();
//   String operatorImg = "";
//   String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";

//   String region1 = " ";
//   String town1 = " ";
//   String township1 = " ";
//   String township1ID = " ";
//   String regional = " ";
//   String post_code = " ";
//   late TownshipResponse townshipResponse;
//   List<String> townships = <String>[];
//   List<String> townshipsSelected = <String>[];
//   List<Datum> datas = <Datum>[];
//   bool switchNew = true;
//   DateTime? donationDateDetail;

//   List<String> hospitalsSelected = <String>[];
//   List<String> hospitals = <String>[
//     "ငွေမိုးဆေးရုံ",
//     "မော်လမြိုင်ပြည်သူ့ဆေးရုံကြီး",
//     "ဇာနည်ဘွားဆေးရုံ",
//     "ရတနာမွန်ဆေးရုံ",
//     "တော်ဝင်ဆေးရုံ",
//     "ရွှေလမင်းဆေးရုံ",
//     "ခရစ်ယာန်အရေပြားဆေးရုံ",
//     "အေးသန္တာဆေးရုံ",
//     "မေတ္တာရိပ်ဆေးခန်း",
//     "ဇာနည်အောင်ဆေးရုံ",
//     "ဇာသပြင်တိုက်နယ်ဆေးရုံ",
//     "လွမ်းသာဆေးခန်း",
//     "ချမ်းသာသုခဆေးခန်း",
//     "ချမ်းမြေ့ဂုဏ်ဆေးခန်း",
//     "အေဝမ်းဆေးခန်း",
//     "ကျိုက်မရောမြို့နယ်ဆေးရုံ",
//     "ကောင်းဆေးခန်း",
//     "မုတ္တမတိုက်နယ်ဆေးရုံ",
//     "အမေရိကန်ဆေးရုံ"
//   ];

//   List<String> diseasesSelected = <String>[];
//   List<String> diseases = <String>[
//     "......(ကင်ဆာ)",
//     "သွေးရောဂါ",
//     "အစာအိမ်နှင့်အူလမ်းကြောင်းဆိုင်ရာရောဂါ",
//     "အသည်းနှင့်ဆိုင်ရာရောဂါ",
//     "အဆုတ်နှင့်ဆိုင်ရာရောဂါ",
//     "နှလုံးနှင့်ဆိုင်ရာရောဂါ",
//     "မီးယပ်နှင့်သားဖွားဆိုင်ရာရောဂါ",
//     "ဆီးလမ်းကြောင်းနှင့်ဆိုင်ရာရောဂါ",
//     "ကျောက်ကပ်နှင့်ဆိုင်ရာရောဂါ",
//     "ဦးနှောက်နှင့်အာရုံကြောဆိုင်ရာရောဂါ",
//     "နား၊နှာခေါင်း၊လည်ချောင်းနှင့်ဆိုင်ရာရောဂါ",
//     "နာတာရှည်ကြောင့် သွေးအားနည်း",
//     "ခုခံအားကျဆင်းမှုကူးစက်ရောဂါ",
//     "သွေးတိုး",
//     "ဆီးချို",
//     "တီဘီ",
//     "သွေးလွန်တုပ်ကွေး",
//     "ရင်သားနှင့်ဆိုင်ရာရောဂါ",
//     "ယာဉ်မတော်တဆ",
//     "ခိုက်ရန်ဖြစ်ပွား နှင့် လက်နက်မတော်တဆ",
//     "မြွေကိုက်",
//     "မတော်တဆဖြစ်ရပ်",
//     "အရေပြားနှင့်ဆိုင်ရာရောဂါ",
//     "အရိုးအကြောနှင့်ဆိုင်ရာရောဂါ",
//     "သည်းခြေအိတ်နှင့်ဆိုင်ရာရောဂါ",
//     "မုန့်ချိုအိတ်နှင့်ဆိုင်ရာရောဂါ",
//     "သရက်ရွက်နှင့်ဆိုင်ရာရောဂါ",
//     "လိပ်ခေါင်းရောဂါ",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     initial();
//   }

//   editDonation(String name, String age, String selectHospital,
//       String selectDisease, String quarter, String township) {
//     ref.watch(realmProvider)!.updateDonation(
//           data,
//           patientName: name,
//           patientAge: age,
//           hospital: selectHospital,
//           donationDate: donationDateDetail == null
//               ? data.donationDate
//               : donationDateDetail!.toLocal(),
//           patientDisease: selectDisease,
//           patientAddress: "$quarter၊$township",
//         );

//     Utils.messageSuccessDialog("အချက်အလက်ပြင်ဆင်ခြင်း \nအောင်မြင်ပါသည်။",
//         context, "အိုကေ", Colors.black);
//     nameController.clear();
//     ageController.clear();
//     diseaseController.clear();
//     hospitalController.clear();
//     quarterController.clear();
//     townController.clear();
//     region1 = "";
//     regional = "";
//   }

//   void initial() async {
//     nameController.text = data.patientName ?? "";
//     ageController.text = data.patientAge ?? "";
//     quarterController.text = data.patientAddress.toString().split("၊")[0];
//     townController.text = data.patientAddress.toString().split("၊")[1];
//     hospitalController.text = data.hospital ?? "";
//     diseaseController.text = data.patientDisease ?? "";
//     donationDate = data.donationDate != null
//         ? data.donationDate!.string("dd-MM-yyyy")
//         : "";
//     setRegion(townController.text.toString());
//     if (data.patientName == null || data.patientName == "") {
//       setState(() {
//         switchNew = false;
//       });
//     }

//     final String response =
//         await rootBundle.loadString('assets/json/township.json');
//     townshipResponse = TownshipResponse.fromJson(json.decode(response));
//     for (var element in townshipResponse.data!) {
//       datas.add(element);
//       townships.add(element.township!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     YYDialog.init(context);
//     return Scaffold(
//       backgroundColor: const Color(0xfff2f2f2),
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
//           padding: const EdgeInsets.only(top: 4, right: 18),
//           child: Center(
//             child: Text("သွေးလှူဒါန်းမှုအချက်အလက် ပြင်ဆင်မည်",
//                 textScaleFactor: 1.0,
//                 style: TextStyle(
//                     fontSize: Responsive.isMobile(context) ? 15 : 16,
//                     color: Colors.white)),
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Responsive.isMobile(context)
//             ? SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       margin: const EdgeInsets.only(
//                           left: 12, top: 12, bottom: 15, right: 12),
//                       child: Container(
//                         padding: const EdgeInsets.only(
//                             bottom: 20, left: 4, right: 4, top: 8),
//                         decoration: shadowDecoration(Colors.white),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       "အကျဥ်း",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           color: switchNew
//                                               ? Colors.black
//                                               : primaryColor),
//                                     ),
//                                     Switch(
//                                         value: switchNew,
//                                         onChanged: (value) {
//                                           setState(() {
//                                             switchNew = value;
//                                           });
//                                         }),
//                                     Text(
//                                       "အပြည့်စုံ",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           color: switchNew
//                                               ? primaryColor
//                                               : Colors.black),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 16, right: 20),
//                               child: const Text(
//                                 "သွေးလှူဒါန်းသူ အမည်",
//                                 textScaleFactor: 1.0,
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 4, right: 20),
//                               child: Text(
//                                 "${data.memberObj!.name} (  ${data.memberObj!.memberId}  )",
//                                 textScaleFactor: 1.0,
//                                 style: const TextStyle(
//                                     fontSize: 15, color: Colors.black),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 16, right: 20),
//                               child: Container(
//                                 width: double.infinity,
//                                 height: 50,
//                                 margin: const EdgeInsets.only(
//                                   top: 4,
//                                 ),
//                                 child: fluent.Button(
//                                   child: Text(
//                                     donationDate,
//                                     style: TextStyle(
//                                         fontSize: 14, color: primaryColor),
//                                   ),
//                                   onPressed: () {
//                                     showDatePicker();
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, top: 24, bottom: 8, right: 20),
//                                 child: TextFormField(
//                                   controller: nameController,
//                                   decoration: inputBoxDecoration("လူနာအမည်"),
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, top: 16, bottom: 8, right: 20),
//                                 child: TextFormField(
//                                   controller: ageController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: inputBoxDecoration("လူနာအသက်"),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 16, bottom: 8, right: 20),
//                               child: TypeAheadField(
//                                 hideSuggestionsOnKeyboardHide: false,
//                                 textFieldConfiguration: TextFieldConfiguration(
//                                   controller: hospitalController,
//                                   autofocus: false,
//                                   decoration:
//                                       inputBoxDecoration("လှူဒါန်းသည့်နေရာ"),
//                                 ),
//                                 suggestionsCallback: (pattern) {
//                                   hospitalsSelected.clear();
//                                   hospitalsSelected.addAll(hospitals);
//                                   hospitalsSelected.retainWhere((s) => s
//                                       .toLowerCase()
//                                       .contains(pattern.toLowerCase()));
//                                   return hospitalsSelected;
//                                 },
//                                 transitionBuilder:
//                                     (context, suggestionsBox, controller) {
//                                   return suggestionsBox;
//                                 },
//                                 itemBuilder: (context, suggestion) {
//                                   return ListTile(
//                                     title: Text(
//                                       suggestion.toString(),
//                                       textScaleFactor: 1.0,
//                                     ),
//                                   );
//                                 },
//                                 errorBuilder: (BuildContext context,
//                                         Object? error) =>
//                                     Text('$error',
//                                         style: TextStyle(color: Colors.red)),
//                                 onSuggestionSelected: (suggestion) {
//                                   hospitalController.text =
//                                       suggestion.toString();
//                                 },
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, top: 16, bottom: 8, right: 20),
//                                 child: TypeAheadField(
//                                   hideSuggestionsOnKeyboardHide: false,
//                                   textFieldConfiguration:
//                                       TextFieldConfiguration(
//                                     controller: diseaseController,
//                                     autofocus: false,
//                                     decoration:
//                                         inputBoxDecoration("ဖြစ်ပွားသည့်ရောဂါ"),
//                                   ),
//                                   suggestionsCallback: (pattern) {
//                                     diseasesSelected.clear();
//                                     diseasesSelected.addAll(diseases);
//                                     diseasesSelected.retainWhere((s) => s
//                                         .toLowerCase()
//                                         .contains(pattern.toLowerCase()));
//                                     return diseasesSelected;
//                                   },
//                                   transitionBuilder:
//                                       (context, suggestionsBox, controller) {
//                                     return suggestionsBox;
//                                   },
//                                   itemBuilder: (context, suggestion) {
//                                     return ListTile(
//                                       title: Text(
//                                         suggestion.toString(),
//                                         textScaleFactor: 1.0,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (BuildContext context,
//                                           Object? error) =>
//                                       Text('$error',
//                                           style: TextStyle(color: Colors.red)),
//                                   onSuggestionSelected: (suggestion) {
//                                     diseaseController.text =
//                                         suggestion.toString();
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, top: 16, bottom: 8, right: 20),
//                                 child: TextFormField(
//                                   controller: quarterController,
//                                   decoration:
//                                       inputBoxDecoration("ရပ်ကွက်/ရွာအမည်"),
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 20, top: 16, bottom: 8, right: 20),
//                                 child: TypeAheadField(
//                                   hideSuggestionsOnKeyboardHide: false,
//                                   textFieldConfiguration:
//                                       TextFieldConfiguration(
//                                     controller: townController,
//                                     autofocus: false,
//                                     decoration: inputBoxDecoration("မြို့နယ်"),
//                                   ),
//                                   suggestionsCallback: (pattern) {
//                                     townshipsSelected.clear();
//                                     townshipsSelected.addAll(townships);
//                                     townshipsSelected.retainWhere((s) => s
//                                         .toLowerCase()
//                                         .contains(pattern.toLowerCase()));
//                                     return townshipsSelected;
//                                   },
//                                   transitionBuilder:
//                                       (context, suggestionsBox, controller) {
//                                     return suggestionsBox;
//                                   },
//                                   itemBuilder: (context, suggestion) {
//                                     return ListTile(
//                                       title: Text(
//                                         suggestion.toString(),
//                                         textScaleFactor: 1.0,
//                                       ),
//                                     );
//                                   },
//                                   errorBuilder: (BuildContext context,
//                                           Object? error) =>
//                                       Text('$error',
//                                           style: TextStyle(color: Colors.red)),
//                                   onSuggestionSelected: (suggestion) {
//                                     townController.text = suggestion.toString();
//                                     setRegion(suggestion.toString());
//                                   },
//                                 ),
//                               ),
//                             ),
//                             Visibility(
//                               visible: switchNew,
//                               child: Container(
//                                 margin: const EdgeInsets.only(
//                                     left: 30, bottom: 4, right: 20),
//                                 child: Text(regional,
//                                     textScaleFactor: 1.0,
//                                     textAlign: TextAlign.left,
//                                     style: TextStyle(
//                                         fontSize: 15, color: primaryColor)),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: primaryColor,
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(12.0))),
//                           margin: const EdgeInsets.only(
//                               left: 15, bottom: 16, right: 15),
//                           width: double.infinity,
//                           child: GestureDetector(
//                             behavior: HitTestBehavior.translucent,
//                             onTap: () {
//                               if (donationDate !=
//                                   "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
//                                 editDonation(
//                                     nameController.text.toString(),
//                                     ageController.text.toString(),
//                                     hospitalController.text.toString(),
//                                     diseaseController.text.toString(),
//                                     quarterController.text.toString(),
//                                     townController.text.toString());
//                               } else if (donationDate ==
//                                   "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
//                                 Utils.messageDialog(
//                                     "လှူဒါန်းသည့် ရက်စွဲ ရွေးချယ်ပေးရပါမည်",
//                                     context,
//                                     "ရွေးချယ်မည်",
//                                     Colors.black);
//                               } else {
//                                 Utils.messageDialog(
//                                     "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
//                                     context,
//                                     "ပြင်ဆင်မည်",
//                                     Colors.black);
//                               }

//                               // if (operatorImg == "") {
//                               //   Util.messageDialog("ဖုန်းနံပါတ် မှားယွင်းနေပါသည်",
//                               //       context, "ပြင်ဆင်မည်", Colors.black);
//                               // } else if (homeNo.text.toString() == "" ||
//                               //     street.text.toString() == "" ||
//                               //     quarter.text.toString() == "" ||
//                               //     town1.toString() == " ") {
//                               //   Util.messageDialog(
//                               //       "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
//                               //       context,
//                               //       "ဖြည့်သွင်းမည်",
//                               //       Colors.black);
//                               // } else {

//                               // }
//                             },
//                             child: const Align(
//                                 alignment: Alignment.center,
//                                 child: Padding(
//                                     padding: EdgeInsets.only(top: 8, bottom: 8),
//                                     child: Text(
//                                       "ပြင်ဆင်မည်",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 16.0, color: Colors.white),
//                                     ))),
//                           ),
//                         ))
//                   ],
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Container(
//                       margin: EdgeInsets.only(
//                           left: 54,
//                           top: 24,
//                           bottom: 15,
//                           right: MediaQuery.of(context).size.width * 0.1),
//                       child: Container(
//                         padding: const EdgeInsets.only(
//                             bottom: 20, left: 4, right: 4, top: 8),
//                         decoration: shadowDecoration(Colors.white),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Align(
//                               alignment: Alignment.centerRight,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(right: 16.0),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       "အကျဥ်း",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           color: switchNew
//                                               ? Colors.black
//                                               : primaryColor),
//                                     ),
//                                     Switch(
//                                         value: switchNew,
//                                         onChanged: (value) {
//                                           setState(() {
//                                             switchNew = value;
//                                           });
//                                         }),
//                                     Text(
//                                       "အပြည့်စုံ",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 15,
//                                           color: switchNew
//                                               ? primaryColor
//                                               : Colors.black),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 16, right: 20, bottom: 12),
//                               child: const Text(
//                                 "သွေးလှူဒါန်းသူ အမည်",
//                                 textScaleFactor: 1.0,
//                                 style: TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(
//                                   left: 20, top: 4, right: 20),
//                               child: Text(
//                                 "${data.memberObj!.name} (  ${data.memberObj!.memberId}  )",
//                                 textScaleFactor: 1.0,
//                                 style: const TextStyle(
//                                     fontSize: 15, color: Colors.black),
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         margin: const EdgeInsets.only(
//                                             left: 20,
//                                             top: 16,
//                                             right: 20,
//                                             bottom: 42),
//                                         child: Container(
//                                           width: double.infinity,
//                                           height: 50,
//                                           margin: const EdgeInsets.only(
//                                               top: 0, bottom: 4, right: 20),
//                                           child: fluent.Button(
//                                             child: Text(
//                                               donationDate,
//                                               style: TextStyle(
//                                                   fontSize: 14,
//                                                   color: primaryColor),
//                                             ),
//                                             onPressed: () {
//                                               showDatePicker();
//                                             },
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 5,
//                                   child: Container(),
//                                 )
//                               ],
//                             ),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Container(
//                                     margin: const EdgeInsets.only(
//                                         left: 20,
//                                         top: 16,
//                                         bottom: 42,
//                                         right: 20),
//                                     child: TypeAheadField(
//                                       hideSuggestionsOnKeyboardHide: false,
//                                       textFieldConfiguration:
//                                           TextFieldConfiguration(
//                                         controller: hospitalController,
//                                         autofocus: false,
//                                         decoration: inputBoxDecoration(
//                                             "လှူဒါန်းသည့်နေရာ"),
//                                       ),
//                                       suggestionsCallback: (pattern) {
//                                         hospitalsSelected.clear();
//                                         hospitalsSelected.addAll(hospitals);
//                                         hospitalsSelected.retainWhere((s) => s
//                                             .toLowerCase()
//                                             .contains(pattern.toLowerCase()));
//                                         return hospitalsSelected;
//                                       },
//                                       transitionBuilder: (context,
//                                           suggestionsBox, controller) {
//                                         return suggestionsBox;
//                                       },
//                                       itemBuilder: (context, suggestion) {
//                                         return ListTile(
//                                           title: Text(
//                                             suggestion.toString(),
//                                             textScaleFactor: 1.0,
//                                           ),
//                                         );
//                                       },
//                                       errorBuilder: (BuildContext context,
//                                               Object? error) =>
//                                           Text('$error',
//                                               style:
//                                                   TextStyle(color: Colors.red)),
//                                       onSuggestionSelected: (suggestion) {
//                                         hospitalController.text =
//                                             suggestion.toString();
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Visibility(
//                                     visible: switchNew,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(
//                                           top: 16,
//                                           left: 20,
//                                           bottom: 8,
//                                           right: 20),
//                                       child: TextFormField(
//                                         controller: nameController,
//                                         decoration:
//                                             inputBoxDecoration("လူနာအမည်"),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Container(),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Visibility(
//                                     visible: switchNew,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 20,
//                                           top: 8,
//                                           bottom: 8,
//                                           right: 20),
//                                       child: TypeAheadField(
//                                         hideSuggestionsOnKeyboardHide: false,
//                                         textFieldConfiguration:
//                                             TextFieldConfiguration(
//                                           controller: diseaseController,
//                                           autofocus: false,
//                                           decoration: inputBoxDecoration(
//                                               "ဖြစ်ပွားသည့်ရောဂါ"),
//                                         ),
//                                         suggestionsCallback: (pattern) {
//                                           diseasesSelected.clear();
//                                           diseasesSelected.addAll(diseases);
//                                           diseasesSelected.retainWhere((s) => s
//                                               .toLowerCase()
//                                               .contains(pattern.toLowerCase()));
//                                           return diseasesSelected;
//                                         },
//                                         transitionBuilder: (context,
//                                             suggestionsBox, controller) {
//                                           return suggestionsBox;
//                                         },
//                                         itemBuilder: (context, suggestion) {
//                                           return ListTile(
//                                             title: Text(
//                                               suggestion.toString(),
//                                               textScaleFactor: 1.0,
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder: (BuildContext context,
//                                                 Object? error) =>
//                                             Text('$error',
//                                                 style: TextStyle(
//                                                     color: Colors.red)),
//                                         onSuggestionSelected: (suggestion) {
//                                           diseaseController.text =
//                                               suggestion.toString();
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Visibility(
//                                     visible: switchNew,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 20,
//                                           top: 8,
//                                           bottom: 8,
//                                           right: 20),
//                                       child: TextFormField(
//                                         controller: ageController,
//                                         keyboardType: TextInputType.number,
//                                         inputFormatters: <TextInputFormatter>[
//                                           FilteringTextInputFormatter.digitsOnly
//                                         ],
//                                         decoration:
//                                             inputBoxDecoration("လူနာအသက်"),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Container(),
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Visibility(
//                                     visible: switchNew,
//                                     child: Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 20,
//                                           top: 16,
//                                           bottom: 8,
//                                           right: 20),
//                                       child: TextFormField(
//                                         controller: quarterController,
//                                         decoration: inputBoxDecoration(
//                                             "ရပ်ကွက်/ရွာအမည်"),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Visibility(
//                                         visible: switchNew,
//                                         child: Container(
//                                           margin: const EdgeInsets.only(
//                                               left: 20,
//                                               top: 16,
//                                               bottom: 8,
//                                               right: 20),
//                                           child: TypeAheadField(
//                                             hideSuggestionsOnKeyboardHide:
//                                                 false,
//                                             textFieldConfiguration:
//                                                 TextFieldConfiguration(
//                                               controller: townController,
//                                               autofocus: false,
//                                               decoration: inputBoxDecoration(
//                                                   "မြို့နယ်"),
//                                             ),
//                                             suggestionsCallback: (pattern) {
//                                               townshipsSelected.clear();
//                                               townshipsSelected
//                                                   .addAll(townships);
//                                               townshipsSelected.retainWhere(
//                                                   (s) => s
//                                                       .toLowerCase()
//                                                       .contains(pattern
//                                                           .toLowerCase()));
//                                               return townshipsSelected;
//                                             },
//                                             transitionBuilder: (context,
//                                                 suggestionsBox, controller) {
//                                               return suggestionsBox;
//                                             },
//                                             itemBuilder: (context, suggestion) {
//                                               return ListTile(
//                                                 title: Text(
//                                                   suggestion.toString(),
//                                                   textScaleFactor: 1.0,
//                                                 ),
//                                               );
//                                             },
//                                             errorBuilder: (BuildContext context,
//                                                     Object? error) =>
//                                                 Text('$error',
//                                                     style: TextStyle(
//                                                         color: Colors.red)),
//                                             onSuggestionSelected: (suggestion) {
//                                               townController.text =
//                                                   suggestion.toString();
//                                               setRegion(suggestion.toString());
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                       Visibility(
//                                         visible: switchNew,
//                                         child: Container(
//                                           margin: const EdgeInsets.only(
//                                               left: 30, bottom: 4, right: 20),
//                                           child: Text(regional,
//                                               textScaleFactor: 1.0,
//                                               textAlign: TextAlign.left,
//                                               style: TextStyle(
//                                                   fontSize: 15,
//                                                   color: primaryColor)),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Container(),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Align(
//                         alignment: Alignment.bottomLeft,
//                         child: Container(
//                           decoration: BoxDecoration(
//                               color: primaryColor,
//                               borderRadius: const BorderRadius.all(
//                                   Radius.circular(12.0))),
//                           width: MediaQuery.of(context).size.width / 2.8,
//                           margin: const EdgeInsets.only(
//                               left: 54, bottom: 16, right: 8),
//                           child: GestureDetector(
//                             behavior: HitTestBehavior.translucent,
//                             onTap: () {
//                               if (donationDate !=
//                                   "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
//                                 editDonation(
//                                     nameController.text.toString(),
//                                     ageController.text.toString(),
//                                     hospitalController.text.toString(),
//                                     diseaseController.text.toString(),
//                                     quarterController.text.toString(),
//                                     townController.text.toString());
//                               } else if (donationDate ==
//                                   "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
//                                 Utils.messageDialog(
//                                     "လှူဒါန်းသည့် ရက်စွဲ ရွေးချယ်ပေးရပါမည်",
//                                     context,
//                                     "ရွေးချယ်မည်",
//                                     Colors.black);
//                               } else {
//                                 Utils.messageDialog(
//                                     "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
//                                     context,
//                                     "ပြင်ဆင်မည်",
//                                     Colors.black);
//                               }

//                               // if (operatorImg == "") {
//                               //   Util.messageDialog("ဖုန်းနံပါတ် မှားယွင်းနေပါသည်",
//                               //       context, "ပြင်ဆင်မည်", Colors.black);
//                               // } else if (homeNo.text.toString() == "" ||
//                               //     street.text.toString() == "" ||
//                               //     quarter.text.toString() == "" ||
//                               //     town1.toString() == " ") {
//                               //   Util.messageDialog(
//                               //       "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
//                               //       context,
//                               //       "ဖြည့်သွင်းမည်",
//                               //       Colors.black);
//                               // } else {

//                               // }
//                             },
//                             child: const Align(
//                                 alignment: Alignment.center,
//                                 child: Padding(
//                                     padding: EdgeInsets.only(top: 8, bottom: 8),
//                                     child: Text(
//                                       "ပြင်ဆင်မည်",
//                                       textScaleFactor: 1.0,
//                                       style: TextStyle(
//                                           fontSize: 15, color: Colors.white),
//                                     ))),
//                           ),
//                         ))
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   void setRegion(String township) {
//     townController.text = township;

//     for (var element in datas) {
//       if (element.township == township) {
//         setState(() {
//           regional = "${element.town!}, ${element.region!}";
//           town1 = element.town!;
//           region1 = element.region!;
//           township1 = township;
//         });
//       }
//     }
//   }

//   Widget buildOperator() {
//     if (operatorImg == "") {
//       return Container(child: null);
//     } else {
//       return Opacity(
//         opacity: 0.6,
//         child: SvgPicture.asset(
//           operatorImg,
//           height: 34,
//         ),
//       );
//     }
//   }

//   String checkPhone(String phone) {
//     var operator = "";

//     RegExp ooredoo = RegExp(
//       "(09|\\+?959)9(5|6|7|8)\\d{7}",
//       caseSensitive: false,
//       multiLine: false,
//     );
//     RegExp telenor = RegExp(
//       "(09|\\+?959)7([5-9])\\d{7}",
//       caseSensitive: false,
//       multiLine: false,
//     );
//     RegExp mytel = RegExp(
//       "(09|\\+?959)6([6-9])\\d{7}",
//       caseSensitive: false,
//       multiLine: false,
//     );
//     RegExp mec = RegExp(
//       "(09|\\+?959)3([0-9])\\d{6}",
//       caseSensitive: false,
//       multiLine: false,
//     );
//     RegExp mpt = RegExp(
//       "(09|\\+?959)(5\\d{6}|4\\d{7}|4\\d{8}|2\\d{6}|2\\d{7}|2\\d{8}|3\\d{7}|3\\d{8}|6\\d{6}|8\\d{6}|8\\d{7}|8\\d{8}|7\\d{7}|9(0|1|9)\\d{5}|9(0|1|9)\\d{6}|2([0-4])\\d{5}|5([0-6])\\d{5}|8([3-7])\\d{5}|3([0-369])\\d{6}|34\\d{7}|4([1379])\\d{6}|73\\d{6}|91\\d{6}|25\\d{7}|26([0-5])d{6}|40([0-4])\\d{6}|42\\d{7}|45\\d{7}|89([6789])\\d{6})",
//       caseSensitive: false,
//       multiLine: false,
//     );

//     if (ooredoo.hasMatch(phone)) {
//       operator = "Ooredoo";
//     } else if (telenor.hasMatch(phone)) {
//       operator = "Telenor";
//     } else if (mytel.hasMatch(phone)) {
//       operator = "Mytel";
//     } else if (mec.hasMatch(phone)) {
//       operator = "MEC";
//     } else if (mpt.hasMatch(phone)) {
//       operator = "MPT";
//     } else {
//       operator = "Not_Valid";
//     }

//     return operator;
//   }

//   showDatePicker() async {
//     Utils.showCupertinoDatePicker(
//       context,
//       (DateTime newDateTime) {
//         setState(() {
//           donationDate = newDateTime.string("dd-MM-yyyy");
//           donationDateDetail = newDateTime.toLocal();
//         });
//         log("newDateTime: ${newDateTime.toLocal()}");
//       },
//     );
//   }
// }
