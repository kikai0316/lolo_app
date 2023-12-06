import 'dart:convert';
import 'dart:io';

import 'package:lolo_app/model/user_data.dart';
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
  final file = await _localFile("user");
  if (file != null) {
    try {
      final String contents = await file.readAsString();
      final toDecode = jsonDecode(contents) as Map<String, dynamic>;
      final imgListDecode = toDecode["img"] == ""
          ? null
          : base64Decode(toDecode["img"] as String);
      final setData = UserData(
          id: toDecode["id"] as String,
          name: toDecode["name"] as String,
          birthday: toDecode["birthday"] as String,
          img: imgListDecode);
      return setData;
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}
