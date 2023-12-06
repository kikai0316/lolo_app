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
