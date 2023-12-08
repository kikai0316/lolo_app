import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';

class NotNamePage extends HookConsumerWidget {
  const NotNamePage({
    super.key,
    required this.userData,
  });
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final text = useState<String>("");
    final errorText = useState<String?>(null);
    final isLoading = useState<bool>(false);
    Future<void> dataUpLoad() async {
      isLoading.value = true;
      final setData = UserData(
        img: userData.img,
        id: userData.id,
        name: text.value,
        birthday: userData.birthday,
      );
      final isWite = await writeUserData(setData);
      if (isWite) {
        final nextScreenWhisUserData = nextScreenWhisUserDataCheck(setData);
        if (nextScreenWhisUserData != null) {
          // ignore: use_build_context_synchronously
          screenTransitionNormal(context, nextScreenWhisUserData);
        } else {
          final nextScreenWithLocation =
              await nextScreenWithLocationCheck(setData);
          if (context.mounted) {
            screenTransitionNormal(context, nextScreenWithLocation);
          }
        }
      } else {
        isLoading.value = false;
        // ignore: use_build_context_synchronously
        errorSnackbar(
          context,
          message: "何らかの問題が発生しました。再試行してください。",
        );
      }
    }

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
                      bottom: safeAreaHeight * 0.06,
                    ),
                    child: nText(
                      "ユーザー名を入力していください",
                      color: Colors.white,
                      fontSize: safeAreaWidth / 18,
                      bold: 700,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: safeAreaWidth * 0.08,
                      left: safeAreaWidth * 0.08,
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        errorText.value = null;
                        text.value = value;
                      },
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Normal",
                        fontVariations: const [FontVariation("wght", 700)],
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: safeAreaWidth / 20,
                      ),
                      decoration: InputDecoration(
                        errorText: errorText.value,
                        errorStyle: TextStyle(
                          fontFamily: "Normal",
                          fontVariations: const [FontVariation("wght", 400)],
                          color: Colors.red,
                          fontSize: safeAreaWidth / 30,
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: "ユーザー名を入力...",
                        hintStyle: TextStyle(
                          fontFamily: "Normal",
                          fontVariations: const [FontVariation("wght", 700)],
                          color: Colors.grey.withOpacity(0.5),
                          fontSize: safeAreaWidth / 25,
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
              child: Opacity(
                opacity: text.value.isEmpty ? 0.3 : 1,
                child: Padding(
                  padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
                  child: bottomButton(
                    context: context,
                    isWhiteMainColor: true,
                    text: "完了",
                    onTap: () async {
                      if (text.value.isNotEmpty) {
                        primaryFocus?.unfocus();
                        dataUpLoad();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          loadinPage(
            context: context,
            isLoading: isLoading.value,
            text: null,
          ),
        ],
      ),
    );
  }
}
