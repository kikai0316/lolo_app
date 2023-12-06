import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/view/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final User? user = FirebaseAuth.instance.currentUser;
    // Future<void> getSecureStorageData() async {
    //   await cacheSecureStorage();
    //   final UserData? userData = await readUserData();
    //   return userData;
    // }

    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}

Future<void> cacheSecureStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirst = prefs.getBool('is_first');
  if (isFirst == null || isFirst) {
    // flutter_secure_storageのデータを破棄
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    await prefs.setBool('is_first', false);
  }
}
