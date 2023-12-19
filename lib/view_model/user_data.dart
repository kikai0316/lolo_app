import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_data.g.dart';

@Riverpod(keepAlive: true)
class UserDataNotifier extends _$UserDataNotifier {
  @override
  Future<UserData?> build() async {
    final result = await LineSDK.instance.currentAccessToken;
    if (result != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      final StoreData? getStoreData =
          user != null ? await fetchStoreDetails(user.uid) : null;
      final userData = await readUserData();
      if (userData != null) {
        return UserData(
            img: userData.img,
            id: userData.id,
            name: userData.name,
            birthday: userData.birthday,
            storeData: getStoreData);
      }
    }
    return null;
  }

  Future<bool> upData(UserData userData) async {
    final isSuccess = await writeUserData(userData);
    if (isSuccess) {
      state = await AsyncValue.guard(() async {
        return userData;
      });
    }
    return isSuccess;
  }

  Future<void> addStoreData(StoreData? storeData) async {
    state = await AsyncValue.guard(() async {
      return UserData(
          img: state.value!.img,
          id: state.value!.id,
          name: state.value!.name,
          birthday: state.value!.birthday,
          storeData: storeData);
    });
  }

  Future<void> reFetchStore() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final StoreData? getStoreData =
        user != null ? await fetchStoreDetails(user.uid) : null;
    if (getStoreData != null) {
      state = await AsyncValue.guard(() async {
        return UserData(
            img: state.value!.img,
            id: state.value!.id,
            name: state.value!.name,
            birthday: state.value!.birthday,
            storeData: getStoreData);
      });
    }
  }
}
// class AccountData {
//   bool? isGeneralUser;
//   StoreData? storeData;
//   UserData? userData;
//   AccountData(
//       {required this.isGeneralUser,
//       required this.storeData,
//       required this.userData});
// }

// Future<StoreData?> toStoreData(Map<String, dynamic> dbData, String id) async {
//   try {
//     final dbGetData = await storeDataGet(
//       StoreData(
//           postImgList: [],
//           logo: null,
//           id: id,
//           name: "",
//           address: "",
//           businessHours: "",
//           location: const LatLng(0, 0)),
//     );
//     final String? name = dbData["name"];
//     final String? address = dbData["address"];
//     final String? businessHours = dbData[" businessHours"];
//     final GeoPoint? getGeo = dbData['geo']["geopoint"] as GeoPoint?;
//     if (name != null &&
//         address != null &&
//         businessHours != null &&
//         getGeo != null &&
//         dbGetData?.logo != null) {
//       return StoreData(
//           postImgList: dbGetData?.postImgList ?? [],
//           logo: dbGetData!.logo,
//           id: id,
//           name: name,
//           address: address,
//           businessHours: businessHours,
//           location: LatLng(getGeo.latitude, getGeo.longitude));
//     } else {
//       return null;
//     }
//   } catch (e) {
//     return null;
//   }
// }

