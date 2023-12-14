import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> get _localPath async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final dataPath = directory.path;
    return dataPath;
  } catch (e) {
    return null;
  }
}

Future<File?> _localFile(String fileName) async {
  final path = await _localPath;
  if (path != null) {
    return File('$path/$fileName');
  } else {
    return null;
  }
}

Future<bool> writeUserData(
  UserData data,
) async {
  final file = await _localFile("user");
  if (file != null) {
    try {
      final toBase64 = data.img == null ? "" : base64Encode(data.img!);
      final Map<String, dynamic> setData = <String, dynamic>{
        "id": data.id,
        "name": data.name,
        "img": toBase64,
        "birthday": data.birthday,
        "storeData": data.storeData == null ? "" : data.storeData!.id,
      };
      final jsonList = jsonEncode(setData);
      await file.writeAsString(jsonList);
      return true;
    } catch (e) {
      return false;
    }
  } else {
    return false;
  }
}

Future<UserData?> readUserData() async {
  try {
    final file = await _localFile("user");
    if (file == null) return null;
    final User? user = FirebaseAuth.instance.currentUser;
    final String contents = await file.readAsString();
    final Map<String, dynamic> toDecode = jsonDecode(contents);
    final imgListDecode =
        toDecode["img"] == "" ? null : base64Decode(toDecode["img"]);
    final String id = toDecode["id"] ?? "";
    final String name = toDecode["name"] ?? "";
    final String birthday = toDecode["birthday"] ?? "";
    final getStoreID = toDecode["storeData"] ?? "";
    final getDB = getStoreID.isNotEmpty && (user?.uid ?? "") == getStoreID
        ? await fetchStoreDetails(getStoreID)
        : null;
    return UserData(
      id: id,
      name: name,
      birthday: birthday,
      img: imgListDecode,
      storeData: getDB,
    );
  } catch (e) {
    return null;
  }
}
