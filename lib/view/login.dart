import 'package:flutter/services.dart';
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
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view_model/user_data.dart';
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

    // Future<void> nextPage() async {
    // final isPermission = await checkNotificationPermissionStatus();
    // isLoading.value = false;
    // if (isSuccess) {
    //   final nextScreenWhisUserData = nextScreenWhisUserDataCheck(userData);
    //   if (nextScreenWhisUserData != null) {
    //     // ignore: use_build_context_synchronously
    //     screenTransitionNormal(context, nextScreenWhisUserData);
    //   } else {
    //     //後
    //     // final nextScreenWithLocation =
    //     //     await nextScreenWithLocationCheck(userData, ref);
    //     // if (context.mounted) {
    //     //   screenTransitionNormal(context, nextScreenWithLocation);
    //     // }
    //   }
    // } else {
    //   showSnackbar(2);
    // }
    // }
    // Future<void> logIn(String email, String password) async {
    //   try {
    //     isLoading.value = true;
    //     await FirebaseAuth.instance
    //         .signInWithEmailAndPassword(email: email, password: password);
    //     await Future<void>.delayed(const Duration(milliseconds: 3));
    //     final User? user = FirebaseAuth.instance.currentUser;
    //     if (user == null || !context.mounted) {
    //       showSnackbar(2);
    //       return;
    //     }
    //     final getDB = await dbGetDataToAccountData(user.uid);
    //     if (getDB == null || !context.mounted) {
    //       showSnackbar(2);
    //       return;
    //     }
    //     final notifier = ref.read(userDataNotifierProvider.notifier);
    //     final isSuccess = await notifier.upData(getDB);
    //     if (!isSuccess || !context.mounted) {
    //       showSnackbar(2);
    //       return;
    //     }
    //     final isWriteAccountData = await writeSecureStorage(
    //       userType: "store",
    //       email: email,
    //       password: password,
    //     );
    //     if (!isWriteAccountData) {
    //       showSnackbar(2);
    //       return;
    //     }
    //     final nextScreen = await nextScreenWithLocationCheck(getDB, ref);
    //     // ignore: use_build_context_synchronously
    //     screenTransition(context, nextScreen);
    //   } catch (e) {
    //     showSnackbar(1);
    //   } finally {
    //     isLoading.value = false;
    //   }
    // }

    // Future<void> singInUp(
    //   String email,
    //   String password,
    //   String name,
    // ) async {
    //   final FirebaseAuth auth = FirebaseAuth.instance;
    //   try {
    //     isLoading.value = true;
    //     await auth.createUserWithEmailAndPassword(
    //       email: email,
    //       password: password,
    //     );
    //     final User? user = auth.currentUser;
    //     final writeAccountData = await writeSecureStorage(
    //       userType: "store",
    //       email: email,
    //       password: password,
    //     );
    //     if (user != null && writeAccountData) {

    //       final dataSet = UserData(
    //         img: null,
    //         id: user.uid,
    //         name: name,
    //         birthday: "",
    //       );

    //       nextPage(
    //           // dataSet
    //           );
    //     } else {
    //       isLoading.value = false;
    //       showSnackbar(2);
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     isLoading.value = false;
    //     if (e.code == 'email-already-in-use') {
    //       showSnackbar(0);
    //     } else {
    //       showSnackbar(2);
    //     }
    //   }
    // }

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
      final notifier = ref.read(userDataNotifierProvider.notifier);
      final isSuccess = await notifier.upData(setData);
      if (isSuccess) {
        // ignore: use_build_context_synchronously
        loginSuccessSnackbar(context);
        return;
      } else {
        showSnackbar(2);
        return;
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
                  // if (isLoginSwitch.value) ...{
                  //   bottomButton(
                  //     context: context,
                  //     isWhiteMainColor: true,
                  //     text: "ログイン",
                  //     onTap: () => bottomSheet(context,
                  //         page: LoginSheetWidget(
                  //           onTap: (email, password) => logIn(email, password),
                  //         ),
                  //         isBackgroundColor: true),
                  //   ),
                  //   Padding(
                  //     padding: EdgeInsets.only(
                  //       top: safeAreaHeight * 0.01,
                  //     ),
                  //     child: loginLine(
                  //       context,
                  //     ),
                  //   ),
                  //   borderButton(
                  //     context: context,
                  //     text: "新規登録",
                  //     onTap: () => bottomSheet(context,
                  //         page: SingInSheetWidget(
                  //           onTap: (email, password, name) =>
                  //               singInUp(email, password, name),
                  //         ),
                  //         isBackgroundColor: true),
                  //   ),
                  // } else ...{
                  //   lineLoginButton(context: context, onTap: () => LineLogin()),
                  // },
                  lineLoginButton(context: context, onTap: () => lineLogin()),
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
        loadinPage(context: context, isLoading: isLoading.value, text: null),
      ],
    );
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
