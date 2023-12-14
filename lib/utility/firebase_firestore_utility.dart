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
    var dbGetData = await storeDataGet(StoreData(
      postImgList: [],
      logo: null,
      id: id,
      name: "",
      address: "",
      businessHours: "",
      location: const LatLng(0, 0),
    ));

    if (dbGetData?.logo == null) return null;

    var getGeo = dbData['geo']["geopoint"] as GeoPoint?;
    if (getGeo == null) return null;

    return StoreData(
      postImgList: dbGetData!.postImgList,
      logo: dbGetData.logo,
      id: id,
      name: dbData["name"],
      address: dbData["address"],
      businessHours: dbData["businessHours"],
      location: LatLng(getGeo.latitude, getGeo.longitude),
    );
  } catch (e) {
    return null;
  }
}
