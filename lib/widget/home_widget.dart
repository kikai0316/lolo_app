import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/store/on_store_upload.dart';
import 'package:lolo_app/view_model/all_stores.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

Widget otherWidget(BuildContext context,
    {required Widget widget,
    required void Function()? onTap,
    required bool isLocation}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: safeAreaWidth * 0.19,
      width: safeAreaWidth * 0.19,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1.0,
          ),
        ],
        color: isLocation ? blueColor2 : blackColor,
        border: Border.all(
          color: isLocation
              ? Colors.white.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget,
    ),
  );
}

Widget storeWidget(
  BuildContext context, {
  required void Function()? onTap,
  required StoreData storeData,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: safeAreaWidth * 0.21,
        width: safeAreaWidth * 0.19,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              alignment: Alignment.center,
              height: safeAreaWidth * 0.19,
              width: safeAreaWidth * 0.19,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  ),
                ],
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: FractionalOffset.topRight,
                  end: FractionalOffset.bottomLeft,
                  colors: [
                    Color.fromARGB(255, 4, 15, 238),
                    Color.fromARGB(255, 6, 120, 255),
                    Color.fromARGB(255, 4, 200, 255),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(safeAreaWidth * 0.006),
                child: Container(
                  alignment: Alignment.center,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: blackColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaWidth * 0.002),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://i.pinimg.com/564x/cc/00/24/cc0024a79bc48352591109167ce41faa.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () => screenTransitionToTop(
                    context,
                    OnUpLoadPage(
                      storeData: storeData,
                    )),
                child: Container(
                  alignment: Alignment.center,
                  height: safeAreaWidth * 0.09,
                  width: safeAreaWidth * 0.09,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(1),
                        blurRadius: 10,
                        spreadRadius: 1.0,
                      ),
                    ],
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(safeAreaWidth * 0.02),
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage("assets/img/add_icon.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ));
}

final PageController pageController = PageController();

class MainScreenWidget extends HookConsumerWidget {
  const MainScreenWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final indicatorIndex = useState<int>(0);
    final isMove = useState<bool>(false);
    bool isWithinRange(double? value) {
      if (value != null) {
        double decimalPart = value - value.toInt();
        return decimalPart <= 0.2 || decimalPart >= 0.8;
      }
      return false; // valueがint型の場合、範囲内にはないと見なす
    }

