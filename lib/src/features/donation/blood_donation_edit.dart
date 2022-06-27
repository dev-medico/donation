import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:merchant/data/response/member_response.dart';
import 'package:merchant/data/response/township_response/datum.dart';
import 'package:merchant/data/response/township_response/township_response.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:merchant/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class BloodDonationEditScreen extends StatefulWidget {
  String doc_id;
  Map<String, dynamic> data;
  BloodDonationEditScreen({Key? key, required this.data, required this.doc_id})
      : super(key: key);
  int selectedIndex = 0;

  @override
  BloodDonationEditState createState() => BloodDonationEditState(data, doc_id);
}

class BloodDonationEditState extends State<BloodDonationEditScreen> {
  Map<String, dynamic> data;
  String doc_id;
  BloodDonationEditState(this.data, this.doc_id);
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final quarterController = TextEditingController();
  final townController = TextEditingController();
  final hospitalController = TextEditingController();
  final diseaseController = TextEditingController();
  String operatorImg = "";
  String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";

  String region1 = " ";
  String town1 = " ";
  String township1 = " ";
  String township1ID = " ";
  String regional = " ";
  String post_code = " ";
  bool _isLoading = false;
  late FirebaseFirestore firestore;
  late TownshipResponse townshipResponse;
  List<String> townships = <String>[];
  List<String> townshipsSelected = <String>[];
  List<Datum> datas = <Datum>[];
  bool switchNew = true;
  DateTime? donationDateDetail;

  List<String> hospitalsSelected = <String>[];
  List<String> hospitals = <String>[
    "ဆေးရုံကြီး",
    "အမေရိကန်ဆေးရုံ",
    "ငွေမိုး",
    "ဇာနည်ဘွား",
    "တော်ဝင်",
    "ရတနာမွန်",
    "အေးသန္တာ",
    "အရေပြားဆေးရုံ",
    "ရွှေလမင်း",
    "ဇာနည်အောင်",
  ];

  List<String> diseasesSelected = <String>[];
  List<String> diseases = <String>[
    "သွေးအားနည်းရောဂါ"
        "အစာအိမ်သွေးယို",
    "အူမကြီးကင်ဆာ"
        "သွေးကင်ဆာ",
    "ဆီးချို/သွေးတိုး",
    "(---)ကင်ဆာ",
    "မတော်တဆဖြစ်စဥ်",
    "(---)ခွဲစိတ်",
    "ဓမ္မတာသွေးဆင်းများ",
    "ကိုယ်ဝန်ပျက်ကျသွေးဆင်းများ"
  ];

  @override
  void initState() {
    super.initState();
    print("Doc ID - " + doc_id);
    initial();
  }

  Future<void> editDonation(String name, String age, String selectHospital,
      String selectDisease, String quarter, String township) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('blood_donations').doc(doc_id);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      // Perform an update on the document
      transaction.update(documentReference, {
        'patient_name': name,
        'patient_age': age,
        'date': donationDate,
        'day': int.parse(donationDate.split(' ')[0]),
        'month': donationDate.split(' ')[1],
        'year': int.parse(donationDate.split(' ')[2]),
        'date_detail': donationDateDetail,
        'hospital': selectHospital,
        'patient_disease': diseaseController.text.toString(),
        'member_name': data['member_name'],
        'member_id': data['member_id'],
        'member_blood_type': data['member_blood_type'],
        'member_blood_bank_card': data['member_blood_bank_card'],
        'member_birth_date': data['member_birth_date'],
        'member_father_name': data['member_father_name'],
        'patient_address': quarter + "၊" + township,
      });

