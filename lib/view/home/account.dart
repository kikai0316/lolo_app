import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/constant/url.dart';
import 'package:lolo_app/model/user_data.dart';
import 'package:lolo_app/utility/path_provider_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account/profile_setting.dart';
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
    final userData = useState<UserData?>(null);
    final isDataGet = useState<bool>(false);
    useEffect(() {
      Future(() async {
        final UserData? getData = await readUserData();
        if (context.mounted) {
          userData.value = getData;
          isDataGet.value = true;
        }
      });
      return null;
    }, []);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context, "アカウント設定"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: safeAreaHeight * 0.02),
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  width: safeAreaWidth * 0.9,
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      safeAreaHeight * 0.02,
                    ),
                    child: isDataGet.value
                        ? Column(
                            children: [
                              if (userData.value != null) ...{
                                Container(
                                    height: safeAreaWidth * 0.2,
                                    width: safeAreaWidth * 0.2,
                                    decoration: BoxDecoration(
                                      image: userData.value!.img != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                  userData.value!.img!),
                                              fit: BoxFit.cover)
                                          : notImg(),
                                      shape: BoxShape.circle,
                                    )),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: safeAreaHeight * 0.01,
                                    bottom: safeAreaHeight * 0.015,
                                  ),
                                  child: nText(
                                    userData.value!.name,
                                    color: Colors.white,
                                    fontSize: safeAreaWidth / 20,
                                    bold: 700,
                                  ),
                                ),
                                miniButton(
                                  context: context,
                                  text: "プロフィールを編集",
                                  onTap: () => screenTransitionNormal(
                                    context,
                                    ProfileSetting(
                                      userData: userData.value!,
                                      onSave: (value) {
                                        userData.value = value;
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              } else ...{
                                Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: safeAreaWidth / 10,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: safeAreaHeight * 0.01),
                                  child: nText("プロフィールの取得に失敗しました。",
                                      color: Colors.white,
                                      fontSize: safeAreaWidth / 25,
                                      bold: 500),
                                )
                              }
                            ],
                          )
                        : CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: safeAreaHeight * 0.018,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: safeAreaHeight * 0.04,
                  bottom: safeAreaHeight * 0.01,
                ),
                child: accountMainWidget(context, isEncounter: false, data: 0),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: safeAreaWidth * 0.1,
                    top: safeAreaHeight * 0.02,
                    bottom: safeAreaHeight * 0.01,
                  ),
                  child: Text(
                    "設定・その他",
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: safeAreaWidth / 25,
                    ),
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
                    for (int i = 0; i < 4; i++) ...{
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
                        isRedTitle: i == 3,
                        iconText: settingTitle[i],
                        isOnlyTopRadius: i == 0,
                        isOnlyBottomRadius: i == 3,
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
