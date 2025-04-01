import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/donation.dart';
import 'package:donation/src/features/donation_member/presentation/member_edit.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  static const routeName = '/member-detail';
  final String memberId;
  final bool isEditable;

  const MemberDetailScreen(
      {Key? key, required this.memberId, this.isEditable = true})
      : super(key: key);

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  bool _isLoading = true;
  Member? _member;
  List<Donation> _donations = [];
  String? _errorMessage;
  final MemberRepository _repository = MemberRepository();

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  Future<void> _loadMemberData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final memberData = await _repository.getMemberById(widget.memberId);

      if (!mounted) return;

      setState(() {
        _member = memberData.member;
        _donations = memberData.donations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint("Error loading member data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Padding(
          padding: EdgeInsets.only(top: 4, right: 20),
          child: Center(
            child: Text("အဖွဲ့၀င် အချက်အလက်များ",
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMemberData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _member != null
                  ? _buildMemberDetailView(context, _member!, _donations)
                  : const Center(child: Text('No member data found')),
    );
  }

  Widget _buildMemberDetailView(
      BuildContext context, Member member, List<Donation> donations) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member Info Card - Left Half
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Image.asset("assets/images/card.png", width: 54),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("အဖွဲ့၀င်အမှတ်",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
                              const SizedBox(height: 8),
                              Text(
                                member.memberId ?? 'N/A',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("ရက်စွဲ",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 116, 112, 112))),
                            const SizedBox(height: 8),
                            Text(
                              member.registerDate ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow("အမည်", member.name ?? 'N/A'),
                  _buildInfoRow("အဖအမည်", member.fatherName ?? 'N/A'),
                  _buildInfoRow("မွေးသက္ကရာဇ်", member.birthDate ?? 'N/A'),
                  _buildInfoRow(
                      "နိုင်ငံသားစီစစ်ရေး\nကတ်ပြားအမှတ်", member.nrc ?? 'N/A'),
                  _buildInfoRow("သွေးအုပ်စု", member.bloodType ?? 'N/A'),
                  _buildInfoRow(
                      "သွေးဘဏ်ကတ်နံပါတ်", member.bloodBankCard ?? 'N/A'),
                  _buildInfoRow("လိင်အမျိုးအစား", _formatGender(member.gender)),
                  _buildInfoRow(
                      "အဖွဲ့နှင့်သွေးလှူဒါန်းမှု", donations.length.toString()),
                  _buildInfoRow(
                      "စုစုပေါင်းသွေးလှူဒါန်းမှု", member.totalCount ?? '0'),
                  _buildInfoRow("ဖုန်းနံပါတ်", member.phone ?? 'N/A'),
                  _buildAddressRow("နေရပ်လိပ်စာ", member.address ?? 'N/A'),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  widget.isEditable
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              right: 12,
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("ပြင်ဆင်မည်",
                                      style: TextStyle(
                                          fontSize: 15, color: primaryColor)),
                                  const SizedBox(width: 8),
                                  Image.asset(
                                    "assets/images/edit.png",
                                    width: 24,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MemberEditScreen(
                                      memberId: member.id.toString(),
                                      member: member,
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true) {
                                    _loadMemberData();

                                    // Reset filters when returning from member edit
                                    resetFilterProviders(ref);
                                  }
                                });
                              },
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),

          // Space between cards
          const SizedBox(width: 20),

          // Donation History Card - Right Half
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "သွေးလှူဒါန်းမှတ်တမ်း",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: donations.isEmpty
                        ? Center(
                            child: Text(
                              "သွေးလှူဒါန်းမှတ်တမ်း မရှိပါ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: donations.length,
                            itemBuilder: (context, index) =>
                                _buildDonationCard(donations[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      donation.date ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    donation.hospital ?? 'N/A',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      const Text(
                        "လူနာ - ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          donation.patientName ?? 'N/A',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "ရောဂါ - ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          donation.patientDisease ?? 'N/A',
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 116, 112, 112),
                    height: 1.8)),
          ),
          const Text("-", style: TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text("$label   - ",
                style: const TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 116, 112, 112))),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _formatGender(String? gender) {
    if (gender == null) return 'N/A';

    switch (gender.toLowerCase()) {
      case 'male':
        return 'ကျား';
      case 'female':
        return 'မ';
      default:
        return gender;
    }
  }
}
