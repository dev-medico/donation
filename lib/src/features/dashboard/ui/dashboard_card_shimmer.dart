import 'package:flutter/material.dart';
import 'package:merchant/utils/Colors.dart';
import 'package:merchant/utils/tool_widgets.dart';
import 'package:shimmer/shimmer.dart';

class DashBoardCardShimmer extends StatelessWidget {
  const DashBoardCardShimmer({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: primaryDark,
        highlightColor: primaryColor,
        child: Container(
          decoration: shadowDecoration(primaryColor),
          margin: const EdgeInsets.only(top: 12, right: 12),
          height: 86,
        ),
      ),
    );
  }
}
