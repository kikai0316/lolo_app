import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:path_provider/path_provider.dart';

Future<StoreData?> storeDataGet(String id) async {
  try {
    final List<StoryType> storyImgList = [];
    final List<EventType> eventList = [];
    final resultMain =
        await FirebaseStorage.instance.ref("store/$id/main").listAll();
    final mainImgGet = await resultMain.items.first.getData();
    if (mainImgGet != null) {
      final resultStory =
          await FirebaseStorage.instance.ref("store/$id/story").listAll();
      final resultEvent =
          await FirebaseStorage.instance.ref("store/$id/event").listAll();
      for (final ref in resultStory.items) {
        final Uint8List? getImg = await ref.getData();
        final List<String> parts = ref.name.split('@');
        if (getImg != null && parts.length == 2) {
          storyImgList.add(StoryType(
              img: getImg, id: parts[0], date: DateTime.parse(parts[1])));
        }
      }
      for (final ref in resultEvent.items) {
        final Uint8List? getImg = await ref.getData();
        final List<String> parts = ref.name.split('@');
        if (getImg != null && parts.length == 3) {
          eventList.add(EventType(
            img: getImg,
            id: parts[0],
            category: parts[1],
            date: DateTime.parse(
              parts[2],
            ),
          ));
        }
      }
      return StoreData(
          storyList: sortStoriesByOldestDate(
            storyImgList,
          ),
          logo: mainImgGet,
          id: "",
          name: "",
          location: const LatLng(0, 0),
          address: "",
          businessHours: "",
          searchWord: [],
          eventList: filteredAndSortedEvents(eventList));
    } else {
      return null;
    }
  } on FirebaseException {
    return null;
  }
}

Future<bool> upLoadMain(Uint8List img, String id) async {
  try {
    final resultMain =
        await FirebaseStorage.instance.ref("store/$id/main").listAll();
    for (final ref in resultMain.items) {
      ref.delete();
    }
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/logo.png';
    File file = File(imagePath);
    await file.writeAsBytes(img);
    await FirebaseStorage.instance
        .ref("store/$id/main/${DateTime.now()}")
        .putFile(file);
    return true;
  } on FirebaseException {
    return false;
  }
}

Future<bool> upDataStory(
    {required StoryType data,
    required String id,
    required bool isDelete}) async {
  try {
    if (isDelete) {
      final resultStory =
          await FirebaseStorage.instance.ref("store/$id/story").listAll();
      for (final ref in resultStory.items) {
        final List<String> parts = ref.name.split('@');
        if (data.id == parts[0]) {
          ref.delete();
        }
      }
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/story.png';
      File file = File(imagePath);
      await file.writeAsBytes(data.img);
      await FirebaseStorage.instance
          .ref("store/$id/story/${data.id}@${data.date}")
          .putFile(file);
    }
    return true;
  } on FirebaseException {
    return false;
  }
}

Future<bool> upLoadEvent(
    {required List<EventType> addDataList,
    required String id,
    required List<String> deleteDataList}) async {
  try {
    if (deleteDataList.isNotEmpty) {
      final resultStory =
          await FirebaseStorage.instance.ref("store/$id/event").listAll();
      for (final ref in resultStory.items) {
        final List<String> parts = ref.name.split('@');
        if (deleteDataList.contains(parts[0])) {
          ref.delete();
        }
      }
    }
    for (final item in addDataList) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/event.png';
      File file = File(imagePath);
      await file.writeAsBytes(item.img);
      await FirebaseStorage.instance
          .ref("store/$id/event/${item.id}@${item.category}@${item.date}") //後
          .putFile(file);
    }
    return true;
  } on FirebaseException {
    return false;
  }
}

Future<UserData?> userDataGet(String id) async {
  try {
    final resultMain =
        await FirebaseStorage.instance.ref("user/$id/").listAll();
    final mainImgGet = await resultMain.items.first.getData();
    if (mainImgGet != null) {
      return UserData(
          img: mainImgGet, id: "", name: "", birthday: "", storeData: null);
    } else {
      return null;
    }
  } on FirebaseException {
    return null;
  }
}

Future<bool> userDataUpLoad(UserData userData) async {
  try {
    final resultMain =
        await FirebaseStorage.instance.ref("user/${userData.id}").listAll();
    for (final ref in resultMain.items) {
      ref.delete();
    }
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/img.png';
    File file = File(imagePath);
    if (userData.img != null) {
      await file.writeAsBytes(userData.img!);
    } else {
      final ByteData data = await rootBundle.load("assets/img/not.png");
      await file.writeAsBytes(data.buffer.asUint8List());
    }
    await FirebaseStorage.instance
        .ref("user/${userData.id}/${userData.name}")
        .putFile(file);
    return true;
  } on FirebaseException {
    return false;
  }
}
