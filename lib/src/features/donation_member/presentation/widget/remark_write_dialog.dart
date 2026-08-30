import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/src/ui/blood_chip.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';

class RemarkWriteDialog extends ConsumerStatefulWidget {
  final Member? member;

  /// Called with the saved member so an open directory can update that one row
  /// in place. Without it the directory falls back to a full refresh.
  final void Function(Member saved)? onSaved;

  const RemarkWriteDialog({super.key, required this.member, this.onSaved});

  @override
  ConsumerState<RemarkWriteDialog> createState() => _RemarkWriteDialogState();
}

class _RemarkWriteDialogState extends ConsumerState<RemarkWriteDialog> {
  TextEditingController remarkController = TextEditingController();
  bool checked = false;
  bool isLoading = false;

  /// The remarks staff actually save, most frequent first in the ledger:
  /// switched-off or unreachable phones, donors now working abroad, health
  /// rests, pregnancy. One tap fills the field mid-call.
  static const List<String> _quickRemarks = [
    'ဖုန်းစက်ပိတ်ထား',
    'ဖုန်းဆက်လို့မရ',
    'ယိုးဒယားရောက်နေ',
    'နိုင်ငံခြားရောက်နေ',
    'ကျန်းမာရေးအရ နားထား',
    'ကိုယ်ဝန်ရှိ',
  ];

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

  void _fillQuickRemark(String phrase) {
    final existing = remarkController.text.trim();
    final next = existing.isEmpty ? phrase : '$existing၊ $phrase';
    remarkController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  Future<void> _save() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Only update the two fields controlled by this dialog. Search rows
      // contain a derived last donation date, so reposting the whole row
      // could overwrite newer data.
      final repository = ref.read(memberRepositoryProvider);
      final saved = await repository.updateMemberAvailability(
        widget.member!.id.toString(),
        canDonate: checked,
        note: remarkController.text.trim(),
      );

      // The update endpoint returns the raw member record; merge only the
      // availability fields onto the directory row so the derived effective
      // last-donation date survives.
      final merged = (widget.member ?? saved).withAvailability(
        status: saved.status ?? (checked ? 'available' : 'not_available'),
        note: saved.note ?? remarkController.text.trim(),
        canDonateValue: saved.canDonateValue,
      );

      // The member-list screen re-fetches on its next visit.
      ref.invalidate(memberListProvider);

      final onSaved = widget.onSaved;
      if (onSaved != null) {
        // The directory updates this one row in place: no reload, no lost
        // scroll position while the admin works down the list.
        onSaved(merged);
      } else {
        ref.invalidate(searchMemberListProvider);
      }

      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        final name = (merged.name ?? '').trim();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              name.isEmpty ? 'သိမ်းဆည်းပြီးပါပြီ' : '$name — သိမ်းဆည်းပြီးပါပြီ',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'သိမ်းဆည်း၍ မရသေးပါ။ အင်တာနက်ကို စစ်ဆေးပြီး ထပ်မံကြိုးစားပါ။',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
          _MemberIdentityHeader(member: widget.member),
          const SizedBox(height: 14),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12),
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
            margin: const EdgeInsets.only(left: 12, right: 12, top: 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final phrase in _quickRemarks)
                  ActionChip(
                    key: ValueKey('quick-remark-$phrase'),
                    label: Text(phrase),
                    labelStyle: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF334155),
                    ),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: StadiumBorder(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: isLoading ? null : () => _fillQuickRemark(phrase),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(left: 12, bottom: 16, right: 12, top: 24),
            child: FilledButton.icon(
              onPressed: isLoading ? null : _save,
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

/// Names the donor being edited. Admins work through hundreds of similar rows
/// in one sitting; showing who this save belongs to prevents editing the
/// wrong donor after a mis-tap.
class _MemberIdentityHeader extends StatelessWidget {
  const _MemberIdentityHeader({required this.member});

  final Member? member;

  @override
  Widget build(BuildContext context) {
    final name = (member?.name ?? '').trim();
    final details = <String>[
      if ((member?.memberId ?? '').trim().isNotEmpty)
        member!.memberId!.trim(),
      if ((member?.phone ?? '').trim().isNotEmpty) member!.phone!.trim(),
    ];

    return Container(
      key: const ValueKey('remark-member-identity'),
      margin: const EdgeInsets.only(left: 12, right: 12, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          BloodChip(bloodType: member?.bloodType, size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'အမည်မရှိ' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    details.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
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
}
