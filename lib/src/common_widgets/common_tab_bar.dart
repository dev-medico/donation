import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';

class CommonTabBar extends StatelessWidget {
  const CommonTabBar({super.key, required this.listWidget, this.underline});

  final List<CommonTabBarWidget> listWidget;
  final bool? underline;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
          color: (underline ?? false)
              ? Colors.white
              : const Color.fromARGB(255, 235, 233, 233),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: listWidget,
        ),
      ),
    );
  }
}

class CommonTabBarWidget extends StatelessWidget {
  const CommonTabBarWidget(
      {super.key,
      required this.name,
      required this.isSelected,
      required this.i,
      required this.onTap,
      this.underline,
      this.color});

  final String name;
  final int isSelected;
  final int i;
  final bool? underline;
  final Color? color;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: (underline ?? false)
              ? BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: isSelected == i
                              ? color ?? primaryColor
                              : Colors.transparent,
                          width: 4)))
              : BoxDecoration(
                  color: isSelected == i
                      ? color ?? primaryColor
                      : Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(5))),
          height: 40,
          child: Text(
            name,
            style: TextStyle(
                fontSize: 14,
                color: isSelected == i
                    ? (underline ?? false)
                        ? Colors.black
                        : Colors.white
                    : const Color(0xff5C5C5C)),
          ),
        ),
      ),
    );
  }
}
