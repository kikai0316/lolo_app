import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/home_story_widget.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final mapController = useState<GoogleMapController?>(null);
    // useEffect(
    //   () {},
    //   const [],
    // );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              GoogleMap(
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                initialCameraPosition: const CameraPosition(
                  // target: LatLng(35.50924, 139.769812),
                  target: LatLng(33.8688120681006, 130.705492682755),
                  zoom: 18,
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

                // markers: markerListNotifier,
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(safeAreaWidth * 0.03),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: [
                        myAccountWidget(
                          context,
                        ),
                        for (int i = 0; i < 2; i++) ...{
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.015),
                            child: otherWidget(context,
                                onTap: () async {},
                                widget: Icon(
                                  i == 0 ? Icons.settings : Icons.search,
                                  color: Colors.white,
                                  size: safeAreaWidth / 10,
                                )),
                          ),
                        },
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: safeAreaHeight * 0.23,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
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
                        // child: CupertinoActivityIndicator(
                        //   color: Colors.white,
                        //   radius: safeAreaHeight * 0.018,
                        // ),
                      )
                      // if (nearbyLisWhen.isEmpty) ...{
                      //   Align(
                      //     alignment: Alignment.topCenter,
                      //     child: Padding(
                      //       padding:
                      //           EdgeInsets.only(top: safeAreaHeight * 0.065),
                      //       child: Container(
                      //         height: safeAreaHeight * 0.08,
                      //         width: safeAreaHeight * 0.08,
                      //         decoration: const BoxDecoration(
                      //           image: DecorationImage(
                      //             image: AssetImage("assets/img/emoji1.png"),
                      //             fit: BoxFit.cover,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // } else ...{
                      //   Align(
                      //     alignment: Alignment.topCenter,
                      //     child: Column(
                      //       children: [
                      //         Padding(
                      //           padding: EdgeInsets.all(safeAreaWidth * 0.02),
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               color: blackColor.withOpacity(0.6),
                      //               borderRadius: BorderRadius.circular(50),
                      //             ),
                      //             child: Padding(
                      //               padding: EdgeInsets.only(
                      //                 top: safeAreaWidth * 0.015,
                      //                 bottom: safeAreaWidth * 0.015,
                      //                 left: safeAreaWidth * 0.03,
                      //                 right: safeAreaWidth * 0.03,
                      //               ),
                      //               child: nText(
                      //                 "近くに${nearbyLisWhen.length}人のユーザーがいます",
                      //                 color: Colors.white,
                      //                 fontSize: safeAreaWidth / 38,
                      //                 bold: 700,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         SizedBox(
                      //           width: safeAreaWidth * 1,
                      //           child: SingleChildScrollView(
                      //             scrollDirection: Axis.horizontal,
                      //             child: Row(
                      //               children: [
                      //                 SizedBox(
                      //                   width: safeAreaWidth * 0.05,
                      //                 ),
                      //                 for (int i = 0;
                      //                     i < nearbyLisWhen.length;
                      //                     i++) ...{
                      //                   OnNearby(
                      //                     key: ValueKey(nearbyLisWhen[i]),
                      //                     id: nearbyLisWhen[i],
                      //                     onTap: () => screenTransitionHero(
                      //                       context,
                      //                       SwiperPage(
                      //                         myUserData: userDataNotifier!,
                      //                         isMyData: false,
                      //                         index: i,
                      //                         nearbyList: nearbyLisWhen,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 },
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // },
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
