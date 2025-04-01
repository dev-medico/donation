import 'dart:convert';
import 'dart:developer';

// import 'package:donation/realm/realm_services.dart';
// import 'package:donation/realm/schemas.dart' hide Donation;
import 'package:donation/src/providers/providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
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
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/services/member_service.dart'
    as member_services;

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
    "မေတ္တာရိပ်ဆေးခန်း",
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
    "......(ကင်ဆာ)",
    "သွေးရောဂါ",
    "အစာအိမ်နှင့်အူလမ်းကြောင်းဆိုင်ရာရောဂါ",
    "အသည်းနှင့်ဆိုင်ရာရောဂါ",
    "အဆုတ်နှင့်ဆိုင်ရာရောဂါ",
    "နှလုံးနှင့်ဆိုင်ရာရောဂါ",
    "မီးယပ်နှင့်သားဖွားဆိုင်ရာရောဂါ",
    "ဆီးလမ်းကြောင်းနှင့်ဆိုင်ရာရောဂါ",
    "ကျောက်ကပ်နှင့်ဆိုင်ရာရောဂါ",
    "ဦးနှောက်နှင့်အာရုံကြောဆိုင်ရာရောဂါ",
    "နား၊နှာခေါင်း၊လည်ချောင်းနှင့်ဆိုင်ရာရောဂါ",
    "နာတာရှည်ကြောင့် သွေးအားနည်း",
    "ခုခံအားကျဆင်းမှုကူးစက်ရောဂါ",
    "သွေးတိုး",
    "ဆီးချို",
    "တီဘီ",
    "သွေးလွန်တုပ်ကွေး",
    "ရင်သားနှင့်ဆိုင်ရာရောဂါ",
    "ယာဉ်မတော်တဆ",
    "ခိုက်ရန်ဖြစ်ပွား နှင့် လက်နက်မတော်တဆ",
    "မြွေကိုက်",
    "မတော်တဆဖြစ်ရပ်",
    "အရေပြားနှင့်ဆိုင်ရာရောဂါ",
    "အရိုးအကြောနှင့်ဆိုင်ရာရောဂါ",
    "သည်းခြေအိတ်နှင့်ဆိုင်ရာရောဂါ",
    "မုန့်ချိုအိတ်နှင့်ဆိုင်ရာရောဂါ",
    "သရက်ရွက်နှင့်ဆိုင်ရာရောဂါ",
    "လိပ်ခေါင်းရောဂါ",
  ];

  @override
  void initState() {
    super.initState();
    initial();
  }

  addDonation(String name, String age, String selectHospital,
      String selectDisease, String quarter, String township) async {
    // Create the donation data
    final donationData = {
      'member': selectedMember != null ? selectedMember!.id : null,
      'date': donationDateDetail != null
          ? DateFormat("dd MMM yyyy").format(donationDateDetail!)
          : null,
      'donationDate': donationDateDetail?.toIso8601String(),
      'hospital': selectHospital,
      'memberId': selectedMember != null ? selectedMember!.memberId : "",
      'patientAddress': "$quarter၊$township",
      'patientAge': age,
      'patientDisease': diseaseController.text.toString(),
      'patientName': name,
    };

    try {
      // Use the donation provider to create the donation
      final donationNotifier = ref.read(donationListProvider.notifier);
      await donationNotifier.createDonation(donationData);

      Utils.messageSuccessDialog(
          "သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
          context,
          "အိုကေ",
          Colors.black);

      // Update the member if needed
      if (selectedMember != null) {
        final memberService = ref.read(member_services.memberServiceProvider);

        // Get current count values
        final memberCount = int.parse(selectedMember!.memberCount ?? "0") + 1;
        final totalCount = int.parse(selectedMember!.totalCount ?? "0") + 1;

        // Determine last date
        DateTime? lastDate;
        if (selectedMember!.lastDate != null) {
          try {
            final DateTime existingLastDate =
                DateTime.parse(selectedMember!.lastDate!);
            lastDate = donationDateDetail != null &&
                    donationDateDetail!.isAfter(existingLastDate)
                ? donationDateDetail
                : existingLastDate;
          } catch (e) {
            lastDate = donationDateDetail;
          }
        } else {
          lastDate = donationDateDetail;
        }

        // Update member data
        final memberData = {
          'member_count': memberCount.toString(),
          'total_count': totalCount.toString(),
          'last_date': lastDate?.toIso8601String(),
        };

        await memberService.updateMember(
            selectedMember!.id.toString(), memberData);

        // Refresh member data
        ref.refresh(memberListProvider);
      }

      // Clear input fields
      nameController.clear();
      ageController.clear();
      diseaseController.clear();
      hospitalController.clear();
      quarterController.clear();
      townController.clear();
      memberController.clear();
      setState(() {
        selectedMember = null;
        donationDateDetail = null;
        donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";
      });
    } catch (e) {
      print('Error creating donation: $e');
      Utils.messageDialog("သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nမအောင်မြင်ပါ - $e",
          context, "အိုကေ", Colors.red);
    }
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
    final membersAsync = ref.watch(memberListProvider);
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
                                      "အပြည့်စုံ",
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
                                child: fluent.Button(
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
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 20, top: 16, right: 20),
                              child: membersAsync.when(
                                data: (members) {
                                  return TypeAheadField<Member>(
                                    hideSuggestionsOnKeyboardHide: true,
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: memberController,
                                      autofocus: false,
                                      decoration:
                                          inputBoxDecoration("လှူဒါန်းသူ"),
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      if (pattern.isEmpty) return [];
                                      var list = members
                                          .where((element) =>
                                              element.name != null &&
                                              element.name!
                                                  .toLowerCase()
                                                  .contains(
                                                      pattern.toLowerCase()))
                                          .toList();
                                      return list;
                                    },
                                    itemBuilder: (context, Member suggestion) {
                                      return ListTile(
                                        title: Text(suggestion.name ?? ""),
                                        subtitle: Text(
                                            "${suggestion.bloodType ?? ""} ${suggestion.fatherName ?? ""}  [${suggestion.birthDate ?? ""}]"),
                                      );
                                    },
                                    onSuggestionSelected: (Member suggestion) {
                                      setState(() {
                                        selectedMember = suggestion;
                                      });
                                      memberController.text =
                                          suggestion.name ?? "";
                                    },
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) =>
                                    Text('Error loading members: $error'),
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
                              child: TypeAheadField<String>(
                                hideSuggestionsOnKeyboardHide: true,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: hospitalController,
                                  autofocus: false,
                                  decoration:
                                      inputBoxDecoration("လှူဒါန်းသည့်နေရာ"),
                                ),
                                suggestionsCallback: (pattern) {
                                  hospitalsSelected.clear();
                                  hospitalsSelected.addAll(hospitals);
                                  hospitalsSelected.where((element) => element
                                      .toString()
                                      .toString()
                                      .startsWith(pattern.toLowerCase()));
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
                                        style: TextStyle(color: Colors.red)),
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
                                child: TypeAheadField<String>(
                                  hideSuggestionsOnKeyboardHide: true,
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    controller: diseaseController,
                                    autofocus: false,
                                    decoration:
                                        inputBoxDecoration("ဖြစ်ပွားသည့်ရောဂါ"),
                                  ),
                                  suggestionsCallback: (pattern) {
                                    diseasesSelected.clear();
                                    diseasesSelected.addAll(diseases);
                                    diseasesSelected.where((element) => element
                                        .toString()
                                        .toString()
                                        .startsWith(pattern.toLowerCase()));
                                    return diseasesSelected;
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
                                          style: TextStyle(color: Colors.red)),
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
                                child: TypeAheadField<String>(
                                  hideSuggestionsOnKeyboardHide: false,
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    cursorColor: Colors.white,
                                    controller: townController,
                                    autofocus: false,
                                    decoration: inputBoxDecoration("မြို့နယ်"),
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
                                      hoverColor: Colors.white,
                                      title: Text(
                                        suggestion.toString(),
                                        textScaleFactor: 1.0,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                          Object? error) =>
                                      Text('$error',
                                          style: TextStyle(color: Colors.red)),
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
                            onTap: () async {
                              if (selectedMember != null &&
                                  donationDate !=
                                      "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                bool result = await InternetConnectionChecker()
                                    .hasConnection;
                                if (result == true) {
                                  addDonation(
                                      nameController.text.toString(),
                                      ageController.text.toString(),
                                      hospitalController.text.toString(),
                                      diseaseController.text.toString(),
                                      quarterController.text.toString(),
                                      townController.text.toString());
                                } else {
                                  Utils.messageDialog(
                                      "Poor Internet Connection! Please check with your Internet",
                                      context,
                                      "အိုကေ",
                                      Colors.black);
                                }
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
                                      child: fluent.Button(
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
                                    child: TypeAheadField<Member>(
                                      hideSuggestionsOnKeyboardHide: true,
                                      textFieldConfiguration:
                                          TextFieldConfiguration(
                                        controller: memberController,
                                        autofocus: false,
                                        decoration:
                                            inputBoxDecoration("လှူဒါန်းသူ"),
                                      ),
                                      suggestionsCallback: (pattern) async {
                                        var list = membersAsync.when(
                                          data: (members) => members
                                              .where((element) =>
                                                  element.name != null &&
                                                  element.name!
                                                      .toLowerCase()
                                                      .contains(pattern
                                                          .toLowerCase()))
                                              .toList(),
                                          loading: () => <Member>[],
                                          error: (error, stack) => <Member>[],
                                        );
                                        return list;
                                      },
                                      transitionBuilder: (context,
                                          suggestionsBox, controller) {
                                        return suggestionsBox;
                                      },
                                      itemBuilder:
                                          (context, Member suggestion) {
                                        return ListTile(
                                          title: Text(suggestion.name ?? ""),
                                          subtitle: Text(
                                              "${suggestion.bloodType ?? ""} ${suggestion.fatherName ?? ""}  [${suggestion.birthDate ?? ""}]"),
                                          hoverColor: Colors.white,
                                        );
                                      },
                                      errorBuilder: (BuildContext context,
                                              Object? error) =>
                                          Text('$error',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                      onSuggestionSelected: (suggestion) {
                                        townController.text =
                                            suggestion.toString();
                                        setRegion(suggestion.toString());
                                      },
                                    ),
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
                            onTap: () async {
                              if (selectedMember != null &&
                                  donationDate !=
                                      "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်") {
                                bool result = await InternetConnectionChecker()
                                    .hasConnection;
                                if (result == true) {
                                  addDonation(
                                      nameController.text.toString(),
                                      ageController.text.toString(),
                                      hospitalController.text.toString(),
                                      diseaseController.text.toString(),
                                      quarterController.text.toString(),
                                      townController.text.toString());
                                } else {
                                  Utils.messageDialog(
                                      "Poor Internet Connection! Please check with your Internet",
                                      context,
                                      "အိုကေ",
                                      Colors.black);
                                }
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
