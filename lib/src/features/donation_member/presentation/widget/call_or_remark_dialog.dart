import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/widget/call_multi_phone_dialog.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:donation/src/features/donation_member/presentation/widget/remark_write_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallOrRemarkDialog extends StatelessWidget {
  final String? title;
  final Member? member;
  const CallOrRemarkDialog(
      {super.key, required this.title, required this.member});

  @override
  Widget build(BuildContext context) {
    final phone = (member?.phone ?? '').trim();
    final hasPhone = phone.isNotEmpty;
    final remark = DonorEligibility.normalizeRemark(member?.note);

    return CommonDialog(
      title: title.toString(),
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.3,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          if (remark.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                border: Border.all(color: const Color(0xFFFCD34D)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes_outlined,
                          size: 17, color: Color(0xFF854D0E)),
                      SizedBox(width: 6),
                      Text(
                        'မှတ်ချက်',
                        style: TextStyle(
                          color: Color(0xFF854D0E),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    remark,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
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
            margin: const EdgeInsets.only(left: 15, bottom: 16, right: 15),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: !hasPhone
                  ? null
                  : () {
                      Navigator.pop(context);
                      if (phone.contains(",")) {
                        final phones = phone
                            .split(',')
                            .map((item) => item.trim())
                            .where((item) => item.isNotEmpty)
                            .toList(growable: false);
                        showDialog(
                            context: context,
                            builder: (context) => CallMultiPhoneDialog(
                                title: "ဖုန်းခေါ်ဆိုမည်", phones: phones));
                      } else {
                        launchUrl(Uri(scheme: 'tel', path: phone));
                      }
                    },
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: Responsive.isMobile(context) ? 20 : 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            "assets/images/phone.png",
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            hasPhone ? "ဖုန်းခေါ်ဆိုမည်" : "ဖုန်းနံပါတ် မရှိပါ",
                            style: TextStyle(
                              fontSize: 15.0,
                              color: hasPhone ? Colors.black : Colors.grey,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                          ),
                        ],
                      ))),
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
                const EdgeInsets.only(left: 15, bottom: 28, right: 15, top: 28),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                    context: context,
                    builder: (context) => RemarkWriteDialog(
                          member: member,
                        ));
              },
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: Responsive.isMobile(context) ? 20 : 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
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
                            style:
                                TextStyle(fontSize: 15.0, color: Colors.black),
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
