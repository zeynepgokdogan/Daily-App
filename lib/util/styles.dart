import 'package:flutter/material.dart';

const TextStyle customTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 15.0,
  fontWeight: FontWeight.w400,
  height: 21.6 / 18.0,
  letterSpacing: 0.02,
  color: Colors.black,
);

const TextStyle hintTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  height: 21.6 / 18.0,
  letterSpacing: 0.02,
  color: Colors.black,
);

const TextStyle appBarTextStyle = TextStyle(
  fontFamily: 'Poppins',
  fontSize: 18.0,
  fontWeight: FontWeight.w800,
  height: 21.6 / 18.0,
  letterSpacing: 0.02,
  color: accentColor,
);

IconThemeData iconStyle({
  Color color = Colors.white,
  double iconSize = 18.0,
}) {
  return IconThemeData(
    color: color,
    size: iconSize,
  );
}

const Color primaryColor = Color(0xFFF26950);
const Color secondaryColor = Color(0xFFf79c8c);
const Color accentColor = Color(0xFf58a6ef);
