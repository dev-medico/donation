import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:flutter/material.dart';

class MonthlyReportDialog extends StatelessWidget {
  final String title;
  final Widget child;
  const MonthlyReportDialog(
      {super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
        title: title,
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.5,
        child: child);
  }
}
