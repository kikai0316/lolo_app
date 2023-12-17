import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/view_model/near_stores.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'all_stores.g.dart';

@Riverpod(keepAlive: true)
class AllStoresNotifier extends _$AllStoresNotifier {
  @override
  Future<List<StoreData>?> build() async {
    final isPermission = await checkLocationPermission();
    if (isPermission) {
      // final currentPosition = await Geolocator.getCurrentPosition();
      // dbGetStoreData(currentPosition.latitude, currentPosition.longitude);
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
    final notifier = ref.read(nearStoresNotifierProvider.notifier);
    await notifier.upDataList([newData.id]);
    final int index =
        state.value!.indexWhere((userData) => userData.id == newData.id);
    if (index == -1) {
      state = await AsyncValue.guard(() async {
        if (state.value == null) {
          return [newData];
        } else {
          return [...state.value!, newData];
        }
      });
    }
  }

  Future<void> dbGetStoreData(double lat, double lon) async {
    try {
      StreamSubscription? subscription;
      final List<StoreData> newStoreList = [];
      final GeoPoint center = GeoPoint(lat, lon);
      const String field = 'geo';
      final CollectionReference<Map<String, dynamic>> collectionReference =
          FirebaseFirestore.instance.collection('store');
      GeoPoint geopointFrom(Map<String, dynamic> data) =>
          (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
      final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> stream =
          GeoCollectionReference<Map<String, dynamic>>(collectionReference)
              .subscribeWithin(
        center: GeoFirePoint(center),
        radiusInKm: 2,
        field: field,
        geopointFrom: geopointFrom,
      );

      subscription = stream.listen((event) async {
        for (final change in event) {
          final Map<String, dynamic>? data = change.data();
          final int index = state.value!.indexWhere(
            (userData) => userData.id == change.id,
          );
          if (index == -1) {
            List<String> searchWordList =
                List<String>.from(data!['search_word'] ?? []);
            final GeoPoint getGeo = data['geo']["geopoint"] as GeoPoint;
            newStoreList.add(StoreData(
              postImgList: [],
              logo: null,
              id: change.id,
              searchWord: searchWordList,
              name: nullCheckString(data["name"]) ?? "未設定",
              address: nullCheckString(data["address"]) ?? "未設定",
              businessHours: nullCheckString(data["business_hour"]) ?? "",
              location: LatLng(getGeo.latitude, getGeo.longitude),
            ));
          }
        }
        List<String> idList = event.map((storeData) => storeData.id).toList();
        final notifier = ref.read(nearStoresNotifierProvider.notifier);
        notifier.upDataList(idList);
        if (newStoreList.isNotEmpty) {
          state = await AsyncValue.guard(() async {
            return [...state.value!, ...newStoreList];
          });
        }
        await subscription?.cancel();
      });
    } catch (e) {
      return;
    }
  }
}

Future<bool> checkLocationPermission() async {
  var status = await Permission.location.status;
  if (status.isGranted) {
    return true;
  }
  return false;
}