    return SizedBox(
      width: safeAreaWidth * 1,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
                onPageChanged: (value, _) {
                  indicatorIndex.value = value;
                },
                onScrolled: (position) {
                  if (isWithinRange(position)) {
                    isMove.value = false;
                  } else {
                    isMove.value = true;
                  }
                },
                aspectRatio: 3.2 / 1,
                viewportFraction: 1,
                // autoPlay: true,
                enableInfiniteScroll: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                disableCenter: true),
            items: [1, 2, 3, 4, 5].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.all(
                      safeAreaWidth * 0.03,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1.0,
                          )
                        ],
                        image: const DecorationImage(
                            image: NetworkImage(
                                "https://i.pinimg.com/564x/91/a6/56/91a65632fd748886ba560af7e21d08ef.jpg"),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: safeAreaHeight * 0.025),
            child: Opacity(
              opacity: isMove.value ? 0.5 : 1,
              child: AnimatedSmoothIndicator(
                  activeIndex: indicatorIndex.value,
                  count: [1, 2, 3, 4, 5].length,
                  effect: ScrollingDotsEffect(
                    dotColor: Colors.grey.withOpacity(0.5),
                    activeDotColor: Colors.white,
                    dotHeight: safeAreaWidth * 0.018,
                    dotWidth: safeAreaWidth * 0.018,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class OnStore extends HookConsumerWidget {
  const OnStore({
    super.key,
    required this.storeData,
    required this.distance,
    required this.onTap,
    required this.locationonTap,
    required this.isFocus,
  });
  final StoreData storeData;
  final String distance;
  final void Function() onTap;
  final void Function()? locationonTap;
  final bool isFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTapEvent = useState<bool>(false);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    return GestureDetector(
      onTap: () {
        isTapEvent.value = false;
        onTap();
      },
      onTapDown: (TapDownDetails downDetails) {
        isTapEvent.value = true;
      },
      onTapCancel: () {
        isTapEvent.value = false;
      },
      child: Hero(
        tag: storeData.id,
        child: AnimatedPadding(
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 500),
          padding: EdgeInsets.only(bottom: isFocus ? 20 : 0),
          child: Container(
            alignment: Alignment.center,
            height: safeAreaHeight * 0.13,
            width: safeAreaHeight * 0.11,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: safeAreaHeight * 0.01,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(
                          isTapEvent.value ? safeAreaWidth * 0.008 : 0,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: safeAreaHeight * 0.11,
                          width: safeAreaHeight * 0.11,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: storeData.postImgList.isEmpty
                                ? null
                                : const LinearGradient(
                                    begin: FractionalOffset.topRight,
                                    end: FractionalOffset.bottomLeft,
                                    colors: [
                                      Color.fromARGB(255, 4, 15, 238),
                                      Color.fromARGB(255, 6, 120, 255),
                                      Color.fromARGB(255, 4, 200, 255),
                                    ],
                                  ),
                            color: storeData.postImgList.isEmpty
                                ? Colors.grey.withOpacity(0.5)
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(safeAreaHeight * 0.004),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: blackColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(safeAreaHeight * 0.002),
                                    child: Container(
                                      height: double.infinity,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                        image: storeData.logo == null
                                            ? null
                                            : DecorationImage(
                                                image: MemoryImage(
                                                    storeData.logo!),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (locationonTap != null) ...{
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: GestureDetector(
                                      onTap: locationonTap,
                                      child: Container(
                                          height: safeAreaHeight * 0.04,
                                          width: safeAreaHeight * 0.04,
                                          decoration: BoxDecoration(
                                            color: blueColor,
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.8)),
                                            shape: BoxShape.circle,
                                          ),
                                          child: imgIcon(
                                              file:
                                                  "assets/img/location_icon.png",
                                              padding: safeAreaWidth * 0.008)),
                                    )),
                              },
                              Align(
                                  alignment: Alignment.topRight,
                                  child: nTextWithShadow(distance,
                                      color: Colors.white,
                                      fontSize: safeAreaWidth / 35,
                                      bold: 700))
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: safeAreaHeight * 0.005),
                      child: nText(
                        "NightClub",
                        color: Colors.white.withOpacity(1),
                        fontSize: safeAreaWidth / 37,
                        bold: 700,
                      ),
                    ),
                  ],
                ),
                if (isFocus)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Transform.rotate(
                      angle: 90 * 2.0 * pi / 180,
                      child: Icon(
                        Icons.navigation,
                        color: greenColor,
                        size: safeAreaWidth / 20,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool is12HoursPassed(DateTime data) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(data);
    return difference.inHours >= 12;
  }
}

class OnMarker extends HookConsumerWidget {
  const OnMarker({
    super.key,
    required this.storeData,
    required this.task,
  });
  final StoreData storeData;
  final void Function(Future<Uint8List?>) task;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repaintBoundaryKey = GlobalKey(debugLabel: storeData.id);
    final data = useState<StoreData?>(null);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    useEffect(() {
      Future(() async {
        final dbGetData = await storeDataGet(storeData);
        if (dbGetData != null && context.mounted) {
          final notifier = ref.read(allStoresNotifierProvider.notifier);
          notifier.dataUpDate(dbGetData);
          data.value = dbGetData;
        }
      });
      return null;
    }, []);
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        alignment: Alignment.center,
        height: safeAreaWidth * 0.19,
        width: safeAreaWidth * 0.19,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: blueColor2.withOpacity(0.2),
          border: Border.all(color: blueColor.withOpacity(0.1)),
        ),
        child: Container(
            alignment: Alignment.center,
            height: safeAreaWidth * 0.115,
            width: safeAreaWidth * 0.115,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
            child: data.value != null && data.value?.logo != null
                ? ClipOval(
                    child: Image.memory(
                      data.value!.logo!,
                      fit: BoxFit.cover,
                      height: safeAreaWidth * 0.11,
                      width: safeAreaWidth * 0.11,
                      frameBuilder: (
                        BuildContext context,
                        Widget child,
                        int? frame,
                        bool wasSynchronouslyLoaded,
                      ) {
                        if (frame == null) {
                          return const SizedBox();
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            task(getBytesFromWidget(repaintBoundaryKey));
                          });
                          return child;
                        }
                      },
                    ),
                  )
                : null),
      ),
    );
  }

  Future<Uint8List?> getBytesFromWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
}
