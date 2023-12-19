import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';

String? nullCheckString(
  dynamic data,
) {
  return data as String?;
}

int nullCheckInt(
  dynamic data,
) {
  if (data == null) {
    return 0;
  } else {
    return data as int;
  }
}

Future<StoreData?> fetchStoreDetails(String id) async {
  try {
    var documentSnapshot =
        await FirebaseFirestore.instance.collection('store').doc(id).get();
    if (!documentSnapshot.exists) return null;

    var documentData = documentSnapshot.data() as Map<String, dynamic>;
    var storeData = await toStoreData(documentData, id);
    if (storeData == null) return null;

    return storeData;
  } catch (e) {
    return null;
  }
}

Future<StoreData?> toStoreData(Map<String, dynamic> dbData, String id) async {
  try {
    var dbGetData = await storeDataGet(id);
    if (dbGetData?.logo == null) return null;
    var getGeo = dbData['geo']["geopoint"] as GeoPoint?;
    if (getGeo == null) return null;
    List<String> searchWordList =
        List<String>.from(dbData['search_word'] ?? []);
    return StoreData(
        postImgList: dbGetData!.postImgList,
        logo: dbGetData.logo,
        id: id,
        name: dbData["name"] ?? "",
        searchWord: searchWordList,
        address: dbData["address"] ?? "",
        businessHours: dbData["business_hours"] ?? "",
        location: LatLng(getGeo.latitude, getGeo.longitude),
        eventList: dbGetData.eventList);
  } catch (e) {
    return null;
  }
}

Future<bool> setDataStore(Map<String, dynamic> setData, String id) async {
  try {
    final storedb = FirebaseFirestore.instance.collection("store").doc(id);
    await storedb.set(setData);
    return true;
  } on FirebaseException {
    return false;
  }
}

Future<bool> upDataStore(Map<String, dynamic> setData, String id) async {
  try {
    final storedb = FirebaseFirestore.instance.collection("store").doc(id);
    await storedb.update(setData);
    return true;
  } on FirebaseException {
    return false;
  }
}
