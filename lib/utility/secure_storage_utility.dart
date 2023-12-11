import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<Map<String, String>?> readSecureStorage() async {
  const storage = FlutterSecureStorage();
  final String? jsonString = await storage.read(key: "account");
  if (jsonString != null) {
    final Map<String, dynamic> userData =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return {
      'email': userData["email"] as String,
      "password": userData["password"] as String,
    };
  } else {
    return null;
  }
}

Future<bool> writeSecureStorage({
  required String email,
  required String password,
}) async {
  try {
    const storage = FlutterSecureStorage();
    final Map<String, String> userData = {
      'email': email,
      "password": password,
    };
    await storage.write(
      key: "account",
      value: jsonEncode(userData),
    );
    return true;
  } catch (e) {
    return false;
  }
}
