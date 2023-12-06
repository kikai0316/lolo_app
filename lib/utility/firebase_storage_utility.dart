// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:lolo_app/model/user_data.dart';

// Future<UserData?> myDataGet(String id) async {
//   try {
//     final resultMain = await FirebaseStorage.instance.ref(id).listAll();
//     final mainImgGet = await resultMain.items.first.getData();
//     final List<String> parts = resultMain.items.first.name.split('@');
//     if (mainImgGet != null && parts.length > 1) {
//       return UserData(
//         img: mainImgGet,
//         id: id,
//         name: parts[0],
//         birthday: parts[1],
//       );
//     }
//   } on FirebaseException {
//     return null;
//   }
// }
