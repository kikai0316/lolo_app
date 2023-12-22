import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/constant/url.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/secure_storage_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/login/login_sheet.dart';
import 'package:lolo_app/view/login/store_information_sheet.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/login/login_widget.dart';

class StartPage extends HookConsumerWidget {
  const StartPage({
    super.key,
    required this.isGeneral,
  });
  final bool isGeneral;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final initStoreData = useState<StoreDataInformation?>(null);
    final geoPointWidget = useState<Widget?>(null);
    final errorMessage = [
      "指定されたメールアドレスはすでに使用されています。",
      "アカウントが見つかりませんでした。\nメールアドレスとパスワードを確認して、もう一度お試しください。",
      "システムエラーが発生しました。\n少し時間を置いてからもう一度お試しください。",
      "データのアップロードに失敗しました。\n少し時間を置いてからもう一度お試しください。",
    ];
    void showSnackbar(int index) {
      isLoading.value = false;
      errorSnackbar(context, message: errorMessage[index]);
    }

    Future<void> writeStoreData(StoreData storeData) async {
      final notifier = ref.read(userDataNotifierProvider.notifier);
      await notifier.addStoreData(storeData);
      if (context.mounted) {
        isLoading.value = false;
        Navigator.pop(context);
        successSnackbar(
          context,
          "ようこそ！ログインに成功しました。",
        );
      }
    }

