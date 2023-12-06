import 'dart:typed_data';

import 'package:flutter/material.dart';
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
          child: GestureDetector(
            onTap: deleteOnTap,
            child: Container(
              alignment: Alignment.center,
              height: safeAreaHeight * 0.04,
              width: safeAreaHeight * 0.04,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: safeAreaWidth / 18,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
