import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/store/event_fullscreen_sheet.dart';
import 'package:lolo_app/view/pages/img_fullscreen_page.dart';
import 'package:lolo_app/view/store/store_information.dart';

final List<String> storeSettingTitle = [
  "店舗名",
  "住所",
  "座標",
  "営業時間",
  "検索キーワード",
  "店舗コード",
];
PreferredSizeWidget? storeAppBar(
    BuildContext context, StoreData storeData, int? crowdingSelectNumber) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;

  return PreferredSize(
    preferredSize: Size.fromHeight(safeAreaHeight * 0.08),
    child: AppBar(
        backgroundColor: blackColor,
        elevation: 0,
        // automaticallyImplyLeading: isLeftIcon,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: safeAreaWidth * 0.04),
            child: IconButton(
              alignment: Alignment.center,
              splashRadius: safeAreaHeight * 0.03,
              onPressed: () =>
                  screenTransitionNormal(context, const StoreInformation()),
              icon: Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.settings,
                  size: safeAreaWidth / 13,
                ),
              ),
            ),
          )
        ],
        title: SizedBox(
          width: safeAreaWidth * 0.9,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: safeAreaWidth * 0.03),
                child: Container(
                  alignment: const Alignment(1.1, 1.1),
                  height: safeAreaWidth * 0.12,
                  width: safeAreaWidth * 0.12,
                  decoration: BoxDecoration(
                    image: storeData.logo != null
                        ? DecorationImage(
                            image: MemoryImage(storeData.logo!),
                            fit: BoxFit.cover)
                        : notImg(),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                      height: safeAreaWidth * 0.045,
                      width: safeAreaWidth * 0.045,
                      decoration: BoxDecoration(
                        color: crowdingSelectNumber != null
                            ? [
                                greenColor,
                                yellowColor,
                                redColor
                              ][crowdingSelectNumber]
                            : null,
                        shape: BoxShape.circle,
                      )),
                ),
              ),
              Expanded(
                  child: Container(
                alignment: Alignment.centerLeft,
                child: nText(storeData.name,
                    color: Colors.white,
                    fontSize: safeAreaWidth / 20,
                    bold: 700),
              ))
            ],
          ),
        )),
  );
}

Widget crowdingWidget(BuildContext context,
    {required void Function(int) onTap, required int? selectNumber}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  final colorList = [greenColor, yellowColor, redColor];
  return Expanded(
    child: Container(
      height: safeAreaHeight * 0.05,
      decoration: BoxDecoration(
        color: blackColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++) ...{
            Expanded(
                child: GestureDetector(
              onTap: i == selectNumber ? null : () => onTap(i),
              child: Opacity(
                opacity: i == selectNumber ? 1 : 0.3,
                child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectNumber == i
                          ? Colors.white.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            i == 0 ? const Radius.circular(50) : Radius.zero,
                        bottomLeft:
                            i == 0 ? const Radius.circular(50) : Radius.zero,
                        bottomRight:
                            i == 2 ? const Radius.circular(50) : Radius.zero,
                        topRight:
                            i == 2 ? const Radius.circular(50) : Radius.zero,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: safeAreaWidth * 0.03,
                          width: safeAreaWidth * 0.03,
                          decoration: BoxDecoration(
                            color: colorList[i],
                            boxShadow: [
                              BoxShadow(
                                color: colorList[i].withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 1.0,
                              )
                            ],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: safeAreaHeight * 0.005),
                          child: nText(["余裕あり", "やや混雑", "大混雑"][i],
                              color: Colors.white.withOpacity(0.9),
                              fontSize: safeAreaWidth / 40,
                              bold: 700),
                        )
                      ],
                    )),
              ),
            )),
            if (i != 2)
              Container(
                height: safeAreaHeight * 0.06,
                width: 1,
                color: Colors.grey.withOpacity(0.5),
              )
          }
        ],
      ),
    ),
  );
}

Widget storeNotPost(BuildContext context, IconData? icon, String message) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Opacity(
    opacity: 0.5,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...{
          Padding(
            padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
            child: Container(
              alignment: Alignment.center,
              height: safeAreaHeight * 0.08,
              width: safeAreaHeight * 0.08,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: safeAreaWidth / 13,
              ),
            ),
          ),
        },
        nText(message,
            color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
      ],
    ),
  );
}

Widget storeStoryWidget(
  BuildContext context, {
  required StoryType data,
  required void Function() onDelete,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);

  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(bottom: safeAreaHeight * 0.005),
        child: nText(timeAgo(data.date),
            color: Colors.white, fontSize: safeAreaWidth / 35, bold: 700),
      ),
      SizedBox(
        height: safeAreaHeight * 0.21,
        child: AspectRatio(
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
                alignment: Alignment.topRight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                      image: MemoryImage(data.img), fit: BoxFit.cover),
                ),
                child: GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaWidth * 0.005),
                    child: Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1.0,
                        )
                      ],
                      size: safeAreaWidth / 18,
                    ),
                  ),
                ),
              ),
            )),
      ),
    ],
  );
}

Widget storeEventWidget(BuildContext context,
    {required EventType data, required void Function()? onDelete}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  String toEvelntDateOfTime(
    DateTime date,
  ) {
    final DateFormat formatter = DateFormat('M/d ( E )', 'ja_JP');
    return formatter.format(date);
  }

  return SizedBox(
    width: safeAreaWidth * 0.4,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: safeAreaHeight * 0.005),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              nText("開催日：",
                  color: Colors.white.withOpacity(0.5),
                  fontSize: safeAreaWidth / 40,
                  bold: 700),
              nText(toEvelntDateOfTime(data.date),
                  color: Colors.white, fontSize: safeAreaWidth / 27, bold: 700),
            ],
          ),
        ),
        AspectRatio(
            aspectRatio: 16 / 9,
            child: GestureDetector(
              onTap: () => bottomSheet(context,
                  page: EventFullScreenSheet(event: data),
                  isBackgroundColor: false),
              child: Container(
                  alignment: Alignment.topRight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: MemoryImage(data.img), fit: BoxFit.cover),
                  ),
                  child: onDelete != null
                      ? Padding(
                          padding: EdgeInsets.all(safeAreaWidth * 0.001),
                          child: GestureDetector(
                            onTap: onDelete,
                            child: Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                              size: safeAreaWidth / 15,
                              shadows: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 10,
                                  spreadRadius: 10.0,
                                )
                              ],
                            ),
                          ),
                        )
                      : null),
            )),
      ],
    ),
  );
}
