import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:merchant/data/repository/repository.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/data/response/total_data_response.dart';
import 'package:merchant/data/response/township_response/datum.dart';
import 'package:merchant/data/response/township_response/township_response.dart';
import 'package:merchant/data/response/xata_member_list_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class NewBloodDonationScreen extends StatefulWidget {
  NewBloodDonationScreen({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewBloodDonationState createState() => NewBloodDonationState();
}

class NewBloodDonationState extends State<NewBloodDonationScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final quarterController = TextEditingController();
  final townController = TextEditingController();
  final hospitalController = TextEditingController();
  final memberController = TextEditingController();
  final diseaseController = TextEditingController();
  bool isSwitched = false;
  String operatorImg = "";
  String member_record_id = "";

  String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";
  DateTime? donationDateDetail;

  String region1 = " ";
  String town1 = " ";
  String township1 = " ";
  String township1ID = " ";
  String regional = " ";
  String post_code = " ";
  bool _isLoading = false;
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];
  List<String> townshipsSelected = <String>[];
  List<String> membersSelected = <String>[];
  List<String> allMembers = <String>[];
  List<String> allMemberIDs = <String>[];
  List<String> allBTypes = <String>[];
  List<String> allFatherNames = <String>[];
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

  addDonation(
      String memberRecordId,
      String name,
      String age,
      String selectHospital,
      String selectDisease,
      String quarter,
      String township) {
    XataRepository()
        .uploadNewDonations(jsonEncode(<String, dynamic>{
      "patient_disease": diseaseController.text.toString(),
      "hospital": selectHospital,
      "patient_address": "$quarter၊$township",
      "patient_age": age,
      "patient_name": name,
      "date": donationDateDetail.toString(),
      "member": memberRecordId
    }))
        .then((value) {
      if (value.statusCode.toString().startsWith("2")) {
        setState(() {
          _isLoading = false;
        });
        Utils.messageSuccessDialog(
            "သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
            context,
            "အိုကေ",
            Colors.black);

        XataRepository().getDonationsTotal().then((value) {
          var newMemberCount = int.parse(
                  TotalDataResponse.fromJson(jsonDecode(value.body))
                      .records!
                      .first
                      .value
                      .toString()) +
              1;
          XataRepository().updateDonationsTotal(newMemberCount);
          int donationCount = 0;
          int totalCount = 0;
          for (var element in allMember) {
            if (element.id == memberRecordId) {
              donationCount = (element.donationCounts ?? 0) + 1;
              totalCount = (element.totalCount ?? 0) + 1;
            }
          }
          XataRepository()
              .updateMember(memberRecordId, donationCount, totalCount);
        });
      } else {
        log(value.statusCode.toString());
        log(value.body);
      }
    });
  }

  void initial() async {
    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }
    setState(() {
      _isLoading = true;
    });

    callAPI("");
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
        setState(() {
          _isLoading = false;
        });
        allMember.sort((a, b) => a.name!.compareTo(b.name!));
        for (var element in allMember) {
          allMembers.add(element.name!);
          allMemberIDs.add(element.id!);
          allBTypes.add(element.bloodType!);
          allFatherNames.add(element.fatherName!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    YYDialog.init(context);
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      child: Scaffold(
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
                      fontSize: Responsive.isMobile(context) ? 15 : 17,
                      color: Colors.white)),
            ),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isLoading,
          color: Colors.black,
          progressIndicator: const SpinKitCircle(
            color: Colors.white,
            size: 60.0,
          ),
          dismissible: false,
          child: SafeArea(
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
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TypeAheadField(
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: memberController,
                                      autofocus: false,
                                      decoration:
                                          inputBoxDecoration("လှူဒါန်းသူ"),
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      membersSelected.clear();
                                      membersSelected.addAll(allMembers);
                                      membersSelected.retainWhere((s) => s
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()));
                                      return membersSelected;
                                    },
                                    transitionBuilder:
                                        (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    itemBuilder: (context, suggestion) {
                                      var data = suggestion;
                                      String bloodType = "";
                                      String fatherName = "";
                                      for (var i = 0;
                                          i < allMembers.length;
                                          i++) {
                                        if (allMembers[i] == data) {
                                          bloodType = allBTypes[i];
                                          fatherName = allFatherNames[i];
                                        }
                                      }

                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(data.toString()),
                                            subtitle:
                                                Text("$bloodType  $fatherName"),
                                          ),
                                          const Divider(
                                            height: 1,
                                          ),
                                        ],
                                      );
                                    },
                                    errorBuilder:
                                        (BuildContext context, Object? error) =>
                                            Text('$error',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor)),
                                    onSuggestionSelected: (suggestion) {
                                      var data = suggestion;
                                      memberController.text = data.toString();
                                      for (var i = 0;
                                          i < allMembers.length;
                                          i++) {
                                        if (allMembers[i] == data) {
                                          setState(() {
                                            member_record_id = allMemberIDs[i];
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                Visibility(
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
                                Visibility(
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
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration:
                                          inputBoxDecoration("လူနာအသက်"),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TypeAheadField(
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
                                      hospitalsSelected.retainWhere((s) => s
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()));
                                      return hospitalsSelected;
                                    },
                                    transitionBuilder:
                                        (context, suggestionsBox, controller) {
                                      return suggestionsBox;
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        title: Text(
                                          suggestion.toString(),
                                          textScaleFactor: 1.0,
                                        ),
                                      );
                                    },
                                    errorBuilder:
                                        (BuildContext context, Object? error) =>
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
                                Visibility(
                                  visible: switchNew,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20,
                                        top: 16,
                                        bottom: 8,
                                        right: 20),
                                    child: TextFormField(
                                      controller: diseaseController,
                                      keyboardType: TextInputType.text,
                                      decoration: inputBoxDecoration(
                                          "ဖြစ်ပွားသည့်ရောဂါ"),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: switchNew,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 20,
                                        top: 16,
                                        bottom: 8,
                                        right: 20),
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
                                        left: 20,
                                        top: 16,
                                        bottom: 8,
                                        right: 20),
                                    child: TypeAheadField(
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        controller: townController,
                                        autofocus: false,
                                        decoration:
                                            inputBoxDecoration("မြို့နယ်"),
                                      ),
                                      suggestionsCallback: (pattern) {
                                        townshipsSelected.clear();
                                        townshipsSelected.addAll(townships);
                                        townshipsSelected.retainWhere((s) => s
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()));
                                        return townshipsSelected;
                                      },
                                      transitionBuilder: (context,
                                          suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      itemBuilder: (context, suggestion) {
                                        return ListTile(
                                          title: Text(
                                            suggestion.toString(),
                                            textScaleFactor: 1.0,
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
                                  if (member_record_id != "" &&
                                      donationDate !=
                                          "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    addDonation(
                                        member_record_id,
                                        nameController.text.toString(),
                                        ageController.text.toString(),
                                        hospitalController.text.toString(),
                                        diseaseController.text.toString(),
                                        quarterController.text.toString(),
                                        townController.text.toString());
                                  } else if (member_record_id == "") {
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

                                  // if (operatorImg == "") {
                                  //   Util.messageDialog("ဖုန်းနံပါတ် မှားယွင်းနေပါသည်",
                                  //       context, "ပြင်ဆင်မည်", Colors.black);
                                  // } else if (homeNo.text.toString() == "" ||
                                  //     street.text.toString() == "" ||
                                  //     quarter.text.toString() == "" ||
                                  //     town1.toString() == " ") {
                                  //   Util.messageDialog(
                                  //       "အချက်အလက်ပြည့်စုံစွာ ဖြည့်သွင်းပေးပါ",
                                  //       context,
                                  //       "ဖြည့်သွင်းမည်",
                                  //       Colors.black);
                                  // } else {

                                  // }
                                },
                                child: const Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                        padding:
                                            EdgeInsets.only(top: 8, bottom: 8),
                                        child: Text(
                                          "ထည့်သွင်းမည်",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white),
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
                                          textFieldConfiguration:
                                              TextFieldConfiguration(
                                            controller: memberController,
                                            autofocus: false,
                                            decoration: inputBoxDecoration(
                                                "လှူဒါန်းသူ"),
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            membersSelected.clear();
                                            membersSelected.addAll(allMembers);
                                            membersSelected.retainWhere((s) => s
                                                .toLowerCase()
                                                .contains(
                                                    pattern.toLowerCase()));
                                            return membersSelected;
                                          },
                                          transitionBuilder: (context,
                                              suggestionsBox, controller) {
                                            return suggestionsBox;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            var data = suggestion;
                                            String bloodType = "";
                                            String fatherName = "";
                                            for (var i = 0;
                                                i < allMembers.length;
                                                i++) {
                                              if (allMembers[i] == data) {
                                                bloodType = allBTypes[i];
                                                fatherName = allFatherNames[i];
                                              }
                                            }

                                            return Column(
                                              children: [
                                                ListTile(
                                                  title: Text(data.toString()),
                                                  subtitle: Text(
                                                      "$bloodType  $fatherName"),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                ),
                                              ],
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                                  Object? error) =>
                                              Text('$error',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .errorColor)),
                                          onSuggestionSelected: (suggestion) {
                                            var data = suggestion;
                                            memberController.text =
                                                data.toString();
                                            for (var i = 0;
                                                i < allMembers.length;
                                                i++) {
                                              if (allMembers[i] == data) {
                                                setState(() {
                                                  member_record_id =
                                                      allMemberIDs[i];
                                                });
                                              }
                                            }
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
                                            hospitalsSelected.retainWhere((s) =>
                                                s.toLowerCase().contains(
                                                    pattern.toLowerCase()));
                                            return hospitalsSelected;
                                          },
                                          transitionBuilder: (context,
                                              suggestionsBox, controller) {
                                            return suggestionsBox;
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(
                                                suggestion.toString(),
                                                textScaleFactor: 1.0,
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
                                              diseasesSelected.retainWhere(
                                                  (s) => s
                                                      .toLowerCase()
                                                      .contains(pattern
                                                          .toLowerCase()));
                                              return diseasesSelected;
                                            },
                                            transitionBuilder: (context,
                                                suggestionsBox, controller) {
                                              return suggestionsBox;
                                            },
                                            itemBuilder: (context, suggestion) {
                                              return ListTile(
                                                title: Text(
                                                  suggestion.toString(),
                                                  textScaleFactor: 1.0,
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
                                                textFieldConfiguration:
                                                    TextFieldConfiguration(
                                                  controller: townController,
                                                  autofocus: false,
                                                  decoration:
                                                      inputBoxDecoration(
                                                          "မြို့နယ်"),
                                                ),
                                                suggestionsCallback: (pattern) {
                                                  townshipsSelected.clear();
                                                  townshipsSelected
                                                      .addAll(townships);
                                                  townshipsSelected.retainWhere(
                                                      (s) => s
                                                          .toLowerCase()
                                                          .contains(pattern
                                                              .toLowerCase()));
                                                  return townshipsSelected;
                                                },
                                                transitionBuilder: (context,
                                                    suggestionsBox,
                                                    controller) {
                                                  return suggestionsBox;
                                                },
                                                itemBuilder:
                                                    (context, suggestion) {
                                                  return ListTile(
                                                    title: Text(
                                                      suggestion.toString(),
                                                      textScaleFactor: 1.0,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (BuildContext
                                                            context,
                                                        Object? error) =>
                                                    Text('$error',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .errorColor)),
                                                onSuggestionSelected:
                                                    (suggestion) {
                                                  townController.text =
                                                      suggestion.toString();
                                                  setRegion(
                                                      suggestion.toString());
                                                },
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: switchNew,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  left: 30,
                                                  bottom: 4,
                                                  right: 20),
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
                                  if (member_record_id != "" &&
                                      donationDate !=
                                          "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    addDonation(
                                        member_record_id,
                                        nameController.text.toString(),
                                        ageController.text.toString(),
                                        hospitalController.text.toString(),
                                        diseaseController.text.toString(),
                                        quarterController.text.toString(),
                                        townController.text.toString());
                                  } else if (member_record_id == "") {
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
                                        padding: EdgeInsets.only(
                                            top: 16, bottom: 16),
                                        child: Text(
                                          "ထည့်သွင်းမည်",
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white),
                                        ))),
                              ),
                            ))
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  showDatePicker() async {
    DateTime? newDateTime = await showRoundedDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 150),
        lastDate: DateTime(DateTime.now().year + 1),
        theme: ThemeData(primarySwatch: Colors.red),
        styleDatePicker: MaterialRoundedDatePickerStyle(
          textStyleDayButton:
              const TextStyle(fontSize: 20, color: Colors.white),
          textStyleYearButton: const TextStyle(
            fontSize: 22,
            color: Colors.white,
          ),
          textStyleDayHeader: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          textStyleCurrentDayOnCalendar: const TextStyle(
              fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleDayOnCalendar:
              const TextStyle(fontSize: 16, color: Colors.white),
          textStyleDayOnCalendarSelected: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleDayOnCalendarDisabled:
              TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.1)),
          textStyleMonthYearHeader: const TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          paddingMonthHeader: const EdgeInsets.all(16),
          paddingDateYearHeader: const EdgeInsets.all(20),
          sizeArrow: 28,
          colorArrowNext: Colors.white,
          colorArrowPrevious: Colors.white,
          marginLeftArrowPrevious: 4,
          marginTopArrowPrevious: 4,
          marginTopArrowNext: 4,
          marginRightArrowNext: 4,
          textStyleButtonAction:
              const TextStyle(fontSize: 28, color: Colors.white),
          textStyleButtonPositive: const TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          textStyleButtonNegative:
              TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
          decorationDateSelected:
              BoxDecoration(color: Colors.orange[600], shape: BoxShape.circle),
          backgroundPicker: Colors.red[400],
          backgroundActionBar: Colors.red[300],
          backgroundHeaderMonth: Colors.red[300],
        ),
        styleYearPicker: MaterialRoundedYearPickerStyle(
          textStyleYear: const TextStyle(fontSize: 20, color: Colors.white),
          textStyleYearSelected: const TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
          heightYearRow: 60,
          backgroundPicker: Colors.red[400],
        ));
    setState(() {
      String formattedDate = DateFormat('dd MMM yyyy').format(newDateTime!);
      donationDateDetail = newDateTime;
      donationDate = formattedDate;
      //DateTime.fromMillisecondsSinceEpoch(msIntFromServer)
    });
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
}
