import 'package:firebase_database/firebase_database.dart';

Future<bool> updateCongestion(String id, int index) async {
  final Map<String, dynamic> data = {
    'index': index,
    "dateTime": DateTime.now().toString()
  };
  try {
    // ignore: deprecated_member_use
    final databaseReference = FirebaseDatabase(
      databaseURL:
          "https://lolo-app-club-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ).ref("store");
    await databaseReference.child(id).set(data);
    return true;
  } catch (e) {
    return false;
  }
}
