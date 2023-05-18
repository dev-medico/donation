import 'package:flutter/material.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_card_shimmer.dart';
import 'package:donation/src/features/dashboard/ui/dashboard_label_shimmer.dart';
import 'package:donation/utils/Colors.dart';

class DashboardLoading extends StatelessWidget {
  const DashboardLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: primaryColor,
          height: MediaQuery.of(context).size.height / 2.5,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8),
              child: Row(
                children: const [
                  DashBoardCardShimmer(),
                  DashBoardCardShimmer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8),
              child: Row(
                children: const [
                  DashBoardCardShimmer(),
                  DashBoardCardShimmer(),
                ],
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 10.0, top: 4),
                scrollDirection: Axis.horizontal,
                children: const [
                  DashBoardLabelShimmer(),
                  DashBoardLabelShimmer(),
                  DashBoardLabelShimmer(),
                  DashBoardLabelShimmer(),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
