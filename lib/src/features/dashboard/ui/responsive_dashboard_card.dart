import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/src/features/donar/donar_list_screen.dart';
import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:donation/src/features/finder/request_give_list_screen.dart';

class ResponsiveDashboardCard extends StatelessWidget {
  final int index;
  final Color color;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  const ResponsiveDashboardCard({
    Key? key,
    required this.index,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (index == 0) {
              await Navigator.pushNamed(context, MemberListScreen.routeName);
            } else if (index == 1) {
              await Navigator.pushNamed(context, DonationListScreen.routeName);
            } else if (index == 2) {
              await Navigator.pushNamed(context, SpecialEventListScreen.routeName);
            } else if (index == 3) {
              await Navigator.pushNamed(context, DonarListScreen.routeName);
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RequestGiveListScreen(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Check if height is bounded
                final hasAmount = amount.isNotEmpty;
                final isHeightBounded = constraints.maxHeight != double.infinity;
                
                if (!hasAmount || !isHeightBounded) {
                  // If no amount or unbounded height, use intrinsic layout
                  return IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 12 : 14,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 10 : 11,
                              color: Colors.grey,
                            ),
                          ),
                        if (hasAmount) ...[
                          const SizedBox(height: 8),
                          Text(
                            amount,
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: amountColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                } else {
                  // If bounded height and has amount, use spaceBetween layout
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context) ? 12 : 14,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: Responsive.isMobile(context) ? 12 : 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 10 : 11,
                            color: Colors.grey,
                          ),
                        ),
                      const Spacer(),
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: amountColor,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}