import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/location_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/swiper.dart';
import 'package:lolo_app/view_model/marker_list.dart';
import 'package:lolo_app/view_model/store_list.dart';
import 'package:lolo_app/widget/home_widget.dart';

final ScrollController scrollController = ScrollController();

class HomePage extends HookConsumerWidget {
  HomePage({super.key, required this.userData, required this.locationData});
  final UserData userData;
  final Position locationData;
  final taskQueue = AsyncTaskQueue();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final cameraPosition = useState<String?>(userData.id);
    final trySearchWidget = useState<Widget?>(null);
    final storeKeys = useState<Map<String, GlobalKey>>({});
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final mapController = useState<GoogleMapController?>(null);
    final myLocation =
        useState<LatLng>(LatLng(locationData.latitude, locationData.longitude));
    final storeList = ref.watch(storeDataListNotifierProvider);
    final markerList = ref.watch(markerListNotifierProvider);
    final List<StoreData> storeListWhen = storeList.when(
      data: (value) {
        // print(111);
        final sortStores = filterAndSortStores(value, myLocation.value);
        for (int i = 0; i < sortStores.length; i++) {
          storeKeys.value[sortStores[i].id] = GlobalKey();
        }
        storeKeys.value = {...storeKeys.value};
        return sortStores;
      },
      error: (e, s) => [],
      loading: () => [],
    );
    final Set<Marker> markerListWhen = markerList.when(
      data: (value) => value,
      error: (e, s) => {},
      loading: () => {},
    );

