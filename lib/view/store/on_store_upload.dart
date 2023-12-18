import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/img_confirmation_page.dart';
import 'package:lolo_app/view/store/on_add_event.dart';
import 'package:lolo_app/view/store/on_preview_store.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/store_upload_widget.dart';

class OnUpLoadPage extends HookConsumerWidget {
  const OnUpLoadPage({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final pageIndex = useState<int>(0);
    final postImgList =
        useState<List<StoryImgType>>([...storeData.postImgList]);
    final eventList = useState<List<StoryEventType>>([]);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: appBar(context, "投稿"),
          body: Container(
            height: safeAreaHeight * 1,
            width: safeAreaWidth * 1,
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    storeTitleWithCircleAndAddWidget(context, text: "ストーリー",
                        onAdd: () async {
                      isLoading.value = true;
                      await getMobileImage(onSuccess: (value) {
                        screenTransitionToTop(
                            context,
                            ImgConfirmation(
                              img: value,
                              onTap: (value) {
                                if (context.mounted) {
                                  final dateNow = DateTime.now();
                                  postImgList.value = [
                                    ...postImgList.value,
                                    StoryImgType(img: value, date: dateNow)
                                  ];
                                }
                              },
                            ));
                      }, onError: () {
                        errorSnackbar(context, message: "画像の取得に失敗しました");
                      });
                      isLoading.value = false;
                    }),
                  ],
                ),
                if (postImgList.value.isEmpty) ...{
                  Align(
                    child: notData(context, Icons.photo_camera, "投稿がありません"),
                  )
                } else ...{
                  Container(
                    alignment: Alignment.centerLeft,
                    height: safeAreaHeight / 2.5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int i = 0;
                              i < postImgList.value.length;
                              i++) ...{
                            Padding(
                              key: ValueKey(i),
                              padding: EdgeInsets.all(safeAreaWidth * 0.02),
                              child: postImgWidget(context,
                                  img: postImgList.value[i].img, onDelete: () {
                                postImgList.value.removeAt(i);
                                postImgList.value = [...postImgList.value];
                              }),
                            )
                          }
                        ],
                      ),
                    ),
                  )
                },
                storeTitleWithCircleAndAddWidget(context, text: "イベント",
                    onAdd: () async {
                  screenTransitionToTop(context, OnAddEventPage(
                    onAdd: (value) {
                      eventList.value = [...eventList.value, value];
                    },
                  ));
                }),
                if (eventList.value.isEmpty) ...{
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: safeAreaHeight * 0.05),
                      child: nText("イベントがありません",
                          color: Colors.white.withOpacity(0.5),
                          fontSize: safeAreaWidth / 20,
                          bold: 700),
                    ),
                  )
                },
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < eventList.value.length; i++) ...{
                        Padding(
                          key: ValueKey(i),
                          padding: EdgeInsets.all(safeAreaWidth * 0.02),
                          child: eventImgWidget(context,
                              data: eventList.value[i], onDelete: () {
                            eventList.value.removeAt(i);
                            eventList.value = [...eventList.value];
                          }),
                        )
                      }
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        if (!listEquals(postImgList.value, storeData.postImgList)) ...{
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: safeAreaHeight * 0.015),
                    child: GestureDetector(
                      onTap: () {
                        screenTransitionHero(
                          context,
                          OnStorePreviewPage(
                            storeData: StoreData(
                                postImgList: postImgList.value,
                                logo: storeData.logo,
                                id: storeData.id,
                                name: storeData.name,
                                address: storeData.address,
                                businessHours: storeData.businessHours,
                                searchWord: storeData.searchWord,
                                location: storeData.location),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            color: blueColor,
                            size: safeAreaWidth / 20,
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: safeAreaWidth * 0.02),
                            child: nText("プレビュー",
                                color: blueColor,
                                fontSize: safeAreaWidth / 25,
                                bold: 500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottomButton(
                      context: context,
                      isWhiteMainColor: true,
                      text: "公開する",
                      onTap: pageIndex.value == 0 ? () {} : null),
                ],
              ),
            ),
          ),
        },
        loadinPage(context: context, isLoading: isLoading.value, text: null)
      ],
    );
  }

  Widget notData(BuildContext context, IconData icon, String message) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: 0.5,
      child: SizedBox(
        height: safeAreaHeight * 0.27,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  // top: safeAreaHeight * 0.07,
                  bottom: safeAreaHeight * 0.02),
              child: Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.08,
                width: safeAreaHeight * 0.08,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: safeAreaWidth / 13,
                ),
              ),
            ),
            nText(message,
                color: Colors.white, fontSize: safeAreaWidth / 20, bold: 700),
          ],
        ),
      ),
    );
  }
}
