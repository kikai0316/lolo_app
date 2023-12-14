import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/firebase_options.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/login.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "lolo-app-club",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LineSDK.instance.setup("2002147089");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends HookConsumerWidget {
  const MyApp({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> cacheSecureStorage() async {
      final prefs = await SharedPreferences.getInstance();
      final isFirst = prefs.getBool('is_first');
      if (isFirst == null || isFirst) {
        const storage = FlutterSecureStorage();
        await LineSDK.instance.logout();
        await storage.deleteAll();
        await prefs.setBool('is_first', false);
      }
    }

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<void>(
        future: cacheSecureStorage(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WithIconInLoadingPage();
            } else if (snapshot.hasError) {
              return const StartPage();
            }
          }
          return const InitialWidget();
        },
      ),
    );
  }
}

class InitialWidget extends HookConsumerWidget {
  const InitialWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataNotifier = ref.watch(userDataNotifierProvider);

    return userDataNotifier.when(
        data: (data) => data != null
            ? FutureBuilder<Widget>(
                future: nextScreenWithLocationCheck(
                  data,
                ),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const WithIconInLoadingPage();
                    } else if (snapshot.hasError) {
                      return const StartPage();
                    }
                  }
                  return snapshot.data ?? const StartPage();
                },
              )
            : const StartPage(),
        error: (e, s) => const StartPage(),
        loading: () => const WithIconInLoadingPage());
  }
}