    void scrollToStore(String storeId) {
      final key = storeKeys.value[storeId];
      if (key == null) return;

      final context = key.currentContext;
      if (context == null) return;

      final renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final offset = position.dx;
      if (offset < 0 || offset > safeAreaWidth) {
        scrollController.animateTo(
          scrollController.offset + offset - (safeAreaWidth * 0.2),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              for (int i = 0; i < storeListWhen.length; i++) ...{
                if (!containsMarkerWithId(
                    markerListWhen, storeListWhen[i].id)) ...{
                  OnMarker(
                      key: ValueKey(
                        storeListWhen[i].id,
                      ),
                      storeData: storeListWhen[i],
                      task: (value) {
                        taskQueue.addTask(() async {
                          final getIMG = await value;
                          if (context.mounted) {
                            final notifier =
                                ref.read(markerListNotifierProvider.notifier);
                            notifier.addData(
                              Marker(
                                onTap: () async {
                                  mapController.value?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: storeListWhen[i].location,
                                        zoom: 17.5,
                                        tilt: 10,
                                      ),
                                    ),
                                  );

                                  scrollToStore(storeListWhen[i].id);
                                },
                                markerId: MarkerId(storeListWhen[i].id),
                                position: LatLng(
                                    storeListWhen[i].location.latitude,
                                    storeListWhen[i].location.longitude),
                                icon: BitmapDescriptor.fromBytes(getIMG),
                              ),
                            );
                          }
                        });
                      }),
                }
              },
              GoogleMap(
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        myLocation.value.latitude, myLocation.value.longitude),
                    zoom: 17,
                    tilt: 10,
                  ),
                  onMapCreated: (controller) {
                    mapController.value = controller;
                    rootBundle
                        .loadString("assets/map/map_style.json")
                        .then((string) {
                      controller.setMapStyle(string);
                    });
                  },
                  onCameraMove: (CameraPosition position) {
                    double distanceToUser = Geolocator.distanceBetween(
                      position.target.latitude,
                      position.target.longitude,
                      locationData.latitude,
                      locationData.longitude,
                    );
                    if (distanceToUser < 2) {
                      cameraPosition.value = userData.id;
                    } else if (distanceToUser > 20) {
                      trySearchWidget.value = radiusButton(
                          context: context,
                          text: "再検索",
                          onTap: () {
                            myLocation.value = LatLng(
                              position.target.latitude,
                              position.target.longitude,
                            );
                            trySearchWidget.value = null;
                          });
                      cameraPosition.value = null;
                    } else {
                      for (var marker in markerListWhen) {
                        double distanceToMarker = Geolocator.distanceBetween(
                          position.target.latitude,
                          position.target.longitude,
                          marker.position.latitude,
                          marker.position.longitude,
                        );
                        if (distanceToMarker < 2) {
                          cameraPosition.value = marker.markerId.value;
                          break;
                        } else {
                          cameraPosition.value = null;
                        }
                      }
                    }
                  },
                  onTap: (value) {},
                  markers: markerListWhen),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const MainScreenWidget(),
                    for (int i = 0; i < 3; i++) ...{
                      if (i != 2 || cameraPosition.value != userData.id) ...{
                        Padding(
                          padding: EdgeInsets.only(
                              right: safeAreaWidth * 0.03,
                              top: safeAreaHeight * (i == 0 ? 0.015 : 0.015)),
                          child: otherWidget(context, onTap: () async {
                            if (i == 2) {
                              mapController.value?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(locationData.latitude,
                                        locationData.longitude),
                                    zoom: 17,
                                    tilt: 10,
                                  ),
                                ),
                              );
                            }
                          },
                              isLocation: i == 2,
                              widget: Icon(
                                i == 0
                                    ? Icons.settings
                                    : i == 1
                                        ? Icons.search
                                        : Icons.near_me,
                                color: Colors.white,
                                size: safeAreaWidth / 10,
                              )),
                        ),
                      }
                    },
                  ],
                ),
              ),
              if (trySearchWidget.value == null) ...{
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      alignment: Alignment.center,
                      height: safeAreaHeight * 0.12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1.0,
                          ),
                        ],
                        color: blueColor2,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: storeListWhen.isEmpty
                          ? nText("周辺10km圏内に店舗は見当たりません",
                              color: Colors.white,
                              fontSize: safeAreaWidth / 25,
                              bold: 700)
                          : null),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification notification) {
                        if (notification is ScrollStartNotification) {
                          if (cameraPosition.value != userData.id) {
                            cameraPosition.value = null;
                          }
                        }
                        return true;
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: safeAreaWidth * 0.05,
                            ),
                            for (int i = 0; i < storeListWhen.length; i++) ...{
                              if (containsMarkerWithId(
                                  markerListWhen, storeListWhen[i].id)) ...{
                                OnStore(
                                  key: storeKeys.value[storeListWhen[i].id],
                                  isFocus: cameraPosition.value ==
                                      storeListWhen[i].id,
                                  storeData: storeListWhen[i],
                                  locationonTap: () =>
                                      mapController.value?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: storeListWhen[i].location,
                                        zoom: 17.5,
                                        tilt: 10,
                                      ),
                                    ),
                                  ),
                                  distance: calculateDistance(
                                      storeListWhen[i].location,
                                      myLocation.value),
                                  onTap: () => screenTransitionHero(
                                    context,
                                    SwiperPage(
                                      myUserData: userData,
                                      storeList: storeListWhen,
                                      index: i,
                                    ),
                                  ),
                                ),
                              }
                            },
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              } else ...{
                SafeArea(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: trySearchWidget.value!))
              }
            ],
          )),
    );
  }

  bool containsMarkerWithId(Set<Marker> markers, String specificId) {
    return markers.any((marker) => marker.markerId.value == specificId);
  }

  bool containsStoreDataWithId(List<StoreData> storeList, String specificId) {
    return storeList.any((marker) => marker.id == specificId);
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  String calculateDistance(LatLng location1, LatLng location2) {
    const double earthRadius = 6371.0; // 地球の半径（キロメートル）
    double lat1 = location1.latitude;
    double lon1 = location1.longitude;
    double lat2 = location2.latitude;
    double lon2 = location2.longitude;

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    if (distance < 1) {
      int distanceInMeters = (distance * 1000).round();
      return "${(distanceInMeters / 10).round() * 10}m";
    } else {
      return "${(distance * 10).round() / 10.0}km";
    }
  }
}

class AsyncTaskQueue {
  final Queue<Future Function()> _taskQueue = Queue();
  bool _isProcessing = false;

  void addTask(Future Function() task) {
    _taskQueue.add(task);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _isProcessing = true;
    while (_taskQueue.isNotEmpty) {
      final task = _taskQueue.removeFirst();
      await task();
    }
    _isProcessing = false;
  }
}
