import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/src/features/donar/donar_list.dart';
import 'package:merchant/src/features/donation/blood_donation_list.dart';
import 'package:merchant/src/features/member/member_list.dart';

class DashBoardCard extends StatelessWidget {
  final int index;
  final Color color;
  final String title;
  final String amount;
  final Color amountColor;
  final VoidCallback callBack;
  const DashBoardCard(
      {Key? key,
      required this.index,
      required this.color,
      required this.title,
      required this.amount,
      required this.amountColor,
      required this.callBack})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height / 7.9,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: NeumorphicButton(
          onPressed: () async {
            if (index == 0) {
              await Navigator.pushNamed(context, MemberList.routeName);
              callBack();
            } else if (index == 1) {
              await Navigator.pushNamed(context, BloodDonationList.routeName);
              callBack();
            } else if (index == 2) {
              await Navigator.pushNamed(context, DonarList.routeName);
              callBack();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const Spacer(),
                Text(
                  amount,
                  style: TextStyle(
                      color: NeumorphicTheme.of(context)
                          ?.current!
                          .defaultTextColor),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
