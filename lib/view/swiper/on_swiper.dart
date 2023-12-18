import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'dart:ui' as ui;

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
    final safeAreaWidth = MediaQuery.of(context).size.width;
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
                  Row(
                    children: [
                      for (int i = 0; i < 2; i++) ...{
                        Expanded(
                          child: GestureDetector(
                            onTap: context.mounted
                                ? () {
                                    if (i == 0) {
                                      if (imgIndex.value > 0) {
                                        imgIndex.value--;
                                      } else {
                                        onBack();
                                      }
                                    } else {
                                      if (imgIndex.value <
                                          storeData.postImgList.length - 1) {
                                        imgIndex.value++;
                                      } else {
                                        onNext();
                                      }
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
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
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
                                for (int i = 0;
                                    i < storeData.postImgList.length;
                                    i++) ...{
                                  Expanded(
                                    child: Opacity(
                                      opacity: i == imgIndex.value ? 1 : 0.4,
                                      child: Container(
                                        height: safeAreaHeight * 0.005,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              blurRadius: 10,
                                              spreadRadius: 1.0,
                                            )
                                          ],
                                          image: storeData.logo == null
                                              ? null
                                              : DecorationImage(
                                                  image: MemoryImage(
                                                      storeData.logo!),
                                                  fit: BoxFit.cover,
                                                ),
                                          color: Colors.grey),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: safeAreaWidth * 0.02),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: safeAreaWidth * 0.5,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: nTextWithShadow(
                                                  storeData.name,
                                                  color: Colors.white,
                                                  fontSize: safeAreaWidth / 23,
                                                  bold: 700),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: safeAreaWidth * 0.02),
                                            child: nTextWithShadow("1時間前",
                                                color: Colors.white,
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
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: safeAreaHeight * 0.015),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ui.ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              height: safeAreaHeight * 0.17,
                              width: safeAreaWidth * 0.93,
                              decoration: BoxDecoration(
                                color: blackColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: safeAreaWidth * 0.03,
                                  left: safeAreaWidth * 0.03,
                                  bottom: safeAreaHeight * 0.015,
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        safeAreaWidth * 0.75,
                                                  ),
                                                  child: nText(
                                                    "",
                                                    color: Colors.black,
                                                    fontSize:
                                                        safeAreaWidth / 23,
                                                    bold: 700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: safeAreaHeight * 0.05,
                                      child: Row(
                                        children: [
                                          for (int i = 0; i < 2; i++) ...{
                                            Expanded(
                                              child: Material(
                                                color: i == 0
                                                    ? Colors.white
                                                    : blueColor2,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: InkWell(
                                                  onTap: () {},
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    height:
                                                        safeAreaHeight * 0.05,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10,
                                                      ),
                                                    ),
                                                    child: nText(
                                                      i == 0 ? "予約する" : "連絡する",
                                                      color: i == 0
                                                          ? blueColor2
                                                          : Colors.white,
                                                      fontSize:
                                                          safeAreaWidth / 28,
                                                      bold: 700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (i == 0)
                                              SizedBox(
                                                width: safeAreaHeight * 0.02,
                                              ),
                                          },
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
