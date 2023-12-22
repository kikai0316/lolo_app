import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class NotImgPage extends HookConsumerWidget {
  const NotImgPage({
    super.key,
    required this.userData,
  });
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final img = useState<Uint8List?>(null);
    final upLoadMesse = useState<String>("");
    final isLoading = useState<bool>(false);
    final isPermission = useState<bool>(false);
    void showSnackbar() {
      errorSnackbar(
        context,
        message: "何らかの問題が発生しました。再試行してください。",
      );
    }

    Future<void> successGetImg(Uint8List value) async {
      if (context.mounted) {
        img.value = value;
      }
    }

    Future<void> dataUpLoad() async {
      isLoading.value = true;
      if (img.value == null) {
        final ByteData data = await rootBundle.load("assets/img/not.png");
        img.value = data.buffer.asUint8List();
      }
      final setData = UserData(
          img: img.value,
          id: userData.id,
          name: userData.name,
          birthday: userData.birthday,
          storeData: userData.storeData);
      final iswWite = await writeUserData(setData);
      if (iswWite) {
        final nextScreenWhisUserData = nextScreenWhisUserDataCheck(setData);
        if (nextScreenWhisUserData != null) {
          // ignore: use_build_context_synchronously
          screenTransitionNormal(context, nextScreenWhisUserData);
        } else {
          final nextScreenWithLocation = await nextScreenWithLocationCheck();
          if (context.mounted) {
            screenTransitionNormal(context, nextScreenWithLocation);
          }
        }
      } else {
        isLoading.value = false;
        showSnackbar();
      }
    }

    useEffect(
      () {
        Future(() async {
          await Permission.photosAddOnly.request();
          final isBool = await hasPhotoPermission();
          if (context.mounted) {
            isPermission.value = isBool;
          }
        });
        return null;
      },
      [],
    );

    return Scaffold(
      backgroundColor: blackColor,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.06,
                      bottom: safeAreaHeight * 0.08,
                    ),
                    child: nText(
                      "プロフィール画像を\n選択してください。",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 16,
                      bold: 700,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.03),
                    child: Container(
                        alignment: Alignment.bottomRight,
                        height: safeAreaWidth * 0.3,
                        width: safeAreaWidth * 0.3,
                        decoration: BoxDecoration(
                          image: img.value == null
                              ? notImg()
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(
                                    img.value!,
                                  )),
                          shape: BoxShape.circle,
                        ),
                        child: img.value != null
                            ? deleteIconWithCircle(
                                size: safeAreaWidth * 0.1,
                                onDelete: () => img.value = null,
                                padding: 0) //後
                            : null),
                  ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () async {
                        isLoading.value = true;
                        await getMobileImage(
                          onSuccess: (value) => successGetImg(value),
                          onError: () => errorSnackbar(context,
                              message: "画像の取得に失敗しました。\n再試行してください。"),
                        );
                        if (context.mounted) {
                          isLoading.value = false;
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        alignment: Alignment.center,
                        height: safeAreaHeight * 0.05,
                        width: safeAreaWidth * 0.4,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: nText(
                          "画像を追加",
                          color: Colors.white,
                          fontSize: safeAreaWidth / 25,
                          bold: 700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: bottomButton(
                context: context,
                isWhiteMainColor: true,
                text: "アップロード",
                onTap: () async {
                  dataUpLoad();
                },
              ),
            ),
          ),
          loadinPage(
            context: context,
            isLoading: isLoading.value,
            text: upLoadMesse.value,
          ),
          Visibility(
            visible: isPermission.value,
            child: photoPermissionWidget(context),
          ),
        ],
      ),
    );
  }
}

Widget upWidget(
  BuildContext context, {
  required void Function()? onTap,
  required bool isBlack,
}) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Material(
    borderRadius: BorderRadius.circular(10),
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.topCenter,
        height: safeAreaHeight * 0.2,
        width: safeAreaWidth * 0.25,
        decoration: BoxDecoration(
          border: Border.all(
            color: isBlack ? Colors.black : Colors.white,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: isBlack ? Colors.black : Colors.white,
              size: safeAreaWidth / 15,
            ),
            Padding(
              padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
              child: nText(
                "画像を追加",
                fontSize: safeAreaWidth / 30,
                color: isBlack ? Colors.black : Colors.white,
                bold: 700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget photoPermissionWidget(
  BuildContext context,
) {
  final safeAreaHeight = safeHeight(context);
  final safeAreaWidth = MediaQuery.of(context).size.width;
  return Container(
    alignment: Alignment.center,
    height: double.infinity,
    color: Colors.black.withOpacity(0.8),
    child: Container(
      alignment: Alignment.center,
      height: safeAreaHeight * 0.35,
      width: safeAreaWidth * 0.85,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: nText(
                  "カメラロールへの\nアクセス許可が必要です",
                  color: Colors.black,
                  fontSize: safeAreaWidth / 20,
                  bold: 700,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: safeAreaWidth * 0.05,
              right: safeAreaWidth * 0.05,
              bottom: safeAreaHeight * 0.02,
            ),
            child: Text(
              // permissionMessage,
              "カメラロールへのアクセス権を、下記の「設定画面」ボタンをタップ→「写真」を選択→「すべての写真」を選択",
              textAlign: TextAlign.center,

              style: TextStyle(
                decoration: TextDecoration.none,
                fontFamily: "Normal",
                fontVariations: const [FontVariation("wght", 700)],
                color: Colors.grey,
                fontSize: safeAreaWidth / 35,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: safeAreaWidth * 0.05,
              right: safeAreaWidth * 0.05,
              bottom: safeAreaHeight * 0.01,
            ),
            child: Text(
              // permissionMessage,
              "変更後はアプリを再起動してください。",
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontFamily: "Normal",
                fontVariations: const [FontVariation("wght", 700)],
                color: Colors.red,
                fontSize: safeAreaWidth / 35,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(safeAreaWidth * 0.03),
            child: GestureDetector(
              onTap: () {
                openAppSettings();
              },
              child: Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.065,
                width: safeAreaWidth * 0.95,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: blueColor2,
                  ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: nText(
                  "設定画面へ",
                  color: blueColor2,
                  fontSize: safeAreaWidth / 27,
                  bold: 700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<bool> hasPhotoPermission() async {
  final status = await Permission.photosAddOnly.status;
  if (status.isGranted) {
    return false;
  }
  return true;
}
