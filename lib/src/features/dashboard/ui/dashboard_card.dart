import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:merchant/responsive.dart';
import 'package:merchant/src/features/donation_member/presentation/member_list.dart';

import '../../donar/donar_list.dart';
import '../../donation/blood_donation_list_new_style.dart';
import '../../donation_member/presentation/member_list_back_up.dart';
import '../../special_event/event_list.dart';

class DashboardCard extends StatelessWidget {
  int index;
  Color color;
  String title;
  String subtitle;
  String amount;
  Color amountColor;
  Function() onTap;

  DashboardCard(
      {Key? key,
      required this.index,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.amount,
      required this.amountColor,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height / 4.75
            : amount == ""
                ? MediaQuery.of(context).size.height / 5.2
                : MediaQuery.of(context).size.height / 4,
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
              await Navigator.pushNamed(context, MemberListScreen.routeName);
              onTap.call();
            } else if (index == 1) {
              await Navigator.pushNamed(
                  context, BloodDonationListNewStyle.routeName);
              onTap.call();
            } else if (index == 2) {
              await Navigator.pushNamed(context, EventListScreen.routeName);
              onTap.call();
            } else if (index == 3) {
              await Navigator.pushNamed(context, DonarList.routeName);
              onTap.call();
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
                      fontSize: Responsive.isMobile(context) ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 16,
                      color:
                          NeumorphicTheme.of(context)?.current!.variantColor),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  amount,
                  style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 17 : 20,
                      fontWeight: FontWeight.bold,
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
