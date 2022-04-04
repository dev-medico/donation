import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashBoardLabelShimmer extends StatelessWidget {
  const DashBoardLabelShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.5,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8, right: 8.0),
      child: Material(
        shadowColor: Colors.grey[50],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 6.0,
        child: Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: Colors.grey[200]!,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), color: Colors.white),
          ),
        ),
      ),
    );
  }
}
