import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/img_fullscreen_page.dart';
import 'package:lolo_app/view/store/event_fullscreen_sheet.dart';
import 'package:lolo_app/widget/app_widget.dart';

Widget storeTitleWithCircleAndAddWidget(BuildContext context,
    {required String text,
    required void Function()? onAdd,
    required int? count}) {
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
              nText(count == null ? "" : "　( $count/5 )",
                  color: Colors.white.withOpacity(0.5),
                  fontSize: safeAreaWidth / 30,
                  bold: 700),
            ],
          ),
          if (onAdd != null)
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

Widget storyWidget(BuildContext context,
    {required StoryImgType data, required void Function() onDelete}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  String ofTime(
    DateTime date,
  ) {
    final DateFormat formatter = DateFormat('y年M月d日', 'ja_JP');
    return formatter.format(date);
  }

  return AspectRatio(
      aspectRatio: 9 / 16,
      child: GestureDetector(
        onTap: () {
          OverlayEntry? overlayEntry;
          overlayEntry = OverlayEntry(
            builder: (context) => ImgFullScreenPage(
              img: data.img,
              onCancel: () => overlayEntry?.remove(),
            ),
          );
          Overlay.of(context).insert(overlayEntry);
        },
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: MemoryImage(data.img), fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaWidth * 0.015),
                    child: deleteIconWithCircle(
                        size: safeAreaHeight * 0.04,
                        onDelete: onDelete,
                        padding: 0),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaWidth * 0.015),
                    child: nTextWithShadow(ofTime(data.date),
                        opacity: 1,
                        color: Colors.white,
                        fontSize: safeAreaWidth / 28,
                        bold: 700),
                  ),
                ),
              ],
            )),
      ));
}

Widget eventWidget(BuildContext context,
    {required EventType data, required void Function()? onDelete}) {
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
    child: Column(
      children: [
        AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => bottomSheet(context,
                  page: EventFullScreenSheet(event: data),
                  isBackgroundColor: false),
              child: Container(
                  alignment: Alignment.bottomRight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: MemoryImage(data.img), fit: BoxFit.cover),
                  ),
                  child: Stack(
                    children: [
                      if (onDelete != null) ...{
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.all(safeAreaWidth * 0.015),
                            child: deleteIconWithCircle(
                                size: safeAreaHeight * 0.04,
                                onDelete: onDelete,
                                padding: 0),
                          ),
                        )
                      },
                      Align(
                        alignment: const Alignment(1, -1.6),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            children: [
                              nTextWithShadow(toEvelntDateOfTime(data.date),
                                  color: Colors.white,
                                  fontSize: safeAreaWidth / 18,
                                  opacity: 1,
                                  bold: 700),
                              nTextWithShadow(toEvelntDateOfWeek(data.date),
                                  color: Colors.white,
                                  fontSize: safeAreaWidth / 30,
                                  opacity: 1,
                                  bold: 700),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            )),
        Container(
            alignment: Alignment.topCenter,
            width: safeAreaWidth * 1,
            child: Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
              child: Text(
                data.title,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  height: 1,
                  decoration: TextDecoration.none,
                  fontFamily: "Normal",
                  fontVariations: const [FontVariation("wght", 700)],
                  color: Colors.white,
                  fontSize: safeAreaWidth / 35,
                ),
              ),
            ))
      ],
    ),
  );
}
