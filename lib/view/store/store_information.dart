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
import 'package:lolo_app/view/initiale_page.dart';
import 'package:lolo_app/view/store/on_store_edit.dart';
import 'package:lolo_app/view_model/page_index.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/account/account_widget.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/store/store_home_widget.dart';

class StoreInformation extends HookConsumerWidget {
  const StoreInformation({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final User? user = FirebaseAuth.instance.currentUser;
    final userNotifier = ref.watch(userDataNotifierProvider);
    final userNotifierWhen = userNotifier.when(
        data: (value) {
          if (value?.storeData != null) {
            return Stack(
              children: [
                Padding(
                  padding: xPadding(context),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: safeAreaHeight * 0.16,
                          decoration: BoxDecoration(
                            color: blackColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            alignment: Alignment.bottomRight,
                            height: safeAreaHeight * 0.1,
                            width: safeAreaHeight * 0.1,
                            decoration: BoxDecoration(
                              image: value!.storeData!.logo != null
                                  ? DecorationImage(
                                      image:
                                          MemoryImage(value.storeData!.logo!),
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
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: safeAreaHeight * 0.02,
                            bottom: safeAreaHeight * 0.02,
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
                                            value.storeData!.name,
                                            value.storeData!.address,
                                            "${value.storeData!.location.latitude.toStringAsFixed(3)}°N,${value.storeData!.location.longitude.toStringAsFixed(3)}°E",
                                            value.storeData!.businessHours
                                                .replaceAll("@", " 〜 "),
                                            value.storeData!.searchWord
                                                .join(', '),
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
                        Material(
                          color: blackColor,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: () => showAlertDialog(
                              context,
                              title: "ログアウトしますか？",
                              subTitle: "ログアウトしても店舗アカウントは削除されません。",
                              buttonText: "ログアウト",
                              ontap: () async {
                                FirebaseAuth.instance.signOut();
                                final pageIndexNotifier = ref
                                    .read(pageIndexNotifierProvider.notifier);
                                await pageIndexNotifier.upData(2);
                                final notifier =
                                    ref.read(userDataNotifierProvider.notifier);
                                await notifier.addStoreData(null);
                                if (context.mounted) {
                                  bottomNavigationKey = GlobalKey();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              alignment: Alignment.center,
                              height: safeAreaHeight * 0.08,
                              child: nText(
                                "店舗アカウントログアウト",
                                color: Colors.red,
                                fontSize: safeAreaWidth / 26,
                                bold: 700,
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
                    child: bottomButton(
                        context: context,
                        text: "編集する",
                        isWhiteMainColor: true,
                        onTap: () => screenTransitionNormal(
                            context,
                            OnStoreSetting(
                              storeData: value.storeData!,
                            ))),
                  ),
                ),
              ],
            );
          } else {
            return errorWidget(context);
          }
        },
        error: (e, s) => errorWidget(context),
        loading: () => Padding(
              padding: EdgeInsets.only(bottom: safeAreaHeight * 0.1),
              child:
                  loadinPage(context: context, isLoading: true, text: "データ取得中"),
            ));

    return Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        appBar: appBar(context, "店舗基本情報", true),
        backgroundColor: Colors.black,
        body: userNotifierWhen);
  }

  Widget errorWidget(BuildContext context) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: safeAreaHeight * 0.05),
        child: nText("データ取得に失敗しました",
            color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
      ),
    );
  }
}
