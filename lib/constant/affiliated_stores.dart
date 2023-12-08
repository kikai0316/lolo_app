import 'package:google_maps_flutter/google_maps_flutter.dart';

List<AfiliatedStore> afiliatedStoresList = [
  AfiliatedStore(
      id: "aaaaa",
      location: const LatLng(33.8673087755819, 130.70469237864015)),
  AfiliatedStore(
      id: "ddddd",
      location: const LatLng(33.87059009491246, 130.70545613765717))
];

class AfiliatedStore {
  String id;
  LatLng location;
  AfiliatedStore({
    required this.id,
    required this.location,
  });
}
