import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/store/store_post_widget.dart';

class OnSwiper extends HookConsumerWidget {
  const OnSwiper({
    super.key,
    required this.storeData,
    required this.onNext,
    required this.onBack,
    required this.controller,
  });
  final StoreData storeData;
  final void Function() onNext;
  final void Function() onBack;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final imgIndex = useState<int>(0);

    return SafeArea(
      child: SingleChildScrollView(
        controller: controller,
        child: Column(
          children: [
            Container(
              height: safeAreaHeight * 1,
              width: double.infinity,
              decoration: BoxDecoration(
                image: storeData.postImgList.isNotEmpty
                    ? DecorationImage(
                        image: MemoryImage(
                            storeData.postImgList[imgIndex.value].img),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  if (storeData.postImgList.isEmpty) ...{
                    notPostWidget(context, storeData: storeData)
                  },
                  tapEventWidget(
                    context,
                    nextOnTap: () {
                      if (imgIndex.value < storeData.postImgList.length - 1) {
                        imgIndex.value++;
                      } else {
                        onNext();
                      }
                    },
                    backOnTap: () {
                      if (imgIndex.value > 0) {
                        imgIndex.value--;
                      } else {
                        onBack();
                      }
                    },
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: appBarWidget(context,
                        storeData: storeData, imgIndex: imgIndex.value),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: InformationContainerWidget(storeData: storeData)),
                ],
              ),
            ),
            SizedBox(
              height: safeAreaHeight * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}

Widget tapEventWidget(BuildContext context,
    {required void Function() nextOnTap, required void Function() backOnTap}) {
  return Row(
    children: [
      for (int i = 0; i < 2; i++) ...{
        Expanded(
          child: GestureDetector(
            onTap: context.mounted
                ? () {
                    if (i == 0) {
                      backOnTap();
                    } else {
                      nextOnTap();
                    }
                  }
                : null,
            child: Container(
              height: double.infinity,
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
      },
    ],
  );
}

Widget notPostWidget(BuildContext context, {required StoreData storeData}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    alignment: Alignment.center,
    height: safeAreaHeight * 1,
    width: safeAreaWidth * 1,
    decoration: BoxDecoration(
      color: blackColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Opacity(
      opacity: 0.8,
      child: SizedBox(
        height: safeAreaHeight * 0.27,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  Icons.photo_camera,
                  color: Colors.white,
                  size: safeAreaWidth / 13,
                ),
              ),
            ),
            nText("投稿がありません。",
                color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
          ],
        ),
      ),
    ),
  );
}

Widget appBarWidget(BuildContext context,
    {required StoreData storeData, required int imgIndex}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    height: safeAreaHeight * 0.12,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: FractionalOffset.topCenter,
        end: FractionalOffset.bottomCenter,
        colors: [
          Colors.black.withOpacity(0.2),
          Colors.black.withOpacity(0),
        ],
      ),
    ),
    child: Padding(
      padding: EdgeInsets.only(
        top: safeAreaHeight * 0.02,
        left: safeAreaWidth * 0.04,
        right: safeAreaWidth * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (int i = 0; i < storeData.postImgList.length; i++) ...{
                Expanded(
                  child: Opacity(
                    opacity: i == imgIndex ? 1 : 0.4,
                    child: Container(
                      height: safeAreaHeight * 0.005,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                if (i < storeData.postImgList.length)
                  SizedBox(width: safeAreaWidth * 0.01),
              },
            ],
          ),
          SizedBox(height: safeAreaHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: safeAreaHeight * 0.055,
                    width: safeAreaHeight * 0.055,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1.0,
                          )
                        ],
                        image: storeData.logo == null
                            ? notImg()
                            : DecorationImage(
                                image: MemoryImage(storeData.logo!),
                                fit: BoxFit.cover,
                              ),
                        color: Colors.grey),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: safeAreaWidth * 0.02),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: safeAreaWidth * 0.5,
                          ),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: nTextWithShadow(storeData.name,
                                color: Colors.white,
                                fontSize: safeAreaWidth / 23,
                                opacity: 0.3,
                                bold: 700),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: safeAreaWidth * 0.02),
                          child: nTextWithShadow(
                              storeData.postImgList.isEmpty
                                  ? ""
                                  : timeAgo(
                                      storeData.postImgList[imgIndex].date),
                              color: Colors.white,
                              opacity: 0.3,
                              fontSize: safeAreaWidth / 30,
                              bold: 500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 0.8,
                    ),
                  ],
                  size: safeAreaWidth / 9,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class InformationContainerWidget extends HookConsumerWidget {
  const InformationContainerWidget({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isContainerOpen = useState<bool>(true);
    final isDataOpen = useState<bool>(true);
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        alignment: Alignment.center,
        height: safeAreaHeight * (isContainerOpen.value ? 0.25 : 0.1),
        width: safeAreaWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: [
              Colors.black.withOpacity(0),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () async {
                if (isContainerOpen.value) {
                  isContainerOpen.value = false;
                  isDataOpen.value = false;
                } else {
                  isContainerOpen.value = true;
                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  if (context.mounted) {
                    isDataOpen.value = true;
                  }
                }
              },
              child: Container(
                alignment: Alignment.center,
                width: safeAreaWidth * 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    nTextWithShadow("イベント情報",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 22,
                        opacity: 0.1,
                        bold: 700),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        isDataOpen.value
                            ? Icons.expand_more
                            : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: safeAreaWidth / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isDataOpen.value) ...{
              if (storeData.eventList.isEmpty) ...{
                Padding(
                  padding: EdgeInsets.all(safeAreaWidth * 0.05),
                  child: nTextWithShadow("イベントはありません",
                      color: Colors.grey,
                      opacity: 1,
                      fontSize: safeAreaWidth / 25,
                      bold: 700),
                ),
              } else ...{
                Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < storeData.eventList.length;
                              i++) ...{
                            Padding(
                              key: ValueKey(i),
                              padding: EdgeInsets.all(safeAreaWidth * 0.02),
                              child: eventWidget(context,
                                  data: storeData.eventList[i], onDelete: null),
                            )
                          }
                        ],
                      ),
                    ))
              }
            }
          ],
        ),
      ),
    );
  }
}
