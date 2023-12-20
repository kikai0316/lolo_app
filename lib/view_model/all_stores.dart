import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_stores.g.dart';

@Riverpod(keepAlive: true)
class AllStoresNotifier extends _$AllStoresNotifier {
  @override
  Future<List<StoreData>?> build() async {
    final isPermission = await checkLocationPermission();
    if (isPermission) {
      final currentPosition = await Geolocator.getCurrentPosition();
      dbGetStoreData(currentPosition.latitude, currentPosition.longitude);
      return [];
    } else {
      return null;
    }
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

  Future<void> wordSearch(StoreData newData) async {
    // final notifier = ref.read(nearStoresNotifierProvider.notifier);
    // await notifier.upDataList([newData.id]);
    // final int index =
    //     state.value!.indexWhere((userData) => userData.id == newData.id);
    // if (index == -1) {
    //   state = await AsyncValue.guard(() async {
    //     if (state.value == null) {
    //       return [newData];
    //     } else {
    //       return [...state.value!, newData];
    //     }
    //   });
    // }
  }

  Future<void> dbGetStoreData(double lat, double lon) async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection("store");
      QuerySnapshot querySnapshot = await collection.get();

      // 各ドキュメントに対して非同期処理を行うためのFutureリストを作成
      var futures = <Future<StoreData?>>[];

      for (final change in querySnapshot.docs) {
        futures.add(processDocument(change));
      }

      // すべてのFutureが完了するのを待つ
      final results = await Future.wait(futures);

      // nullでない結果のみを新しいリストに追加
      final newStoreList =
          results.where((result) => result != null).cast<StoreData>();

      if (newStoreList.isNotEmpty) {
        state = await AsyncValue.guard(() async {
          return [...state.value!, ...newStoreList];
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<StoreData?> processDocument(QueryDocumentSnapshot change) async {
    final Map<String, dynamic> data = change.data() as Map<String, dynamic>;
    final int index = state.value!.indexWhere(
      (userData) => userData.id == change.id,
    );
    if (index == -1) {
      List<String> searchWordList =
          List<String>.from(data['search_word'] ?? []);
      final GeoPoint getGeo = data['geo']["geopoint"] as GeoPoint;
      final storageDataGet = await storeDataGet(
        change.id,
      );
      return StoreData(
        postImgList: storageDataGet?.postImgList ?? [],
        logo: storageDataGet?.logo,
        eventList: storageDataGet?.eventList ?? [],
        id: change.id,
        searchWord: searchWordList,
        name: nullCheckString(data["name"]) ?? "未設定",
        address: nullCheckString(data["address"]) ?? "未設定",
        businessHours: nullCheckString(data["business_hour"]) ?? "",
        location: LatLng(getGeo.latitude, getGeo.longitude),
      );
    }
    return null;
  }
}

Future<bool> checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isGranted) {
    return true;
  }
  return false;
}
