import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/img_fullscreen_page.dart';

Widget imgWidget(
  BuildContext context,
  Key? key, {
  required void Function()? deleteOnTap,
  required Uint8List img,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Card(
    key: key,
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: GestureDetector(
      onTap: () {
        OverlayEntry? overlayEntry;
        overlayEntry = OverlayEntry(
          builder: (context) => ImgFullScreenPage(
            img: img,
            onCancel: () => overlayEntry?.remove(),
          ),
        );
        Overlay.of(context).insert(overlayEntry);
      },
      child: Container(
        key: key,
        height: safeAreaHeight / 4,
        width: safeAreaWidth / 4,
        alignment: Alignment.bottomRight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(image: MemoryImage(img), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: EdgeInsets.all(safeAreaWidth * 0.01),
          child: deleteIconWithCircle(
              size: safeAreaHeight * 0.04,
              onDelete: deleteOnTap!,
              padding: 0), //後
        ),
      ),
    ),
  );
}

PreferredSizeWidget? appBar(BuildContext context, String? title) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    actions: [
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
            color: Colors.black.withOpacity(0.7),
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
