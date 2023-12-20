import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/store/event_fullscreen_sheet.dart';
import 'package:lolo_app/view_model/all_stores.dart';

Widget otherWidget(BuildContext context,
    {required Widget widget,
    required void Function()? onTap,
    required bool isLocation}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      alignment: Alignment.center,
      height: safeAreaWidth * 0.17,
      width: safeAreaWidth * 0.17,
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

final PageController pageController = PageController();

class MainScreenWidget extends HookConsumerWidget {
  const MainScreenWidget({super.key, required this.myLocation});
  final Position myLocation;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final safeAreaHeight = safeHeight(context);
    final allStores = ref.watch(allStoresNotifierProvider);
    final List<EventType> allStoresEvent = allStores.when(
      data: (value) => value != null
          ? getSortedEvents(
              value, LatLng(myLocation.latitude, myLocation.longitude))
          : [],
      error: (e, s) => [],
      loading: () => [],
    );

    final List<StoreData> allStoresList = allStores.when(
      data: (value) => value ?? [],
      error: (e, s) => [],
      loading: () => [],
    );
    String toEventDateOfTime(DateTime date) {
      final DateFormat formatter = DateFormat('M月d日', 'ja_JP');
      DateTime now = DateTime.now();

      // 今日の日付と比較
      if (date.year == now.year &&
          date.month == now.month &&
          date.day <= now.day) {
        return '本日開催';
      } else {
        return formatter.format(date);
      }
    }

    String findStoreByEventId(String eventId) {
      for (var store in allStoresList) {
        for (var event in store.eventList) {
          if (event.id == eventId) {
            return calculateDistanceToString(store.location,
                LatLng(myLocation.latitude, myLocation.longitude));
          }
        }
      }
      return "";
    }

    return SizedBox(
        height: safeAreaHeight * 0.13,
        width: safeAreaWidth * 12,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < allStoresEvent.length; i++) ...{
                Padding(
                    key: ValueKey(i),
                    padding: EdgeInsets.all(safeAreaWidth * 0.02),
                    child: SizedBox(
                      width: safeAreaWidth * 0.4,
                      child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: GestureDetector(
                            onTap: () => bottomSheet(context,
                                page: EventFullScreenSheet(
                                    event: allStoresEvent[i]),
                                isBackgroundColor: false),
                            child: Container(
                                alignment: Alignment.bottomRight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: MemoryImage(allStoresEvent[i].img),
                                      fit: BoxFit.cover),
                                ),
                                child: Stack(
                                  children: [
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              safeAreaWidth * 0.01),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: safeAreaHeight * 0.025,
                                            width: safeAreaWidth * 0.15,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                  safeAreaWidth * 0.005),
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: nText(
                                                    toEventDateOfTime(
                                                        allStoresEvent[i].date),
                                                    color: Colors.white,
                                                    fontSize:
                                                        safeAreaWidth / 35,
                                                    bold: 700),
                                              ),
                                            ),
                                          ),
                                        )),
                                    Align(
                                        alignment: const Alignment(-1, 1),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: safeAreaWidth * 0.01),
                                          child: nTextWithShadow(
                                              findStoreByEventId(
                                                  allStoresEvent[i].id),
                                              color: Colors.white,
                                              fontSize: safeAreaWidth / 25,
                                              opacity: 1,
                                              bold: 700),
                                        ))
                                  ],
                                )),
                          )),
                    ))
              }
            ],
          ),
        ));
  }

  List<EventType> getSortedEvents(
      List<StoreData> stores, LatLng currentLocation) {
    DateTime now = DateTime.now();
    DateTime start = now.subtract(const Duration(hours: 8));
    DateTime end = now.add(const Duration(hours: 8));

    var allEvents = stores.expand((store) => store.eventList).toList();

    var filteredEvents = allEvents
        .where((event) => event.date.isAfter(start) && event.date.isBefore(end))
        .toList();
    filteredEvents.sort((a, b) {
      var distA = calculateDistance(
          stores.firstWhere((store) => store.eventList.contains(a)).location,
          currentLocation);
      var distB = calculateDistance(
          stores.firstWhere((store) => store.eventList.contains(b)).location,
          currentLocation);
      return distA.compareTo(distB);
    });
    var remainingEvents =
        allEvents.where((event) => !filteredEvents.contains(event)).toList();
    remainingEvents.sort((a, b) {
      int dateCompare = a.date.compareTo(b.date);
      if (dateCompare == 0) {
        var distA = calculateDistance(
            stores.firstWhere((store) => store.eventList.contains(a)).location,
            currentLocation);
        var distB = calculateDistance(
            stores.firstWhere((store) => store.eventList.contains(b)).location,
            currentLocation);
        return distA.compareTo(distB);
      }
      return dateCompare;
    });
    return filteredEvents + remainingEvents;
  }
}

class OnStore extends HookConsumerWidget {
  const OnStore(
      {super.key,
      required this.storeData,
      required this.distance,
      required this.onTap,
      required this.locationonTap,
      required this.isFocus,
      required this.myDataOnTap});
  final StoreData storeData;
  final String distance;
  final void Function() onTap;
  final void Function()? locationonTap;
  final void Function()? myDataOnTap;
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
          padding: EdgeInsets.only(bottom: isFocus ? safeAreaHeight * 0.02 : 0),
          child: Container(
            alignment: Alignment.center,
            height: safeAreaHeight * 0.13,
            width: safeAreaHeight * 0.115,
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
                          height: safeAreaHeight * 0.1,
                          width: safeAreaHeight * 0.1,
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
                                            ? notImg()
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
                              if (myDataOnTap != null) ...{
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: GestureDetector(
                                      onTap: myDataOnTap,
                                      child: Container(
                                        height: safeAreaHeight * 0.04,
                                        width: safeAreaHeight * 0.04,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              safeAreaWidth * 0.02),
                                          child: Container(
                                            height: double.infinity,
                                            width: double.infinity,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/img/add_icon.png"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )),
                              },
                              Align(
                                  alignment: Alignment.topRight,
                                  child: nTextWithShadow(distance,
                                      color: Colors.white,
                                      opacity: 1,
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
                        storeData.name,
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
    final safeAreaWidth = MediaQuery.of(context).size.width;
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
            child: storeData.logo != null
                ? ClipOval(
                    child: Image.memory(
                      storeData.logo!,
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
