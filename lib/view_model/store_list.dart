import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/constant/affiliated_stores.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_list.g.dart';

@Riverpod(keepAlive: true)
class StoreDataListNotifier extends _$StoreDataListNotifier {
  @override
  Future<List<StoreData>> build() async {
    final getData = await dbGetStoreData();
    return getData;
  }

  Future<void> dataUpDate(StoreData newData) async {
    final int index =
        state.value!.indexWhere((userData) => userData.id == newData.id);
    if (index != -1) {
      final setList = [...state.value!];
      setList[index] = newData;
      state = await AsyncValue.guard(() async {
        return [...setList];
      });
    }
  }
}

Future<List<StoreData>> dbGetStoreData() async {
  try {
    final List<StoreData> setList = [];
    for (final item in afiliatedStoresList) {
      setList.add(StoreData(
          postImgList: [],
          logo: null,
          id: item.id,
          name: "",
          location: item.location));
    }
    // ignore: deprecated_member_use, unused_local_variable
    final databaseReference = FirebaseDatabase(
      databaseURL:
          "https://lolo-app-38ca7-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ).ref();
    final snapshot = await databaseReference.child("stores").get();
    if (snapshot.exists && snapshot.value != null) {
      Map<dynamic, dynamic> values =
          Map<dynamic, dynamic>.from(snapshot.value as Map);
      values.forEach((key, value) {
        try {
          final lat = value["lat"] as double?;
          final lon = value["lon"] as double?;
          if (lat != null && lon != null && key != null) {
            setList.add(StoreData(
                postImgList: [],
                logo: null,
                id: key,
                name: "",
                location: LatLng(lat, lon)));
          }
        } catch (e) {
          return;
        }
      });
    }
    return setList;
  } catch (e) {
    return [];
  }
}
