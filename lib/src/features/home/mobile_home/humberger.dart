import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Humberger extends StatelessWidget {
  Function onTap;
  Humberger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppBar().preferredSize.height - 8,
      height: AppBar().preferredSize.height - 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppBar().preferredSize.height),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SvgPicture.asset(
              "assets/images/menu_humberger.svg",
              width: 20,
              color: Colors.white,
            ),
          )),
          onTap: () {
            onTap.call();
          },
        ),
      ),
    );
  }
}
