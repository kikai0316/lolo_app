import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/login_widget.dart';

class SingInSheetWidget extends HookConsumerWidget {
  SingInSheetWidget({super.key, required this.onTap});
  final controllerList = List.generate(4, (index) => TextEditingController());
  final void Function(String, String, String) onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    // final birthday = useState<String?>(null);
    final subTextList = ["メールアドレスを入力", "パスワードを入力", "ユーザー名を入力"];
    final iconList = [
      Icons.email,
      Icons.lock,
      Icons.person,
    ];
    final errorMessage =
        useState<List<String?>>(List.generate(3, (index) => null));
    Widget errorText(String text) {
      return Padding(
        padding: EdgeInsets.only(top: safeAreaHeight * 0.005),
        child: nText(
          text,
          color: Colors.red,
          fontSize: safeAreaWidth / 35,
          bold: 400,
        ),
      );
    }

    bool isCheck() {
      errorMessage.value = List.generate(5, (index) => null);
      bool isError = true;
      final isEmail = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(controllerList[0].text);

      if (!isEmail || controllerList[0].text.isEmpty) {
        errorMessage.value[0] = "メールアドレスの形式が正しくありません";
        isError = false;
      }
      if (controllerList[1].text.isEmpty || controllerList[1].text.length < 6) {
        errorMessage.value[1] = "6文字以上のパスワードを入力してください。";
        isError = false;
      }
      if (controllerList[2].text.isEmpty) {
        errorMessage.value[2] = "ユーザー名を入力してください";
        isError = false;
      }
      if (controllerList[2].text.contains('@')) {
        errorMessage.value[2] = "ユーザー名に「@」を含めないでください。";
        isError = false;
      }
      errorMessage.value = [...errorMessage.value];
      return isError;
    }

    return SizedBox(
      height: safeAreaHeight * 0.9,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: loginSheetAppBar(
          context,
          "Sign Up!",
        ),
        body: SafeArea(
          child: Padding(
            padding: xPadding(context),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        for (int i = 0; i < 3; i++) ...{
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.02),
                            child: LoginTextField(
                              icon: iconList[i],
                              isError: errorMessage.value[i] != null,
                              subText: "${subTextList[i]}...",
                              isPassword: i == 1,
                              controller: controllerList[i],
                              onChanged: (value) {
                                errorMessage.value[i] = null;
                                errorMessage.value = [...errorMessage.value];
                              },
                            ),
                          ),
                          if (i == 2 && errorMessage.value[2] == null) ...{
                            Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.005),
                              child: nText(
                                "ユーザー名に「@」を含めないでください。",
                                color: Colors.grey,
                                fontSize: safeAreaWidth / 35,
                                bold: 400,
                              ),
                            ),
                          },
                          if (i == 1 && errorMessage.value[1] == null) ...{
                            Padding(
                              padding:
                                  EdgeInsets.only(top: safeAreaHeight * 0.005),
                              child: nText(
                                "パスワードは6文字以上にしてください。",
                                color: Colors.grey,
                                fontSize: safeAreaWidth / 35,
                                bold: 400,
                              ),
                            ),
                          },
                          if (errorMessage.value[i] != null) ...{
                            errorText(errorMessage.value[i]!),
                          },
                        },
                        SizedBox(
                          height: safeAreaHeight * 0.1,
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.01),
                    child: bottomButton(
                      context: context,
                      isWhiteMainColor: false,
                      text: "新規登録",
                      onTap: () async {
                        primaryFocus?.unfocus();
                        if (isCheck()) {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 500),
                          );
                          onTap(
                            controllerList[0].text,
                            controllerList[1].text,
                            controllerList[2].text,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
