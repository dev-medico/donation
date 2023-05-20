import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:donation/data/response/member_response.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MemberEditNewStyleScreen extends StatefulWidget {
  MemberData data;
  MemberEditNewStyleScreen({Key? key, required this.data}) : super(key: key);
  int selectedIndex = 0;

  @override
  MemberEditState createState() => MemberEditState(data);
}

class MemberEditState extends State<MemberEditNewStyleScreen> {
  MemberData data;
  MemberEditState(this.data);
  final nameController = TextEditingController();
  final fatherNameController = TextEditingController();
  final birthDateController = TextEditingController();
  final nrcController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodBankNoController = TextEditingController();
  final homeNoController = TextEditingController();
  final streetController = TextEditingController();
  final quarterController = TextEditingController();
  final noteController = TextEditingController();
  final townController = TextEditingController();
  final totalDonationController = TextEditingController();
  String birthDate = "မွေးသက္ကရာဇ်";
  bool isSwitched = false;
  String operatorImg = "";
  int id = 0;

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
  String selectedBloodType = "သွေးအုပ်စု";
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "သွေးအုပ်စု", child: Text("သွေးအုပ်စု")),
      const DropdownMenuItem(value: "A (Rh +)", child: Text("A (Rh +)")),
      const DropdownMenuItem(value: "B (Rh +)", child: Text("B (Rh +)")),
      const DropdownMenuItem(value: "O (Rh +)", child: Text("O (Rh +)")),
      const DropdownMenuItem(value: "AB (Rh +)", child: Text("AB (Rh +)")),
      const DropdownMenuItem(value: "A (Rh -)", child: Text("A (Rh -)")),
      const DropdownMenuItem(value: "B (Rh -)", child: Text("B (Rh -)")),
      const DropdownMenuItem(value: "O (Rh -)", child: Text("O (Rh -)")),
      const DropdownMenuItem(value: "AB (Rh -)", child: Text("AB (Rh -)")),
    ];
    return menuItems;
  }

  @override
  void initState() {
    super.initState();
    initial();
  }

  CollectionReference members =
      FirebaseFirestore.instance.collection('members');

  void initial() async {
    firestore = FirebaseFirestore.instance;

    nameController.text = data.name!;
    fatherNameController.text = data.fatherName!;
    nrcController.text = data.nrc!;
    phoneController.text = data.phone!;
    selectedBloodType = data.bloodType!;
    bloodBankNoController.text = data.bloodBankCard!;
    totalDonationController.text = data.totalCount.toString();
    homeNoController.text = data.address!.split(',')[0];
    streetController.text = data.address!.split(',')[1];
    quarterController.text = data.address!.split(',')[2];
    townController.text = data.address!.split(',')[3];
    setRegion(townController.text.toString());
    birthDate = data.birthDate!;

    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }

    phoneController.addListener(() {
      if (checkPhone(phoneController.text.toString()) == "Ooredoo") {
        setState(() {
          operatorImg = "assets/images/ooredoo_logo.svg";
        });
      } else if (checkPhone(phoneController.text.toString()) == "Telenor") {
        setState(() {
          operatorImg = "assets/images/telenor_logo.svg";
        });
      } else if (checkPhone(phoneController.text.toString()) == "Mytel") {
        setState(() {
          operatorImg = "assets/images/mytel_logo.svg";
        });
      } else if (checkPhone(phoneController.text.toString()) == "MEC") {
        setState(() {
          operatorImg = "assets/images/mec.svg";
        });
      } else if (checkPhone(phoneController.text.toString()) == "MPT") {
        setState(() {
          operatorImg = "assets/images/mpt_logo.svg";
        });
      } else {
        setState(() {
          operatorImg = "";
        });
      }
    });
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
          padding: const EdgeInsets.only(top: 4, right: 12),
          child: Center(
            child: Text("အဖွဲ့၀င်အချက်အလက် ပြင်ဆင်မည်",
                textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
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
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 24, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: inputBoxDecoration("အမည်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: fatherNameController,
                                    decoration: inputBoxDecoration("အဖအမည်"),
                                  ),
                                ),
                                Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(
                                        left: 20, top: 8, bottom: 4, right: 20),
                                    child: NeumorphicButton(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: birthDate == "မွေးသက္ကရာဇ်"
                                                ? 0
                                                : 6.0),
                                        child: Text(
                                          birthDate,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                      onPressed: () {
                                        showDatePicker();
                                      },
                                    )),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: nrcController,
                                    decoration:
                                        inputBoxDecoration("မှတ်ပုံတင်အမှတ်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: Stack(
                                    children: [
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: phoneController,
                                        decoration:
                                            inputBoxDecoration("ဖုန်းနံပါတ်"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, right: 20),
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: buildOperator()),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: DropdownButtonFormField(
                                      value: selectedBloodType,
                                      style: const TextStyle(
                                          fontSize: 13.5, color: Colors.black),
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        contentPadding: const EdgeInsets.only(
                                            left: 20, right: 12, bottom: 4),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedBloodType = val.toString();
                                        });
                                      },
                                      items: dropdownItems),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: bloodBankNoController,
                                    decoration:
                                        inputBoxDecoration("သွေးဘဏ်ကတ်နံပါတ်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: totalDonationController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputBoxDecoration(
                                        "သွေးလှူခဲ့သည့် ကြိမ်ရေစုစုပေါင်း"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: homeNoController,
                                    decoration: inputBoxDecoration(
                                        "အိမ်အမှတ်/တိုက်ခန်းအမှတ်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: streetController,
                                    decoration: inputBoxDecoration("လမ်းအမည်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TextFormField(
                                    controller: quarterController,
                                    decoration:
                                        inputBoxDecoration("ရပ်ကွက်အမည်"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  child: TypeAheadField(
                                    hideSuggestionsOnKeyboardHide: false,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: townController,
                                      autofocus: false,
                                      decoration:
                                          inputBoxDecoration("မြို့နယ်"),

                                      // decoration: const InputDecoration(
                                      //   hintText: "မြို့",
                                      //   border: InputBorder.none,
                                      //   focusedBorder: InputBorder.none,
                                      //   enabledBorder: InputBorder.none,
                                      //   errorBorder: InputBorder.none,
                                      //   disabledBorder: InputBorder.none,
                                      //   contentPadding:  EdgeInsets.only(
                                      //       left: 15, bottom: 8, top: 8, right: 15),
                                      //   hintStyle:  TextStyle(
                                      //       fontSize: 15.0, color: Colors.grey),
                                      // ),
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
                                                        .colorScheme
                                                        .error)),
                                    onSuggestionSelected: (suggestion) {
                                      townController.text =
                                          suggestion.toString();
                                      setRegion(suggestion.toString());
                                    },
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 30, bottom: 4, right: 20),
                                  child: Text(regional,
                                      textScaleFactor: 1.0,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor)),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, bottom: 8, right: 20),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFefefef),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0))),
                                  child: TextFormField(
                                      controller: noteController,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        hintText: "မှတ်ချက်ရေးမည်",
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 15,
                                            bottom: 8,
                                            top: 8,
                                            right: 15),
                                        hintStyle: TextStyle(
                                            fontSize: 15.0, color: Colors.grey),
                                      )),
                                ),
                              ],
                            ),
                          )),
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
                                if (nameController.text.isNotEmpty &&
                                    fatherNameController.text.isNotEmpty &&
                                    nrcController.text.isNotEmpty &&
                                    phoneController.text.isNotEmpty &&
                                    selectedBloodType != "သွေးအုပ်စု") {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  getAutoIncrementKey(data.memberId!);
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
                              top: 20,
                              bottom: 20,
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: Container(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 4, right: 4, top: 8),
                            decoration: shadowDecoration(Colors.white),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 24,
                                            bottom: 8,
                                            right: 20),
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration:
                                              inputBoxDecoration("အမည်"),
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
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: TextFormField(
                                          controller: fatherNameController,
                                          decoration:
                                              inputBoxDecoration("အဖအမည်"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: DropdownButtonFormField(
                                            value: selectedBloodType,
                                            style: const TextStyle(
                                                fontSize: 13.5,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 20,
                                                      right: 12,
                                                      bottom: 4),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            onChanged: (val) {
                                              setState(() {
                                                selectedBloodType =
                                                    val.toString();
                                              });
                                            },
                                            items: dropdownItems),
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
                                        child: TextFormField(
                                          controller: nrcController,
                                          decoration: inputBoxDecoration(
                                              "မှတ်ပုံတင်အမှတ်"),
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
                                        width: double.infinity,
                                        height: 50,
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 4,
                                            right: 20),
                                        child: NeumorphicButton(
                                          child: Text(
                                            birthDate,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {
                                            showDatePicker();
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: Stack(
                                          children: [
                                            TextFormField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: phoneController,
                                              decoration: inputBoxDecoration(
                                                  "ဖုန်းနံပါတ်"),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, right: 20),
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: buildOperator()),
                                            )
                                          ],
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
                                        child: TextFormField(
                                          controller: bloodBankNoController,
                                          decoration: inputBoxDecoration(
                                              "သွေးဘဏ်ကတ်နံပါတ်"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: TextFormField(
                                          controller: totalDonationController,
                                          keyboardType: TextInputType.number,
                                          decoration: inputBoxDecoration(
                                              "သွေးလှူခဲ့သည့် ကြိမ်ရေစုစုပေါင်း"),
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
                                        child: TextFormField(
                                          controller: homeNoController,
                                          decoration: inputBoxDecoration(
                                              "အိမ်အမှတ်/တိုက်ခန်းအမှတ်"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: TextFormField(
                                          controller: streetController,
                                          decoration:
                                              inputBoxDecoration("လမ်းအမည်"),
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20,
                                            top: 16,
                                            bottom: 8,
                                            right: 20),
                                        child: TextFormField(
                                          controller: quarterController,
                                          decoration:
                                              inputBoxDecoration("ရပ်ကွက်အမည်"),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20,
                                                top: 16,
                                                bottom: 8,
                                                right: 20),
                                            child: TypeAheadField(
                                              hideSuggestionsOnKeyboardHide:
                                                  false,
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
                                                                  .colorScheme
                                                                  .error)),
                                              onSuggestionSelected:
                                                  (suggestion) {
                                                townController.text =
                                                    suggestion.toString();
                                                setRegion(
                                                    suggestion.toString());
                                              },
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 30, bottom: 4, right: 20),
                                            child: Text(regional,
                                                textScaleFactor: 1.0,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: primaryColor)),
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
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  margin: const EdgeInsets.only(
                                      left: 20, bottom: 8, right: 20),
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFefefef),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0))),
                                  child: TextFormField(
                                      controller: noteController,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                        hintText: "မှတ်ချက်ရေးမည်",
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            left: 24,
                                            bottom: 8,
                                            top: 20,
                                            right: 15),
                                        hintStyle: TextStyle(
                                            fontSize: 16.0, color: Colors.grey),
                                      )),
                                ),
                              ],
                            ),
                          )),
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
                                if (nameController.text.isNotEmpty &&
                                    fatherNameController.text.isNotEmpty &&
                                    nrcController.text.isNotEmpty &&
                                    phoneController.text.isNotEmpty &&
                                    selectedBloodType != "သွေးအုပ်စု") {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  getAutoIncrementKey(data.memberId!);
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
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16),
                                      child: Text(
                                        "ပြင်ဆင်မည်",
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                            fontSize: 18.0,
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

  getAutoIncrementKey(String memberId) {
    setState(() {
      _isLoading = true;
    });
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('members').doc(memberId);

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      // Perform an update on the document
      transaction.update(documentReference, {
        'member_id': memberId,
        'name': nameController.text.toString(),
        'father_name': fatherNameController.text.toString(),
        'birth_date': birthDate != "မွေးသက္ကရာဇ်" ? birthDate : "-",
        'nrc': nrcController.text.toString() != ""
            ? nrcController.text.toString()
            : "-",
        'phone': phoneController.text.toString(),
        'blood_type': selectedBloodType,
        'blood_bank_card': bloodBankNoController.text.toString() != ""
            ? bloodBankNoController.text.toString()
            : "-",
        'total_count': totalDonationController.text.toString() != ""
            ? totalDonationController.text.toString()
            : "0",
        'note': noteController.text.toString() != ""
            ? noteController.text.toString()
            : "-",
        'home_no': homeNoController.text.toString(),
        'street': streetController.text.toString(),
        'quarter': quarterController.text.toString(),
        'town': townController.text.toString(),
        'region': region1,
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
      fatherNameController.clear();
      nrcController.clear();
      phoneController.clear();
      selectedBloodType = "သွေးအုပ်စု";
      bloodBankNoController.clear();
      totalDonationController.clear();
      homeNoController.clear();
      streetController.clear();
      quarterController.clear();
      townController.clear();
      region1 = "";
      regional = "";
      noteController.clear();
    }).catchError((error) => print("Failed to update Member: $error"));
  }

  showDatePicker() async {
    Utils.showCupertinoDatePicker(
      context,
      (DateTime newDateTime) {
        setState(() {
          String formattedDate = DateFormat('dd MMM yyyy').format(newDateTime);
          birthDate = formattedDate;
        });
      },
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
}
