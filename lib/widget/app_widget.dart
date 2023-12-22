import 'package:flutter/material.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

PreferredSizeWidget? appBar(
    BuildContext context, String? title, bool isLeftIcon) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: isLeftIcon,
    actions: isLeftIcon
        ? null
        : [
            Padding(
              padding: EdgeInsets.only(right: safeAreaWidth * 0.04),
              child: IconButton(
                alignment: Alignment.center,
                splashRadius: safeAreaHeight * 0.03,
                onPressed: () => Navigator.pop(context),
                icon: Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close,
                    size: safeAreaWidth / 13,
                  ),
                ),
              ),
            )
          ],
    title: title == null
        ? null
        : nText(
            title,
            color: Colors.white,
            fontSize: safeAreaWidth / 17,
            bold: 700,
          ),
  );
}

Widget deleteIconWithCircle({
  required double size,
  required void Function() onDelete,
  required double padding,
}) {
  return GestureDetector(
    onTap: onDelete,
    child: Container(
      alignment: Alignment.center,
      height: size,
      width: size,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1.0,
          )
        ],
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: const FittedBox(
          fit: BoxFit.fitWidth,
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget titleWithCircle(BuildContext context, String text) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
        padding: EdgeInsets.only(right: safeAreaWidth * 0.02),
        child: Container(
          height: safeAreaWidth * 0.05,
          width: safeAreaWidth * 0.05,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
      nText(text, color: Colors.white, fontSize: safeAreaWidth / 25, bold: 700)
    ],
  );
}
