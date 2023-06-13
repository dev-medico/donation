import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/src/providers/providers.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:intl/intl.dart';

class NewMemberScreen extends ConsumerStatefulWidget {
  NewMemberScreen({Key? key}) : super(key: key);
  int selectedIndex = 0;

  @override
  NewMemberState createState() => NewMemberState();
}

class NewMemberState extends ConsumerState<NewMemberScreen> {
  final memberIDController = TextEditingController();
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

  String MIN_DATETIME = '1900-01-01';
  String MAX_DATETIME = '2020-01-01';
  String INIT_DATETIME = '2019-05-17';

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
  //late FirebaseFirestore firestore;
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

  List<DropdownMenuItem<String>>? nrc_initial_options_dropDownMenuItems;
  String? nrc_initial_options_Value;
  List<DropdownMenuItem<String>>? nrc_region_state_options_dropDownMenuItems;
  String? nrc_region_state_options_Value;
  List nrc_type_options = ["နိုင်", "ဧည့်", "ပြု"];
  List<DropdownMenuItem<String>>? nrc_type_options_dropDownMenuItems;
  String? nrc_type_options_Value;
  bool nameChecked = false;
  bool editable = true;
  DateTime? selected;

  @override
  void initState() {
    super.initState();
    initial();
    nrc_initial_options_dropDownMenuItems =
        getNrcNationalOptionDropDownMenuItems();
    nrc_initial_options_Value = nrc_initial_options_dropDownMenuItems![0].value;

    nrc_type_options_dropDownMenuItems = getNrcTypeOptionDropDownMenuItems();
    nrc_type_options_Value = nrc_type_options_dropDownMenuItems![0].value;

    //region state
    nrc_region_state_options_dropDownMenuItems =
        getNrcRegionStateOptionDropDownMenuItems(kachin);
    nrc_region_state_options_Value =
        nrc_region_state_options_dropDownMenuItems![0].value;
  }

