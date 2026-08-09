import 'package:flutter/material.dart';

class Humberger extends StatelessWidget {
  final Function onTap;
  const Humberger({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          label: 'မီနူး',
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppBar().preferredSize.height),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.menu_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
            onTap: () {
              onTap.call();
            },
          ),
        ),
      ),
    );
  }
}
