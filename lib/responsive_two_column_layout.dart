import 'package:flutter/material.dart';

class Breakpoint {
  static const double desktop = 900;
  static const double tablet = 600;
}

/// Responsive layout that shows two child widgets side by side if there is
/// enough space, or vertically stacked if there is not enough space.
class ResponsiveTwoColumnLayout extends StatelessWidget {
  const ResponsiveTwoColumnLayout({
    Key? key,
    required this.startContent,
    required this.endContent,
    this.startFlex = 1,
    this.endFlex = 1,
    this.breakpoint = Breakpoint.tablet,
    required this.spacing,
    this.rowMainAxisAlignment = MainAxisAlignment.start,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.columnMainAxisAlignment = MainAxisAlignment.start,
    this.columnCrossAxisAlignment = CrossAxisAlignment.stretch,
  }) : super(key: key);
  final Widget startContent;
  final Widget endContent;
  final int startFlex;
  final int endFlex;
  final double breakpoint;
  final double spacing;
  final MainAxisAlignment rowMainAxisAlignment;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final MainAxisAlignment columnMainAxisAlignment;
  final CrossAxisAlignment columnCrossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            mainAxisAlignment: rowMainAxisAlignment,
            crossAxisAlignment: rowCrossAxisAlignment,
            children: [
              Flexible(flex: startFlex, child: startContent),
              SizedBox(width: spacing),
              Flexible(flex: endFlex, child: endContent),
            ],
          );
        } else {
          return ListView(
            shrinkWrap: true,
            // mainAxisAlignment: columnMainAxisAlignment,
            // crossAxisAlignment: columnCrossAxisAlignment,
            children: [
              startContent,
              SizedBox(height: spacing),
              endContent,
            ],
          );
        }
      },
    );
  }
}
