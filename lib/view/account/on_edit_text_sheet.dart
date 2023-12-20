import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';

class StringEditSheet extends HookConsumerWidget {
  const StringEditSheet({
    super.key,
    required this.title,
    required this.initData,
    required this.controller,
    required this.onTap,
  });

  final String title;
  final String initData;
  final TextEditingController controller;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final errorText = useState<String?>(null);
    bool isValidator() {
      if (title == "ユーザー名を入力") {
        if (controller.text.isEmpty) {
          errorText.value = "ユーザー名を入力してください";
          return false;
        }
        if (controller.text.contains('@')) {
          errorText.value = "ユーザー名に「@」を含めないでください。";
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
                        title,
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
                        hintText: "$titleを入力...",
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
              if (title == "検索キーワード") ...{
                Padding(
                  padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.005,
                    right: safeAreaWidth * 0.03,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (
                            BuildContext context,
                          ) =>
                              Dialog(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: safeAreaWidth * 0.95,
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(safeAreaWidth * 0.05),
                                      child: Text(
                                        "検索キーワードとは、一般ユーザーが店舗検索を行う際に、これらのキーワードを参考にした検索結果が表示されます。\n\n検索キーワードには、店舗名やそのひらがな、カタカナ表記などを入力してください。\n各キーワードは半角カンマ、全角カンマ、またはその両方を使用して区切ってください。",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontFamily: "Normal",
                                            fontVariations: const [
                                              FontVariation("wght", 500)
                                            ],
                                            color: Colors.grey,
                                            fontSize: safeAreaWidth / 30),
                                      ),
                                    ),
                                  )),
                        );
                      },
                      child: nText("検索キーワードとは？",
                          color: blueColor,
                          fontSize: safeAreaWidth / 35,
                          bold: 700),
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
