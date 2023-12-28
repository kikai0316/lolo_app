import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/home/swiper.dart';
import 'package:lolo_app/view_model/marker_list.dart';
import 'package:lolo_app/widget/home/home_page_widget.dart';
import 'package:lolo_app/widget/home/map_stores_widget.dart';

final taskQueue = AsyncTaskQueue();

class MapStoresPage extends HookConsumerWidget {
  const MapStoresPage(
      {super.key,
      required this.locationData,
      required this.myId,
      required this.allStores});
  final Position locationData;
  final String myId;
  final List<StoreData> allStores;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final focusStoreData = useState<StoreData?>(null);
    final isMyPosition = useState<bool>(true);
    final defaultCameraPosition = CameraPosition(
      target: LatLng(locationData.latitude, locationData.longitude),
      zoom: 7,
      tilt: 10,
    );
    final zoomLevel = useState<CameraPosition>(defaultCameraPosition);
    final mapController = useState<GoogleMapController?>(null);
    final markerList = ref.watch(markerListNotifierProvider);
    final Set<Marker> markerListWhen = markerList.when(
      data: (value) => value,
      error: (e, s) => {},
      loading: () => {},
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              for (int i = 0; i < allStores.length; i++) ...{
                if (!containsMarkerWithId(markerListWhen, allStores[i].id)) ...{
                  OnMarker(
                      key: ValueKey(
                        allStores[i].id,
                      ),
                      storeData: allStores[i],
                      task: (value) {
                        taskQueue.addTask(() async {
                          final getIMG = await value;
                          if (context.mounted && getIMG != null) {
                            final notifier =
                                ref.read(markerListNotifierProvider.notifier);
                            notifier.addData(
                              Marker(
                                markerId: MarkerId(allStores[i].id),
                                position: LatLng(allStores[i].location.latitude,
                                    allStores[i].location.longitude),
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
                    target:
                        LatLng(locationData.latitude, locationData.longitude),
                    zoom: 7,
                    tilt: 10,
                  ),
                  onMapCreated: (controller) {
                    if (context.mounted) {
                      mapController.value = controller;
                      rootBundle
                          .loadString("assets/map/map_style.json")
                          .then((string) {
                        controller.setMapStyle(string);
                      });
                    }
                  },
                  onCameraMove: (CameraPosition position) {
                    double distanceToUser = Geolocator.distanceBetween(
                      position.target.latitude,
                      position.target.longitude,
                      locationData.latitude,
                      locationData.longitude,
                    );
                    isMyPosition.value = distanceToUser < 10;
                    zoomLevel.value = CameraPosition(
                        target: position.target,
                        zoom: zoomLevel.value.zoom,
                        tilt: 10);
                  },
                  markers: {
                    for (final item in markerListWhen) ...{
                      Marker(
                          onTap: () async {
                            final setData = CameraPosition(
                              target: item.position,
                              zoom: 17.5,
                              tilt: 13,
                            );
                            mapController.value?.animateCamera(
                              CameraUpdate.newCameraPosition(setData),
                            );
                            final int index = allStores.indexWhere(
                                (storeData) =>
                                    storeData.id == item.mapsId.value);
                            if (index != -1) {
                              focusStoreData.value = allStores[index];
                              zoomLevel.value = setData;
                            }
                          },
                          markerId: item.mapsId,
                          position: item.position,
                          icon: item.icon),
                    }
                  }),
              SafeArea(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(safeAreaWidth * 0.03),
                        child: mapButtonWidget(
                          context,
                          onTap: () => Navigator.pop(context),
                          widget: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: safeAreaWidth / 10,
                          ),
                          isLocation: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(safeAreaWidth * 0.03),
                        child: SizedBox(
                          width: safeAreaWidth * 0.15,
                          height: safeAreaHeight * 0.6,
                          child: RotatedBox(
                              quarterTurns: -1,
                              child: Slider(
                                activeColor: blueColor2,
                                inactiveColor: blueColor2,
                                thumbColor: Colors.white,
                                value: zoomLevel.value.zoom,
                                min: 5.0,
                                max: 20.0,
                                divisions: 3000,
                                onChanged: (double value) {
                                  zoomLevel.value = CameraPosition(
                                      target: zoomLevel.value.target,
                                      zoom: value,
                                      tilt: zoomLevel.value.tilt);
                                  mapController.value?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                        zoomLevel.value),
                                  );
                                },
                              )),
                        ),
                      ),
                      if (!isMyPosition.value)
                        Padding(
                          padding: EdgeInsets.all(safeAreaWidth * 0.03),
                          child: mapButtonWidget(
                            context,
                            onTap: () => mapController.value?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                  defaultCameraPosition),
                            ),
                            widget: Icon(
                              Icons.near_me,
                              color: Colors.white,
                              size: safeAreaWidth / 10,
                            ),
                            isLocation: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    alignment: Alignment.center,
                    height: safeAreaHeight * 0.1,
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
                    child: focusStoreData.value == null
                        ? nText("マーカーをタップしてください。",
                            color: Colors.white,
                            fontSize: safeAreaWidth / 25,
                            bold: 700)
                        : null),
              ),
              if (focusStoreData.value != null)
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: safeAreaHeight * 0.03),
                      child: SizedBox(
                        height: safeAreaHeight * 0.13,
                        width: safeAreaWidth * 0.9,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            OnStore(
                              storeData: focusStoreData.value!,
                              distance: calculateDistanceToString(
                                  focusStoreData.value!.location,
                                  LatLng(locationData.latitude,
                                      locationData.longitude)),
                              onTap: () => screenTransitionHero(
                                context,
                                SwiperPage(
                                  storeList: [focusStoreData.value!],
                                  index: 0,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () {
                                  focusStoreData.value = null;
                                  mapController.value?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(locationData.latitude,
                                            locationData.longitude),
                                        zoom: 7,
                                        tilt: 10,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.white.withOpacity(0.8),
                                  size: safeAreaWidth / 14,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
            ],
          )),
    );
  }

  bool containsMarkerWithId(Set<Marker> markers, String specificId) {
    return markers.any((marker) => marker.markerId.value == specificId);
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
