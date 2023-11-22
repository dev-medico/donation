import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    required this.title,
    required this.width,
    required this.child,
    this.height,
    this.isExpand = false,
  });
  final String title;
  final Widget child;
  final double width;
  final double? height;

  final bool isExpand;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: width,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogGradientTitleWidget(
              title: title,
              width: width,
              height: 60,
            ),
            SizedBox(
              height: Responsive.isMobile(context) ? 2 : 10,
            ),
            Flexible(
              flex: isExpand ? 1 : 0,
              child: Padding(
                padding: Responsive.isMobile(context)
                    ? EdgeInsets.fromLTRB(20, 4, 20, 0)
                    : EdgeInsets.fromLTRB(10, 20, 30, 30),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogGradientTitleWidget extends StatelessWidget {
  const DialogGradientTitleWidget({
    Key? key,
    required this.title,
    required this.width,
    required this.height,
  }) : super(key: key);

  final String title;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: <Color>[
            primaryDark,
            primaryDark,
          ], // red to yellow
          // tileMode: TileMode.repeated, // repeats the gradient over the canvas
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isMobile(context) ? 15 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
