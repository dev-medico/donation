import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/services/member_service.dart'
    as member_services;
import 'package:donation/src/features/services/donation_service.dart';

class BloodDonationEditScreen extends ConsumerStatefulWidget {
  final Donation data;

  const BloodDonationEditScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  ConsumerState<BloodDonationEditScreen> createState() =>
      _BloodDonationEditScreenState();
}

class _BloodDonationEditScreenState
    extends ConsumerState<BloodDonationEditScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final quarterController = TextEditingController();
  final townController = TextEditingController();
  final hospitalController = TextEditingController();
  final diseaseController = TextEditingController();

  String operatorImg = "";
  String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";

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
  DateTime? donationDateDetail;
  bool isLoading = false;

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
    "နား၊နှာခေါင်း၊လည်ချောင်းနှင့်ဆိုင်ရာရောဂါ",
    "နာတာရှည်ကြောင့် သွေးအားနည်း",
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
    initializeData();
  }

  void initializeData() async {
    // Initialize form with existing donation data
    nameController.text = widget.data.patientName ?? "";
    ageController.text = widget.data.patientAge ?? "";

    if (widget.data.patientAddress != null) {
      final addressParts = widget.data.patientAddress!.split("၊");
      quarterController.text = addressParts.isNotEmpty ? addressParts[0] : "";
      townController.text = addressParts.length > 1 ? addressParts[1] : "";
    }

    hospitalController.text = widget.data.hospital ?? "";
    diseaseController.text = widget.data.patientDisease ?? "";

    if (widget.data.donationDate != null) {
      donationDateDetail = widget.data.donationDate;
      donationDate = DateFormat("dd-MM-yyyy").format(widget.data.donationDate!);
    }

    if (widget.data.patientName == null || widget.data.patientName!.isEmpty) {
      setState(() {
        switchNew = false;
      });
    }

    setRegion(townController.text);

    // Load township data
    final String response =
        await rootBundle.loadString('assets/json/township.json');
    townshipResponse = TownshipResponse.fromJson(json.decode(response));
    for (var element in townshipResponse.data!) {
      datas.add(element);
      townships.add(element.township!);
    }
  }

  // Simulate setting region based on township
  void setRegion(String township) {
    // This is just a placeholder; replace with actual logic if needed
    regional = township;
  }

  Future<void> updateDonation() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare data for donation update
      final updateData = {
        'patient_name': nameController.text,
        'patient_age': ageController.text,
        'hospital': hospitalController.text,
        'donation_date': donationDateDetail?.toIso8601String(),
        'patient_disease': diseaseController.text,
        'patient_address': "${quarterController.text}၊${townController.text}",
        'member_id': widget.data.memberId,
        'member': widget.data.member
      };

      // Use the donation provider to update
      final donationNotifier = ref.read(donationListProvider.notifier);
      await donationNotifier.updateDonation(widget.data.id, updateData);

      // Show success message and navigate back
      Utils.messageSuccessDialog("အချက်အလက်ပြင်ဆင်ခြင်း \nအောင်မြင်ပါသည်။",
          context, "အိုကေ", Colors.black);

      Navigator.pop(context);
    } catch (e) {
      log('Error updating donation: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အချက်အလက် ပြင်ဆင်ရာတွင် အမှားရှိပါသည် - $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
                    fontSize: Responsive.isMobile(context) ? 15 : 16,
                    color: Colors.white)),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Responsive.isMobile(context)
                ? SingleChildScrollView(
                    child: _buildEditForm(),
                  )
                : Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: SingleChildScrollView(
                        child: _buildEditForm(),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin:
              const EdgeInsets.only(left: 12, top: 12, bottom: 15, right: 12),
          child: Container(
            padding:
                const EdgeInsets.only(bottom: 20, left: 4, right: 4, top: 8),
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
                              color: switchNew ? Colors.black : primaryColor),
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
                              color: switchNew ? primaryColor : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDatePicker(),
                _buildHospitalInput(),
                Visibility(
                  visible: switchNew,
                  child: Column(
                    children: [
                      _buildPatientNameInput(),
                      _buildPatientAgeInput(),
                      _buildPatientAddressInput(),
                      _buildPatientDiseaseInput(),
                    ],
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "လှူဒါန်းသည့် ရက်စွဲ",
            style: TextStyle(fontSize: 15),
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: donationDateDetail ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() {
                  donationDateDetail = pickedDate;
                  donationDate = DateFormat("dd-MM-yyyy").format(pickedDate);
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    donationDate,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalInput() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "လှူဒါန်းသည့် နေရာ",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: hospitalController,
              decoration: InputDecoration(
                hintText: 'နေရာ ရွေးပါ (သို့) ရိုက်ပါ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            suggestionsCallback: (pattern) {
              return hospitals.where(
                  (item) => item.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, String suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (String suggestion) {
              hospitalController.text = suggestion;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientNameInput() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "လူနာ အမည်",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'လူနာအမည်ရိုက်ပါ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAgeInput() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "လူနာ အသက်",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'လူနာ အသက်ရိုက်ပါ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAddressInput() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "လူနာ လိပ်စာ",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: quarterController,
                  decoration: InputDecoration(
                    hintText: 'ရပ်ကွက်/ကျေးရွာ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: townController,
                    decoration: InputDecoration(
                      hintText: 'မြို့နယ်',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return townships.where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()));
                  },
                  itemBuilder: (context, String suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (String suggestion) {
                    townController.text = suggestion;
                    setRegion(suggestion);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientDiseaseInput() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ဖြစ်ပွားသည့် ရောဂါ",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: diseaseController,
              decoration: InputDecoration(
                hintText: 'ရောဂါ ရွေးပါ (သို့) ရိုက်ပါ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            suggestionsCallback: (pattern) {
              return diseases.where(
                  (item) => item.toLowerCase().contains(pattern.toLowerCase()));
            },
            itemBuilder: (context, String suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (String suggestion) {
              diseaseController.text = suggestion;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 24),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "ဖျက်သိမ်းမည်",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: updateDonation,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "ပြင်ဆင်မည်",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
