import 'package:donation/realm/realm_services.dart';
import 'package:donation/realm/schemas.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/utils/Colors.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RemarkWriteDialog extends ConsumerStatefulWidget {
  final Member? member;
  const RemarkWriteDialog({super.key, required this.member});

  @override
  ConsumerState<RemarkWriteDialog> createState() => _RemarkWriteDialogState();
}

class _RemarkWriteDialogState extends ConsumerState<RemarkWriteDialog> {
  TextEditingController remarkController = TextEditingController();
  bool checked = false;

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
          fluent.Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: fluent.ToggleSwitch(
              checked: checked,
              onChanged: (v) => setState(() => checked = v),
              content: Text(checked ? 'Available' : 'Not Available'),
            ),
          ),
          SizedBox(
            height: 24,
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
              onTap: () {
                Navigator.pop(context);
                ref.watch(realmProvider)!.updateMember(widget.member!,
                    note: remarkController.text.toString(),
                    status: checked ? "available" : "not_available");
              },
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8, left: 30),
                      child: Row(
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
                            "မှတ်ချက်ရေးမည်",
                            textScaleFactor: 1.0,
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
