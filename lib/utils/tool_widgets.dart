import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:merchant/utils/Colors.dart';

BoxDecoration shadowDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(11, 254, 245, 245),
        blurRadius: 24,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Color.fromARGB(11, 254, 245, 245),
        blurRadius: 24,
        offset: Offset(-2, -2),
      ),
    ],
  );
}

BoxDecoration shadowDecorationWithBorder(Color color, Color borderColor) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: borderColor, width: 1.4),
    boxShadow: const [
      BoxShadow(
        color: Color.fromARGB(11, 254, 245, 245),
        blurRadius: 24,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Color.fromARGB(11, 254, 245, 245),
        blurRadius: 24,
        offset: Offset(-2, -2),
      ),
    ],
  );
}

BoxDecoration shadowDecorationOnlyTop(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0c000000),
        blurRadius: 24,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Color(0x0c000000),
        blurRadius: 24,
        offset: Offset(-2, -2),
      ),
    ],
  );
}

BoxDecoration borderDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: color, width: 1),
  );
}

BoxDecoration borderDecorationNoRadius(Color color) {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: color, width: 0.1),
  );
}

BoxDecoration normalDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(12),
  );
}

InputDecoration inputBoxDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: const TextStyle(fontSize: 14, color: Colors.black),

    fillColor: const Color(0xFFefefef),
    contentPadding: const EdgeInsets.only(left: 20, right: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(),
    ),
    //fillColor: Colors.green
  );
}

InputDecoration searchDecoration(String hintText) {
  return InputDecoration(
    filled: true,
    hintText: hintText,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    suffixIcon: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: SvgPicture.asset(
          'assets/images/search.svg',
          width: 20,
        ),
      ),
    ),
    suffixIconConstraints: const BoxConstraints(
      minWidth: 16,
      minHeight: 16,
    ),
  );
}

BoxDecoration shadowDecorationGradient() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    gradient: LinearGradient(
        colors: [
          secondColor,
          secondColor,
        ],
        begin: const FractionalOffset(0.0, 0.0),
        end: const FractionalOffset(0.0, 1.0),
        stops: const [0.0, 1.0],
        tileMode: TileMode.clamp),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0c000000),
        blurRadius: 24,
        offset: Offset(2, 2),
      ),
      BoxShadow(
        color: Color(0x0c000000),
        blurRadius: 24,
        offset: Offset(-2, -2),
      ),
    ],
    color: Colors.white,
  );
}
