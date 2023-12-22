import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/app_widget.dart';

class EventFullScreenSheet extends HookConsumerWidget {
  const EventFullScreenSheet({super.key, required this.event});
  final EventType event;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;

    return Container(
      height: safeAreaHeight * 0.95,
      color: blackColor,
      child: Stack(
        children: [
          Column(
            children: [
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    alignment: Alignment.topRight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: MemoryImage(event.img), fit: BoxFit.cover),
                    ),
                  )),
              Padding(
                padding: xPadding(context),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.03,
                          bottom: safeAreaHeight * 0.02),
                      child: titleWithCircle(context, "開催日時"),
                    ),
                    nText(toEvelntDateString(event.date),
                        color: Colors.white,
                        fontSize: safeAreaWidth / 20,
                        bold: 700),
                    Padding(
                      padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.03,
                          bottom: safeAreaHeight * 0.02),
                      child: titleWithCircle(context, "イベント名"),
                    ),
                    nText(event.title,
                        color: Colors.white,
                        fontSize: safeAreaWidth / 20,
                        bold: 700),
                  ],
                ),
              )
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: bottomButton(
                  context: context,
                  isWhiteMainColor: true,
                  text: "とじる",
                  onTap: () => Navigator.pop(context)),
            ),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget? appBar(BuildContext context, String title) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: blackColor,
      title: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: safeAreaWidth / 13,
              ),
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
    );
  }
}
