import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'store_data.freezed.dart';

@freezed
class StoreData with _$StoreData {
  const factory StoreData(
      {required List<StoryImgType> postImgList,
      required Uint8List? logo,
      required String id,
      required String name,
      required String address,
      required String businessHours,
      required List<String> searchWord,
      required LatLng location}) = _StoreData;
}

class StoryImgType {
  Uint8List img;
  DateTime date;
  StoryImgType({
    required this.img,
    required this.date,
  });
}
