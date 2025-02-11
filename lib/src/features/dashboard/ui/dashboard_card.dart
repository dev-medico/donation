import 'package:donation/src/features/donar/donar_list_new.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/patient/patient_list.dart';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../donar/donar_list.dart';

class DashboardCard extends ConsumerWidget {
  int index;
  Color color;
  String title;
  String subtitle;
  String amount;
  Color amountColor;

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
              // Todo
              // if (index == 0) {
              //   // ref.watch(membersProvider).forEach((element) {
              //   //   ref.watch(realmProvider)!.deleteMember(element);
              //   // });
              //   // await Navigator.pushNamed(
              //   //     context, MemberListBackupScreen.routeName);
              //   await Navigator.pushNamed(context, MemberListScreen.routeName);
              // } else if (index == 1) {
              //   // ref.watch(donationsProvider).forEach((element) {
              //   //   ref.watch(realmProvider)!.deleteDonation(element);
              //   // });
              //   await Navigator.pushNamed(context, DonationListScreen.routeName);
              // } else if (index == 2) {
              //   await Navigator.pushNamed(context, PatientList.routeName);
              // } else if (index == 3) {
              //   await Navigator.pushNamed(context, DonarListNewScreen.routeName);
              // }
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
