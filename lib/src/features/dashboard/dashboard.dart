import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/data/repository/repository.dart';
import 'package:donation/data/response/xata_donation_list_response.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card.dart';
import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/services/request_give_service.dart';
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

  callAPI(String after) {
    if (after.isEmpty) {
      setState(() {
        dataList = [];
        data = [];
      });
    }
    XataRepository().getDonationsList(after).then((response) {
      setState(() {
        dataList.addAll(
            XataDonationListResponse.fromJson(jsonDecode(response.body))
                .records!);
      });

      if (XataDonationListResponse.fromJson(jsonDecode(response.body))
              .meta!
              .page!
              .more ??
          false) {
        callAPI(XataDonationListResponse.fromJson(jsonDecode(response.body))
            .meta!
            .page!
            .cursor!);
      } else {
        data = [];
        for (int i = 0; i < dataList.length; i++) {
          //get current year
          var date = DateTime.now().toLocal();
          String donationYear = DateFormat('yyyy').format(date);

          var tempDate = "";
          if (dataList[i].date!.toString().contains("T")) {
            tempDate = dataList[i].date!.toString().split("T")[0];
          } else if (dataList[i].date!.toString().contains(" ")) {
            tempDate = dataList[i].date!.toString().split(" ")[0];
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
    String dateFormat = DateFormat('dd MMM yyyy ( EEEE )').format(date);

    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Padding(
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
      body: Responsive.isMobile(context)
          ? ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 8),
                      child: Row(
                        children: [
                          DashboardCard(
                            index: 0,
                            color: primaryDark,
                            title: "အဖွဲ့၀င် စာရင်း",
                            subtitle: "စုစုပေါင်း အရေအတွက်",
                            amount:
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                            amountColor: Colors.black,
                          ),
                          DashboardCard(
                            index: 1,
                            color: primaryDark,
                            title: "သွေးလှူမှု မှတ်တမ်း",
                            subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                            amount:
                                "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                            amountColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, top: 8, bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                DashboardCard(
                                  index: 2,
                                  color: primaryDark,
                                  title: "ထူးခြားဖြစ်စဉ်",
                                  subtitle: "",
                                  amount: "",
                                  amountColor: Colors.black,
                                ),
                                DashboardCard(
                                  index: 3,
                                  color: primaryDark,
                                  title: "ရ/သုံး ငွေစာရင်း",
                                  subtitle: "",
                                  amount: "",
                                  amountColor: Colors.black,
                                ),
                              ],
                            ),
                          ),
                          DashboardCard(
                            index: 4,
                            color: primaryDark,
                            title: "သွေးတောင်းခံ/လှူဒါန်းမှု",
                            subtitle: "အသေးစိတ် ကြည့်မည်",
                            amount: "",
                            amountColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Request Give Chart
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: BloodRequestGiveChartScreen(),
                ),
              ],
            )
          : Row(
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
                          DashboardCard(
                            index: 0,
                            color: primaryDark,
                            title: "အဖွဲ့၀င် စာရင်း",
                            subtitle: "စုစုပေါင်း အရေအတွက်",
                            amount:
                                "${Utils.strToMM(totalMember.toString())} ဦး",
                            amountColor: Colors.black,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 1,
                            color: primaryDark,
                            title: "သွေးလှူမှု မှတ်တမ်း",
                            subtitle: "စုစုပေါင်း အကြိမ်ရေ",
                            amount:
                                "${Utils.strToMM(totalDonation.toString())} ကြိမ်",
                            amountColor: Colors.blue,
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
                          DashboardCard(
                            index: 2,
                            color: primaryDark,
                            title: "ထူးခြားဖြစ်စဉ်",
                            subtitle: "အသေးစိတ် ကြည့်မည်",
                            amount: "",
                            amountColor: Colors.black,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          DashboardCard(
                            index: 3,
                            color: primaryDark,
                            title: "ရ/သုံး ငွေစာရင်း",
                            subtitle: "အသေးစိတ် ကြည့်မည်",
                            amount: "",
                            amountColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Request Give Chart for Desktop
                const Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(top: 12, right: 20),
                    child: BloodRequestGiveChartScreen(),
                  ),
                ),
              ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    if (!_formKey.currentState!.validate()) return;

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
          content: Text('သွေးတောင်းခံ/လှူဒါန်းမှု မှတ်တမ်း အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ'),
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
