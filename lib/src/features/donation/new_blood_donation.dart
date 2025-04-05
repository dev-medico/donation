import 'dart:convert';
import 'dart:developer';

// import 'package:donation/realm/realm_services.dart';
// import 'package:donation/realm/schemas.dart' hide Donation;
import 'package:donation/src/providers/providers.dart';
import 'package:flutter/services.dart';
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
import 'package:donation/src/features/donation_member/domain/member_repository.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/src/features/services/member_service.dart'
    as member_services;
import 'package:donation/src/features/services/donation_service.dart';

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

  String donationDate = "လှူဒါန်းသည့် ရက်စွဲ ရွေးမည်";
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
  bool isFullForm = false; // Toggle for short/full form
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
  // This will use the cache from memberListProvider
  List<Member> cachedMembers = [];

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

  // Add formatted address preview
  String get formattedAddress =>
      "${quarterController.text}${quarterController.text.isNotEmpty ? '၊' : ''}${townController.text}";

  @override
  void initState() {
    super.initState();
    initial();
    // Load the cached members
    _loadCachedMembers();

    // Set today's date as default donation date
    setState(() {
      donationDateDetail = DateTime.now();
      donationDate = DateFormat("dd MMM yyyy").format(donationDateDetail!);
    });

    // Add listeners to address controllers to update UI when they change
    quarterController.addListener(_addressFieldsChanged);
    townController.addListener(_addressFieldsChanged);
  }

  // Handle changes to address fields
  void _addressFieldsChanged() {
    setState(() {
      // Just triggers a rebuild to show updated formatted address
    });
  }

  // New method to load cached members
  void _loadCachedMembers() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Check if we have members in the provider
      final memberState = ref.read(memberListProvider);

      if (memberState is AsyncData &&
          memberState.value != null &&
          memberState.value!.isNotEmpty) {
        setState(() {
          cachedMembers = memberState.value ?? [];
          isLoading = false;
        });
        print('Using ${cachedMembers.length} members from provider cache');
      } else {
        // If not in provider, fetch and cache them
        final memberService = ref.read(member_services.memberServiceProvider);
        final memberRepository = MemberRepository();

        try {
          // Try to get from repository first
          final members = await memberRepository.getMembers();
          if (members.isNotEmpty) {
            setState(() {
              cachedMembers = members;
              isLoading = false;
            });
            print(
                'Loaded ${cachedMembers.length} members from repository cache');

            // Refresh the provider via invalidation instead of direct state setting
            ref.invalidate(memberListProvider);
          } else {
            // If repository is empty, force fetch from API
            print('No members found in repository, fetching from API...');
            final fetchedMembers = await memberService.getMembers();

            if (fetchedMembers.isNotEmpty) {
              final memberList =
                  fetchedMembers.map((m) => Member.fromJson(m)).toList();

              // Save to repository for future use
              for (var member in memberList) {
                await memberRepository.addMember(member);
              }

              setState(() {
                cachedMembers = memberList;
                isLoading = false;
              });

              // Refresh the provider
              ref.invalidate(memberListProvider);
              print(
                  'Fetched and cached ${cachedMembers.length} members from API');
            } else {
              setState(() {
                cachedMembers = [];
                isLoading = false;
              });
              print('No members found in API');
            }
          }
        } catch (e) {
          // If any errors occur during repository or API fetch, try direct API fetch as last resort
          print('Error with repository fetch: $e, trying direct API call');
          try {
            final fetchedMembers = await memberService.getMembers();
            final memberList =
                fetchedMembers.map((m) => Member.fromJson(m)).toList();

            setState(() {
              cachedMembers = memberList;
              isLoading = false;
            });

            // Refresh the provider
            ref.invalidate(memberListProvider);
            print(
                'Recovered with direct API fetch: ${cachedMembers.length} members');
          } catch (finalError) {
            setState(() {
              cachedMembers = [];
              isLoading = false;
            });
            print('Failed to fetch members after all attempts: $finalError');
          }
        }
      }
    } catch (e) {
      setState(() {
        cachedMembers = [];
        isLoading = false;
      });
      print('Error loading cached members: $e');
    }
  }

  // Toggle between short and full form
  void _toggleFormType() {
    setState(() {
      isFullForm = !isFullForm;
    });
  }

  addDonation(String name, String age, String selectHospital,
      String selectDisease, String quarter, String township) async {
    // Validate required fields
    if (name.isEmpty) {
      Utils.messageDialog(
          "လူနာအမည် ဖြည့်ရန်လိုအပ်ပါသည်", context, "အိုကေ", Colors.red);
      return;
    }

    if (age.isEmpty) {
      Utils.messageDialog(
          "လူနာအသက် ဖြည့်ရန်လိုအပ်ပါသည်", context, "အိုကေ", Colors.red);
      return;
    }

    if (quarter.isEmpty && township.isEmpty) {
      Utils.messageDialog(
          "လူနာလိပ်စာ ဖြည့်ရန်လိုအပ်ပါသည်", context, "အိုကေ", Colors.red);
      return;
    }

    if (selectHospital.isEmpty) {
      Utils.messageDialog(
          "ဆေးရုံအမည် ရွေးချယ်ရန်လိုအပ်ပါသည်", context, "အိုကေ", Colors.red);
      return;
    }

    if (donationDateDetail == null) {
      Utils.messageDialog("လှူဒါန်းသည့်ရက်စွဲ ရွေးချယ်ရန်လိုအပ်ပါသည်", context,
          "အိုကေ", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Create the donation data with formatted address
    final String formattedAddress =
        "$quarter${quarter.isNotEmpty ? '၊' : ''}$township";

    final donationData = {
      'member': selectedMember != null ? selectedMember!.id : null,
      'member_id': selectedMember != null ? selectedMember!.memberId : "",
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
      'hospital': selectHospital,
      'patient_address': formattedAddress,
      'patient_age': age,
      'patient_disease': selectDisease,
      'patient_name': name,
      // Set owner_id to be the same as member_id as required by the server
      'owner_id': selectedMember != null ? selectedMember!.memberId : "",
    };

    try {
      print('Sending donation data to API: $donationData');

      // Use the donation service directly to ensure we're using the correct API endpoint
      final donationService = ref.read(donationServiceProvider);
      await donationService.createDonation(donationData);

      ref.invalidate(donationsByMonthYearProvider);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Pop back to previous screen after successful creation
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error creating donation: $e');
      Utils.messageDialog("သွေးလှူဒါန်းမှု အသစ်ထည့်ခြင်း \nမအောင်မြင်ပါ - $e",
          context, "အိုကေ", Colors.red);
    }
  }

  // Reset the form fields
  void _resetForm() {
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
  }

  void initial() async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'သွေးလှူဒါန်းမှု အသစ်ထည့်ရန်',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Toggle button for short/full form
          IconButton(
            icon: Icon(
              isFullForm ? Icons.view_headline : Icons.view_agenda,
              color: Colors.white,
            ),
            onPressed: _toggleFormType,
            tooltip:
                isFullForm ? 'အတိုကောက်ပုံစံပြရန်' : 'အပြည့်အစုံပုံစံပြရန်',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  alignment: Alignment.centerLeft,
                  child: isFullForm ? _buildFullForm() : _buildShortForm(),
                ),
              ),
            ),
    );
  }

  // Short form with essential fields only
  Widget _buildShortForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blood donor selection (Member)
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
                  'သွေးလှူဒါန်းသူ ရွေးချယ်ရန်',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TypeAheadField<Member>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: memberController,
                    decoration: InputDecoration(
                      labelText: 'သွေးလှူဒါန်းသူ အမည်',
                      hintText: 'အမည်ရိုက်ထည့်ပါ',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return cachedMembers
                        .where((member) =>
                            member.name != null &&
                            member.name!
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                        .take(10)
                        .toList();
                  },
                  itemBuilder: (context, Member member) {
                    return ListTile(
                      title: Text(member.name ?? ''),
                      subtitle: Text(
                          '${member.bloodType ?? ''} - ${member.memberId ?? ''}'),
                    );
                  },
                  onSuggestionSelected: (Member member) {
                    setState(() {
                      selectedMember = member;
                      memberController.text = member.name ?? '';
                    });
                  },
                ),
                if (selectedMember != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('အမည်', selectedMember!.name ?? ''),
                        _infoRow('ကတ်နံပါတ်', selectedMember!.memberId ?? ''),
                        _infoRow(
                            'သွေးအမျိုးအစား', selectedMember!.bloodType ?? ''),
                        _infoRow('ဖုန်းနံပါတ်', selectedMember!.phone ?? ''),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Patient Information
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
                  'လူနာအချက်အလက်',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'လူနာအမည်',
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
                SizedBox(height: 12),
                Text(
                  'လူနာလိပ်စာ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quarterController,
                        decoration: InputDecoration(
                          labelText: 'ရပ်ကွက်',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TypeAheadField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: townController,
                          decoration: InputDecoration(
                            labelText: 'မြို့နယ်',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return townships
                              .where((township) => township
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .take(5)
                              .toList();
                        },
                        itemBuilder: (context, String township) {
                          return ListTile(
                            title: Text(township),
                          );
                        },
                        onSuggestionSelected: (String township) {
                          townController.text = township;
                        },
                      ),
                    ),
                  ],
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
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'ဆေးရုံ/ဆေးခန်း',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return hospitals
                        .where((hospital) => hospital
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String hospital) {
                    return ListTile(
                      title: Text(hospital),
                    );
                  },
                  onSuggestionSelected: (String hospital) {
                    hospitalController.text = hospital;
                  },
                ),
                SizedBox(height: 12),
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: diseaseController,
                    decoration: InputDecoration(
                      labelText: 'ရောဂါအမျိုးအစား',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return diseases
                        .where((disease) => disease
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String disease) {
                    return ListTile(
                      title: Text(disease),
                    );
                  },
                  onSuggestionSelected: (String disease) {
                    diseaseController.text = disease;
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Donation Date
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
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        donationDateDetail = picked;
                        donationDate = DateFormat("dd MMM yyyy").format(picked);
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
            onPressed: () {
              final name = nameController.text;
              final age = ageController.text;
              final hospital = hospitalController.text;
              final disease = diseaseController.text;
              final quarter = quarterController.text;
              final township = townController.text;

              addDonation(name, age, hospital, disease, quarter, township);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              'သွေးလှူဒါန်းမှု ထည့်သွင်းမည်',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Full form with all fields
  Widget _buildFullForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Blood donor selection (Member)
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
                  'သွေးလှူဒါန်းသူ ရွေးချယ်ရန်',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TypeAheadField<Member>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: memberController,
                    decoration: InputDecoration(
                      labelText: 'သွေးလှူဒါန်းသူ အမည်',
                      hintText: 'အမည်ရိုက်ထည့်ပါ',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return cachedMembers
                        .where((member) =>
                            member.name != null &&
                            member.name!
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                        .take(10)
                        .toList();
                  },
                  itemBuilder: (context, Member member) {
                    return ListTile(
                      title: Text(member.name ?? ''),
                      subtitle: Text(
                          '${member.bloodType ?? ''} - ${member.memberId ?? ''}'),
                    );
                  },
                  onSuggestionSelected: (Member member) {
                    setState(() {
                      selectedMember = member;
                      memberController.text = member.name ?? '';
                    });
                  },
                ),
                if (selectedMember != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow('အမည်', selectedMember!.name ?? ''),
                        _infoRow('ကတ်နံပါတ်', selectedMember!.memberId ?? ''),
                        _infoRow(
                            'သွေးအမျိုးအစား', selectedMember!.bloodType ?? ''),
                        _infoRow('ဖုန်းနံပါတ်', selectedMember!.phone ?? ''),
                        _infoRow('လိပ်စာ', selectedMember!.address ?? ''),
                        _infoRow('လှူပြီးအကြိမ်',
                            selectedMember!.memberCount ?? '0'),
                        if (selectedMember!.lastDate != null)
                          _infoRow(
                              'နောက်ဆုံးလှူရက်',
                              DateFormat("dd MMM yyyy").format(
                                  DateTime.parse(selectedMember!.lastDate!))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Patient Information
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
                  'လူနာအချက်အလက်',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'လူနာအမည်',
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
                SizedBox(height: 12),
                Text(
                  'လူနာလိပ်စာ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quarterController,
                        decoration: InputDecoration(
                          labelText: 'ရပ်ကွက်',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TypeAheadField<String>(
                        textFieldConfiguration: TextFieldConfiguration(
                          controller: townController,
                          decoration: InputDecoration(
                            labelText: 'မြို့နယ်',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return townships
                              .where((township) => township
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase()))
                              .take(5)
                              .toList();
                        },
                        itemBuilder: (context, String township) {
                          return ListTile(
                            title: Text(township),
                          );
                        },
                        onSuggestionSelected: (String township) {
                          townController.text = township;
                        },
                      ),
                    ),
                  ],
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
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: hospitalController,
                    decoration: InputDecoration(
                      labelText: 'ဆေးရုံ/ဆေးခန်း',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return hospitals
                        .where((hospital) => hospital
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String hospital) {
                    return ListTile(
                      title: Text(hospital),
                    );
                  },
                  onSuggestionSelected: (String hospital) {
                    hospitalController.text = hospital;
                  },
                ),
                SizedBox(height: 12),
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: diseaseController,
                    decoration: InputDecoration(
                      labelText: 'ရောဂါအမျိုးအစား',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) {
                    return diseases
                        .where((disease) => disease
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, String disease) {
                    return ListTile(
                      title: Text(disease),
                    );
                  },
                  onSuggestionSelected: (String disease) {
                    diseaseController.text = disease;
                  },
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Donation Date
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
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        donationDateDetail = picked;
                        donationDate = DateFormat("dd MMM yyyy").format(picked);
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
            onPressed: () {
              final name = nameController.text;
              final age = ageController.text;
              final hospital = hospitalController.text;
              final disease = diseaseController.text;
              final quarter = quarterController.text;
              final township = townController.text;

              addDonation(name, age, hospital, disease, quarter, township);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Text(
              'သွေးလှူဒါန်းမှု ထည့်သွင်းမည်',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to create info rows
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ":",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