      // Return the new count
      return true;
    }).then((value) {
      print("Member updated to $value");
      setState(() {
        _isLoading = false;
      });
      Utils.messageSuccessDialog("အချက်အလက်ပြင်ဆင်ခြင်း \nအောင်မြင်ပါသည်။",
          context, "အိုကေ", Colors.black);
      nameController.clear();
      ageController.clear();
      diseaseController.clear();
      hospitalController.clear();
      quarterController.clear();
      townController.clear();
      region1 = "";
      regional = "";
    }).catchError((error) => print("Failed to update Member: $error"));
  }

  void initial() async {
    firestore = FirebaseFirestore.instance;

    nameController.text = data['patient_name'];
    ageController.text = data['patient_age'];
    quarterController.text = data['patient_address'].split("၊")[0] ?? "";
    townController.text = data['patient_address'].split("၊")[1] ?? "";
    hospitalController.text = data['hospital'];
    diseaseController.text = data['patient_disease'];
    donationDate = data['date'];
    setRegion(townController.text.toString());
    if (data['patient_name'] == null || data['patient_name'] == "") {
      setState(() {
        switchNew = false;
      });
    }

    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: Text("သွေးလှူဒါန်းမှုအချက်အလက် ပြင်ဆင်မည်",
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
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: const Text(
                                  "သွေးလှူဒါန်းသူ အမည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 4, right: 20),
                                child: Text(
                                  data['member_name'] +
                                      " (  " +
                                      data['member_id'] +
                                      "  )",
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, right: 20),
                                child: const Text(
                                  "လှူဒါန်းသည့် ရက်စွဲ",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 50,
                                margin: const EdgeInsets.only(
                                    left: 20, top: 8, bottom: 14, right: 20),
                                child: NeumorphicButton(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      donationDate,
                                      style: TextStyle(
                                          fontSize: 14, color: primaryColor),
                                    ),
                                  ),
                                  onPressed: () {
                                    showDatePicker();
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
                                    decoration: inputBoxDecoration("လူနာအသက်"),
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
                                    decoration:
                                        inputBoxDecoration("လှူဒါန်းသည့်နေရာ"),
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
                              Visibility(
                                visible: switchNew,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
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
                                      diseasesSelected.retainWhere((s) => s
                                          .toLowerCase()
                                          .contains(pattern.toLowerCase()));
                                      return diseasesSelected;
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
                                      diseaseController.text =
                                          suggestion.toString();
                                    },
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
                                if (donationDate !=
                                    "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  editDonation(
                                      nameController.text.toString(),
                                      ageController.text.toString(),
                                      hospitalController.text.toString(),
                                      diseaseController.text.toString(),
                                      quarterController.text.toString(),
                                      townController.text.toString());
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
                                        "ပြင်ဆင်မည်",
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
                            top: 24,
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
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 16, right: 20, bottom: 12),
                                child: const Text(
                                  "သွေးလှူဒါန်းသူ အမည်",
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 20, top: 4, right: 20),
                                child: Text(
                                  data['member_name'] +
                                      " (  " +
                                      data['member_id'] +
                                      "  )",
                                  textScaleFactor: 1.0,
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20,
                                              top: 16,
                                              right: 20,
                                              bottom: 12),
                                          child: const Text(
                                            "လှူဒါန်းသည့် ရက်စွဲ",
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                              left: 20,
                                              top: 8,
                                              bottom: 14,
                                              right: 20),
                                          child: NeumorphicButton(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 6.0),
                                              child: Text(
                                                donationDate,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: primaryColor),
                                              ),
                                            ),
                                            onPressed: () {
                                              showDatePicker();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(),
                                  )
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
                                          hospitalsSelected.retainWhere((s) => s
                                              .toLowerCase()
                                              .contains(pattern.toLowerCase()));
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
                                            diseasesSelected.retainWhere((s) =>
                                                s.toLowerCase().contains(
                                                    pattern.toLowerCase()));
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
                                                decoration: inputBoxDecoration(
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
                                                  suggestionsBox, controller) {
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
                                                          color:
                                                              Theme.of(context)
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
                                if (donationDate !=
                                    "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  editDonation(
                                      nameController.text.toString(),
                                      ageController.text.toString(),
                                      hospitalController.text.toString(),
                                      diseaseController.text.toString(),
                                      quarterController.text.toString(),
                                      townController.text.toString());
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
                                          EdgeInsets.only(top: 16, bottom: 16),
                                      child: Text(
                                        "ပြင်ဆင်မည်",
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
      donationDate = formattedDate;
      donationDateDetail = newDateTime;
    });
  }

  void setRegion(String township) {
    townController.text = township;

    for (var element in datas) {
      if (element.township == township) {
        setState(() {
          regional = element.town! + ", " + element.region!;
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
