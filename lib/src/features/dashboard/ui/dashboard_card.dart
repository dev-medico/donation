import 'package:donation/src/features/donar/donar_list_screen.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/finder/request_give_list_screen.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardCard extends ConsumerWidget {
  final int index;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  DashboardCard({
    Key? key,
    required this.index,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Container(
        height: Responsive.isMobile(context)
            ? amount == ""
                ? MediaQuery.of(context).size.height / 9
                : MediaQuery.of(context).size.height / 6
            : amount == ""
                ? MediaQuery.of(context).size.height * 0.11
                : MediaQuery.of(context).size.height * 0.2,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
          ),
          child: InkWell(
            borderRadius:
                BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
            onTap: () async {
              if (index == 0) {
                await Navigator.pushNamed(context, MemberListScreen.routeName);
              } else if (index == 1) {
                await Navigator.pushNamed(context, DonationListScreen.routeName);
              } else if (index == 2) {
                // Navigate to special events
                await Navigator.pushNamed(context, SpecialEventListScreen.routeName);
              } else if (index == 3) {
                // Navigate to donar list for finance
                await Navigator.pushNamed(context, DonarListScreen.routeName);
              } else if (index == 4) {
                // Navigate to request give list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestGiveListScreen(),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Responsive.isMobile(context)
                      ? Container()
                      : Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 13 : 14,
                          ),
                        ),
                  const SizedBox(
                    height: 4,
                  ),
                  amount != ""
                      ? Text(
                          amount,
                          style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 16 : 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        )
                      : Container(),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
