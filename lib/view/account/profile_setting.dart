import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/crop_img_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account/on_edit_text_sheet.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/account_widget.dart';

TextEditingController? textController;

class ProfileSetting extends HookConsumerWidget {
  const ProfileSetting({
    super.key,
    required this.userData,
  });
  final UserData userData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final editName = useState<String>(userData.name);
    final editLogo = useState<Uint8List?>(userData.img);
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
          userData.birthday == editBirthday.value &&
          editLogo.value == userData.img) {
        return true;
      } else {
        return false;
      }
    }

    Future<void> getImg() async {
      isLoading.value = true;
      await getMobileImage(onSuccess: (value) async {
        final cropLogo = await cropLogoImg(value);
        if (context.mounted && cropLogo != null) {
          editLogo.value = cropLogo;
        }
      }, onError: () {
        errorSnackbar(
          context,
          message: "画像の取得に失敗しました。",
        );
      });
      isLoading.value = false;
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
                        padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.03,
                        ),
                        child:
                            imgSetteingWidget(context, editLogo.value, getImg),
                      ),
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
                                              page: StringEditSheet(
                                                title: "ユーザー名を入力",
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
                              img: editLogo.value,
                              id: userData.id,
                              name: editName.value,
                              birthday: editBirthday.value,
                              storeData: userData.storeData);
                          final notifier =
                              ref.read(userDataNotifierProvider.notifier);
                          final isUpData = await notifier.upData(setData);
                          if (context.mounted) {
                            isLoading.value = false;
                            if (isUpData) {
                              Navigator.pop(context);
                              successSnackbar(
                                context,
                                "データ更新が正常に完了しました",
                              );
                            } else {
                              errorSnackbar(
                                context,
                                message:
                                    "システムエラーが発生しました。\n少し時間を置いてからもう一度お試しください。",
                              );
                            }
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
