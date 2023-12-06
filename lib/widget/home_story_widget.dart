import 'package:flutter/material.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';

Widget otherWidget(
  BuildContext context, {
  required Widget widget,
  required void Function()? onTap,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: safeAreaWidth * 0.17,
      width: safeAreaWidth * 0.17,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
        ],
        color: blackColor,
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget,
    ),
  );
}

Widget myAccountWidget(
  BuildContext context,
) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return SizedBox(
    height: safeAreaWidth * 0.21,
    width: safeAreaWidth * 0.17,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          alignment: Alignment.center,
          height: safeAreaWidth * 0.17,
          width: safeAreaWidth * 0.17,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1.0,
              ),
            ],
            image: notImg(),
            color: blackColor,
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: safeAreaWidth * 0.08,
            width: safeAreaWidth * 0.08,
            decoration: const BoxDecoration(
              color: blueColor2,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 10,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
