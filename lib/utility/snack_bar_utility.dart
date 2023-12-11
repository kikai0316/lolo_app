import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lolo_app/utility/utility.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void errorSnackbar(BuildContext context, {required String message}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  HapticFeedback.vibrate();
  Flushbar(
    backgroundColor: Colors.red,
    padding: EdgeInsets.only(
      left: safeAreaWidth * 0.03,
      right: safeAreaWidth * 0.03,
      top: safeAreaHeight * 0.01,
      bottom: safeAreaHeight * 0.01,
    ),
    flushbarPosition: FlushbarPosition.TOP,
    margin: EdgeInsets.only(
      right: safeAreaWidth * 0.03,
      left: safeAreaWidth * 0.03,
    ),
    borderRadius: BorderRadius.circular(15),
    messageText: SizedBox(
      width: safeAreaWidth * 1,
      child: Padding(
        padding: EdgeInsets.all(
          safeAreaHeight * 0.01,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: safeAreaWidth * 0.03),
              child: Icon(
                Icons.error,
                color: Colors.white,
                size: safeAreaWidth / 12,
              ),
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 700)],
                  color: Colors.white,
                  fontSize: safeAreaWidth / 28,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    duration: const Duration(seconds: 4),
  ).show(context);
}