    Future<void> logIn(String id) async {
      try {
        final getDB = await fetchStoreDetails(id);
        if (!context.mounted) {
          showSnackbar(2);
          return;
        }
        if (getDB == null) {
          screenTransitionToTop(
            context,
            StoreSetteingSheetWidget(
              initData: initStoreData.value,
              onTap: (value) async {
                isLoading.value = true;
                initStoreData.value = value;
                final List<double>? getGeo =
                    await geocodeAddress(value.address);
                isLoading.value = false;
                geoPointWidget.value = GeoPositionWidget(
                    locationData: getGeo,
                    removeOnTap: () => geoPointWidget.value = null,
                    onTap: (location) async {
                      isLoading.value = true;
                      geoPointWidget.value = null;
                      final GeoFirePoint geoFirePoint =
                          GeoFirePoint(GeoPoint(location[0], location[1]));
                      try {
                        final setData = {
                          "name": value.name,
                          "address": value.address,
                          "business_hours": "${value.opnen}@${value.close}",
                          "geo": geoFirePoint.data,
                          "search_word": value.searchWord,
                        };
                        final isDataUpLoading = await setDataStore(setData, id);
                        final isLogoUpLoading = await upLoadMain(value.img, id);
                        if (isDataUpLoading && isLogoUpLoading) {
                          await writeStoreData(StoreData(
                              postImgList: [],
                              logo: value.img,
                              id: id,
                              searchWord: value.searchWord,
                              name: value.name,
                              address: value.address,
                              businessHours: "${value.opnen}@${value.close}",
                              eventList: [],
                              location: LatLng(location[0], location[1])));
                        } else {
                          isLoading.value = false;
                          showSnackbar(3);
                        }
                      } on FirebaseException {
                        isLoading.value = false;
                        showSnackbar(3);
                      }
                    });
              },
            ),
          );
          return;
        } else {
          await writeStoreData(getDB);
          return;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          showSnackbar(1);
        } else if (e.code == 'wrong-password') {
          showSnackbar(1);
        } else {
          showSnackbar(2);
        }
      } catch (e) {
        showSnackbar(2);
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> lineLogin() async {
      final result = await LineSDK.instance.login();
      if (result.userProfile?.userId == null) {
        showSnackbar(2);
        return;
      }
      final getimg = await fetchImage(result.userProfile?.pictureUrl);
      final setData = UserData(
          img: getimg,
          id: result.userProfile?.userId ?? "",
          name: result.userProfile?.displayName ?? "",
          birthday: "",
          storeData: null);
      if (!context.mounted) {
        showSnackbar(2);
        return;
      }
      final notifier = ref.read(userDataNotifierProvider.notifier);
      final isdbUpload = await userDataUpLoad(setData);
      final isSuccess = await notifier.upData(setData);
      if (isSuccess && isdbUpload && context.mounted) {
        successSnackbar(
          context,
          "ようこそ！ログインに成功しました。",
        );
        return;
      } else {
        showSnackbar(2);
        return;
      }
    }

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: blackColor,
          appBar: isGeneral
              ? AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                )
              : appBar(context, null, false),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: safeAreaWidth * 0.06,
                right: safeAreaWidth * 0.06,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: safeAreaHeight * 0.1,
                          width: safeAreaWidth * 0.3,
                          // decoration: BoxDecoration(
                          //   image: appLogoImg(),
                          // ),
                          child: nText(
                            "LoLo.",
                            color: Colors.white,
                            fontSize: safeAreaWidth / 14,
                            bold: 700,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: nText(
                              "新しい世界へ\nの扉を開けましょう",
                              color: Colors.white,
                              fontSize: safeAreaWidth / 14,
                              bold: 700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isGeneral) ...{
                    bottomButton(
                        context: context,
                        isWhiteMainColor: true,
                        text: "ログイン",
                        onTap: () async {
                          bottomSheet(context, page:
                              LoginSheetWidget(onTap: (email, password) async {
                            isLoading.value = true;
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password);
                            await Future<void>.delayed(
                                const Duration(milliseconds: 3));
                            final User? user =
                                FirebaseAuth.instance.currentUser;
                            if (user == null || !context.mounted) {
                              showSnackbar(2);
                              return;
                            }
                            final isWriteAccountData = await writeSecureStorage(
                              email: email,
                              password: password,
                            );
                            if (!isWriteAccountData || !context.mounted) {
                              showSnackbar(2);
                              return;
                            }
                            await logIn(user.uid);
                          }), isBackgroundColor: true);
                        }),
                  } else ...{
                    lineLoginButton(context: context, onTap: () => lineLogin()),
                  },
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.06,
                      bottom: safeAreaHeight * 0.02,
                    ),
                    child: privacyText(
                      context: context,
                      onTap1: () => openURL(
                        url: termsURL,
                        onError: () => showSnackbar(2),
                      ),
                      onTap2: () => openURL(
                        url: privacyURL,
                        onError: () => showSnackbar(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (geoPointWidget.value != null) ...{geoPointWidget.value!},
        loadinPage(context: context, isLoading: isLoading.value, text: null),
      ],
    );
  }

  Future<List<double>?> geocodeAddress(
    String address,
  ) async {
    final endpoint =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=AIzaSyDo6gch_s9aMklIYr_4Is0d_kV2zKVCuYA';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final Map<String, dynamic> result =
          json.decode(response.body) as Map<String, dynamic>;
      if (result['results'] != null && (result['results'] as List).isNotEmpty) {
        final Map<String, dynamic> geometry =
            // ignore: avoid_dynamic_calls
            result['results'][0]['geometry'] as Map<String, dynamic>;
        return [
          // ignore: avoid_dynamic_calls
          geometry['location']['lat'] as double,
          // ignore: avoid_dynamic_calls
          geometry['location']['lng'] as double
        ];
      }
    }
    return null;
  }

  Future<Uint8List?> fetchImage(String? url) async {
    if (url != null) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } else {
      try {
        final ByteData data = await rootBundle.load("assets/img/not.png");
        return data.buffer.asUint8List();
      } catch (e) {
        return null;
      }
    }
  }

  Widget loginLine(BuildContext context) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: safeAreaHeight * 0.05,
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.2,
              width: double.infinity,
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(safeAreaWidth * 0.025),
            child: Text(
              "または",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: safeAreaWidth / 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.2,
              width: double.infinity,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
