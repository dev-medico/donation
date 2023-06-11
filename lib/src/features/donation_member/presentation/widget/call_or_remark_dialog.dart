import 'package:donation/responsive.dart';
import 'package:donation/src/features/donation_member/presentation/widget/common_dialog.dart';
import 'package:flutter/material.dart';

class CallOrRemarkDialog extends StatelessWidget {
  final String? message;
  final String? title;
  const CallOrRemarkDialog(
      {super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
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
          Text(
            message.toString(),
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [],
          )
        ],
      ),
    );
  }
}
