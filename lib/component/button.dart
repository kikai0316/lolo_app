import 'package:flutter/material.dart';
import 'package:lolo_app/constant/color.dart';
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

Widget shadowButton(
  BuildContext context, {
  required String text,
  required void Function() onTap,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: safeAreaHeight * 0.065,
      width: safeAreaWidth * 0.95,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: const LinearGradient(
          begin: FractionalOffset.centerLeft,
          end: FractionalOffset.centerRight,
          colors: [blueColor2, blueColor],
        ),
        boxShadow: [
          BoxShadow(
            color: blueColor2.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: nText(
        text,
        color: Colors.white,
        fontSize: safeAreaWidth / 27,
        bold: 700,
      ),
    ),
  );
}

Widget miniButton({
  required BuildContext context,
  required String text,
  required void Function()? onTap,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    color: Colors.grey.withOpacity(0.2),
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        height: safeAreaHeight * 0.05,
        width: safeAreaWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: nText(
          text,
          color: Colors.white,
          fontSize: safeAreaWidth / 30,
          bold: 700,
        ),
      ),
    ),
  );
}

Widget lineLoginButton({
  required BuildContext context,
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
        width: safeAreaWidth * 0.8,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 6, 199, 85),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(safeAreaWidth * 0.02),
              child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage("assets/img/line.png"),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  )),
            ),
            nText(
              "LINEアカウントでログイン",
              color: Colors.white,
              fontSize: safeAreaWidth / 28,
              bold: 700,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget miniButtonWithCustomColor({
  required BuildContext context,
  required String text,
  required void Function()? onTap,
  required Color color,
  required Color textColor,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    color: color,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        height: safeAreaHeight * 0.05,
        width: safeAreaWidth * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: nText(
          text,
          color: textColor,
          fontSize: safeAreaWidth / 30,
          bold: 700,
        ),
      ),
    ),
  );
}

Widget addButton(BuildContext context, {required void Function() onTap}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    color: blueColor,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        // height: safeAreaHeight * 0.04,
        // width: safeAreaWidth * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.all(safeAreaWidth * 0.02),
          child: nText("＋アップロード",
              color: Colors.white, fontSize: safeAreaWidth / 35, bold: 700),
        ),
      ),
    ),
  );
}

Widget textButton(
    {required void Function() onTap,
    required String text,
    required double size}) {
  return TextButton(
    onPressed: onTap,
    style: ButtonStyle(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.grey.withOpacity(0.1);
          }
          return null;
        },
      ),
    ),
    child: nText(text, color: Colors.white, fontSize: size, bold: 700),
  );
}
