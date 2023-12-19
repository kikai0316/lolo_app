import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/component/loading.dart';
import 'package:lolo_app/constant/color.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';
import 'package:lolo_app/view/img_page/img_confirmation_page.dart';
import 'package:lolo_app/view/store/on_add_event.dart';
import 'package:lolo_app/view/store/on_preview_store.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/store_post_widget.dart';

class StorePostPage extends HookConsumerWidget {
  const StorePostPage({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final isLoading = useState<bool>(false);
    final initStoryImgList =
        useState<List<StoryImgType>>([...storeData.postImgList]);
    final initEventList = useState<List<EventType>>([...storeData.eventList]);
    final pageIndex = useState<int>(0);
    final storyImgList =
        useState<List<StoryImgType>>([...storeData.postImgList]);
    final eventList = useState<List<EventType>>([...storeData.eventList]);

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: appBar(context, "投稿", false),
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
                    Row(
                      children: [
                        storeTitleWithCircleAndAddWidget(context,
                            text: "ストーリー",
                            count: storyImgList.value.length,
                            onAdd: storyImgList.value.length < 5
                                ? () async {
                                    isLoading.value = true;
                                    await getMobileImage(onSuccess: (value) {
                                      screenTransitionToTop(
                                          context,
                                          ImgConfirmation(
                                            img: value,
                                            onTap: (value) {
                                              if (context.mounted) {
                                                final dateNow = DateTime.now();
                                                storyImgList.value = [
                                                  ...storyImgList.value,
                                                  StoryImgType(
                                                    img: value,
                                                    date: dateNow,
                                                    id: generateRandomString(),
                                                  )
                                                ];
                                              }
                                            },
                                          ));
                                    }, onError: () {
                                      errorSnackbar(context,
                                          message: "画像の取得に失敗しました");
                                    });
                                    isLoading.value = false;
                                  }
                                : null),
                      ],
                    ),
                  ],
                ),
                if (storyImgList.value.isEmpty) ...{
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
                              i < storyImgList.value.length;
                              i++) ...{
                            Padding(
                              key: ValueKey(i),
                              padding: EdgeInsets.all(safeAreaWidth * 0.02),
                              child: storyWidget(context,
                                  data: storyImgList.value[i], onDelete: () {
                                storyImgList.value.removeAt(i);
                                storyImgList.value = [...storyImgList.value];
                              }),
                            )
                          }
                        ],
                      ),
                    ),
                  )
                },
                storeTitleWithCircleAndAddWidget(context,
                    text: "イベント", count: null, onAdd: () async {
                  screenTransitionToTop(context, OnAddEventPage(
                    onAdd: (value) {
                      final filtere =
                          filteredAndSortedEvents([...eventList.value, value]);
                      eventList.value = [...filtere];
                    },
                  ));
                }),
                if (eventList.value.isEmpty) ...{
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: safeAreaHeight * 0.05,
                      ),
                      child: nText("イベントがありません",
                          color: Colors.white.withOpacity(0.5),
                          fontSize: safeAreaWidth / 20,
                          bold: 700),
                    ),
                  )
                },
                Padding(
                  padding: EdgeInsets.only(
                    top: safeAreaHeight * 0.02,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < eventList.value.length; i++) ...{
                          Padding(
                            key: ValueKey(i),
                            padding: EdgeInsets.all(safeAreaWidth * 0.02),
                            child: eventWidget(context,
                                data: eventList.value[i], onDelete: () {
                              eventList.value.removeAt(i);
                              eventList.value = [...eventList.value];
                            }),
                          )
                        }
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (!listEquals(storyImgList.value, initStoryImgList.value) ||
            !listEquals(eventList.value, initEventList.value)) ...{
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
                                postImgList: storyImgList.value,
                                logo: storeData.logo,
                                id: storeData.id,
                                name: storeData.name,
                                address: storeData.address,
                                businessHours: storeData.businessHours,
                                searchWord: storeData.searchWord,
                                location: storeData.location,
                                eventList: eventList.value),
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
                      onTap: pageIndex.value == 0
                          ? () async {
                              isLoading.value = true;
                              var resultStoryImgType = compareStoryImgTypeLists(
                                  initStoryImgList.value, storyImgList.value);
                              var resultEventType = compareEventTypeLists(
                                  initEventList.value, eventList.value);
                              final ss = await upLoadStory(
                                  addDataList: resultStoryImgType["add"]
                                      as List<StoryImgType>,
                                  deleteDataList: resultStoryImgType["delete"]
                                      as List<String>,
                                  id: storeData.id);
                              final sss = await upLoadEvent(
                                  addDataList:
                                      resultEventType["add"] as List<EventType>,
                                  deleteDataList:
                                      resultEventType["delete"] as List<String>,
                                  id: storeData.id);
                              if (ss && sss) {
                                final notifire =
                                    ref.read(userDataNotifierProvider.notifier);
                                await notifire.reFetchStore();
                                if (context.mounted) {
                                  initStoryImgList.value = [
                                    ...storyImgList.value
                                  ];
                                  initEventList.value = [...eventList.value];
                                  successSnackbar(context, "投稿が正常にアップロードされました");
                                }
                              } else {
                                if (context.mounted) {
                                  errorSnackbar(context,
                                      message: "投稿のアップロードに失敗しました。再試行してください。");
                                }
                              }
                              if (context.mounted) {
                                isLoading.value = false;
                              }
                            }
                          : null),
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

Map<String, dynamic> compareStoryImgTypeLists(
    List<StoryImgType> original, List<StoryImgType> edited) {
  List<StoryImgType> added =
      edited.where((item) => !original.contains(item)).toList();
  List<String> removedIds = original
      .where((item) => !edited.contains(item))
      .map((item) => item.id)
      .toList();

  return {'add': added, 'delete': removedIds};
}

Map<String, dynamic> compareEventTypeLists(
    List<EventType> original, List<EventType> edited) {
  List<EventType> added =
      edited.where((item) => !original.contains(item)).toList();
  List<String> removedIds = original
      .where((item) => !edited.contains(item))
      .map((item) => item.id)
      .toList();

  return {'add': added, 'delete': removedIds};
}
