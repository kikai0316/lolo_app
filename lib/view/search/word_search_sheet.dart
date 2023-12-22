import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view_model/all_stores.dart';

import 'package:lolo_app/widget/search/search_widget.dart';

class WordSearchSheetWidget extends HookConsumerWidget {
  const WordSearchSheetWidget(
      {super.key, required this.searchWord, required this.onSearch});
  final String searchWord;
  final void Function(LatLng)? onSearch;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final searchStoreData = useState<List<StoreData>?>(null);
    final myLocation = useState<LatLng?>(null);
    final imgIndexList = useState<List<int>>([]);
    useEffect(() {
      Future(() async {
        final currentPosition = await Geolocator.getCurrentPosition();

        final List<StoreData> setList = [];
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        QuerySnapshot querySnapshot = await firestore
            .collection('store')
            .where('search_word', arrayContains: searchWord)
            .get();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          final GeoPoint getGeo = data['geo']["geopoint"] as GeoPoint;
          setList.add(StoreData(
              postImgList: [],
              logo: null,
              id: doc.id,
              searchWord: [],
              name: nullCheckString(data["name"]) ?? "未設定",
              address: nullCheckString(data["address"]) ?? "未設定",
              businessHours: nullCheckString(data["business_hour"]) ?? "",
              location: LatLng(getGeo.latitude, getGeo.longitude),
              eventList: []));
        }
        if (context.mounted) {
          imgIndexList.value = imgRandomIndex(setList.length);
          myLocation.value =
              LatLng(currentPosition.latitude, currentPosition.longitude);
          searchStoreData.value = [...setList];
        }
      });

      return null;
    }, []);
    return Container(
        height: safeAreaHeight * 0.8,
        decoration: const BoxDecoration(
          color: blackColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(safeAreaWidth * 0.03),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.grey.withOpacity(0.1);
                        }
                        return null;
                      },
                    ),
                  ),
                  child: nText("とじる",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 25,
                      bold: 600),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: safeAreaWidth * 0.01,
                ),
                child: Container(
                  width: safeAreaWidth * 1,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: nText("”$searchWord”での検索結果",
                        color: Colors.white,
                        fontSize: safeAreaWidth / 16,
                        bold: 700),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.01, bottom: safeAreaHeight * 0.015),
                child: nText(
                    searchStoreData.value == null
                        ? "検索中..."
                        : "${searchStoreData.value!.length}件のお店が見つかりました",
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: safeAreaWidth / 25,
                    bold: 500),
              ),
              Expanded(
                  child: searchStoreData.value == null
                      ? Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding:
                                EdgeInsets.only(bottom: safeAreaHeight * 0.2),
                            child: CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: safeAreaHeight * 0.018,
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: safeAreaWidth * 0.01,
                                  ),
                                  for (int i = 0;
                                      i < searchStoreData.value!.length;
                                      i++) ...{
                                    onWordSearchWidget(
                                      context,
                                      onTap: () {
                                        final notifier = ref.read(
                                            allStoresNotifierProvider.notifier);
                                        notifier.wordSearch(
                                            searchStoreData.value![i]);
                                        Navigator.pop(context);
                                        onSearch!(
                                            searchStoreData.value![i].location);
                                      },
                                      storeData: searchStoreData.value![i],
                                      index: imgIndexList.value[i],
                                      distance: myLocation.value == null
                                          ? "計測中..."
                                          : calculateDistanceToString(
                                              searchStoreData
                                                  .value![i].location,
                                              myLocation.value!),
                                    )
                                  },
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: safeAreaHeight * 0.03,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    colors: [
                                      blackColor.withOpacity(1),
                                      blackColor.withOpacity(0),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ))
            ],
          ),
        ));
  }
}
