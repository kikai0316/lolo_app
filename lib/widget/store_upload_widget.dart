import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/img_fullscreen_page.dart';
import 'package:lolo_app/view/store/on_add_event.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:marquee/marquee.dart';

Widget storeTitleWithCircleAndAddWidget(
  BuildContext context, {
  required String text,
  required void Function() onAdd,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return SizedBox(
    width: safeAreaWidth * 1,
    child: Padding(
      padding: EdgeInsets.only(
          left: safeAreaWidth * 0.03,
          right: safeAreaWidth * 0.03,
          top: safeAreaHeight * 0.03,
          bottom: safeAreaHeight * 0.005),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: safeAreaWidth * 0.02),
                child: Container(
                  height: safeAreaWidth * 0.055,
                  width: safeAreaWidth * 0.055,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              nText(text,
                  color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
            ],
          ),
          Material(
            color: blueColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.04,
                width: safeAreaWidth * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: safeAreaWidth / 18,
                    ),
                    nText("追加",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 25,
                        bold: 700),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget postImgWidget(BuildContext context,
    {required Uint8List img, required void Function() onDelete}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return AspectRatio(
      aspectRatio: 9 / 16,
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
            alignment: Alignment.bottomRight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
              image:
                  DecorationImage(image: MemoryImage(img), fit: BoxFit.cover),
            ),
            child: Padding(
              padding: EdgeInsets.all(safeAreaWidth * 0.015),
              child: deleteIconWithCircle(
                  size: safeAreaHeight * 0.04,
                  onDelete: onDelete,
                  padding: 0), //後
            )),
      ));
}

Widget eventImgWidget(BuildContext context,
    {required StoryEventType data, required void Function() onDelete}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  String toEvelntDateOfTime(
    DateTime date,
  ) {
    final DateFormat formatter = DateFormat('M/d', 'ja_JP');
    return formatter.format(date);
  }

  String toEvelntDateOfWeek(
    DateTime date,
  ) {
    final DateFormat formatter = DateFormat('( E )', 'ja_JP');
    return formatter.format(date);
  }

  return SizedBox(
    width: safeAreaWidth * 0.4,
    height: safeAreaHeight * 0.18,
    child: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                      alignment: Alignment.bottomRight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: MemoryImage(data.img), fit: BoxFit.cover),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(safeAreaWidth * 0.015),
                        child: deleteIconWithCircle(
                            size: safeAreaHeight * 0.04,
                            onDelete: onDelete,
                            padding: 0), //後
                      )),
                )),
            Container(
              alignment: Alignment.center,
              height: safeAreaHeight * 0.04,
              width: safeAreaWidth * 1,
              child: Marquee(
                text: 'こんにちは！今日はいい天気ですね！', //表示するテキスト
                blankSpace: safeAreaWidth * 0.1, //空白
                velocity: 60, //速さ
                style: TextStyle(
                  decoration: TextDecoration.none,
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 700)],
                  color: Colors.white,
                  fontSize: safeAreaWidth / 25,
                ),
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  ),
                ]),
            child: Row(
              children: [
                nTextWithShadow(toEvelntDateOfTime(data.date),
                    color: Colors.white,
                    fontSize: safeAreaWidth / 18,
                    bold: 700),
                nTextWithShadow(toEvelntDateOfWeek(data.date),
                    color: Colors.white,
                    fontSize: safeAreaWidth / 30,
                    bold: 700),
              ],
            ),
          ),
        )
      ],
    ),
  );
}
