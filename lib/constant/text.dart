import 'dart:ui';

import 'package:flutter/material.dart';

Widget nText(
  String text, {
  required Color color,
  required double fontSize,
  required double bold,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      decoration: TextDecoration.none,
      fontFamily: "Normal",
      fontVariations: [FontVariation("wght", bold)],
      color: color,
      fontSize: fontSize,
    ),
  );
}

Widget nTextWithShadow(
  String text, {
  required Color color,
  required double fontSize,
  required double bold,
}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      decoration: TextDecoration.none,
      fontFamily: "Normal",
      shadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 1.0,
        )
      ],
      fontVariations: [FontVariation("wght", bold)],
      color: color,
      fontSize: fontSize,
    ),
  );
}
