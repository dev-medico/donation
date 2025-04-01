import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_edit.dart';
import 'package:flutter/material.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  Member? memberData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
    });
  }

  Future<void> _loadMemberData() async {
    try {
      ref.invalidate(memberByIdProvider(widget.memberId));
      await ref.read(memberByIdProvider(widget.memberId).future);
    } catch (e) {
      print("Error loading member data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberAsync = ref.watch(memberByIdProvider(widget.memberId));
    final isLoading = ref.watch(memberLoadingProvider);
    final errorMessage = ref.watch(memberErrorProvider);

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $errorMessage'),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(memberByIdProvider(widget.memberId));
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : memberAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $error'),
                        ElevatedButton(
                          onPressed: () {
                            ref.refresh(memberByIdProvider(widget.memberId));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (member) => _buildMemberDetailView(context, member),
                ),
    );
  }

  Widget _buildMemberDetailView(BuildContext context, Member member) {
    return Responsive.isMobile(context)
        ? ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                decoration: shadowDecoration(Colors.white),
                margin: const EdgeInsets.only(
                    top: 8, left: 20, right: 20, bottom: 20),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
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
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
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
                              Text(
                                  Responsive.isMobile(context)
                                      ? "ရက်စွဲ"
                                      : "အဖွဲ့ဝင်သည့်ရက်စွဲ",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color:
                                          Color.fromARGB(255, 116, 112, 112))),
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
                      width: MediaQuery.of(context).size.width - 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow("အမည်", member.name ?? 'N/A'),
                    _buildInfoRow("အဖအမည်", member.fatherName ?? 'N/A'),
                    _buildInfoRow("မွေးသက္ကရာဇ်", member.birthDate ?? 'N/A'),
                    _buildInfoRow("နိုင်ငံသားစီစစ်ရေး\nကတ်ပြားအမှတ်",
                        member.nrc ?? 'N/A'),
                    _buildInfoRow("သွေးအုပ်စု", member.bloodType ?? 'N/A'),
                    _buildInfoRow(
                        "သွေးဘဏ်ကတ်နံပါတ်", member.bloodBankCard ?? 'N/A'),
                    _buildInfoRow("လိင်အမျိုးအစား", member.gender ?? 'N/A'),
                    _buildInfoRow(
                        "အဖွဲ့နှင့်သွေးလှူဒါန်းမှု", member.memberCount ?? '0'),
                    _buildInfoRow(
                        "စုစုပေါင်းသွေးလှူဒါန်းမှု", member.totalCount ?? '0'),
                    _buildInfoRow("ဖုန်းနံပါတ်", member.phone ?? 'N/A'),
                    _buildAddressRow("နေရပ်လိပ်စာ", member.address ?? 'N/A'),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width - 80,
                      color: Colors.grey,
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
                                          memberId: member.id.toString()),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: shadowDecoration(Colors.white),
                  margin: const EdgeInsets.only(
                    left: 20,
                    top: 30,
                    bottom: 20,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
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
                                          color: Color.fromARGB(
                                              255, 116, 112, 112))),
                                  const SizedBox(height: 12),
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
                                const Text("အဖွဲ့ဝင်သည့်ရက်စွဲ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 116, 112, 112))),
                                const SizedBox(height: 12),
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
                        width: MediaQuery.of(context).size.width - 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow("အမည်", member.name ?? 'N/A'),
                      _buildInfoRow("အဖအမည်", member.fatherName ?? 'N/A'),
                      _buildInfoRow("မွေးသက္ကရာဇ်", member.birthDate ?? 'N/A'),
                      _buildInfoRow("နိုင်ငံသားစီစစ်ရေး\nကတ်ပြားအမှတ်",
                          member.nrc ?? 'N/A'),
                      _buildInfoRow("သွေးအုပ်စု", member.bloodType ?? 'N/A'),
                      _buildInfoRow(
                          "သွေးဘဏ်ကတ်နံပါတ်", member.bloodBankCard ?? 'N/A'),
                      _buildInfoRow("လိင်အမျိုးအစား", member.gender ?? 'N/A'),
                      _buildInfoRow("အဖွဲ့နှင့်သွေးလှူဒါန်းမှု",
                          member.memberCount ?? '0'),
                      _buildInfoRow("စုစုပေါင်းသွေးလှူဒါန်းမှု",
                          member.totalCount ?? '0'),
                      _buildInfoRow("ဖုန်းနံပါတ်", member.phone ?? 'N/A'),
                      _buildAddressRow("နေရပ်လိပ်စာ", member.address ?? 'N/A'),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width - 80,
                        color: Colors.grey,
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
                                              fontSize: 15,
                                              color: primaryColor)),
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
                                            memberId: member.id.toString()),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
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
}
