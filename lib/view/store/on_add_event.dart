import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/crop_img_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/login_widget.dart';

class OnAddEventPage extends HookConsumerWidget {
  OnAddEventPage({super.key, required this.onAdd});
  final void Function(StoryEventType) onAdd;
  final controllerList = List.generate(
      2,
      (index) =>
          TextEditingController(text: index == 0 ? null : initEventDetails));
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final eventImg = useState<Uint8List?>(null);
    final eventDate = useState<DateTime?>(null);
    return Stack(children: [
      Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        appBar: appBar(context, "イベント追加"),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                        onTap: () async {
                          isLoading.value = true;
                          await getMobileImage(onSuccess: (value) async {
                            final cropEvent = await cropEventImg(value);
                            if (cropEvent != null) {
                              eventImg.value = cropEvent;
                            }
                          }, onError: () {
                            errorSnackbar(context, message: "画像の取得に失敗しました");
                          });
                          isLoading.value = false;
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(15),
                                image: eventImg.value != null
                                    ? DecorationImage(
                                        image: MemoryImage(eventImg.value!),
                                        fit: BoxFit.cover)
                                    : null),
                            child: eventImg.value == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white.withOpacity(0.5),
                                        size: safeAreaWidth / 10,
                                      ),
                                      nText("カメラロールから画像を追加",
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: safeAreaWidth / 25,
                                          bold: 700)
                                    ],
                                  )
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(safeAreaWidth * 0.03),
                                      child: deleteIconWithCircle(
                                          size: safeAreaWidth * 0.1,
                                          padding: 0, //後
                                          onDelete: () =>
                                              eventImg.value = null),
                                    ),
                                  ))),
                  )),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.02,
                    right: safeAreaWidth * 0.03,
                    left: safeAreaWidth * 0.03),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                        opacity: 0.6, child: titleWithCircle(context, "開催日時")),
                    if (eventDate.value == null) ...{
                      addButton(context, onAdd: () async {
                        final getDate = await showCalendar(context);
                        if (getDate != null) {
                          eventDate.value = getDate;
                        }
                      })
                    }
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.02, bottom: safeAreaHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    nText(
                        eventDate.value == null
                            ? "未選択"
                            : toEvelntDateString(eventDate.value!),
                        color: Colors.white
                            .withOpacity(eventDate.value == null ? 0.5 : 1),
                        fontSize: safeAreaWidth / 20,
                        bold: 700),
                    if (eventDate.value != null) ...{
                      Padding(
                        padding: EdgeInsets.only(left: safeAreaWidth * 0.03),
                        child: deleteIconWithCircle(
                            size: safeAreaWidth * 0.07,
                            onDelete: () => eventDate.value = null,
                            padding: safeAreaWidth * 0.007),
                      )
                    }
                  ],
                ),
              ),
              Padding(
                padding: xPadding(context),
                child: Opacity(
                    opacity: 0.6, child: titleWithCircle(context, "イベント名")),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.02, bottom: safeAreaHeight * 0.04),
                child: StoreSetteingTextField(
                  subText: "イベント名を入力...",
                  title: "",
                  isError: false,
                  controller: controllerList[0],
                  onChanged: (value) {},
                ),
              ),
              Padding(
                padding: xPadding(context),
                child: Opacity(
                    opacity: 0.6, child: titleWithCircle(context, "イベント詳細")),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.02, bottom: safeAreaHeight * 0.04),
                child: EventDetailsField(
                  isError: false,
                  controller: controllerList[1],
                  onChanged: (value) {},
                ),
              ),
              SizedBox(
                height: safeAreaHeight * 0.2,
              )
            ],
          ),
        ),
      ),
      SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: bottomButton(
              context: context,
              isWhiteMainColor: true,
              text: "追加",
              onTap: () {
                if (eventImg.value != null &&
                    eventDate.value != null &&
                    controllerList[0].text.isNotEmpty) {
                  Navigator.pop(context);
                  onAdd(StoryEventType(
                    img: eventImg.value!,
                    date: eventDate.value!,
                    title: controllerList[0].text,
                    detail: controllerList[1].text,
                  ));
                } else {
                  errorSnackbar(context,
                      message:
                          "${eventImg.value == null ? "画像、" : ""}${eventDate.value == null ? "開催日時、" : ""}${controllerList[0].text.isEmpty ? "イベント名、" : ""}を入力してください。");
                }
              }),
        ),
      ),
      loadinPage(context: context, isLoading: isLoading.value, text: null)
    ]);
  }

  Widget addButton(BuildContext context, {required void Function() onAdd}) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          alignment: Alignment.center,
          height: safeAreaWidth * 0.07,
          width: safeAreaWidth * 0.07,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String toEvelntDateString(
    DateTime date,
  ) {
    final DateFormat formatter = DateFormat('y年M月d日（ E ）', 'ja_JP');
    return formatter.format(date);
  }
}

class EventDetailsField extends HookConsumerWidget {
  const EventDetailsField({
    super.key,
    required this.controller,
    required this.isError,
    required this.onChanged,
  });
  final bool isError;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return Container(
      width: safeAreaWidth * 0.95,
      constraints: BoxConstraints(maxHeight: safeAreaHeight * 0.5),
      decoration: BoxDecoration(
        border: isError ? Border.all(color: Colors.red) : null,
        color: blackColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: safeAreaWidth * 0.06, right: safeAreaWidth * 0.06),
        child: TextFormField(
          controller: controller,
          maxLines: null,
          onChanged: onChanged,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: "Normal",
            fontVariations: const [FontVariation("wght", 400)],
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: safeAreaWidth / 27,
          ),
          decoration: InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: "詳細を入力",
            hintStyle: TextStyle(
              fontFamily: "Normal",
              fontVariations: const [FontVariation("wght", 400)],
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: safeAreaWidth / 34,
            ),
          ),
        ),
      ),
    );
  }
}

class StoryEventType {
  Uint8List img;
  String title;
  String detail;
  DateTime date;
  StoryEventType({
    required this.img,
    required this.date,
    required this.detail,
    required this.title,
  });
}
