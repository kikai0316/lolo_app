import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/home/map_stores.dart';
import 'package:lolo_app/view/home/swiper.dart';
import 'package:lolo_app/view/search.dart';
import 'package:lolo_app/view_model/all_stores.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/home/home_page_widget.dart';

class HomePage2 extends HookConsumerWidget {
  const HomePage2(
      {super.key, required this.locationData, required this.userData});
  final Position locationData;
  final UserData userData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final allStores = ref.watch(allStoresNotifierProvider);
    final List<StoreData> allStoresWhen = allStores.when(
      data: (value) => value != null
          ? sortByDistance(
              value, LatLng(locationData.latitude, locationData.longitude))
          : [],
      error: (e, s) => [],
      loading: () => [],
    );
    final List<EventType> allEventList = allStores.when(
      data: (value) =>
          value != null ? getSortedEvents(allStoresWhen, locationData) : [],
      error: (e, s) => [],
      loading: () => [],
    );
    StoreData? findStoreByEventId(String eventId) {
      for (var store in allStoresWhen) {
        for (var event in store.eventList) {
          if (event.id == eventId) {
            return store;
          }
        }
      }
      return null;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: xPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  nText("ストーリー",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 20,
                      bold: 700),
                  Row(
                    children: [
                      for (int i = 0; i < 2; i++) ...{
                        Padding(
                          padding: EdgeInsets.only(left: safeAreaWidth * 0.03),
                          child: GestureDetector(
                            onTap: [
                              () => screenTransition(
                                  context,
                                  SearchPage(
                                    locationData: locationData,
                                  )),
                              () => screenTransitionToTop(
                                  context,
                                  MapStoresPage(
                                      locationData: locationData,
                                      myId: userData.id,
                                      allStores: allStoresWhen)),
                            ][i],
                            child: SizedBox(
                                height: safeAreaWidth * 0.1,
                                width: safeAreaWidth * 0.1,
                                child: imgIcon(
                                    file: i == 0
                                        ? "assets/img/search_icon.png"
                                        : "assets/img/map_icon.png",
                                    padding: safeAreaWidth * 0.01)),
                          ),
                        )
                      }
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: safeAreaWidth * 0.03,
                    ),
                    for (int i = 0; i < allStoresWhen.length; i++) ...{
                      Padding(
                        padding: EdgeInsets.only(right: safeAreaWidth * 0.05),
                        child: OnStore(
                          storeData: allStoresWhen[i],
                          distance: calculateDistanceToString(
                              allStoresWhen[i].location,
                              LatLng(locationData.latitude,
                                  locationData.longitude)),
                          onTap: () => screenTransitionHero(
                            context,
                            SwiperPage(
                              storeList: allStoresWhen,
                              index: i,
                            ),
                          ),
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.01, bottom: safeAreaHeight * 0.01),
                child: line(context)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < tagList.length; i++) ...{
                    Padding(
                      padding: EdgeInsets.only(right: safeAreaWidth * 0.02),
                      child: Chip(
                          padding: EdgeInsets.all(safeAreaWidth * 0.03),
                          backgroundColor: i == 0 ? blueColor2 : blackColor,
                          label: nText(tagList[i],
                              color: Colors.white,
                              fontSize: safeAreaWidth / 30,
                              bold: 700)),
                    )
                  }
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
              child: Wrap(
                spacing: safeAreaWidth * 0.03,
                runSpacing: safeAreaHeight * 0.03,
                children: [
                  for (int i = 0; i < allEventList.length; i++) ...{
                    homeEventWiget(context,
                        eventData: allEventList[i],
                        storeData: findStoreByEventId(allEventList[i].id),
                        myLocation: locationData)
                  }
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  List<EventType> getSortedEvents(List<StoreData> stores, Position myLocation) {
    final currentLocation = LatLng(myLocation.latitude, myLocation.longitude);
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

Widget homeEventWiget(BuildContext context,
    {required EventType eventData,
    required StoreData? storeData,
    required Position myLocation}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return storeData != null
      ? SizedBox(
          width: safeAreaWidth * 0.48,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  image: DecorationImage(
                      image: MemoryImage(eventData.img), fit: BoxFit.cover),
                ),
                // child: Padding(
                //   padding: EdgeInsets.only(
                //       left: safeAreaWidth * 0.01,
                //       right: safeAreaWidth * 0.01),
                //   child: Container(
                //     width: safeAreaWidth,
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(50),
                //         color: Colors.black.withOpacity(0.2)),
                //     child: Padding(
                //       padding: EdgeInsets.all(safeAreaWidth * 0.02),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         crossAxisAlignment: CrossAxisAlignment.end,
                //         children: [
                //           Row(
                //             children: [
                //               Container(
                //                 height: safeAreaWidth * 0.09,
                //                 width: safeAreaWidth * 0.09,
                //                 decoration: BoxDecoration(
                //                   border: Border.all(
                //                       color:
                //                           Colors.grey.withOpacity(0.1)),
                //                   image: storeData.logo != null
                //                       ? DecorationImage(
                //                           image: MemoryImage(
                //                               storeData.logo!),
                //                           fit: BoxFit.cover)
                //                       : notImg(),
                //                   shape: BoxShape.circle,
                //                 ),
                //               ),
                //               Padding(
                //                 padding: EdgeInsets.only(
                //                     left: safeAreaWidth * 0.02),
                //                 child: nText(storeData.name,
                //                     color: Colors.white,
                //                     fontSize: safeAreaWidth / 30,
                //                     bold: 700),
                //               )
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               Icon(
                //                 Icons.location_on,
                //                 color: Colors.grey,
                //                 size: safeAreaWidth / 25,
                //               ),
                //               nText(
                //                   calculateDistanceToString(
                //                       storeData.location,
                //                       LatLng(myLocation.latitude,
                //                           myLocation.longitude)),
                //                   color: Colors.grey,
                //                   fontSize: safeAreaWidth / 35,
                //                   bold: 700),
                //             ],
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
              )),
        )
      : const SizedBox();
}

final List<String> tagList = [
  "すべて",
  "HipHop",
  "K-POP",
  "EDM",
  "テクノ",
  "レゲエ",
  "ロック"
];
