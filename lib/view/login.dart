import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/constant/url.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/secure_storage_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/login/login_sheet.dart';
import 'package:lolo_app/view/login/singin_sheet.dart';
import 'package:lolo_app/widget/login_widget.dart';

class StartPage extends HookConsumerWidget {
  const StartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final errorMessage = [
      "指定されたメールアドレスはすでに使用されています。",
      "アカウントが見つかりませんでした。\nメールアドレスとパスワードを確認して、もう一度お試しください。",
      "システムエラーが発生しました。\n少し時間を置いてからもう一度お試しください。"
    ];
    void showSnackbar(int index) {
      isLoading.value = false;
      errorSnackbar(context, message: errorMessage[index]);
    }

    Future<void> nextPage(UserData userData) async {
      final isSuccess = await writeUserData(userData);
      // final isPermission = await checkNotificationPermissionStatus();
      isLoading.value = false;
      if (isSuccess) {
        final nextScreenWhisUserData = nextScreenWhisUserDataCheck(userData);
        if (nextScreenWhisUserData != null) {
          // ignore: use_build_context_synchronously
          screenTransitionNormal(context, nextScreenWhisUserData);
        } else {
          final nextScreenWithLocation =
              await nextScreenWithLocationCheck(userData, ref);
          if (context.mounted) {
            screenTransitionNormal(context, nextScreenWithLocation);
          }
        }
      } else {
        showSnackbar(2);
      }
    }

    Future<void> logIn(String email, String password) async {
      try {
        isLoading.value = true;
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await Future<void>.delayed(const Duration(milliseconds: 3));
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final writeAccountData = await writeSecureStorage(
            email: email,
            password: password,
          );
          if (writeAccountData) {
            nextPage(UserData(img: null, id: user.uid, name: "", birthday: ""));
          } else {
            showSnackbar(2);
          }
        } else {
          showSnackbar(2);
        }
      } catch (e) {
        showSnackbar(1);
      }
    }

    Future<void> singInUp(
      String email,
      String password,
      String name,
    ) async {
      final FirebaseAuth auth = FirebaseAuth.instance;
      try {
        isLoading.value = true;
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final User? user = auth.currentUser;
        final writeAccountData = await writeSecureStorage(
          email: email,
          password: password,
        );
        if (user != null && writeAccountData) {
          final dataSet = UserData(
            img: null,
            id: user.uid,
            name: name,
            birthday: "",
          );
          nextPage(dataSet);
        } else {
          isLoading.value = false;
          showSnackbar(2);
        }
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'email-already-in-use') {
          showSnackbar(0);
        } else {
          showSnackbar(2);
        }
      }
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: blackColor,
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
                  bottomButton(
                    context: context,
                    isWhiteMainColor: true,
                    text: "ログイン",
                    onTap: () => bottomSheet(context,
                        page: LoginSheetWidget(
                          onTap: (email, password) => logIn(email, password),
                        ),
                        isBackgroundColor: true),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.01,
                    ),
                    child: loginLine(
                      context,
                    ),
                  ),
                  borderButton(
                    context: context,
                    text: "新規登録",
                    onTap: () => bottomSheet(context,
                        page: SingInSheetWidget(
                          onTap: (email, password, name) =>
                              singInUp(email, password, name),
                        ),
                        isBackgroundColor: true),
                  ),
                  SizedBox(
                    height: safeAreaHeight * 0.02,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: safeAreaHeight * 0.05,
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
        loadinPage(context: context, isLoading: isLoading.value, text: null),
      ],
    );
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
