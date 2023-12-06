import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/firebase_options.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "lolo-app",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = FirebaseAuth.instance.currentUser;
    Future<UserData?> getSecureStorageData() async {
      await cacheSecureStorage();
      final UserData? userData = await readUserData();
      return userData;
    }

    if (user == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartPage(),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<UserData?>(
          future: getSecureStorageData(),
          builder:
              (BuildContext context, AsyncSnapshot<UserData?> snapshotUser) {
            if (snapshotUser.connectionState == ConnectionState.waiting) {
              return const WithIconInLoadingPage();
            } else if (snapshotUser.hasError) {
              return const StartPage();
            } else {
              if (snapshotUser.data == null) {
                return const StartPage();
              } else {
                return nextScreenWhisUserDataCheck(snapshotUser.data!);
              }
            }
          },
        ),
      );
    }
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
