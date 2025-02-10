import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';

class DashBoardLabelCard extends StatelessWidget {
  final String status;
  final String icon;
  final String title;
  final String count;
  final Color countColor;
  const DashBoardLabelCard(
      {Key? key,
      required this.status,
      required this.icon,
      required this.title,
      required this.count,
      required this.countColor})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width / 2.5
          : MediaQuery.of(context).size.width / 4.5,
      height: Responsive.isMobile(context)
          ? 118
          : MediaQuery.of(context).size.height / 5.7,
      margin: const EdgeInsets.only(top: 8.0, bottom: 8, right: 8.0),
      child: Material(
        shadowColor: Colors.grey[50],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 6.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          child: Material(
            type: MaterialType.transparency,
            elevation: 6.0,
            color: Colors.transparent,
            shadowColor: Colors.grey[50],
            child: InkWell(
              splashColor: Colors.white30,
              onTap: () {
                // Navigator.pushNamed(context, LabelListScreen.routeName,
                //     arguments: ScreenArguments(title, status));
              },
              child: Container(
                padding:
                    EdgeInsets.all(Responsive.isMobile(context) ? 16.0 : 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: Responsive.isMobile(context) ? 0 : 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            icon,
                            color: primaryColor,
                            height: Responsive.isMobile(context) ? 24 : 26,
                          ),
                          Text(
                            count,
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 16,
                              color: countColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 14 : 16,
                          color: Colors.black),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String status;

  ScreenArguments(this.title, this.status);
}
