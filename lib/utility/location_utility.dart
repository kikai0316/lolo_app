import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/model/store_data.dart';

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295; // ラジアンへの変換係数
  const c = cos;
  final a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 結果はキロメートル単位
}

bool isWithin10Km(
  double baseLat,
  double baseLon,
  double targetLat,
  double targetLon,
) {
  final double distance =
      calculateDistance(baseLat, baseLon, targetLat, targetLon);
  return distance <= 10.0; // 10km以内かどうか
}

List<StoreData> filterAndSortStores(List<StoreData> stores, LatLng myLocation) {
  List<StoreData> filteredStores = stores.where((store) {
    return isWithin10Km(myLocation.latitude, myLocation.longitude,
        store.location.latitude, store.location.longitude);
  }).toList();
  filteredStores.sort((a, b) {
    double distanceA = calculateDistance(myLocation.latitude,
        myLocation.longitude, a.location.latitude, a.location.longitude);
    double distanceB = calculateDistance(myLocation.latitude,
        myLocation.longitude, b.location.latitude, b.location.longitude);
    return distanceA.compareTo(distanceB);
  });

  return filteredStores;
}
