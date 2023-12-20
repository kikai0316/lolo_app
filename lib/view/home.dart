import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account.dart';
import 'package:lolo_app/view/near_user.dart';
import 'package:lolo_app/view/search.dart';
import 'package:lolo_app/view/store_post.dart';
import 'package:lolo_app/view/swiper.dart';
import 'package:lolo_app/view_model/all_stores.dart';
import 'package:lolo_app/view_model/marker_list.dart';
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
    final isLoading = useState<bool>(true);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final cameraPosition = useState<String?>(userData.id);
    final storeKeys = useState<Map<String, GlobalKey>>({});
    final mapController = useState<GoogleMapController?>(null);
    final myLocation =
        useState<LatLng>(LatLng(locationData.latitude, locationData.longitude));
    final allStores = ref.watch(allStoresNotifierProvider);
    final markerList = ref.watch(markerListNotifierProvider);
    final List<StoreData> allStoresWhen = allStores.when(
      data: (value) {
        if (value == null) {
          final notifier = ref.read(allStoresNotifierProvider.notifier);
          notifier.dbGetStoreData(
              locationData.latitude, locationData.longitude);
          return [];
        } else {
          if (value.isNotEmpty) {
            Future(() async {
              await Future<void>.delayed(const Duration(seconds: 1));
              if (context.mounted) {
                isLoading.value = false;
              }
            });
          }
          for (int i = 0; i < value.length; i++) {
            storeKeys.value[value[i].id] = GlobalKey();
          }
          storeKeys.value = {...storeKeys.value};

          return sortByDistance(
              value, LatLng(locationData.latitude, locationData.longitude));
        }
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
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              for (int i = 0; i < allStoresWhen.length; i++) ...{
                if (!containsMarkerWithId(
                    markerListWhen, allStoresWhen[i].id)) ...{
                  OnMarker(
                      key: ValueKey(
                        allStoresWhen[i].id,
                      ),
                      storeData: allStoresWhen[i],
                      task: (value) {
                        taskQueue.addTask(() async {
                          final getIMG = await value;
                          if (context.mounted && getIMG != null) {
                            final notifier =
                                ref.read(markerListNotifierProvider.notifier);
                            notifier.addData(
                              Marker(
                                onTap: () async {
                                  mapController.value?.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: allStoresWhen[i].location,
                                        zoom: 17.5,
                                        tilt: 13,
                                      ),
                                    ),
                                  );

                                  scrollToStore(allStoresWhen[i].id);
                                },
                                markerId: MarkerId(allStoresWhen[i].id),
                                position: LatLng(
                                    allStoresWhen[i].location.latitude,
                                    allStoresWhen[i].location.longitude),
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
                  if (distanceToUser < 10) {
                    cameraPosition.value = userData.id;
                  } else {
                    for (var marker in markerListWhen) {
                      double distanceToMarker = Geolocator.distanceBetween(
                        position.target.latitude,
                        position.target.longitude,
                        marker.position.latitude,
                        marker.position.longitude,
                      );
                      if (distanceToMarker < 10) {
                        cameraPosition.value = marker.markerId.value;
                        break;
                      } else {
                        cameraPosition.value = null;
                      }
                    }
                  }
                },
                onTap: (value) async {},
                markers: markerListWhen,
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MainScreenWidget(
                      myLocation: locationData,
                    ),
                    for (int i = 0; i < 4; i++) ...{
                      if (i != 3 || cameraPosition.value != userData.id) ...{
                        Padding(
                          padding: EdgeInsets.only(
                              right: safeAreaWidth * 0.03,
                              top: safeAreaHeight * 0.015),
                          child: otherWidget(context, onTap: () async {
                            if (i == 0) {
                              screenTransitionNormal(
                                  context, const AccountPage());
                            }
                            if (i == 1) {
                              screenTransitionNormal(
                                  context,
                                  SearchPage(
                                    locationData: LatLng(locationData.latitude,
                                        locationData.longitude),
                                    nearStores: allStoresWhen,
                                    onSearch: (data) async {
                                      myLocation.value =
                                          LatLng(data.latitude, data.longitude);
                                      mapController.value?.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: LatLng(
                                                data.latitude, data.longitude),
                                            zoom: 17,
                                            tilt: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ));
                            }
                            if (i == 2) {
                              screenTransitionToTop(
                                  context,
                                  NearUserPage(
                                    key: key,
                                    userData: userData,
                                  ));
                            }
                            if (i == 3) {
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
                            }
                          },
                              isLocation: i == 3,
                              widget: Stack(
                                children: [
                                  if (i == 0) ...{
                                    imgIcon(
                                        file: "assets/img/user_icon.png",
                                        padding: safeAreaWidth * 0.03),
                                    userIconWithSettelingIcon(context)
                                  } else if (i == 1) ...{
                                    imgIcon(
                                        file: "assets/img/search_icon.png",
                                        padding: safeAreaWidth * 0.035)
                                  } else if (i == 2) ...{
                                    imgIcon(
                                        file: "assets/img/radar_icon.png",
                                        padding: safeAreaWidth * 0.025)
                                  } else ...{
                                    Icon(
                                      Icons.near_me,
                                      color: Colors.white,
                                      size: safeAreaWidth / 10,
                                    )
                                  }
                                ],
                              )),
                        ),
                      }
                    },
                  ],
                ),
              ),
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
                ),
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
                          if (userData.storeData != null) ...{
                            OnStore(
                              isFocus: false,
                              myDataOnTap: () => screenTransitionToTop(
                                  context,
                                  StorePostPage(
                                    storeData: userData.storeData!,
                                  )),
                              storeData: userData.storeData!,
                              locationonTap: null,
                              distance: calculateDistanceToString(
                                  userData.storeData!.location,
                                  LatLng(locationData.latitude,
                                      locationData.longitude)),
                              onTap: () => screenTransitionHero(
                                context,
                                SwiperPage(
                                  storeList: [userData.storeData!],
                                  index: 0,
                                ),
                              ),
                            ),
                          },
                          for (int i = 0; i < allStoresWhen.length; i++) ...{
                            if (containsMarkerWithId(
                                    markerListWhen, allStoresWhen[i].id) &&
                                (userData.storeData?.id ?? "") !=
                                    allStoresWhen[i].id) ...{
                              OnStore(
                                key: storeKeys.value[allStoresWhen[i].id],
                                isFocus:
                                    cameraPosition.value == allStoresWhen[i].id,
                                myDataOnTap: null,
                                storeData: allStoresWhen[i],
                                locationonTap: () =>
                                    mapController.value?.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: allStoresWhen[i].location,
                                      zoom: 17.5,
                                      tilt: 10,
                                    ),
                                  ),
                                ),
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
                            }
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading.value) const WithIconInLoadingPage()
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

  Widget userIconWithSettelingIcon(BuildContext context) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(safeAreaWidth * 0.015),
        child: Container(
            alignment: Alignment.center,
            height: safeAreaWidth * 0.06,
            width: safeAreaWidth * 0.06,
            decoration: const BoxDecoration(
              color: blackColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings,
              color: Colors.white,
              size: safeAreaWidth / 20,
            )),
      ),
    );
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

List<StoreData> sortByDistance(List<StoreData> stores, LatLng currentLocation) {
  stores.sort((a, b) => calculateDistance(a.location, currentLocation)
      .compareTo(calculateDistance(b.location, currentLocation)));
  return stores;
}
