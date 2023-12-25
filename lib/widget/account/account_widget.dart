import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account/profile_setting.dart';

final settingTitle = [
  "バージョン",
  "利用規約",
  "プライバシーポリシー",
  "店舗アカウントへログイン",
  "ユーザーアカウント削除",
];

Widget settingWidget({
  required BuildContext context,
  required String iconText,
  required Widget trailing,
  required void Function()? onTap,
  required bool isOnlyTopRadius,
  required bool isOnlyBottomRadius,
  required bool isRedTitle,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  BorderRadiusGeometry radius() {
    return BorderRadius.only(
      topLeft: isOnlyTopRadius ? const Radius.circular(20) : Radius.zero,
      topRight: isOnlyTopRadius ? const Radius.circular(20) : Radius.zero,
      bottomLeft: isOnlyBottomRadius ? const Radius.circular(20) : Radius.zero,
      bottomRight: isOnlyBottomRadius ? const Radius.circular(20) : Radius.zero,
    );
  }

  return Material(
    color: blackColor,
    borderRadius: radius(),
    child: InkWell(
      onTap: onTap,
      borderRadius: radius() as BorderRadius,
      child: SizedBox(
        height: safeAreaHeight * 0.08,
        child: Padding(
          padding: EdgeInsets.only(
            left: safeAreaWidth * 0.03,
            right: safeAreaWidth * 0.03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              nText(
                iconText,
                color: isRedTitle ? Colors.red : Colors.white,
                fontSize: safeAreaWidth / 26,
                bold: 700,
              ),
              trailing,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget profileWidget(
  BuildContext context, {
  required UserData userData,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    alignment: Alignment.center,
    height: safeAreaHeight * 0.25,
    width: safeAreaWidth * 0.9,
    decoration: BoxDecoration(
      color: blackColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: safeAreaWidth * 0.18,
            width: safeAreaWidth * 0.18,
            decoration: BoxDecoration(
              image: userData.img != null
                  ? DecorationImage(
                      image: MemoryImage(userData.img!), fit: BoxFit.cover)
                  : notImg(),
              shape: BoxShape.circle,
            )),
        Padding(
          padding: EdgeInsets.only(
            top: safeAreaHeight * 0.01,
            bottom: safeAreaHeight * 0.015,
          ),
          child: nText(
            userData.name,
            color: Colors.white,
            fontSize: safeAreaWidth / 20,
            bold: 700,
          ),
        ),
        miniButton(
          context: context,
          text: "プロフィールを編集",
          onTap: () => screenTransitionNormal(
            context,
            ProfileSetting(
              userData: userData,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget accountErrorWidget(
  BuildContext context,
) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    alignment: Alignment.center,
    height: safeAreaHeight * 0.25,
    width: safeAreaWidth * 0.9,
    decoration: BoxDecoration(
      color: blackColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.white,
          size: safeAreaWidth / 10,
        ),
        Padding(
          padding: EdgeInsets.only(top: safeAreaHeight * 0.01),
          child: nText("プロフィールの取得に失敗しました。",
              color: Colors.white, fontSize: safeAreaWidth / 25, bold: 500),
        )
      ],
    ),
  );
}

Widget imgSetteingWidget(
    BuildContext context, Uint8List? img, void Function() onTap) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    alignment: Alignment.center,
    height: safeAreaHeight * 0.16,
    width: safeAreaWidth * 0.9,
    decoration: BoxDecoration(
      color: blackColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.bottomRight,
        height: safeAreaHeight * 0.1,
        width: safeAreaHeight * 0.1,
        decoration: BoxDecoration(
          image: img != null
              ? DecorationImage(image: MemoryImage(img), fit: BoxFit.cover)
              : notImg(),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1.0,
            )
          ],
          shape: BoxShape.circle,
        ),
        child: Container(
          height: safeAreaHeight * 0.045,
          width: safeAreaHeight * 0.045,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.photo_camera,
            color: Colors.black.withOpacity(0.8),
          ),
        ),
      ),
    ),
  );
}
