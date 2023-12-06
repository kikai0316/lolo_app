import 'package:flutter/material.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

Widget bottomButton({
  required BuildContext context,
  required bool isWhiteMainColor,
  required String text,
  required void Function()? onTap,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    color: isWhiteMainColor ? Colors.white : Colors.black,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        height: safeAreaHeight * 0.065,
        width: safeAreaWidth * 0.95,
        child: nText(
          text,
          color: isWhiteMainColor ? Colors.black : Colors.white,
          fontSize: safeAreaWidth / 27,
          bold: 700,
        ),
      ),
    ),
  );
}

Widget borderButton({
  required BuildContext context,
  required String text,
  required void Function()? onTap,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        alignment: Alignment.center,
        height: safeAreaHeight * 0.065,
        width: safeAreaWidth * 0.95,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(15),
        ),
        child: nText(
          text,
          color: Colors.white,
          fontSize: safeAreaWidth / 27,
          bold: 700,
        ),
      ),
    ),
  );
}
