import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/constant/url.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/login.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/account_widget.dart';
import 'package:lolo_app/widget/app_widget.dart';

class AccountPage extends HookConsumerWidget {
  const AccountPage({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final notifierUserData = ref.watch(userDataNotifierProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context, "アカウント設定"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
                child: profileWidget(
                  context,
                  data: notifierUserData,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: safeAreaWidth * 0.1,
                    top: safeAreaHeight * 0.02,
                    bottom: safeAreaHeight * 0.01,
                  ),
                  child: nText(
                    "設定・その他",
                    color: Colors.white,
                    bold: 700,
                    fontSize: safeAreaWidth / 25,
                  ),
                ),
              ),
              Container(
                width: safeAreaWidth * 0.9,
                decoration: BoxDecoration(
                  color: blackColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < settingTitle.length; i++) ...{
                      settingWidget(
                        onTap: () {
                          if (i == 0) {
                            showAlertDialog(
                              context,
                              title: "バージョン",
                              subTitle: "12311",
                              buttonText: null,
                              ontap: null,
                            );
                          }
                          if (i == 1) {
                            openURL(url: termsURL, onError: null);
                          }
                          if (i == 2) {
                            openURL(url: privacyURL, onError: null);
                          }
                          if (i == 3) {
                            screenTransitionToTop(
                                context, const StartPage(isGeneral: false));
                          }
                          if (i == 4) {
                            showAlertDialog(
                              context,
                              title: "アカウント削除",
                              subTitle: "アカウントを削除すると、すべてのデータが失われます。本当に削除しますか？",
                              buttonText: "削除する",
                              ontap: () async {
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                        context: context,
                        isRedTitle: i == settingTitle.length - 1,
                        iconText: settingTitle[i],
                        isOnlyTopRadius: i == 0,
                        isOnlyBottomRadius: i == settingTitle.length - 1,
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.8),
                          size: safeAreaWidth / 21,
                        ),
                      ),
                    },
                  ],
                ),
              ),
              SizedBox(
                height: safeAreaHeight * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