  void initial() async {
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
          padding: const EdgeInsets.only(top: 4),
          child: Center(
            child: Text("အဖွဲ့၀င်အသစ် ထည့်သွင်းမည်",
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
                              Visibility(
                                visible: editable,
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 20, top: 16, right: 20),
                                  child: TextFormField(
                                    controller: memberIDController,
                                    decoration:
                                        inputBoxDecoration("အဖွဲ့ဝင်အမှတ်"),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        left: 20,
                                        top: 24,
                                        bottom: 8,
                                      ),
                                      child: TextFormField(
                                        controller: nameController,
                                        decoration: inputBoxDecoration("အမည်"),
                                      ),
                                    ),
                                  ),
                                  nameChecked
                                      ? Expanded(
                                          flex: 1,
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16, right: 4),
                                              child: Image.asset(
                                                "assets/images/checked.png",
                                                height: 24,
                                                width: 20,
                                              )))
                                      : Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              // FirebaseFirestore.instance
                                              //     .collection('members')
                                              //     .where('name',
                                              //         isEqualTo:
                                              //             nameController.text
                                              //                 .toString())
                                              //     .get()
                                              //     .then((value) {
                                              //   if (value.docs.isEmpty) {
                                              //     setState(() {
                                              //       nameChecked = true;
                                              //     });
                                              //   } else {
                                              //     Map<String, dynamic> data =
                                              //         value.docs.first.data();
                                              //     memberExistDialog(
                                              //         context,
                                              //         nameController.text
                                              //             .toString(),
                                              //         data);
                                              //   }
                                              // });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16, right: 4),
                                              child: Image.asset(
                                                "assets/images/magnifier.png",
                                                height: 24,
                                                width: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
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
                                        borderRadius: BorderRadius.circular(12),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 12, left: 22),
                                    child: const Text(
                                      "မှတ်ပုံတင်အမှတ်",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 20, right: 20, top: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration:
                                              shadowDecoration(Colors.white),
                                          child: DropdownButton(
                                            value: nrc_initial_options_Value,
                                            items:
                                                nrc_initial_options_dropDownMenuItems,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            iconSize: 0,
                                            elevation: 16,
                                            underline: const SizedBox(),
                                            onChanged:
                                                nrcInitialOptionschangedDropDownItem,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: const Text(
                                            "/",
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration:
                                              shadowDecoration(Colors.white),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8),
                                              child: DropdownButton(
                                                value:
                                                    nrc_region_state_options_Value,
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),
                                                iconSize: 0,
                                                elevation: 16,
                                                underline: const SizedBox(),
                                                items:
                                                    nrc_region_state_options_dropDownMenuItems,
                                                onChanged:
                                                    nrcInitialRegionStateOptionschangedDropDownItem,
                                              )),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          decoration:
                                              shadowDecoration(Colors.white),
                                          child: DropdownButton(
                                            value: nrc_type_options_Value,
                                            items:
                                                nrc_type_options_dropDownMenuItems,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_down),
                                            iconSize: 0,
                                            elevation: 16,
                                            underline: const SizedBox(),
                                            onChanged:
                                                nrcTypeOptionschangedDropDownItem,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 48,
                                            margin:
                                                const EdgeInsets.only(left: 12),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color(0xffecf0f1),
                                            ),
                                            child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: nrcController,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 24, top: 12, bottom: 12),
                                child: fluent.DatePicker(
                                  header: 'မွေးသက္ကရာဇ်ရွေးချယ်မည်',
                                  headerStyle: TextStyle(fontSize: 15),
                                  selected: selected,
                                  onChanged: (time) => setState(() {
                                    String formattedDate =
                                        DateFormat('dd MMM yyyy').format(time);
                                    birthDate = formattedDate;
                                  }),
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
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
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
                                  decoration: inputBoxDecoration("ရပ်ကွက်အမည်"),
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

                                    decoration: inputBoxDecoration("မြို့နယ်"),

                                    // decoration:  InputDecoration(
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
                                  phoneController.text.isNotEmpty &&
                                  selectedBloodType != "သွေးအုပ်စု") {
                                var members = ref.watch(membersProvider);
                                //check member exist by name, father name and nrc
                                var exist = members
                                    .where((element) =>
                                        element.name ==
                                            nameController.text.toString() &&
                                        element.fatherName ==
                                            fatherNameController.text
                                                .toString() &&
                                        element.bloodType == selectedBloodType)
                                    .toList()
                                    .isNotEmpty;

                                if (!exist) {
                                  getAutoIncrementKey();
                                } else {
                                  var data = members
                                      .where((element) =>
                                          element.name ==
                                              nameController.text.toString() &&
                                          element.fatherName ==
                                              fatherNameController.text
                                                  .toString() &&
                                          element.bloodType ==
                                              selectedBloodType)
                                      .toList()
                                      .first;
                                  memberExistDialog(context, data);
                                }
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
                                    child: Visibility(
                                      visible: editable,
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 20, top: 16, right: 20),
                                        child: TextFormField(
                                          controller: memberIDController,
                                          decoration: inputBoxDecoration(
                                              "အဖွဲ့ဝင်အမှတ်"),
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
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              left: 20,
                                              top: 24,
                                              bottom: 8,
                                            ),
                                            child: TextFormField(
                                              controller: nameController,
                                              decoration:
                                                  inputBoxDecoration("အမည်"),
                                            ),
                                          ),
                                        ),
                                        nameChecked
                                            ? Expanded(
                                                flex: 1,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16, right: 4),
                                                    child: Image.asset(
                                                      "assets/images/checked.png",
                                                      height: 24,
                                                      width: 20,
                                                    )))
                                            : Expanded(
                                                flex: 1,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  onTap: () {
                                                    // FirebaseFirestore.instance
                                                    //     .collection('members')
                                                    //     .where('name',
                                                    //         isEqualTo:
                                                    //             nameController
                                                    //                 .text
                                                    //                 .toString())
                                                    //     .get()
                                                    //     .then((value) {
                                                    //   if (value
                                                    //       .docs.isEmpty) {
                                                    //     setState(() {
                                                    //       nameChecked = true;
                                                    //     });
                                                    //   } else {
                                                    //     Map<String, dynamic>
                                                    //         data = value
                                                    //             .docs.first
                                                    //             .data();
                                                    //     memberExistDialog(
                                                    //         context,
                                                    //         nameController
                                                    //             .text
                                                    //             .toString(),
                                                    //         data);
                                                    //   }
                                                    // });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16, right: 4),
                                                    child: Image.asset(
                                                      "assets/images/magnifier.png",
                                                      height: 24,
                                                      width: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ],
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
                                                  color: Colors.grey, width: 1),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              top: 12, left: 22),
                                          child: const Text(
                                            "မှတ်ပုံတင်အမှတ်",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 20, right: 20, top: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: shadowDecoration(
                                                    Colors.white),
                                                child: DropdownButton(
                                                  value:
                                                      nrc_initial_options_Value,
                                                  items:
                                                      nrc_initial_options_dropDownMenuItems,
                                                  icon: const Icon(Icons
                                                      .keyboard_arrow_down),
                                                  iconSize: 0,
                                                  elevation: 16,
                                                  underline: const SizedBox(),
                                                  onChanged:
                                                      nrcInitialOptionschangedDropDownItem,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 8, right: 8),
                                                child: const Text(
                                                  "/",
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                decoration: shadowDecoration(
                                                    Colors.white),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8, right: 8),
                                                    child: DropdownButton(
                                                      value:
                                                          nrc_region_state_options_Value,
                                                      icon: const Icon(Icons
                                                          .keyboard_arrow_down),
                                                      iconSize: 0,
                                                      elevation: 16,
                                                      underline:
                                                          const SizedBox(),
                                                      items:
                                                          nrc_region_state_options_dropDownMenuItems,
                                                      onChanged:
                                                          nrcInitialRegionStateOptionschangedDropDownItem,
                                                    )),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                decoration: shadowDecoration(
                                                    Colors.white),
                                                child: DropdownButton(
                                                  value: nrc_type_options_Value,
                                                  items:
                                                      nrc_type_options_dropDownMenuItems,
                                                  icon: const Icon(Icons
                                                      .keyboard_arrow_down),
                                                  iconSize: 0,
                                                  elevation: 16,
                                                  underline: const SizedBox(),
                                                  onChanged:
                                                      nrcTypeOptionschangedDropDownItem,
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: 48,
                                                  margin: const EdgeInsets.only(
                                                      left: 12),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color:
                                                        const Color(0xffecf0f1),
                                                  ),
                                                  child: TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: nrcController,
                                                    decoration:
                                                        const InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                      margin: EdgeInsets.only(
                                          left: 24, top: 12, bottom: 12),
                                      child: fluent.DatePicker(
                                        header: 'မွေးသက္ကရာဇ်ရွေးချယ်မည်',
                                        headerStyle: TextStyle(fontSize: 15),
                                        selected: selected,
                                        onChanged: (time) => setState(() {
                                          String formattedDate =
                                              DateFormat('dd MMM yyyy')
                                                  .format(time);
                                          birthDate = formattedDate;
                                        }),
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
                                            keyboardType: TextInputType.number,
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
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
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
                                    left: 20, top: 4, bottom: 8, right: 20),
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12.0))),
                        width: MediaQuery.of(context).size.width / 2.8,
                        margin: const EdgeInsets.only(
                            left: 54, bottom: 16, right: 8),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (nameController.text.isNotEmpty &&
                                fatherNameController.text.isNotEmpty &&
                                phoneController.text.isNotEmpty &&
                                selectedBloodType != "သွေးအုပ်စု") {
                              var members = ref.watch(membersProvider);
                              //check member exist by name, father name and nrc
                              var exist = members
                                  .where((element) =>
                                      element.name ==
                                          nameController.text.toString() &&
                                      element.fatherName ==
                                          fatherNameController.text
                                              .toString() &&
                                      element.bloodType == selectedBloodType)
                                  .toList()
                                  .isNotEmpty;

                              if (!exist) {
                                getAutoIncrementKey();
                              } else {
                                var data = members
                                    .where((element) =>
                                        element.name ==
                                            nameController.text.toString() &&
                                        element.fatherName ==
                                            fatherNameController.text
                                                .toString() &&
                                        element.bloodType == selectedBloodType)
                                    .toList()
                                    .first;
                                memberExistDialog(context, data);
                              }
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
                                        fontSize: 16, color: Colors.white),
                                  ))),
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  static YYDialog memberExistDialog(BuildContext context, Member data) {
    return YYDialog().build()
      ..width = MediaQuery.of(context).size.width - 60
      ..backgroundColor = Colors.white
      ..borderRadius = 20.0
      ..showCallBack = () {}
      ..dismissCallBack = () {}
      ..widget(Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            "assets/images/list_exist.png",
            height: 50,
            width: 50,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(5, 24, 0, 12),
            child: const Text(
              "အဖွဲ့ဝင် ရှိပြီသားဖြစ်ပါသည်။",
              textAlign: TextAlign.center,
              maxLines: 4,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.normal,
                  color: Colors.red),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  flex: 4,
                  child: Text("အမည်",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 116, 112, 112))),
                ),
                const Text("-",
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    data.name.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  flex: 4,
                  child: Text("အဖအမည်",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 116, 112, 112))),
                ),
                const Text("-",
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    data.fatherName.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  flex: 4,
                  child: Text("မွေးသက္ကရာဇ်",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 116, 112, 112))),
                ),
                const Text("-",
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    data.birthDate.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  flex: 4,
                  child: Text("နိုင်ငံသားစီစစ်ရေး\nကတ်ပြားအမှတ်",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 116, 112, 112))),
                ),
                const Text("-",
                    style: TextStyle(fontSize: 14, color: Colors.black)),
                const SizedBox(
                  width: 24,
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    data.nrc.toString(),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ))
      ..widget(Padding(
        padding:
            const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 30),
        child: MaterialButton(
            padding: const EdgeInsets.all(12.0),
            textColor: Colors.white,
            splashColor: primaryColor,
            color: primaryColor,
            elevation: 2.0,
            minWidth: 155,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => MemberDetailScreen(data: data),
              //   ),
              // );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text("အသေးစိတ်ကြည့်မည်",
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white))
                  ]),
            )),
      ))
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
          child: child,
        );
      }
      ..show();
  }

  getAutoIncrementKey() {
    if (editable && memberIDController.text.toString().isNotEmpty) {
      if (memberIDController.text.toString().contains("-") &&
          memberIDController.text.toString().length == 6) {
        DateTime dt = DateTime.parse('2010-01-01 12:00:00');
        ref.watch(realmProvider)!.createMember(
              memberId: memberIDController.text.toString(),
              name: nameController.text.toString(),
              fatherName: fatherNameController.text.toString(),
              birthDate: birthDate != "မွေးသက္ကရာဇ်" ? birthDate : "-",
              nrc: _getCompletNrcInfo() != "" ? _getCompletNrcInfo() : "-",
              phone: phoneController.text.toString(),
              lastDate: dt,
              bloodType: selectedBloodType,
              bloodBankCard: bloodBankNoController.text.toString() != ""
                  ? bloodBankNoController.text.toString()
                  : "-",
              totalCount: totalDonationController.text.toString(),
              memberCount: "0",
              registerDate: DateTime.now(),
              status: "available",
              address: homeNoController.text.toString() +
                  " ၊ " +
                  streetController.text.toString() +
                  " ၊ " +
                  quarterController.text.toString() +
                  " ၊ " +
                  townController.text.toString(),
              note: noteController.text.toString(),
            );
        Utils.messageSuccessDialog("အချက်အလက်ထည့်သွင်းခြင်း \nအောင်မြင်ပါသည်။",
            context, "အိုကေ", Colors.black);
      } else {
        Utils.messageDialog("အဖွဲ့ဝင်အမှတ် မှားယွင်းနေပါသည်", context,
            "ပြင်ဆင်မည်", Colors.black);
      }
    } else {
      // DocumentReference documentReference = FirebaseFirestore.instance
      //     .collection('member_count')
      //     .doc("increment");

      // return FirebaseFirestore.instance
      //     .runTransaction((transaction) async {
      //       // Get the document
      //       DocumentSnapshot snapshot =
      //           await transaction.get(documentReference);

      //       int newCount = 0;
      //       if (!snapshot.exists) {
      //         newCount = 1;
      //       } else {
      //         print(snapshot.data());
      //         Map<String, dynamic> data =
      //             snapshot.data()! as Map<String, dynamic>;
      //         print(data);
      //         newCount = int.parse(data['count'].toString()) + 1;
      //       }
      //       // Perform an update on the document
      //       transaction.update(documentReference, {'count': newCount});
      //       setState(() {
      //         id = newCount;
      //       });

      //       NumberFormat formatter = NumberFormat("0000");
      //       String memberId = "";
      //       if (id <= 1000) {
      //         memberId = "A-${formatter.format(id)}";
      //       } else if (id <= 2000) {
      //         memberId = "B-${formatter.format((id - 1000))}";
      //       } else if (id <= 3000) {
      //         memberId = "C-${formatter.format((id - 2000))}";
      //       } else if (id <= 4000) {
      //         memberId = "D-${formatter.format((id - 3000))}";
      //       } else if (id <= 5000) {
      //         memberId = "E-${formatter.format((id - 4000))}";
      //       } else if (id <= 6000) {
      //         memberId = "F-${formatter.format((id - 5000))}";
      //       } else if (id <= 7000) {
      //         memberId = "G-${formatter.format((id - 6000))}";
      //       } else if (id <= 8000) {
      //         memberId = "H-${formatter.format((id - 7000))}";
      //       } else if (id <= 9000) {
      //         memberId = "I-${formatter.format((id - 8000))}";
      //       } else if (id <= 10000) {
      //         memberId = "J-${formatter.format((id - 9000))}";
      //       } else if (id <= 11000) {
      //         memberId = "K-${formatter.format((id - 10000))}";
      //       } else if (id <= 12000) {
      //         memberId = "L-${formatter.format((id - 11000))}";
      //       } else if (id <= 13000) {
      //         memberId = "M-${formatter.format((id - 12000))}";
      //       } else if (id <= 14000) {
      //         memberId = "N-${formatter.format((id - 13000))}";
      //       } else if (id <= 15000) {
      //         memberId = "O-${formatter.format((id - 14000))}";
      //       } else if (id <= 16000) {
      //         memberId = "P-${formatter.format((id - 15000))}";
      //       } else if (id <= 17000) {
      //         memberId = "Q-${formatter.format((id - 16000))}";
      //       } else if (id <= 18000) {
      //         memberId = "R-${formatter.format((id - 17000))}";
      //       } else if (id <= 19000) {
      //         memberId = "S-${formatter.format((id - 18000))}";
      //       } else if (id <= 20000) {
      //         memberId = "T-${formatter.format((id - 19000))}";
      //       } else if (id <= 21000) {
      //         memberId = "U-${formatter.format((id - 20000))}";
      //       } else if (id <= 22000) {
      //         memberId = "V-${formatter.format((id - 21000))}";
      //       } else if (id <= 23000) {
      //         memberId = "W-${formatter.format((id - 22000))}";
      //       } else if (id <= 24000) {
      //         memberId = "X-${formatter.format((id - 23000))}";
      //       } else if (id <= 25000) {
      //         memberId = "Y-${formatter.format((id - 24000))}";
      //       } else if (id <= 26000) {
      //         memberId = "Z-${formatter.format((id - 25000))}";
      //       }

      //       MemberService(MemberRepository(ref)).addMember(
      //         memberIDController.text.toString(),
      //         nameController.text.toString(),
      //         fatherNameController.text.toString(),
      //         birthDate != "မွေးသက္ကရာဇ်" ? birthDate : "-",
      //         _getCompletNrcInfo() != "" ? _getCompletNrcInfo() : "-",
      //         phoneController.text.toString(),
      //         selectedBloodType,
      //         bloodBankNoController.text.toString() != ""
      //             ? bloodBankNoController.text.toString()
      //             : "-",
      //         totalDonationController.text.toString(),
      //         "0",
      //         homeNoController.text.toString() +
      //             " ၊ " +
      //             streetController.text.toString() +
      //             " ၊ " +
      //             quarterController.text.toString() +
      //             " ၊ " +
      //             townController.text.toString() +
      //             " ၊ " +
      //             region1,
      //         noteController.text.toString(),
      //       );

      //       return newCount;
      //     })
      //     .then((value) => print("Follower count updated to $value"))
      //     .catchError(
      //         (error) => print("Failed to update user followers: $error"));
    }
  }

  showDatePicker() async {
    Utils.showCupertinoDatePicker(
      context,
      (DateTime newDateTime) {
        setState(() {
          birthDate = DateFormat("dd MMM yyyy").format(newDateTime);
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

  _getCompletNrcInfo() {
    return "$nrc_initial_options_Value/$nrc_region_state_options_Value($nrc_type_options_Value)${Utils.strToMM(nrcController.text.toString())}";
  }

  List<DropdownMenuItem<String>> getNrcNationalOptionDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];
    for (String city in nrc_initial_options) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(DropdownMenuItem(value: city, child: Text(city)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getNrcTypeOptionDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = [];

    for (String regionTownship in nrc_type_options) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(
          DropdownMenuItem(value: regionTownship, child: Text(regionTownship)));
    }
    return items;
  }

  void nrcInitialRegionStateOptionschangedDropDownItem(String? selectedCity) {
    setState(() {
      nrc_region_state_options_Value = selectedCity;
      print("select region => $selectedCity");
    });
  }

  List<DropdownMenuItem<String>> getNrcRegionStateOptionDropDownMenuItems(
      List nrcRegionState) {
    List<DropdownMenuItem<String>> items = [];

    for (String regionTownship in nrcRegionState) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(
          DropdownMenuItem(value: regionTownship, child: Text(regionTownship)));
    }
    return items;
  }

  void nrcInitialOptionschangedDropDownItem(String? selectedCity) {
    setState(() {
      List nrcRegionState = kachin;

      switch (selectedCity) {
        case "၁":
          nrcRegionState = kachin;
          break;
        case "၂":
          nrcRegionState = kayar;
          break;
        case "၃":
          nrcRegionState = kayin;
          break;
        case "၄":
          nrcRegionState = chin;
          break;
        case "၅":
          nrcRegionState = sagain;
          break;
        case "၆":
          nrcRegionState = tanintharyi;
          break;
        case "၇":
          nrcRegionState = bago;
          break;
        case "၈":
          nrcRegionState = magway;
          break;
        case "၉":
          nrcRegionState = mandalay;
          break;
        case "၁၀":
          nrcRegionState = mon;
          break;
        case "၁၁":
          nrcRegionState = rakhine;
          break;
        case "၁၂":
          nrcRegionState = yangon;
          break;
        case "၁၃":
          nrcRegionState = shan;
          break;
        case "၁၄":
          nrcRegionState = arrewady;
          break;
      }

      nrc_initial_options_Value = selectedCity;

      //region state
      nrc_region_state_options_dropDownMenuItems =
          getNrcRegionStateOptionDropDownMenuItems(nrcRegionState);
      nrc_region_state_options_Value =
          nrc_region_state_options_dropDownMenuItems![0].value;
    });
  }

  void nrcTypeOptionschangedDropDownItem(String? selectedCity) {
    setState(() {
      nrc_type_options_Value = selectedCity;
      print("select region => $selectedCity");
    });
  }

  List regionAndState = [
    "ကချင်",
    "ကယား",
    "ကရင်",
    "ချင်း",
    "စစ်ကိုင်း",
    "တနင်္သာရီ",
    "ပဲခူး",
    "မကွေး",
    "မန္တလေး",
    "မွန်",
    "ရခိုင်",
    "ရန်ကုန်",
    "ရှမ်း",
    "ဧရာဝတီ"
  ];

  List nrc_initial_options = [
    "၁",
    "၂",
    "၃",
    "၄",
    "၅",
    "၆",
    "၇",
    "၈",
    "၉",
    "၁၀",
    "၁၁",
    "၁၂",
    "၁၃",
    "၁၄"
  ];

  List nrc_initial = [
    "၁",
    "၂",
    "၃",
    "၄",
    "၅",
    "၆",
    "၇",
    "၈",
    "၉",
    "၁၀",
    "၁၁",
    "၁၂",
    "၁၃",
    "၁၄"
  ];

  List kachin = [
    "မကန",
    "ဝမန",
    "ခဖန",
    "ဆလန",
    "တနန",
    "အဂယ",
    "မညန",
    "ကမန",
    "ဗမန",
    "ရကန",
    "မစန",
    "ဗမန",
    "မမန",
    "ပတအ",
    "ဆပဘ",
    "မခဘ",
    "ခဘဒ",
    "နမန",
  ];

  List kayar = [
    "လကန",
    "ဒမဆ",
    "ဖရဆ",
    "ရတန",
    "ဘလခ",
    "မစန",
    "ဖဆန",
  ];

  List kayin = [
    "ဘအန",
    "လဘန",
    "သတန",
    "ကကရ",
    "ကဆက",
    "မဝတ",
    "ဖပန",
  ];

  List chin = [
    "ဟခန",
    "ထတလ",
    "မတန",
    "ပလဝ",
    "မတပ",
    "ကပလ",
    "ဖလန",
    "တတန",
    "တဇန",
  ];

  List sagain = [
    "မရန",
    "အရတ",
    "ခဥတ",
    "ဘတလ",
    "စကန",
    "မမန",
    "မမတ",
    "ကလထ",
    "ကလဝ",
    "မကန",
    "ကသန",
    "အတန",
    "ဗမန",
    "ကလတ",
    "ပလဘ",
    "ဝသန",
    "ထခန",
    "ခတန",
    "ဟမလ",
    "လရန",
    "နယန",
    "လဟန",
    "မလန",
    "ဖပန",
    "ယမပ",
    "ဆလက",
    "ပလန",
    "ကနန",
    "ရဘန",
    "ဒပယ",
    "ကဘလ",
    "ခဥန",
    "ကလန",
    "တဆန",
    "ရဥန",
    "ဝလန",
    "တမန",
  ];

  List tanintharyi = [
    "ထဝန",
    "လလန",
    "သရခ",
    "ရဖန",
    "မမန",
    "တသရ",
    "ကစန",
    "ပလန",
    "ကသန",
    "ဘပန",
  ];

  List bago = [
    "ပခန",
    "ဒဥန",
    "ကတခ",
    "ကဝန",
    "ညလပ",
    "ရကန",
    "သနပ",
    "ဝမန",
    "ပမန",
    "ပတန",
    "သကန",
    "ပခတ",
    "ပတတ",
    "ရတန",
    "သဝတ",
    "မညန",
    "အဖန",
    "လပတ",
    "မလန",
    "နတလ",
    "ဇကန",
    "ကပက",
    "တငန",
    "ထတပ",
    "ဖမန",
    "အတန",
    "ရတရ",
    "ကကန",
  ];

  List magway = [
    "မကန",
    "နမန",
    "မသန",
    "တတက",
    "ရနခ",
    "ခမန",
    "မဘန",
    "ပဖန",
    "ငဖန",
    "စတရ",
    "စလန",
    "ဂဂန",
    "ထလန",
    "ဆမန",
    "သရန",
    "ဆပဝ",
    "မတန",
    "အလန",
    "မလန",
    "ကမန",
    "ပခက",
    "ဆဖန",
    "ပမန",
    "မမန",
    "ရစက",
  ];

  List mandalay = [
    "ကဆန",
    "ကပတ",
    "ခမခ",
    "ခမစ",
    "ခမန",
    "ခအဇ",
    "ငဇန",
    "ငသရ",
    "စကတ",
    "စကန",
    "စကရ",
    "စတတ",
    "စတန",
    "စသန",
    "ဇဇန",
    "ဇပသ",
    "ဇဗသ",
    "ဇယသ",
    "ညဥန",
    "ညဥလ",
    "တကတ",
    "တကန",
    "တတက",
    "တတဥ",
    "တပတ",
    "တမန",
    "တယန",
    "တသန",
    "ဒခသ",
    "ဒဏသ",
    "နတက",
    "နထက",
    "ပကခ",
    "ပကစ",
    "ပခန",
    "ပတခ",
    "ပတန",
    "ပတလ",
    "ပနလ",
    "ပဗသ",
    "ပဘန",
    "ပမန",
    "ပလန",
    "ပသက",
    "ပသန",
    "ပဥလ",
    "ဗမန",
    "မကန",
    "မခန",
    "မတန",
    "မတမ",
    "မတရ",
    "မတလ",
    "မထလ",
    "မနက",
    "မနတ",
    "မနမ",
    "မနလ",
    "မပန",
    "မဖန",
    "မဘန",
    "မမတ",
    "မမန",
    "မယတ",
    "မယမ",
    "မရက",
    "မရတ",
    "မရန",
    "မရပ",
    "မရဘ",
    "မရမ",
    "မရသ",
    "မလန",
    "မသက",
    "မသန",
    "မသရ",
    "မဟမ",
    "မအဇ",
    "မအန",
    "မအရ",
    "မဥလ",
    "ရမတ",
    "ရမသ",
    "လဆန",
    "လဝန",
    "ဝတန",
    "ဝထန",
    "သကမ",
    "သခက",
    "သစန",
    "သတန",
    "သဓန",
    "သပက",
    "သပတ",
    "သရပ",
    "အတန",
    "အဓန",
    "အမဇ",
    "အမရ",
    "ဥတသ"
  ];

  List mon = [
    "မလမ",
    "ရမန",
    "ခဆန",
    "ကမရ",
    "မဒန",
    "သဖရ",
    "သထန",
    "ဘလန",
    "ကထန",
    "ပမန",
    "လမန",
  ];

  List rakhine = [
    "စတန",
    "ပတန",
    "ပဏတ",
    "ရသတ",
    "ကဖန",
    "ရဗန",
    "အမန",
    "မအန",
    "မဥန",
    "မပတ",
    "မပန",
    "ကတန",
    "သတန",
    "တကန",
    "ဂမန",
    "မတန",
    "ဘသတ",
  ];

  List yangon = [
    "ကကက",
    "ကခက",
    "ကခတ",
    "ကခန",
    "ကခရ",
    "ကစက",
    "ကတက",
    "ကတတ",
    "ကတန",
    "ကတလ",
    "ကထက",
    "ကထထ",
    "ကပတ",
    "ကပန",
    "ကဗတ",
    "ကမက",
    "ကမတ",
    "ကမထ",
    "ကမန",
    "ကမရ",
    "ကမလ",
    "ကလထ",
    "ကလန",
    "ကလဝ",
    "ကသရ",
    "ခခန",
    "ခဂတ",
    "ခပန",
    "ခမန",
    "ခရက",
    "ခရန",
    "ခရဟ",
    "ဂဟန",
    "စကန",
    "စခဂ",
    "စခန",
    "စခမ",
    "စဂန",
    "စဇန",
    "စတန",
    "စပန",
    "စပရ",
    "ဆကခ",
    "ဆကန",
    "ဆခန",
    "ဆဖန",
    "တကက",
    "တကတ",
    "တကန",
    "တခန",
    "တခလ",
    "တဂတ",
    "တငန",
    "တတက",
    "တတတ",
    "တတထ",
    "တတန",
    "တတပ",
    "တထန",
    "တထပ",
    "တပန",
    "တဖန",
    "တဗတ",
    "တမ",
    "တမတ",
    "တမန",
    "တဝန",
    "တသန",
    "ထကန",
    "ထတတ",
    "ထတပ",
    "ထတမ",
    "ထမန",
    "ထသန",
    "ဒကတ",
    "ဒဂဆ",
    "ဒဂတ",
    "ဒဂန",
    "ဒဂမ",
    "ဒဂရ",
    "ဒဒရ",
    "ဒနပ",
    "ဒပန",
    "ဒဖန",
    "ဒရန",
    "ဒလန",
    "ဓခန",
    "ဓဓန",
    "ဓနဖ",
    "ဓနမ",
    "ဓလန",
    "နကတ",
    "နကယ",
    "နမန",
    "ပကတ",
    "ပခန",
    "ပဂတ",
    "ပစတ",
    "ပဆတ",
    "ပဇတ",
    "ပဇန",
    "ပတတ",
    "ပတန",
    "ပတအ",
    "ပဗက",
    "ပဘတ",
    "ပဘန",
    "ပမန",
    "ပရတ",
    "ပလန",
    "ပသတ",
    "ပသန",
    "ပအတ",
    "ဖပန",
    "ဖဟန",
    "ဗကတ",
    "ဗကလ",
    "ဗဂတ",
    "ဗတက",
    "ဗတတ",
    "ဗတထ",
    "ဗတန",
    "ဗတလ",
    "ဗထထ",
    "ဗပန",
    "ဗဘတ",
    "ဗမန",
    "ဗယန",
    "ဗရက",
    "ဗလန",
    "ဗလဗ",
    "ဗဟတ",
    "ဗဟန",
    "ဘကတ",
    "ဘကလ",
    "ဘတထ",
    "ဘဓန",
    "ဘပတ",
    "ဘလန",
    "မကတ",
    "မကန",
    "မကမ",
    "မခန",
    "မဂက",
    "မဂတ",
    "မဂဒ",
    "မဂဓ",
    "မဂန",
    "မဂလ",
    "မဂဝ",
    "မဆန",
    "မဇတ",
    "မညန",
    "မတက",
    "မတည",
    "မတတ",
    "မတထ",
    "မတန",
    "မတလ",
    "မထလ",
    "မဒဂ",
    "မဒန",
    "မဓန",
    "မနက",
    "မနမ",
    "မပန",
    "မဘတ",
    "မဘန",
    "မမက",
    "မမတ",
    "မယက",
    "မရက",
    "မရတ",
    "မရန",
    "မလတ",
    "မလန",
    "မဝတ",
    "မသန",
    "မဟန",
    "မအတ",
    "မအန",
    "မအပ",
    "မအရ",
    "မဥန",
    "ယပသ",
    "ရကတ",
    "ရကန",
    "ရကမ",
    "ရတန",
    "ရပတ",
    "ရပသ",
    "ရမက",
    "ရယခ",
    "ရလန",
    "ရသပ",
    "လကတ",
    "လကန",
    "လကပ",
    "လစန",
    "လတတ",
    "လတန",
    "လတပ",
    "လထန",
    "လပတ",
    "လပန",
    "လဘန",
    "လမက",
    "လမတ",
    "လမန",
    "လမရ",
    "လမသ",
    "လရန",
    "လလန",
    "လဝန",
    "လသန",
    "လသမ",
    "လသယ",
    "လသရ",
    "လသသ",
    "လအန",
    "ဝတန",
    "သကက",
    "သကဃ",
    "သကတ",
    "သကန",
    "သကလ",
    "သခက",
    "သခန",
    "သဃက",
    "သဃတ",
    "သဃန",
    "သညက",
    "သတက",
    "သတတ",
    "သတန",
    "သနပ",
    "သပန",
    "သမန",
    "သရန",
    "သလက",
    "သလတ",
    "သလန",
    "သလပ",
    "သလရ",
    "ဟခန",
    "ဟသတ",
    "အခက",
    "အခန",
    "အဂတ",
    "အဂန",
    "အစန",
    "အစရ",
    "အဆန",
    "အတန",
    "အထက",
    "အပန",
    "အဖန",
    "အမတ",
    "အမန",
    "အလက",
    "အလန",
    "အသန",
    "ဥကက",
    "ဥကတ",
    "ဥကထ",
    "ဥကန",
    "ဥကပ",
    "ဥကမ",
    "ဥကလ",
    "ဥတက",
    "ဥတတ",
    "ဥတမ",
    "ဥပတ",
    "ဥသတ"
  ];

  List shan = [
    "ကကန",
    "ကကရ",
    "ကခန",
    "ကခလ",
    "ကစန",
    "ကတတ",
    "ကတန",
    "ကတရ",
    "ကတလ",
    "ကထန",
    "ကမန",
    "ကမရ",
    "ကရန",
    "ကလတ",
    "ကလထ",
    "ကလဒ",
    "ကလန",
    "ကသန",
    "ကသဟ",
    "ကဟန",
    "ခရဟ",
    "ငစန",
    "စကန",
    "ဆဆန",
    "ညကန",
    "ညရန",
    "တကန",
    "တခက",
    "တခန",
    "တခလ",
    "တစလ",
    "တတန",
    "တထန",
    "တပန",
    "တမည",
    "တယန",
    "တရန",
    "တလန",
    "တဟန",
    "နခတ",
    "နခန",
    "နခမ",
    "နစတ",
    "နစန",
    "နဆန",
    "နတယ",
    "နတရ",
    "နမက",
    "နမတ",
    "ပဆတ",
    "ပဇတ",
    "ပတယ",
    "ပဘတ",
    "ပယန",
    "ပလတ",
    "ပလန",
    "ပသရ",
    "ဖခန",
    "ဗဆန",
    "ဘအန",
    "မကတ",
    "မကန",
    "မခန",
    "မငန",
    "မဆက",
    "မဆတ",
    "မဆန",
    "မဆလ",
    "မတတ",
    "မတန",
    "မနတ",
    "မနန",
    "မပတ",
    "မပန",
    "မဖတ",
    "မဖန",
    "မဘန",
    "မမက",
    "မမတ",
    "မမန",
    "မယတ",
    "မယန",
    "မရတ",
    "မရန",
    "မလန",
    "မဟရ",
    "မအန",
    "ရကစ",
    "ရခန",
    "ရငန",
    "ရစန",
    "ရစရ",
    "လကတ",
    "လကန",
    "လကရ",
    "လခတ",
    "လခန",
    "လနန",
    "လရန",
    "လလန",
    "လလရ",
    "လသန",
    "သကတ",
    "သနန",
    "သပန",
    "ဟပတ",
    "ဟပန",
    "ဟပမ",
    "ဥကမ"
  ];

  List arrewady = [
    "ကကတ",
    "ကကထ",
    "ကကန",
    "ကကလ",
    "ကခန",
    "ကတခ",
    "ကပတ",
    "ကပန",
    "ကပရ",
    "ကဖန",
    "ကဘလ",
    "ကမန",
    "ကမရ",
    "ကလန",
    "ခလန",
    "ဂသတ",
    "ငဆန",
    "ငပတ",
    "ငရက",
    "ငသခ",
    "စခမ",
    "စနဖ",
    "စနမ",
    "ဆကလ",
    "ဇလန",
    "ညတန",
    "ညနတ",
    "တကန",
    "တကလ",
    "တခမ",
    "တပတ",
    "တလတ",
    "တသတ",
    "ထကက",
    "ဒဂပ",
    "ဒဂမ",
    "ဒဒရ",
    "ဒနဖ",
    "ဓနဖ",
    "ပစလ",
    "ပတတ",
    "ပတန",
    "ပတပ",
    "ပဖန",
    "ပဖမ",
    "ပမန",
    "ပသန",
    "ပသယ",
    "ပသရ",
    "ဖပန",
    "ဖမန",
    "ဗကလ",
    "ဗတထ",
    "ဗသန",
    "ဘကလ",
    "ဘတလ",
    "မကမ",
    "မကလ",
    "မဂပ",
    "မဆန",
    "မတန",
    "မပက",
    "မပန",
    "မဘန",
    "မမက",
    "မမက",
    "မမက",
    "မမတ",
    "မမန",
    "မလမ",
    "မသန",
    "မအန",
    "မအပ",
    "မအဖ",
    "မအမ",
    "ရကန",
    "ရသယ",
    "လပတ",
    "လပန",
    "လမတ",
    "လမန",
    "ဝခမ",
    "ဝတန",
    "သကတ",
    "သခမ",
    "သပန",
    "သမန",
    "ဟကက",
    "ဟသတ",
    "ဟသန",
    "အခမ",
    "အဂဒ",
    "အဂပ",
    "အမတ",
    "အမန"
  ];
}
