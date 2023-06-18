import 'package:donation/src/features/donation/blood_donation_list_new_style.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/special_event/special_event_list.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
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
                ? MediaQuery.of(context).size.height / 8
                : MediaQuery.of(context).size.height / 4.3
            : amount == ""
                ? MediaQuery.of(context).size.height * 0.15
                : MediaQuery.of(context).size.height * 0.2,
        margin: const EdgeInsets.only(top: 12, right: 12),
        child: NeumorphicButton(
          style: NeumorphicStyle(
            color: Colors.white,
            boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16)),
            depth: 4,
            intensity: 0.8,
            shadowDarkColor: Colors.black,
            shadowLightColor: Colors.white,
          ),
          onPressed: () async {
            if (index == 0) {
              // ref.watch(membersProvider).forEach((element) {
              //   ref.watch(realmProvider)!.deleteMember(element);
              // });
              // await Navigator.pushNamed(
              //     context, MemberListBackupScreen.routeName);
              await Navigator.pushNamed(context, MemberListScreen.routeName);
            } else if (index == 1) {
              // ref.watch(donationsProvider).forEach((element) {
              //   ref.watch(realmProvider)!.deleteDonation(element);
              // });
              await Navigator.pushNamed(
                  context, BloodDonationListNewStyle.routeName);
            } else if (index == 2) {
              await Navigator.pushNamed(
                  context, SpecialEventListScreen.routeName);
            } else if (index == 3) {
              await Navigator.pushNamed(context, DonarList.routeName);
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
                      fontSize: Responsive.isMobile(context) ? 15 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const Spacer(),
                Responsive.isMobile(context)
                    ? Container()
                    : Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 13 : 16,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .variantColor),
                      ),
                const SizedBox(
                  height: 12,
                ),
                amount != ""
                    ? Text(
                        amount,
                        style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 17 : 20,
                            fontWeight: FontWeight.bold,
                            color: NeumorphicTheme.of(context)
                                ?.current!
                                .defaultTextColor),
                      )
                    : Container(),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
