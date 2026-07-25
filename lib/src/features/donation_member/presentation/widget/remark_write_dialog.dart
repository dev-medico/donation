import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';

class RemarkWriteDialog extends ConsumerStatefulWidget {
  final Member? member;
  const RemarkWriteDialog({super.key, required this.member});

  @override
  ConsumerState<RemarkWriteDialog> createState() => _RemarkWriteDialogState();
}

class _RemarkWriteDialogState extends ConsumerState<RemarkWriteDialog> {
  TextEditingController remarkController = TextEditingController();
  bool checked = false;
  bool isLoading = false;
  final MemberRepository _repository = MemberRepository();

  @override
  void initState() {
    super.initState();
    checked = widget.member!.status == "available";
    remarkController.text = widget.member!.note ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: "မှတ်ချက်ရေးရန်",
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 20),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: checked ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: checked ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  checked ? 'သွေးလှူနိုင်သည်' : 'သွေးမလှူနိုင်ပါ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: checked ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                Switch(
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      checked = value;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                  inactiveTrackColor: Colors.red.shade200,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12),
            child: TextFormField(
              autofocus: false,
              controller: remarkController,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              onChanged: (val) {},
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '',
                hintStyle: const TextStyle(color: Colors.black, fontSize: 15.0),
                fillColor: Colors.white.withOpacity(0.2),
                filled: true,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12, bottom: 50),
                  child: Icon(
                    Icons.edit,
                    color: primaryColor,
                  ),
                ),
                contentPadding: const EdgeInsets.only(
                    left: 20, right: 20, top: 24, bottom: 24),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey)),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
          Container(
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.3,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.all(Radius.circular(12.0))),
            margin:
                const EdgeInsets.only(left: 15, bottom: 16, right: 15, top: 34),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: isLoading 
                ? null 
                : () async {
                    setState(() {
                      isLoading = true;
                    });
                    
                    try {
                      // Create updated member with new status and note
                      final updatedMember = Member(
                        id: widget.member!.id,
                        memberId: widget.member!.memberId,
                        name: widget.member!.name,
                        fatherName: widget.member!.fatherName,
                        birthDate: widget.member!.birthDate,
                        nrc: widget.member!.nrc,
                        phone: widget.member!.phone,
                        bloodBankCard: widget.member!.bloodBankCard,
                        address: widget.member!.address,
                        bloodType: widget.member!.bloodType,
                        gender: widget.member!.gender,
                        memberCount: widget.member!.memberCount,
                        totalCount: widget.member!.totalCount,
                        registerDate: widget.member!.registerDate,
                        status: checked ? "available" : "not_available",
                        lastDate: widget.member!.lastDate,
                        note: remarkController.text.trim(),
                      );
                      
                      // Update member via repository
                      await _repository.updateMember(
                        widget.member!.id.toString(), 
                        updatedMember
                      );
                      
                      // Refresh both member list and search list. Awaited only
                      // so the re-fetch finishes before we pop; the refreshed
                      // value itself isn't needed here.
                      // ignore: unused_result
                      await ref.refresh(memberListProvider.future);
                      
                      // Invalidate the search member list provider to force refresh
                      ref.invalidate(searchMemberListWithYearProvider);
                      
                      // This will trigger a re-fetch of the search member list
                      // which will then update the filteredSearchMemberListProvider automatically
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('အချက်အလက်များ သိမ်းဆည်းပြီးပါပြီ'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 30),
                      child: isLoading 
                        ? Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/remark.png",
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                "မှတ်ချက်သိမ်းမည်",
                                style:
                                    TextStyle(fontSize: 16.0, color: Colors.black),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                            ],
                      ))),
            ),
          )
        ],
      ),
    );
  }
}
