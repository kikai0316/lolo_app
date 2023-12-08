import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lolo_app/model/store_data.dart';

Future<StoreData?> storeDataGet(StoreData storeData) async {
  try {
    final List<StoryImgType> imgList = [];
    final resultMain = await FirebaseStorage.instance
        .ref("stores/${storeData.id}/main")
        .listAll();
    final mainImgGet = await resultMain.items.first.getData();
    if (mainImgGet != null) {
      //  final List<String> parts = resultMain.items.first.name.split('@');
      final resultOthers = await FirebaseStorage.instance
          .ref("stores/${storeData.id}/post")
          .listAll();
      for (final ref in resultOthers.items) {
        final Uint8List? getImg = await ref.getData();
        if (getImg != null) {
          // final getDate = DateTime.parse(ref.name);
          imgList.add(StoryImgType(img: getImg, date: DateTime.now()));
        }
      }
      return StoreData(
          postImgList: imgList,
          logo: mainImgGet,
          id: storeData.id,
          name: resultMain.items.first.name,
          location: storeData.location);
    } else {
      return null;
    }
  } on FirebaseException {
    return null;
  }
}
