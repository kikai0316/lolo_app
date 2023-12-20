import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/img.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account/on_store_setting.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/account_widget.dart';
import 'package:lolo_app/widget/app_widget.dart';

class StoreInformation extends HookConsumerWidget {
  const StoreInformation({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final User? user = FirebaseAuth.instance.currentUser;
    final notifier = ref.watch(userDataNotifierProvider);
    final storeData = notifier.when(
        data: (value) => value?.storeData != null ? value!.storeData! : null,
        error: (e, s) => null,
        loading: () => null);

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar(context, "店舗情報", true),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (storeData != null) ...{
            SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                          top: safeAreaHeight * 0.03,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: safeAreaHeight * 0.16,
                          width: safeAreaWidth * 0.9,
                          decoration: BoxDecoration(
                            color: blackColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.bottomRight,
                            height: safeAreaHeight * 0.1,
                            width: safeAreaHeight * 0.1,
                            decoration: BoxDecoration(
                              image: storeData.logo != null
                                  ? DecorationImage(
                                      image: MemoryImage(storeData.logo!),
                                      fit: BoxFit.cover)
                                  : notImg(),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1.0,
                                )
                              ],
                              shape: BoxShape.circle,
                            ),
                          ),
                        )),
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
                              for (int i = 0;
                                  i < storeSettingTitle.length;
                                  i++) ...{
                                settingWidget(
                                  isOnlyBottomRadius:
                                      i == storeSettingTitle.length - 1,
                                  isOnlyTopRadius: i == 0,
                                  isRedTitle: false,
                                  trailing: Container(
                                    height: safeAreaHeight * 0.1,
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: safeAreaWidth * 0.02),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: nText(
                                          [
                                            storeData.name,
                                            storeData.address,
                                            "${storeData.location.latitude.toStringAsFixed(3)}°N,${storeData.location.longitude.toStringAsFixed(3)}°E",
                                            storeData.businessHours
                                                .replaceAll("@", " 〜 "),
                                            storeData.searchWord.join(', '),
                                            user?.email ?? "取得エラー",
                                          ][i],
                                          color: Colors.white,
                                          fontSize: safeAreaWidth / 28,
                                          bold: 700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: null,
                                  context: context,
                                  iconText: storeSettingTitle[i],
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => showAlertDialog(
                        context,
                        title: "ログアウトしますか？",
                        subTitle: "ログアウトしても店舗アカウントは削除されません。",
                        buttonText: "ログアウト",
                        ontap: () async {
                          Navigator.pop(context);
                          FirebaseAuth.instance.signOut();
                          final notifier =
                              ref.read(userDataNotifierProvider.notifier);
                          await notifier.addStoreData(null);
                        },
                      ),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red.withOpacity(0.2);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: nText("ログアウト",
                          color: Colors.red,
                          fontSize: safeAreaWidth / 25,
                          bold: 700),
                    ),
                    bottomButton(
                      context: context,
                      text: "編集する",
                      isWhiteMainColor: true,
                      onTap: () => screenTransitionNormal(
                          context,
                          OnStoreSetting(
                            storeData: storeData,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          } else ...{
            loadinPage(context: context, isLoading: true, text: null)
          },
          Opacity(
            opacity: storeData != null ? 1 : 1,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => showAlertDialog(
                        context,
                        title: "ログアウトしますか？",
                        subTitle: "ログアウトしても店舗アカウントは削除されません。",
                        buttonText: "ログアウト",
                        ontap: () async {
                          FirebaseAuth.instance.signOut();
                          final notifier =
                              ref.read(userDataNotifierProvider.notifier);
                          await notifier.addStoreData(null);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          }
                        },
                      ),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.red.withOpacity(0.2);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: nText("ログアウト",
                          color: Colors.red,
                          fontSize: safeAreaWidth / 25,
                          bold: 700),
                    ),
                    bottomButton(
                        context: context,
                        text: "編集する",
                        isWhiteMainColor: true,
                        onTap: storeData != null
                            ? () => screenTransitionNormal(
                                context,
                                OnStoreSetting(
                                  storeData: storeData,
                                ))
                            : null),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
