import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/widget/account_widget.dart';

TextEditingController? textController;

class ProfileSetting extends HookConsumerWidget {
  const ProfileSetting(
      {super.key, required this.userData, required this.onSave});
  final UserData userData;
  final void Function(UserData) onSave;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final editName = useState<String>(userData.name);
    final editBirthday = useState<String>(userData.birthday);
    final User? user = FirebaseAuth.instance.currentUser;
    final dataList = [
      editName.value,
      formatDateString(
        editBirthday.value,
      ),
      user?.email ?? "取得エラー",
    ];
    DateTime parseDate(String input) {
      final year = int.parse(input.substring(0, 4));
      final month = int.parse(input.substring(4, 6));
      final day = int.parse(input.substring(6, 8));
      return DateTime(year, month, day);
    }

    bool isDataCheck() {
      if (userData.name == editName.value &&
          userData.birthday == editBirthday.value) {
        return true;
      } else {
        return false;
      }
    }

    void showSnackbar() {
      errorSnackbar(
        context,
        message: "サーバーへの接続に問題が発生しました。しばらく時間を置いてから、再度お試しください。",
      );
    }

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: nText(
              "プロフィール編集",
              color: Colors.white,
              fontSize: safeAreaWidth / 20,
              bold: 700,
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: safeAreaWidth / 15,
              ),
              onPressed: () {
                if (isDataCheck()) {
                  Navigator.of(context).pop();
                } else {
                  showAlertDialog(
                    context,
                    title: "変更内容が保存されていません",
                    subTitle: "このページを離れると、入力した内容は失われます。本当に離れますか？",
                    buttonText: "OK",
                    ontap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  );
                }
              },
            ),
          ),
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
                        child: Container(
                          width: safeAreaWidth * 0.9,
                          decoration: BoxDecoration(
                            color: blackColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: safeAreaHeight * 0.001,
                              bottom: safeAreaHeight * 0.001,
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < dataList.length; i++) ...{
                                  Opacity(
                                    opacity: i != 2 ? 1 : 0.3,
                                    child: settingWidget(
                                      isOnlyBottomRadius:
                                          i == dataList.length - 1,
                                      isOnlyTopRadius: i == 0,
                                      isRedTitle: false,
                                      trailing: Container(
                                        alignment: Alignment.center,
                                        height: safeAreaHeight * 0.1,
                                        width: safeAreaWidth * 0.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                right: safeAreaWidth * 0.02,
                                              ),
                                              child: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                width: safeAreaWidth * 0.4,
                                                child: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: nText(
                                                    dataList[i],
                                                    color: Colors.white,
                                                    fontSize:
                                                        safeAreaWidth / 28,
                                                    bold: 700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (i != 2)
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                size: safeAreaWidth / 21,
                                              ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (i == 0) {
                                          textController =
                                              TextEditingController(
                                                  text: editName.value);
                                          bottomSheet(context,
                                              page: UserEditSheet(
                                                isUserName: i == 0,
                                                initData: editName.value,
                                                controller: textController!,
                                                onTap: () async {
                                                  if (i == 0) {
                                                    Navigator.pop(context);
                                                    editName.value =
                                                        textController!.text;
                                                  }
                                                },
                                              ),
                                              isBackgroundColor: true);
                                        }
                                        if (i == 1) {
                                          primaryFocus?.unfocus();
                                          DatePicker.showDatePicker(
                                            context,
                                            minTime: DateTime(1950),
                                            maxTime: DateTime(2022, 8, 17),
                                            currentTime: parseDate(
                                              editBirthday.value,
                                            ),
                                            locale: LocaleType.jp,
                                            onConfirm: (date) {
                                              editBirthday.value =
                                                  '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
                                            },
                                          );
                                        }
                                      },
                                      context: context,
                                      iconText: profileSettingTitle[i],
                                    ),
                                  ),
                                },
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Opacity(
                    opacity: isDataCheck() ? 0.3 : 1,
                    child: bottomButton(
                      context: context,
                      text: "保存",
                      isWhiteMainColor: true,
                      onTap: () async {
                        if (!isDataCheck()) {
                          isLoading.value = true;
                          primaryFocus?.unfocus();
                          final setData = UserData(
                            img: userData.img,
                            id: userData.id,
                            name: editName.value,
                            birthday: editBirthday.value,
                          );
                          final bool localWrite = await writeUserData(setData);
                          if (localWrite) {
                            onSave(setData);
                            isLoading.value = false;
                          } else {
                            isLoading.value = false;
                            showSnackbar();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loadinPage(context: context, isLoading: isLoading.value, text: null),
      ],
    );
  }

  String formatDateString(String dateString) {
    if (dateString.length != 8) {
      return 'error';
    }
    String year = dateString.substring(0, 4);
    String month = dateString.substring(4, 6);
    String day = dateString.substring(6, 8);
    return '$year / $month / $day';
  }
}

final profileSettingTitle = [
  "ユーザー名",
  "生年月日",
  "メールアドレス",
];
