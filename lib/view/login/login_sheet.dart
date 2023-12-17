import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/login_widget.dart';

class LoginSheetWidget extends HookConsumerWidget {
  LoginSheetWidget({super.key, required this.onTap});
  final controllerList = List.generate(2, (index) => TextEditingController());
  final void Function(String, String) onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final errorMessage = useState<String?>(null);

    bool isEmailCheck() {
      final regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      );
      final isError = regExp.hasMatch(controllerList[0].text);
      return isError && isError & controllerList[0].text.isNotEmpty;
    }

    return SizedBox(
      height: safeAreaHeight * 0.8,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: loginSheetAppBar(
          context,
          "Welcome back!",
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
                        Padding(
                          padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                          child: LoginTextField(
                            icon: Icons.storefront,
                            controller: controllerList[0],
                            isError: errorMessage.value != null,
                            subText: "店舗コードを入力...",
                            onChanged: (value) {
                              errorMessage.value = null;
                            },
                            isPassword: false,
                          ),
                        ),
                        if (errorMessage.value != null) ...{
                          Padding(
                            padding:
                                EdgeInsets.only(top: safeAreaHeight * 0.005),
                            child: nText(
                              errorMessage.value!,
                              color: Colors.red,
                              fontSize: safeAreaWidth / 35,
                              bold: 400,
                            ),
                          ),
                        },
                        Padding(
                          padding: EdgeInsets.only(top: safeAreaHeight * 0.03),
                          child: LoginTextField(
                            icon: Icons.lock,
                            controller: controllerList[1],
                            isError: false,
                            subText: "パスワードを入力...",
                            onChanged: null,
                            isPassword: true,
                          ),
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
                      text: "ログイン",
                      onTap: () async {
                        primaryFocus?.unfocus();
                        if (isEmailCheck()) {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 500),
                          );

                          onTap(
                            controllerList[0].text,
                            controllerList[1].text,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        } else {
                          errorMessage.value = "メールアドレスの形式が正しくありません";
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
