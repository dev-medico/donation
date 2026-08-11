import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    checked = widget.member?.canDonate ?? true;
    remarkController.text =
        DonorEligibility.normalizeRemark(widget.member?.note);
  }

  @override
  void dispose() {
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNarrowPhone =
        Responsive.isMobile(context) && MediaQuery.sizeOf(context).width <= 360;

    return CommonDialog(
      title: "လှူဒါန်းနိုင်မှု ပြင်ရန်",
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checked
                            ? 'လှူဒါန်းခွင့် ဖွင့်ထားသည်'
                            : 'လှူဒါန်းခွင့် ပိတ်ထားသည်',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: checked
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checked
                            ? '၄ လစောင့်ဆိုင်းကာလ သို့မဟုတ် မှတ်ချက်ရှိလျှင် အဝါရောင်ဖြင့် ဆက်လက်ပြပါမည်။'
                            : 'စာရင်းတွင် အနီရောင်ဖြင့် ပြပါမည်။',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: checked
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: 'လှူဒါန်းခွင့်',
                  value: checked ? 'ဖွင့်ထားသည်' : 'ပိတ်ထားသည်',
                  child: Switch(
                    value: checked,
                    onChanged: (value) {
                      setState(() {
                        checked = value;
                      });
                    },
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    inactiveTrackColor: Colors.red.shade200,
                  ),
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
                labelText: 'မှတ်ချက် (ရှိပါက)',
                hintText:
                    'ဆက်သွယ်မေးမြန်းရန် သို့မဟုတ် သတိပြုရန် အချက်ကို ရေးပါ',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.0),
                fillColor: Colors.white.withValues(alpha: 0.2),
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
            width: double.infinity,
            margin:
                const EdgeInsets.only(left: 12, bottom: 16, right: 12, top: 28),
            child: FilledButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        // Only update the two fields controlled by this dialog.
                        // Search rows contain a derived last donation date, so
                        // reposting the whole row could overwrite newer data.
                        final repository = ref.read(memberRepositoryProvider);
                        await repository.updateMemberAvailability(
                          widget.member!.id.toString(),
                          canDonate: checked,
                          note: remarkController.text.trim(),
                        );

                        // Both views will re-fetch from the updated source.
                        ref.invalidate(memberListProvider);
                        ref.invalidate(searchMemberListProvider);

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
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                isLoading ? 'သိမ်းဆည်းနေပါသည်...' : 'အချက်အလက် သိမ်းမည်',
                style: const TextStyle(fontFamily: 'MyanUni'),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontSize: isNarrowPhone ? 14 : 15,
                  fontFamily: 'MyanUni',
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
