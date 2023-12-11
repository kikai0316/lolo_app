import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

final settingTitle = ["バージョン", "利用規約", "プライバシーポリシー", "アカウント削除"];

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

class UserEditSheet extends HookConsumerWidget {
  const UserEditSheet({
    super.key,
    required this.isUserName,
    required this.initData,
    required this.controller,
    required this.onTap,
  });

  final bool isUserName;
  final String initData;
  final TextEditingController controller;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final errorText = useState<String?>(null);
    bool isValidator() {
      if (isUserName) {
        if (controller.text.isEmpty) {
          errorText.value = "ユーザー名を入力してください";
          return false;
        }
        if (controller.text.contains('@')) {
          errorText.value = "ユーザー名に「@」を含めないでください。";
          return false;
        }
      } else {
        if (!RegExp(r'^[a-z0-9_.]+$').hasMatch(controller.text)) {
          errorText.value = "正確になInstagramのユーザーIDを入力してください。";
          return false;
        }
      }
      return true;
    }

    return Container(
      height: MediaQuery.of(context).size.height / 1.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.07,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      child: nText(
                        isUserName ? "ユーザー名" : "Instagramアカウント",
                        color: Colors.black,
                        fontSize: safeAreaWidth / 25,
                        bold: 700,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(safeAreaHeight * 0.015),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: safeAreaHeight * 0.25,
                  ),
                  width: safeAreaWidth * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 230, 230, 230)
                        .withOpacity(0.5),
                    border: errorText.value == null
                        ? null
                        : Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: safeAreaWidth * 0.04,
                      right: safeAreaWidth * 0.04,
                    ),
                    child: TextFormField(
                      controller: controller,
                      autofocus: true,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Normal",
                        fontVariations: const [FontVariation("wght", 400)],
                        fontWeight: FontWeight.bold,
                        fontSize: safeAreaWidth / 30,
                      ),
                      onChanged: (value) {
                        if (errorText.value != null) {
                          errorText.value = null;
                        }
                      },
                      decoration: InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: isUserName
                            ? "ユーザーネームを入力..."
                            : "InstagramのユーザーIDを入力...",
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.3),
                          fontSize: safeAreaWidth / 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (errorText.value != null) ...{
                Padding(
                  padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.005,
                    left: safeAreaWidth * 0.07,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: nText(
                      errorText.value!,
                      color: Colors.red,
                      fontSize: safeAreaWidth / 35,
                      bold: 400,
                    ),
                  ),
                ),
              },
              if (!isUserName) ...{
                Padding(
                  padding: EdgeInsets.only(right: safeAreaWidth * 0.04),
                  child: GestureDetector(
                    onTap: () {
                      if (controller.text.isNotEmpty) {
                        openURL(
                          url: "https://instagram.com/${controller.text}",
                          onError: () =>
                              errorText.value = "エラーが発生しました。再試行してください",
                        );
                      } else {
                        errorText.value = "ユーザーIDを入力してください。";
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        nText(
                          "アカウント確認する",
                          color: blueColor,
                          fontSize: safeAreaWidth / 35,
                          bold: 700,
                        ),
                        const Icon(
                          Icons.navigate_next,
                          color: blueColor,
                        ),
                      ],
                    ),
                  ),
                ),
              },
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                child: bottomButton(
                  context: context,
                  isWhiteMainColor: false,
                  text: "保存",
                  onTap: () {
                    if (initData == controller.text) {
                      Navigator.pop(context);
                    } else {
                      if (isValidator()) {
                        onTap!();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget accountMainWidget(
  BuildContext context, {
  required int data,
  required bool isEncounter,
}) {
  final safeAreaWidth = MediaQuery.of(context).size.width;
  final safeAreaHeight = safeHeight(context);
  return Container(
    width: safeAreaWidth * 0.9,
    decoration: BoxDecoration(
      color: isEncounter
          ? const Color.fromARGB(255, 85, 192, 97)
          : const Color.fromARGB(255, 0, 144, 250),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: EdgeInsets.only(
        left: safeAreaWidth * 0.03,
        right: safeAreaWidth * 0.03,
        top: safeAreaHeight * 0.01,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: safeAreaWidth * 0.1,
                height: safeAreaWidth * 0.1,
                decoration: BoxDecoration(
                  color: isEncounter
                      ? const Color.fromARGB(255, 136, 211, 144)
                      : const Color.fromARGB(255, 76, 177, 251),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEncounter ? Icons.people_alt : Icons.generating_tokens,
                  color: Colors.white,
                  size: safeAreaWidth / 20,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: safeAreaWidth * 0.03),
                child: nText(
                  isEncounter ? "今日出会った人数" : "ポイント",
                  color: Colors.white,
                  fontSize: safeAreaWidth / 30,
                  bold: 700,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: safeAreaHeight * 0.005,
            ),
            child: nText("100P",
                color: Colors.white, fontSize: safeAreaWidth / 10, bold: 700),
          ),
        ],
      ),
    ),
  );
}
