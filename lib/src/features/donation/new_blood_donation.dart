import 'dart:convert';
import 'dart:developer';

import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/data/response/xata_member_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewBloodDonationScreen extends ConsumerStatefulWidget {
  NewBloodDonationScreen({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewBloodDonationState createState() => NewBloodDonationState();
}

class NewBloodDonationState extends ConsumerState<NewBloodDonationScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final quarterController = TextEditingController();
  final townController = TextEditingController();
  final hospitalController = TextEditingController();
  final memberController = TextEditingController();
  final diseaseController = TextEditingController();
  bool isSwitched = false;
  String operatorImg = "";
  Member? selectedMember;

  String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";
  DateTime? donationDateDetail;

  String region1 = " ";
  String town1 = " ";
  String township1 = " ";
  String township1ID = " ";
  String regional = " ";
  String post_code = " ";
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];
  List<String> townshipsSelected = <String>[];

  List<Datum> datas = <Datum>[];
  bool switchNew = true;

  List<String> hospitalsSelected = <String>[];
  List<String> hospitals = <String>[
    "ငွေမိုးဆေးရုံ",
    "မော်လမြိုင်ပြည်သူ့ဆေးရုံကြီး",
    "ဇာနည်ဘွားဆေးရုံ",
    "ရတနာမွန်ဆေးရုံ",
    "တော်ဝင်ဆေးရုံ",
    "ရွှေလမင်းဆေးရုံ",
    "ခရစ်ယာန်အရေပြားဆေးရုံ",
    "အေးသန္တာဆေးရုံ",
    "မေတ္တရိပ်ဆေးခန်း",
    "ဇာနည်အောင်ဆေးရုံ",
    "ဇာသပြင်တိုက်နယ်ဆေးရုံ",
    "လွမ်းသာဆေးခန်း",
    "ချမ်းသာသုခဆေးခန်း",
    "ချမ်းမြေ့ဂုဏ်ဆေးခန်း",
    "အေဝမ်းဆေးခန်း",
    "ကျိုက်မရောမြို့နယ်ဆေးရုံ",
    "ကောင်းဆေးခန်း",
    "မုတ္တမတိုက်နယ်ဆေးရုံ",
    "အမေရိကန်ဆေးရုံ"
  ];
  List<MemberData> allMember = [];

  List<String> diseasesSelected = <String>[];
  List<String> diseases = <String>[
    "အစာအိမ်သွေးကြောပေါက်",
    "အသည်းခြောက်",
    "ကျောက်ကပ်အားနည်း",
    "သားအိမ်အလုံးတည်",
    "မီးဖွားသွေးဆင်းများ",
    "ကိုယ်ဝန်ပျက်ကျခြင်း",
    "မတော်တဆဖြစ်ရပ်",
    "......(ခွဲစိတ်)",
    ".....(ကင်ဆာ)",
    ".....(သွေးအားနည်း)",
    "သွေးအားနည်းရောဂါ",
    "အသည်းရောင်အသားဝါ(ဘီ)ပိုး",
    "အသည်းရောင်အသားဝါ(စီ)ပိုး",
    "ကျောက်ကပ်အနာဖြစ်",
    "အူတီဘီ",
    "အစာအိမ်လမ်းကြောင်းအကျိတ်ပေါက်",
    "သွေးလွန်တုပ်ကွေး",
    "ဆီးကျိတ်",
    "သွေးလေးဖက်နာ",
    "အရေပြားရောဂါ",
    "လိပ်ခေါင်းသွေးယို",
    "သည်းခြေကျောက်တည်",
    "လည်ပင်းအကျိတ်",
    "သွေးမတိတ်ရောဂါ",
    "ခုခံအားကျဆင်းမှုကူးစက်ရောဂါ",
    "နှလုံးသွေးကြောကျဉ်း",
    "ဆီးချို",
    "သွေးတိုး",
    "ဦးနှောက်သွေးခဲ",
    "တီဘီ",
  ];

  @override
  void initState() {
    super.initState();
    initial();
  }

  addDonation(String name, String age, String selectHospital,
      String selectDisease, String quarter, String township) {
    ref.watch(realmProvider)!.createDonation(
          member: selectedMember != null ? selectedMember!.id : null,
          date: donationDateDetail!.string("dd MMM yyyy"),
          donationDate: donationDateDetail!.toLocal(),
          hospital: selectHospital,
          memberObj: selectedMember,
          memberId:
              selectedMember != null ? selectedMember!.memberId.toString() : "",
          patientAddress: "$quarter၊$township",
          patientAge: age,
          patientDisease: diseaseController.text.toString(),
          patientName: name,
        );

    Utils.messageSuccessDialog(
        "သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
        context,
        "အိုကေ",
        Colors.black);

    ref.watch(realmProvider)!.updateMember(
          selectedMember!,
          memberCount:
              ((int.parse(selectedMember!.memberCount ?? "0")) + 1).toString(),
          totalCount:
              ((int.parse(selectedMember!.totalCount ?? "0")) + 1).toString(),
        );
  }

  void initial() async {
    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }

    // callAPI("");
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        allMember = [];
      });
    }
    XataRepository().getMemberList(after).then((response) {
      log(response.body.toString());

      setState(() {
        allMember.addAll(
            XataMemberListResponse.fromJson(jsonDecode(response.body))
                .records!);
      });

      if (XataMemberListResponse.fromJson(jsonDecode(response.body))
          .meta!
          .page!
          .more!) {
        callAPI(XataMemberListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        allMember.sort((a, b) => a.name!.compareTo(b.name!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var members = ref.watch(membersProvider);
    YYDialog.init(context);
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
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
          padding: const EdgeInsets.only(top: 4, right: 18),
          child: Center(
            child: Text("သွေးလှူဒါန်းမှုအသစ် ထည့်သွင်းမည်",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: Colors.white)),
          ),
        ),
      ),
      body: SafeArea(
        child: Responsive.isMobile(context)
            ? SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 12, top: 12, bottom: 15, right: 12),
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 4, right: 4, top: 8),
                        decoration: shadowDecoration(Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "အကျဥ်း",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: switchNew
                                              ? Colors.black
                                              : primaryColor),
                                    ),
                                    Switch(
                                        value: switchNew,
                                        onChanged: (value) {
                                          setState(() {
                                            switchNew = value;
                                          });
                                        }),
                                    Text(
                                      "အပြည့်စုံ",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: switchNew
                                              ? primaryColor
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: 24, top: 12, bottom: 12),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, bottom: 4, right: 20),
                                child: NeumorphicButton(
                                  child: Text(
                                    donationDate,
                                    style: TextStyle(
                                        fontSize: 14, color: primaryColor),
                                  ),
                                  onPressed: () {
                                    showDatePicker();
                                  },
                                ),
                              ),
                              // child: fluent.DatePicker(
                              //   header: 'လှူဒါန်းသည့်ရက် ရွေးချယ်မည်',
                              //   headerStyle: TextStyle(fontSize: 15),
                              //   selected: donationDateDetail,
                              //   onChanged: (time) => setState(() {
                              //     donationDate = time.string("dd-MM-yyyy");
                              //     donationDateDetail = time;
                              //   }),
                              // ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20, top: 16, right: 20),
                              child: TypeAheadField(
                                hideSuggestionsOnKeyboardHide: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: memberController,
                                  autofocus: false,
                                  decoration: inputBoxDecoration("လှူဒါန်းသူ"),
                                ),
                                suggestionsCallback: (pattern) async {
                                  var list = members.where((element) => element
                                      .name
                                      .toString()
                                      .toString()
                                      .startsWith(pattern.toLowerCase()));
                                  //   var list = members
                                  //       .where((element) =>
                                  //           element.name
                                  //               .toString()
                                  //               .toLowerCase()
                                  //               .split("")
                                  //               .toSet()
                                  //               .intersection(pattern
                                  //                   .toLowerCase()
                                  //                   .split("")
                                  //                   .toSet())
                                  //               .length ==
                                  //           pattern
                                  //               .toLowerCase()
                                  //               .split("")
                                  //               .toSet()
                                  //               .length)
                                  //       .toList();
                                  return list;
                                },
                                transitionBuilder:
                                    (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                itemBuilder: (context, suggestion) {
                                  return Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title:
                                              Text(suggestion.name.toString()),
                                          subtitle: Text(
                                              "${suggestion.bloodType}  ${suggestion.fatherName} ${suggestion.birthDate}"),
                                        ),
                                        const Divider(
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                        Object? error) =>
                                    Text('$error',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).errorColor)),
                                onSuggestionSelected: (suggestion) {
                                  setState(() {
                                    selectedMember = suggestion;
                                  });
                                  memberController.text =
                                      suggestion.name.toString();
                                },
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 24, bottom: 8, right: 20),
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: inputBoxDecoration("လူနာအမည်"),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, bottom: 8, right: 20),
                                child: TextFormField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: inputBoxDecoration("လူနာအသက်"),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20, top: 16, bottom: 8, right: 20),
                              child: TypeAheadField(
                                hideSuggestionsOnKeyboardHide: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: hospitalController,
                                  autofocus: false,
                                  decoration:
                                      inputBoxDecoration("လှူဒါန်းသည့်နေရာ"),
                                ),
                                suggestionsCallback: (pattern) {
                                  hospitalsSelected.clear();
                                  hospitalsSelected.addAll(hospitals);
                                  hospitalsSelected.where((element) => element
                                      .toString()
                                      .toString()
                                      .startsWith(pattern.toLowerCase()));
                                  //   hospitalsSelected.retainWhere((s) =>
                                  //       s
                                  //           .toString()
                                  //           .toLowerCase()
                                  //           .split("")
                                  //           .toSet()
                                  //           .intersection(pattern
                                  //               .toLowerCase()
                                  //               .split("")
                                  //               .toSet())
                                  //           .length ==
                                  //       pattern
                                  //           .toLowerCase()
                                  //           .split("")
                                  //           .toSet()
                                  //           .length);
                                  return hospitalsSelected;
                                },
                                transitionBuilder:
                                    (context, suggestionsBox, controller) {
                                  return suggestionsBox;
                                },
                                itemBuilder: (context, suggestion) {
                                  return Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      title: Text(
                                        suggestion.toString(),
                                        textScaleFactor: 1.0,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                        Object? error) =>
                                    Text('$error',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).errorColor)),
                                onSuggestionSelected: (suggestion) {
                                  hospitalController.text =
                                      suggestion.toString();
                                },
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, bottom: 8, right: 20),
                                child: TextFormField(
                                  controller: diseaseController,
                                  keyboardType: TextInputType.text,
                                  decoration:
                                      inputBoxDecoration("ဖြစ်ပွားသည့်ရောဂါ"),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, bottom: 8, right: 20),
                                child: TextFormField(
                                  controller: quarterController,
                                  decoration:
                                      inputBoxDecoration("ရပ်ကွက်/ရွာအမည်"),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, bottom: 8, right: 20),
                                child: TypeAheadField(
                                  hideSuggestionsOnKeyboardHide: true,
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: townController,
                                    autofocus: false,
                                    decoration: inputBoxDecoration("မြို့နယ်"),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    townshipsSelected.clear();
                                    townshipsSelected.addAll(townships);
                                    townshipsSelected.where((element) => element
                                        .toString()
                                        .toString()
                                        .startsWith(pattern.toLowerCase()));
                                    // townshipsSelected.retainWhere((s) =>
                                    //     s
                                    //         .toString()
                                    //         .toLowerCase()
                                    //         .split("")
                                    //         .toSet()
                                    //         .intersection(pattern
                                    //             .toLowerCase()
                                    //             .split("")
                                    //             .toSet())
                                    //         .length ==
                                    //     pattern
                                    //         .toLowerCase()
                                    //         .split("")
                                    //         .toSet()
                                    //      .length);
                                    return townshipsSelected;
                                  },
                                  transitionBuilder:
                                      (context, suggestionsBox, controller) {
                                    return suggestionsBox;
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(
                                          suggestion.toString(),
                                          textScaleFactor: 1.0,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                          Object? error) =>
                                      Text('$error',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .errorColor)),
                                  onSuggestionSelected: (suggestion) {
                                    townController.text = suggestion.toString();
                                    setRegion(suggestion.toString());
                                  },
                                ),
                              ),
                            ),
                            Visibility(
                              visible: switchNew,
                              child: Container(
                                margin: const EdgeInsets.only(
                                    left: 30, bottom: 4, right: 20),
                                child: Text(regional,
                                    textScaleFactor: 1.0,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15, color: primaryColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          margin: const EdgeInsets.only(
                              left: 15, bottom: 16, right: 15),
                          width: double.infinity,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (selectedMember != null &&
                                  donationDate !=
                                      "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                addDonation(
                                    nameController.text.toString(),
                                    ageController.text.toString(),
                                    hospitalController.text.toString(),
                                    diseaseController.text.toString(),
                                    quarterController.text.toString(),
                                    townController.text.toString());
                              } else if (selectedMember == null) {
                                Utils.messageDialog(
                                    "လှူဒါန်းသူ ရွေးချယ်ပေးရပါမည်",
                                    context,
                                    "ရွေးချယ်မည်",
                                    Colors.black);
                              } else if (donationDate ==
                                  "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                Utils.messageDialog(
                                    "လှူဒါန်းသည့် ရက်စွဲ ရွေးချယ်ပေးရပါမည်",
                                    context,
                                    "ရွေးချယ်မည်",
                                    Colors.black);
                              } else {
                                Utils.messageDialog(
                                    "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
                                    context,
                                    "ပြင်ဆင်မည်",
                                    Colors.black);
                              }
                            },
                            child: const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: Text(
                                      "ထည့်သွင်းမည်",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white),
                                    ))),
                          ),
                        ))
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: 54,
                          top: 12,
                          bottom: 15,
                          right: MediaQuery.of(context).size.width * 0.1),
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 4, right: 4, top: 8),
                        decoration: shadowDecoration(Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "အကျဥ်း",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: switchNew
                                              ? Colors.black
                                              : primaryColor),
                                    ),
                                    Switch(
                                        value: switchNew,
                                        onChanged: (value) {
                                          setState(() {
                                            switchNew = value;
                                          });
                                        }),
                                    Text(
                                      "အပြည့်စုံ",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: switchNew
                                              ? primaryColor
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 12, bottom: 4),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          top: 16,
                                          bottom: 4,
                                          right: 20),
                                      child: NeumorphicButton(
                                        child: Text(
                                          donationDate,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: primaryColor),
                                        ),
                                        onPressed: () {
                                          showDatePicker();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, top: 16, right: 20),
                                    child: TypeAheadField(
                                      hideSuggestionsOnKeyboardHide: true,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        controller: memberController,
                                        autofocus: false,
                                        decoration:
                                            inputBoxDecoration("လှူဒါန်းသူ"),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        var list = members.where((element) =>
                                            element.name
                                                .toString()
                                                .toString()
                                                .startsWith(
                                                    pattern.toLowerCase()));
                                        // var list = members
                                        //     .where((element) =>
                                        //         element.name
                                        //             .toString()
                                        //             .toLowerCase()
                                        //             .split("")
                                        //             .toSet()
                                        //             .intersection(pattern
                                        //                 .toLowerCase()
                                        //                 .split("")
                                        //                 .toSet())
                                        //             .length ==
                                        //         pattern
                                        //             .toLowerCase()
                                        //             .split("")
                                        //             .toSet()
                                        //             .length)
                                        //     .toList();
                                        return list;
                                      },
                                      transitionBuilder: (context,
                                          suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      itemBuilder: (context, suggestion) {
                                        return Container(
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text(
                                                    suggestion.name.toString()),
                                                subtitle: Text(
                                                    "${suggestion.bloodType} ${suggestion.fatherName}  [${suggestion.birthDate}]"),
                                              ),
                                              const Divider(
                                                height: 1,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context,
                                              Object? error) =>
                                          Text('$error',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .errorColor)),
                                      onSuggestionSelected: (suggestion) {
                                        setState(() {
                                          selectedMember = suggestion;
                                        });
                                        memberController.text =
                                            suggestion.name.toString();
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Visibility(
                                    visible: switchNew,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          top: 24,
                                          bottom: 8,
                                          right: 20),
                                      child: TextFormField(
                                        controller: nameController,
                                        decoration:
                                            inputBoxDecoration("လူနာအမည်"),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20,
                                        top: 16,
                                        bottom: 8,
                                        right: 20),
                                    child: TypeAheadField(
                                      hideSuggestionsOnKeyboardHide: true,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        controller: hospitalController,
                                        autofocus: false,
                                        decoration: inputBoxDecoration(
                                            "လှူဒါန်းသည့်နေရာ"),
                                      ),
                                      suggestionsCallback: (pattern) {
                                        hospitalsSelected.clear();
                                        hospitalsSelected.addAll(hospitals);
                                        hospitalsSelected.retainWhere(
                                            (element) => element
                                                .toString()
                                                .toString()
                                                .startsWith(
                                                    pattern.toLowerCase()));
                                        // hospitalsSelected.retainWhere((s) =>
                                        //     s
                                        //         .toString()
                                        //         .toLowerCase()
                                        //         .split("")
                                        //         .toSet()
                                        //         .intersection(pattern
                                        //             .toLowerCase()
                                        //             .split("")
                                        //             .toSet())
                                        //         .length ==
                                        //     pattern
                                        //         .toLowerCase()
                                        //         .split("")
                                        //         .toSet()
                                        //         .length);
                                        return hospitalsSelected;
                                      },
                                      transitionBuilder: (context,
                                          suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      itemBuilder: (context, suggestion) {
                                        return Container(
                                          color: Colors.white,
                                          child: ListTile(
                                            title: Text(
                                              suggestion.toString(),
                                              textScaleFactor: 1.0,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (BuildContext context,
                                              Object? error) =>
                                          Text('$error',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .errorColor)),
                                      onSuggestionSelected: (suggestion) {
                                        hospitalController.text =
                                            suggestion.toString();
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Visibility(
                                    visible: switchNew,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          top: 16,
                                          bottom: 8,
                                          right: 20),
                                      child: TextFormField(
                                        controller: ageController,
                                        keyboardType: TextInputType.number,
                                        decoration:
                                            inputBoxDecoration("လူနာအသက်"),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Visibility(
                                    visible: switchNew,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          top: 16,
                                          bottom: 8,
                                          right: 20),
                                      child: TypeAheadField(
                                        hideSuggestionsOnKeyboardHide: true,
                                        textFieldConfiguration:
                                            TextFieldConfiguration(
                                          controller: diseaseController,
                                          autofocus: false,
                                          decoration: inputBoxDecoration(
                                              "ဖြစ်ပွားသည့်ရောဂါ"),
                                        ),
                                        suggestionsCallback: (pattern) {
                                          diseasesSelected.clear();
                                          diseasesSelected.addAll(diseases);
                                          diseasesSelected.where((element) =>
                                              element
                                                  .toString()
                                                  .toString()
                                                  .startsWith(
                                                      pattern.toLowerCase()));
                                          //   diseasesSelected.retainWhere((s) =>
                                          //       s
                                          //           .toString()
                                          //           .toLowerCase()
                                          //           .split("")
                                          //           .toSet()
                                          //           .intersection(pattern
                                          //               .toLowerCase()
                                          //               .split("")
                                          //               .toSet())
                                          //           .length ==
                                          //       pattern
                                          //           .toLowerCase()
                                          //           .split("")
                                          //           .toSet()
                                          //           .length);

                                          return diseasesSelected;
                                        },
                                        transitionBuilder: (context,
                                            suggestionsBox, controller) {
                                          return suggestionsBox;
                                        },
                                        itemBuilder: (context, suggestion) {
                                          return Container(
                                            color: Colors.white,
                                            child: ListTile(
                                              title: Text(
                                                suggestion.toString(),
                                                textScaleFactor: 1.0,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (BuildContext context,
                                                Object? error) =>
                                            Text('$error',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor)),
                                        onSuggestionSelected: (suggestion) {
                                          diseaseController.text =
                                              suggestion.toString();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Visibility(
                                    visible: switchNew,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 20,
                                          top: 16,
                                          bottom: 8,
                                          right: 20),
                                      child: TextFormField(
                                        controller: quarterController,
                                        decoration: inputBoxDecoration(
                                            "ရပ်ကွက်/ရွာအမည်"),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: switchNew,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 20,
                                              top: 16,
                                              bottom: 8,
                                              right: 20),
                                          child: TypeAheadField(
                                            hideSuggestionsOnKeyboardHide: true,
                                            textFieldConfiguration:
                                                TextFieldConfiguration(
                                              controller: townController,
                                              autofocus: false,
                                              decoration: inputBoxDecoration(
                                                  "မြို့နယ်"),
                                            ),
                                            suggestionsCallback: (pattern) {
                                              townshipsSelected.clear();
                                              townshipsSelected
                                                  .addAll(townships);
                                              townshipsSelected.retainWhere(
                                                  (element) => element
                                                      .toString()
                                                      .toString()
                                                      .startsWith(pattern
                                                          .toLowerCase()));
                                              //   townshipsSelected.retainWhere(
                                              //       (s) =>
                                              //           s
                                              //               .toString()
                                              //               .toLowerCase()
                                              //               .split("")
                                              //               .toSet()
                                              //               .intersection(pattern
                                              //                   .toLowerCase()
                                              //                   .split("")
                                              //                   .toSet())
                                              //               .length ==
                                              //           pattern
                                              //               .toLowerCase()
                                              //               .split("")
                                              //               .toSet()
                                              //               .length);
                                              return townshipsSelected;
                                            },
                                            transitionBuilder: (context,
                                                suggestionsBox, controller) {
                                              return suggestionsBox;
                                            },
                                            itemBuilder: (context, suggestion) {
                                              return Container(
                                                color: Colors.white,
                                                child: ListTile(
                                                  title: Text(
                                                    suggestion.toString(),
                                                    textScaleFactor: 1.0,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (BuildContext context,
                                                    Object? error) =>
                                                Text('$error',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .errorColor)),
                                            onSuggestionSelected: (suggestion) {
                                              townController.text =
                                                  suggestion.toString();
                                              setRegion(suggestion.toString());
                                            },
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: switchNew,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 30, bottom: 4, right: 20),
                                          child: Text(regional,
                                              textScaleFactor: 1.0,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: primaryColor)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          width: MediaQuery.of(context).size.width / 2.8,
                          margin: const EdgeInsets.only(
                              left: 54, bottom: 16, right: 8),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (selectedMember != null &&
                                  donationDate !=
                                      "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                addDonation(
                                    nameController.text.toString(),
                                    ageController.text.toString(),
                                    hospitalController.text.toString(),
                                    diseaseController.text.toString(),
                                    quarterController.text.toString(),
                                    townController.text.toString());
                              } else if (selectedMember == null) {
                                Utils.messageDialog(
                                    "လှူဒါန်းသူ ရွေးချယ်ပေးရပါမည်",
                                    context,
                                    "ရွေးချယ်မည်",
                                    Colors.black);
                              } else if (donationDate ==
                                  "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                Utils.messageDialog(
                                    "လှူဒါန်းသည့် ရက်စွဲ ရွေးချယ်ပေးရပါမည်",
                                    context,
                                    "ရွေးချယ်မည်",
                                    Colors.black);
                              } else {
                                Utils.messageDialog(
                                    "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
                                    context,
                                    "ပြင်ဆင်မည်",
                                    Colors.black);
                              }
                            },
                            child: const Align(
                                alignment: Alignment.center,
                                child: Padding(
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    child: Text(
                                      "ထည့်သွင်းမည်",
                                      textScaleFactor: 1.0,
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.white),
                                    ))),
                          ),
                        ))
                  ],
                ),
              ),
      ),
    );
  }

  void setRegion(String township) {
    townController.text = township;

    for (var element in datas) {
      if (element.township == township) {
        setState(() {
          regional = "${element.town!}, ${element.region!}";
          town1 = element.town!;
          region1 = element.region!;
          township1 = township;
        });
      }
    }
  }

  Widget buildOperator() {
    if (operatorImg == "") {
      return Container(child: null);
    } else {
      return Opacity(
        opacity: 0.6,
        child: SvgPicture.asset(
          operatorImg,
          height: 34,
        ),
      );
    }
  }

  String checkPhone(String phone) {
    var operator = "";

    RegExp ooredoo = RegExp(
      "(09|\\+?959)9(5|6|7|8)\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp telenor = RegExp(
      "(09|\\+?959)7([5-9])\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mytel = RegExp(
      "(09|\\+?959)6([6-9])\\d{7}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mec = RegExp(
      "(09|\\+?959)3([0-9])\\d{6}",
      caseSensitive: false,
      multiLine: false,
    );
    RegExp mpt = RegExp(
      "(09|\\+?959)(5\\d{6}|4\\d{7}|4\\d{8}|2\\d{6}|2\\d{7}|2\\d{8}|3\\d{7}|3\\d{8}|6\\d{6}|8\\d{6}|8\\d{7}|8\\d{8}|7\\d{7}|9(0|1|9)\\d{5}|9(0|1|9)\\d{6}|2([0-4])\\d{5}|5([0-6])\\d{5}|8([3-7])\\d{5}|3([0-369])\\d{6}|34\\d{7}|4([1379])\\d{6}|73\\d{6}|91\\d{6}|25\\d{7}|26([0-5])d{6}|40([0-4])\\d{6}|42\\d{7}|45\\d{7}|89([6789])\\d{6})",
      caseSensitive: false,
      multiLine: false,
    );

    if (ooredoo.hasMatch(phone)) {
      operator = "Ooredoo";
    } else if (telenor.hasMatch(phone)) {
      operator = "Telenor";
    } else if (mytel.hasMatch(phone)) {
      operator = "Mytel";
    } else if (mec.hasMatch(phone)) {
      operator = "MEC";
    } else if (mpt.hasMatch(phone)) {
      operator = "MPT";
    } else {
      operator = "Not_Valid";
    }

    return operator;
  }

  showDatePicker() async {
    Utils.showCupertinoDatePicker(
      context,
      (DateTime newDateTime) {
        setState(() {
          donationDate = newDateTime.string("dd-MM-yyyy");
          donationDateDetail = newDateTime.toLocal();
        });
      },
    );
  }
}
