import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/xata_donation_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/responsive_dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation/providers/donation_providers.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class DashBoardScreen extends ConsumerStatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);
  static const routeName = "/dashboard";

  @override
  ConsumerState<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends ConsumerState<DashBoardScreen> {
  late int totalMember = 0;
  late int totalDonar = 0;
  late int totalDonation = 0;
  bool finance = false;
  List<DonationRecord> dataList = [];
  List<DonationRecord> data = [];

  @override
  void initState() {
    super.initState();
    // Load data after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() async {
    // Load member count
    try {
      final membersAsync = ref.read(memberListProvider);
      if (membersAsync.hasValue) {
        setState(() {
          totalMember = membersAsync.value?.length ?? 0;
        });
      }
    } catch (e) {
      print('Error loading members: $e');
    }

    // Load donation count
    try {
      // Get current year donations count
      final currentYear = DateTime.now().year;
      final donationsAsync =
          await ref.read(donationsByYearProvider(currentYear).future);
      setState(() {
        totalDonation = donationsAsync.length;
      });
    } catch (e) {
      print('Error loading donations: $e');
    }
  }

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        dataList = [];
        data = [];
      });
    }
    XataRepository().getDonationsList(after).then((response) {
      setState(() {
        final responseData =
            XataDonationListResponse.fromJson(jsonDecode(response.body));
        if (responseData.records != null) {
          dataList.addAll(responseData.records!);
        }
      });

      final responseData =
          XataDonationListResponse.fromJson(jsonDecode(response.body));
      if (responseData.meta?.page?.more == true &&
          responseData.meta?.page?.cursor != null) {
        callAPI(responseData.meta!.page!.cursor!);
      } else {
        data = [];
        for (int i = 0; i < dataList.length; i++) {
          //get current year
          var date = DateTime.now().toLocal();
          String donationYear = DateFormat('yyyy').format(date);

          var tempDate = "";
          final dateStr = dataList[i].date?.toString() ?? "";
          if (dateStr.contains("T")) {
            tempDate = dateStr.split("T")[0];
          } else if (dateStr.contains(" ")) {
            tempDate = dateStr.split(" ")[0];
          }

          if (tempDate.split("-")[0] == donationYear) {
            setState(() {
              data.add(dataList[i]);
            });
          }
        }

        setState(() {
          data = data.reversed.toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.now().toLocal();
    // String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: Responsive.isMobile(context) 
            ? null 
            : const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text("RED Juniors Blood Care Unit",
                    style: TextStyle(fontSize: 17, color: Colors.white)),
              ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: Responsive.isMobile(context) ? 16.0 : 30),
            child: SvgPicture.asset(
              "assets/images/noti.svg",
              width: 26,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

          if (isMobile || isTablet) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ResponsiveDashboardCard(
                          index: 0,
                          color: primaryDark,
                          title: "အဖွဲ့၀င်\nစာရင်း",
                          subtitle: "စုစုပေါင်း",
                          amount: Utils.strToMM(totalMember.toString()),
                          amountColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResponsiveDashboardCard(
                          index: 1,
                          color: primaryDark,
                          title: "သွေးလှူမှု\nမှတ်တမ်း",
                          subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                          amount: Utils.strToMM(totalDonation.toString()),
                          amountColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ResponsiveDashboardCard(
                          index: 2,
                          color: primaryDark,
                          title: "ထူးခြား\nဖြစ်စဉ်",
                          subtitle: "စုစုပေါင်း",
                          amount: Utils.strToMM(totalDonar.toString()),
                          amountColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ResponsiveDashboardCard(
                          index: 3,
                          color: primaryDark,
                          title: "ရ/သုံး\nငွေစာရင်း",
                          subtitle: "အသေးစိတ်",
                          amount: finance ? "364995500/32152850" : "",
                          amountColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ResponsiveDashboardCard(
                    index: 4,
                    color: primaryDark,
                    title: "သွေးတောင်းခံ/လှူဒါန်းမှု",
                    subtitle: "အသေးစိတ် ကြည့်မည်",
                    amount: "",
                    amountColor: Colors.black,
                  ),
                  const SizedBox(height: 16),
                  // Request Give Chart
                  const BloodRequestGiveChartScreen(),
                  const SizedBox(height: 16),
                  // Disease Chart
                  BloodDonationPieChart(),
                ],
              ),
            );
          } else {
            // Desktop layout
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 20.0, top: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResponsiveDashboardCard(
                              index: 0,
                              color: primaryDark,
                              title: "အဖွဲ့၀င် စာရင်း",
                              subtitle: "စုစုပေါင်း အရေအတွက်",
                              amount:
                                  "${Utils.strToMM(totalMember.toString())} ဦး",
                              amountColor: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ResponsiveDashboardCard(
                              index: 1,
                              color: primaryDark,
                              title: "သွေးလှူမှု မှတ်တမ်း",
                              subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                              amount:
                                  "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                              amountColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 12, right: 12, top: 20, bottom: 8),
                      width: MediaQuery.of(context).size.width / 2.15,
                      height: 1,
                      color: Colors.grey,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ResponsiveDashboardCard(
                              index: 2,
                              color: primaryDark,
                              title: "ထူးခြားဖြစ်စဉ်",
                              subtitle: "အသေးစိတ် ကြည့်မည်",
                              amount: "",
                              amountColor: Colors.black,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ResponsiveDashboardCard(
                              index: 3,
                              color: primaryDark,
                              title: "ရ/သုံး ငွေစာရင်း",
                              subtitle: "အသေးစိတ် ကြည့်မည်",
                              amount: "",
                              amountColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Charts column for Desktop
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Request Give Chart for Desktop
                        const Padding(
                          padding: EdgeInsets.only(top: 12, right: 20),
                          child: BloodRequestGiveChartScreen(),
                        ),
                        // Disease Chart for Desktop
                        Padding(
                          padding: EdgeInsets.only(top: 12, right: 20),
                          child: BloodDonationPieChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRequestGiveDialog();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'သွေးတောင်းခံ/လှူဒါန်းမှု ထည့်သွင်းမည်',
      ),
    );
  }

  void _showAddRequestGiveDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddRequestGiveDialog(
        ref: ref,
        onAdded: () {
          // Refresh the chart data
          setState(() {});
        },
      ),
    );
  }
}

// Add Request Give Dialog Widget
class _AddRequestGiveDialog extends StatefulWidget {
  final WidgetRef ref;
  final VoidCallback onAdded;

  const _AddRequestGiveDialog({
    required this.ref,
    required this.onAdded,
  });

  @override
  State<_AddRequestGiveDialog> createState() => _AddRequestGiveDialogState();
}

class _AddRequestGiveDialogState extends State<_AddRequestGiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  final _giveController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်းအသစ်'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month picker
              InkWell(
                onTap: () async {
                  final picked = await showMonthPicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_month),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Request amount field
              TextFormField(
                controller: _requestController,
                decoration: const InputDecoration(
                  labelText: 'တောင်းခံသည့် အရေအတွက်',
                  border: OutlineInputBorder(),
                  suffixText: 'ကြိမ်',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ကိန်းဂဏန်းသာ ထည့်သွင်းပါ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Give amount field
              TextFormField(
                controller: _giveController,
                decoration: const InputDecoration(
                  labelText: 'လှူဒါန်းခဲ့သည့် အရေအတွက်',
                  border: OutlineInputBorder(),
                  suffixText: 'ကြိမ်',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ဖြည့်သွင်းရန် လိုအပ်ပါသည်';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ကိန်းဂဏန်းသာ ထည့်သွင်းပါ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'request': int.parse(_requestController.text),
        'give': int.parse(_giveController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };

      // Call the API service to create request give
      final service = widget.ref.read(requestGiveServiceProvider);
      await service.createRequestGive(data);

      Navigator.pop(context);
      widget.onAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _requestController.dispose();
    _giveController.dispose();
    super.dispose();
  }
}
