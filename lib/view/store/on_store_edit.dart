import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/crop_img_utility.dart';
import 'package:lolo_app/utility/firebase_firestore_utility.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/account/on_edit_business_hour.dart';
import 'package:lolo_app/view/account/on_edit_text_sheet.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/account/account_widget.dart';
import 'package:lolo_app/widget/store/store_home_widget.dart';

TextEditingController? textController;

class OnStoreSetting extends HookConsumerWidget {
  const OnStoreSetting({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final editName = useState<String>(storeData.name);
    final editAddress = useState<String>(storeData.address);
    final editBusinessHour = useState<String>(storeData.businessHours);
    final editLocation = useState<LatLng>(storeData.location);
    final editLogo = useState<Uint8List?>(storeData.logo);
    final editSearchWord = useState<List<String>>(storeData.searchWord);
    final User? user = FirebaseAuth.instance.currentUser;
    final dataList = [
      editName.value,
      editAddress.value,
      "${editLocation.value.latitude.toStringAsFixed(3)}°N,${editLocation.value.longitude.toStringAsFixed(3)}°E",
      editBusinessHour.value.replaceAll("@", " 〜 "),
      editSearchWord.value.join(', '),
      user?.email ?? "取得エラー",
    ];

    bool isDataCheck() {
      if (storeData.logo == editLogo.value &&
          storeData.businessHours == editBusinessHour.value &&
          storeData.searchWord == editSearchWord.value) {
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

    Future<void> dbUpdata() async {
      Map<String, dynamic> setData = {};
      if (storeData.businessHours != editBusinessHour.value) {
        setData["business_hours"] = editBusinessHour.value;
      }
      if (storeData.searchWord != editSearchWord.value) {
        setData["search_word"] = editSearchWord.value;
      }

      final isUpLoadMain = storeData.logo != editLogo.value
          ? await upLoadMain(editLogo.value!, storeData.id)
          : true;
      final isDBUpData =
          setData.isNotEmpty ? await upDataStore(setData, storeData.id) : true;
      if (isDBUpData && isUpLoadMain) {
        final setStoreData = StoreData(
            storyList: storeData.storyList,
            logo: editLogo.value,
            id: storeData.id,
            name: editName.value,
            address: editAddress.value,
            businessHours: editBusinessHour.value,
            searchWord: editSearchWord.value,
            location: editLocation.value,
            eventList: storeData.eventList);
        final notifier = ref.read(userDataNotifierProvider.notifier);
        await notifier.addStoreData(setStoreData);
        if (context.mounted) {
          isLoading.value = false;
          Navigator.pop(context);
          successSnackbar(
            context,
            "データ更新が正常に完了しました",
          );
        }
      } else {
        if (context.mounted) {
          isLoading.value = false;
          errorSnackbar(
            context,
            message: "システムエラーが発生しました。\n少し時間を置いてからもう一度お試しください。",
          );
        }
      }
    }

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: storeEditAppBar(context, isDataCheck()),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      imgSetteingWidget(context, editLogo.value, getImg),
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
                                    opacity: i == 4 || i == 3 ? 1 : 0.3,
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
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: safeAreaHeight * 0.1,
                                                alignment:
                                                    Alignment.centerRight,
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
                                            if (i != dataList.length - 1)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: safeAreaWidth * 0.02,
                                                ),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  size: safeAreaWidth / 21,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      onTap: i == 4 || i == 3
                                          ? () {
                                              if (i == 3) {
                                                bottomSheet(context,
                                                    page: BusinessHourEditSheet(
                                                        initData:
                                                            editBusinessHour
                                                                .value,
                                                        onTap: (value) {
                                                          Navigator.pop(
                                                              context);
                                                          editBusinessHour
                                                              .value = value;
                                                        }),
                                                    isBackgroundColor: true);
                                              }
                                              if (i == 4) {
                                                textController =
                                                    TextEditingController(
                                                  text: editSearchWord.value
                                                      .join(","),
                                                );
                                                bottomSheet(context,
                                                    page: StringEditSheet(
                                                      title: "検索キーワード",
                                                      initData: editSearchWord
                                                          .value
                                                          .join(","),
                                                      controller:
                                                          textController!,
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        editSearchWord.value =
                                                            textController!.text
                                                                .split(RegExp(
                                                                    ',|、'));
                                                      },
                                                    ),
                                                    isBackgroundColor: true);
                                              }
                                            }
                                          : null,
                                      context: context,
                                      iconText: storeSettingTitle[i],
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
                          dbUpdata();
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

  PreferredSizeWidget storeEditAppBar(BuildContext context, bool isDataCheck) {
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: nText(
        "編集",
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
          if (isDataCheck) {
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
    );
  }
}
