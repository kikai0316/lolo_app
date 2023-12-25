import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/crop_img_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/login/login_widget.dart';

class OnAddEventPage extends HookConsumerWidget {
  OnAddEventPage({super.key, required this.onAdd});
  final void Function(EventType) onAdd;
  final controller = TextEditingController();
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
        appBar: appBar(context, "イベント追加", false),
        body: SingleChildScrollView(
          child: Column(
            children: [
              imageSelector(context,
                  img: eventImg.value,
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
                  onDelete: () => eventImg.value = null),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.03,
                    right: safeAreaWidth * 0.03,
                    left: safeAreaWidth * 0.03),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
                      child: titleWithCircle(context, "開催日時"),
                    ),
                    if (eventDate.value == null) ...{
                      miniButtonWithCustomColor(
                          context: context,
                          text: "開催日時を選択...",
                          onTap: () async {
                            final getDate = await showCalendar(context);
                            if (getDate != null) {
                              eventDate.value = getDate;
                            }
                          },
                          color: blueColor,
                          textColor: Colors.white)
                    } else ...{
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          nText(toEvelntDateString(eventDate.value!),
                              color: Colors.white,
                              fontSize: safeAreaWidth / 20,
                              bold: 700),
                          Padding(
                            padding:
                                EdgeInsets.only(left: safeAreaWidth * 0.03),
                            child: deleteIconWithCircle(
                                size: safeAreaWidth * 0.07,
                                onDelete: () => eventDate.value = null,
                                padding: safeAreaWidth * 0.007),
                          )
                        ],
                      ),
                    },
                    Padding(
                      padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.04,
                          bottom: safeAreaHeight * 0.02),
                      child: titleWithCircle(context, "イベント名"),
                    ),
                    StoreSetteingTextField(
                      subText: "イベント名を入力...",
                      title: "",
                      isError: false,
                      controller: controller,
                      onChanged: (value) {},
                    ),
                  ],
                ),
              ),
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
              onTap: () async {
                isLoading.value = true;
                if (eventImg.value != null &&
                    eventDate.value != null &&
                    controller.text.isNotEmpty) {
                  Navigator.pop(context);
                  onAdd(EventType(
                    id: generateRandomString(),
                    img: eventImg.value!,
                    date: eventDate.value!,
                    title: controller.text,
                  ));
                } else {
                  errorSnackbar(context,
                      message:
                          "${eventImg.value == null ? "画像、" : ""}${eventDate.value == null ? "開催日時、" : ""}${controller.text.isEmpty ? "イベント名、" : ""}を入力してください。");
                  await Future<void>.delayed(const Duration(milliseconds: 500));
                  if (context.mounted) {
                    isLoading.value = false;
                  }
                }
              }),
        ),
      ),
      loadinPage(context: context, isLoading: isLoading.value, text: null)
    ]);
  }

  Widget imageSelector(BuildContext context,
      {required Uint8List? img,
      required void Function()? onTap,
      required void Function()? onDelete}) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(15),
                      image: img != null
                          ? DecorationImage(
                              image: MemoryImage(img), fit: BoxFit.cover)
                          : null),
                  child: img == null
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
                            padding: EdgeInsets.all(safeAreaWidth * 0.03),
                            child: deleteIconWithCircle(
                                size: safeAreaWidth * 0.1,
                                padding: 0,
                                onDelete: onDelete!),
                          ),
                        ))),
        ));
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
