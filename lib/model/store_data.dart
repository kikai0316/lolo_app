import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'store_data.freezed.dart';

@freezed
class StoreData with _$StoreData {
  const factory StoreData(
      {required List<StoryType> storyList,
      required Uint8List? logo,
      required String id,
      required String name,
      required String address,
      required String businessHours,
      required List<String> searchWord,
      required List<EventType> eventList,
      required LatLng location}) = _StoreData;
}

class StoryType {
  Uint8List img;
  String id;
  DateTime date;
  StoryType({
    required this.img,
    required this.id,
    required this.date,
  });
}

class EventType {
  Uint8List img;
  String id;
  String title;
  DateTime date;
  EventType({
    required this.img,
    required this.id,
    required this.date,
    required this.title,
  });
}
