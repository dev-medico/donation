import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/data/response/township_response/datum.dart';
import 'package:donation/data/response/township_response/township_response.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/patient/models/patient.dart';
import 'package:donation/src/features/patient/providers/patient_provider.dart';
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
  final patientSearchController = TextEditingController();

  // Patient re-selection state: the patient currently linked to this record
  // (loaded via patient_id) and the patient newly chosen from the typeahead.
  Patient? linkedPatient;
  Patient? selectedPatient;
  bool linkedPatientLoading = false;

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
    "အစာအိမ်နှင့်ဆိုင်ရာရောဂါ",
    "အူလမ်းကြောင်းနှင့်ဆိုင်ရာရောဂါ",
    "အသည်းနှင့်ဆိုင်ရာရောဂါ",
    "အဆုတ်နှင့်ဆိုင်ရာရောဂါ",
    "နှလုံးနှင့်ဆိုင်ရာရောဂါ",
    "သားအိမ်နှင့်ဆိုင်ရာရောဂါ",
    "ကိုယ်ဝန်ဆောင်သွေးအားနည်း",
    "လမပြည့်၊ ပေါင်မပြည့် မွေးဖွား",
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
    nameController.addListener(_onPatientNameEdited);
    initializeData();
    _loadLinkedPatient();
  }

  @override
  void dispose() {
    nameController.removeListener(_onPatientNameEdited);
    nameController.dispose();
    ageController.dispose();
    quarterController.dispose();
    townController.dispose();
    hospitalController.dispose();
    diseaseController.dispose();
    patientSearchController.dispose();
    super.dispose();
  }

  /// Load the patient currently linked to this donation (if any) so the user
  /// can see which patient record the donation points to before changing it.
  Future<void> _loadLinkedPatient() async {
    final patientId = widget.data.patientId;
    if (patientId == null) return;
    setState(() {
      linkedPatientLoading = true;
    });
    try {
      final patient =
          await ref.read(patientServiceProvider).getPatient(patientId);
      if (!mounted) return;
      setState(() {
        linkedPatient = patient;
        linkedPatientLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        linkedPatientLoading = false;
      });
    }
  }

  // If the user manually edits the name after picking a patient, drop the new
  // selection so the saved patient_id always matches the displayed name.
  void _onPatientNameEdited() {
    if (selectedPatient != null &&
        nameController.text != (selectedPatient!.name ?? '')) {
      setState(() {
        selectedPatient = null;
      });
    }
  }

  void _selectPatient(Patient patient) {
    setState(() {
      selectedPatient = patient;
      patientSearchController.text = patient.name ?? '';
      nameController.text = patient.name ?? '';
      if ((patient.age ?? '').isNotEmpty) {
        ageController.text = patient.age!;
      }
      _fillAddressFromPatient(patient);
    });
  }

  void _fillAddressFromPatient(Patient patient) {
    // The patient's flat address carries the full ward ၊ town ၊ township, so
    // keep everything before the township together so the town (မြို့) is not
    // dropped. Fall back to the structured columns only when there is no usable
    // flat address.
    final parts = (patient.address ?? '')
        .split('၊')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      quarterController.text = parts.sublist(0, parts.length - 1).join('၊');
      townController.text = parts.last;
    } else {
      final ward = (patient.ward ?? '').trim();
      final village = (patient.village ?? '').trim();
      final township = (patient.township ?? '').trim();
      quarterController.text = ward.isNotEmpty ? ward : village;
      townController.text = township.isNotEmpty
          ? township
          : (parts.isNotEmpty ? parts.first : '');
    }
    setRegion(townController.text);
  }

  void _clearSelectedPatient() {
    setState(() {
      selectedPatient = null;
      patientSearchController.clear();
      // Undo the field sync too, so the kept patient_id and the displayed
      // name/age/address stay consistent with the original record.
      _restoreOriginalPatientFields();
    });
  }

  void _restoreOriginalPatientFields() {
    nameController.text = widget.data.patientName ?? "";
    ageController.text = widget.data.patientAge ?? "";
    quarterController.text = "";
    townController.text = "";
    final parts = (widget.data.patientAddress ?? "")
        .split("၊")
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      // Keep everything before the township together so the town (မြို့) is
      // preserved in the full ward ၊ town ၊ township address.
      quarterController.text = parts.sublist(0, parts.length - 1).join('၊');
      townController.text = parts.last;
    } else if (parts.length == 1) {
      townController.text = parts.first;
    }
    setRegion(townController.text);
  }

  void initializeData() async {
    // Initialize form with existing donation data
    _restoreOriginalPatientFields();

    hospitalController.text = widget.data.hospital ?? "";
    diseaseController.text = widget.data.patientDisease ?? "";

    if (widget.data.donationDate != null) {
      donationDateDetail = widget.data.donationDate;
      donationDate =
          DateFormat("dd MMM yyyy").format(widget.data.donationDate!);
    }

    // Always show the full form by default
    setState(() {
      switchNew = true;
    });

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
      // Create a formatted address string like in the new form
      final String formattedAddress =
          "${quarterController.text}${quarterController.text.isNotEmpty ? '၊' : ''}${townController.text}";

      // Prepare data for donation update - ensuring all types match the create form
      final updateData = {
        'patient_name': nameController.text,
        'patient_age': ageController.text.toString(), // Ensure this is a string
        'hospital': hospitalController.text,
        'date': donationDateDetail != null
            ? DateFormat("dd MMM yyyy").format(donationDateDetail!)
            : null,
        'donation_date': donationDateDetail != null
            ? DateTime(
                donationDateDetail!.year,
                donationDateDetail!.month,
                donationDateDetail!.day,
                donationDateDetail!.hour,
                donationDateDetail!.minute,
                donationDateDetail!.second,
              ).toIso8601String()
            : null,
        'patient_disease': diseaseController.text,
        'patient_address': formattedAddress,
        'member_id': widget.data.memberId ?? '',
        'member': widget.data.member.toString(),
        'owner_id': widget.data.memberId ?? '',
        // Re-link to the newly selected patient, or keep the existing link.
        'patient_id': selectedPatient?.id ?? widget.data.patientId,
      };

      print('Sending donation update data to API: $updateData');

      // Use donation service directly instead of provider
      final donationService = ref.read(donationServiceProvider);
      await donationService.updateDonation(
          widget.data.id.toString(), updateData);

      // After update, invalidate the month/year provider to refresh the list
      ref.invalidate(donationsByMonthYearProvider);

      setState(() {
        isLoading = false;
      });

      // Show success message like in new form

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အချက်အလက်ပြင်ဆင်ခြင်း \nnအောင်မြင်ပါသည်။'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      // Pop back to previous screen after successful update
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('Error updating donation: $e');
      // Show error message in snackbar only
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အချက်အလက် ပြင်ဆင်ရာတွင် အမှားရှိပါသည် - $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        title: Text(
          'သွေးလှူဒါန်းမှုအချက်အလက် ပြင်ဆင်မည်',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: isMobile
                            ? double.infinity
                            : MediaQuery.of(context).size.width * 0.5,
                        child: _buildEditForm(),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // Formatted address getter for preview
  String get formattedAddress =>
      "${quarterController.text}${quarterController.text.isNotEmpty ? '၊' : ''}${townController.text}";

  Widget _bloodTypeChip(String bloodType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bloodType,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// One-line summary used in the picker and status boxes so patients with
  /// the same name remain distinguishable: age + address.
  String _patientSubtitle(Patient patient) {
    return [
      if ((patient.age ?? '').isNotEmpty) 'အသက် ${patient.age}',
      if ((patient.address ?? '').isNotEmpty) patient.address!,
    ].join(' • ');
  }

  /// Shows which patient record this donation is linked to right now:
  /// green = newly re-selected patient, blue = existing link, amber = none.
  Widget _patientLinkStatusBox() {
    if (selectedPatient != null) {
      final patient = selectedPatient!;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'ပြောင်းရွေးထားသည်: ${patient.name ?? ''}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if ((patient.bloodType ?? '').isNotEmpty) ...[
                        SizedBox(width: 8),
                        _bloodTypeChip(patient.bloodType!),
                      ],
                    ],
                  ),
                  if (_patientSubtitle(patient).isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      _patientSubtitle(patient),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18),
              tooltip: 'ပြောင်းရွေးမှု ပယ်ဖျက်မည်',
              onPressed: _clearSelectedPatient,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      );
    }

    if (linkedPatientLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text(
              'ချိတ်ဆက်ထားသော လူနာကို ရှာနေသည်...',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      );
    }

    if (linkedPatient != null) {
      final patient = linkedPatient!;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link, color: Colors.blue[700], size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'လက်ရှိချိတ်ဆက်ထားသော လူနာ: ${patient.name ?? ''}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if ((patient.bloodType ?? '').isNotEmpty) ...[
                        SizedBox(width: 8),
                        _bloodTypeChip(patient.bloodType!),
                      ],
                    ],
                  ),
                  if (_patientSubtitle(patient).isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      _patientSubtitle(patient),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'လူနာစာရင်းနှင့် ချိတ်ဆက်မထားသေးပါ။ အောက်တွင် ရှာ၍ ရွေးချယ်နိုင်ပါသည်။',
              style: TextStyle(fontSize: 13, color: Colors.amber[900]),
            ),
          ),
        ],
      ),
    );
  }

  /// Typeahead that searches the patient list by name, blood type or address
  /// and re-links this donation to the chosen patient.
  Widget _patientPickerField() {
    return TypeAheadField<Patient>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: patientSearchController,
        decoration: InputDecoration(
          labelText: 'လူနာ ပြောင်းရွေးရန် ရှာပါ',
          hintText: 'အမည် / သွေးအုပ်စု / လိပ်စာ ဖြင့်ရှာပါ',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.person_search),
        ),
      ),
      suggestionsCallback: (pattern) async {
        final service = ref.read(patientServiceProvider);
        return await service.searchPatients(pattern.trim());
      },
      itemBuilder: (context, Patient patient) {
        return ListTile(
          dense: true,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  patient.name ?? '',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if ((patient.bloodType ?? '').isNotEmpty)
                _bloodTypeChip(patient.bloodType!),
            ],
          ),
          subtitle: Text(
            _patientSubtitle(patient),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: EdgeInsets.all(12),
        child: Text('လူနာ မတွေ့ပါ'),
      ),
      onSuggestionSelected: _selectPatient,
    );
  }

  Widget _buildAdaptiveFieldPair({
    required Widget first,
    required Widget second,
  }) {
    if (MediaQuery.of(context).size.width < 480) {
      return Column(
        children: [
          first,
          const SizedBox(height: 12),
          second,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Member information would go here if this screen needed it

        // Donation Information Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "သွေးလှူဒါန်းမှု အချက်အလက်များ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Hospital input
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'ဆေးရုံ/ဆေးခန်း',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return hospitals.where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()));
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
          ),
        ),

        // Patient Information Card (Always visible now)
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "လူနာ အချက်အလက်",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _patientLinkStatusBox(),
                SizedBox(height: 12),
                _patientPickerField(),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'လူနာ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'လူနာအသက်',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "လူနာလိပ်စာ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                _buildAdaptiveFieldPair(
                  first: TextField(
                    controller: quarterController,
                    decoration: InputDecoration(
                      labelText: 'ရပ်ကွက်',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  second: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: townController,
                      decoration: InputDecoration(
                        labelText: 'မြို့နယ်',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      List<String> suggestions = [];

                      // First, get မော်လမြိုင် townships
                      var mawlamyineItems = townships
                          .where((item) => item.contains('မော်လမြိုင်'));

                      // Then get other townships that match the pattern
                      var otherItems = townships.where((item) =>
                          !item.contains('မော်လမြိုင်') &&
                          item.toLowerCase().contains(pattern.toLowerCase()));

                      // If pattern is empty, show မော်လမြိုင် townships first
                      if (pattern.isEmpty) {
                        suggestions.addAll(mawlamyineItems);
                        suggestions
                            .addAll(otherItems.take(10 - suggestions.length));
                      } else {
                        // Filter မော်လမြိုင် townships by pattern
                        var filteredMawlamyine = mawlamyineItems.where((item) =>
                            item.toLowerCase().contains(pattern.toLowerCase()));
                        suggestions.addAll(filteredMawlamyine);
                        suggestions.addAll(otherItems);
                      }

                      return suggestions.take(10).toList();
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
                SizedBox(height: 8),
                if (quarterController.text.isNotEmpty ||
                    townController.text.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'လိပ်စာပြည့်စုံ:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formattedAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: diseaseController,
                    decoration: InputDecoration(
                      labelText: 'ရောဂါအမျိုးအစား',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return diseases.where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()));
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
          ),
        ),

        // Donation Date Card - Separate card like in new form
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'လှူဒါန်းသည့် ရက်စွဲ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
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
                        donationDate =
                            DateFormat("dd MMM yyyy").format(pickedDate);
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          donationDate,
                          style: TextStyle(
                            color: donationDateDetail != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),

        // Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: updateDonation,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              'သွေးလှူဒါန်းမှု ပြင်ဆင်မည်',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
