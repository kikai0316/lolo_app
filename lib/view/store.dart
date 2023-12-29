import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lolo_app/component/button.dart';
import 'package:lolo_app/constant/text.dart';
import 'package:lolo_app/model/store_data.dart';
import 'package:lolo_app/utility/firebase_realtime_utility.dart';
import 'package:lolo_app/utility/firebase_storage_utility.dart';
import 'package:lolo_app/utility/screen_transition_utility.dart';
import 'package:lolo_app/utility/snack_bar_utility.dart';
import 'package:lolo_app/utility/utility.dart';

import 'package:lolo_app/view/store/story_confirmation_page.dart';
import 'package:lolo_app/view/store/add_event_page.dart';
import 'package:lolo_app/view_model/loading.dart';
import 'package:lolo_app/view_model/user_data.dart';
import 'package:lolo_app/widget/app_widget.dart';
import 'package:lolo_app/widget/store/store_home_widget.dart';

StreamSubscription<DatabaseEvent>? congestionListen;

class StorePage extends HookConsumerWidget {
  const StorePage({
    super.key,
    required this.storeData,
  });
  final StoreData storeData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeAreaHeight = safeHeight(context);
    final safeAreaWidth = MediaQuery.of(context).size.width;
    final crowdingSelectNumber = useState<int?>(null);
    useEffect(() {
      // ignore: deprecated_member_use
      final databaseReference = FirebaseDatabase(
        databaseURL:
            "https://lolo-app-club-default-rtdb.asia-southeast1.firebasedatabase.app/",
      ).ref("store");
      congestionListen =
          databaseReference.child(storeData.id).onValue.listen((event) async {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value! as Map<dynamic, dynamic>;
          crowdingSelectNumber.value = data["index"];
        }
      });
      return () {
        congestionListen?.cancel();
      };
    }, []);
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: storeAppBar(context, storeData, crowdingSelectNumber.value),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: xPadding(context),
              child: SizedBox(
                height: safeAreaHeight * 0.1,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: safeAreaWidth * 0.1),
                      child: titleWithCircle(context, "混雑状況"),
                    ),
                    crowdingWidget(context, onTap: (value) async {
                      final loadingNotifier =
                          ref.read(loadingNotifierProvider.notifier);
                      loadingNotifier.upData(true);

                      final isDBUpLoad =
                          await updateCongestion(storeData.id, value);
                      if (context.mounted) {
                        if (isDBUpLoad) {
                          successSnackbar(context, "混雑状況の更新処理が成功しました。");
                        } else {
                          errorSnackbar(context,
                              message: "混雑状況の更新処理でエラーが発生しました。");
                        }
                        loadingNotifier.upData(false);
                      }
                    }, selectNumber: crowdingSelectNumber.value),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: safeAreaHeight * 0.02),
              child: line(context),
            ),
            Padding(
              padding: xPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      titleWithCircle(context, "ストーリー"),
                      nText("　( ${storeData.storyList.length}/7 )",
                          color: Colors.white.withOpacity(0.5),
                          fontSize: safeAreaWidth / 30,
                          bold: 700),
                    ],
                  ),
                  if (storeData.storyList.length < 7)
                    addButton(context, onTap: () async {
                      final loadingNotifier =
                          ref.read(loadingNotifierProvider.notifier);
                      loadingNotifier.upData(true);
                      await getMobileImage(onSuccess: (value) {
                        screenTransitionNormal(
                            context,
                            ImgConfirmation(
                              img: value,
                              storeData: storeData,
                            ));
                      }, onError: () {
                        errorSnackbar(context, message: "画像の取得に失敗しました");
                      });
                      loadingNotifier.upData(false);
                    })
                ],
              ),
            ),
            SizedBox(
              height: safeAreaHeight * 0.01,
            ),
            if (storeData.storyList.isEmpty) ...{
              Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.25,
                child: storeNotPost(context, Icons.photo_camera, "投稿がありません"),
              )
            } else ...{
              Container(
                alignment: Alignment.centerLeft,
                height: safeAreaHeight * 0.25,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < storeData.storyList.length; i++) ...{
                        Padding(
                          key: ValueKey(i),
                          padding: EdgeInsets.all(safeAreaWidth * 0.02),
                          child: storeStoryWidget(
                            context,
                            data: storeData.storyList[i],
                            onDelete: () {
                              showBottomMenu(context, onDelete: () async {
                                final loadingNotifier =
                                    ref.read(loadingNotifierProvider.notifier);
                                loadingNotifier.upData(true);
                                final isStoryUpdated = await upDataStory(
                                    data: storeData.storyList[i],
                                    id: storeData.id,
                                    isDelete: true);
                                if (!context.mounted) return;
                                loadingNotifier.upData(false);
                                Navigator.pop(context);

                                if (isStoryUpdated) {
                                  updateUserData(ref, storeData,
                                      storeData.storyList[i].id);
                                } else {
                                  errorSnackbar(context,
                                      message:
                                          "削除処理に失敗しました。ネットワーク接続を確認して、もう一度お試しください。");
                                }
                              });
                            },
                          ),
                        )
                      }
                    ],
                  ),
                ),
              )
            },
            Padding(
              padding: EdgeInsets.only(
                  top: safeAreaHeight * 0.02, bottom: safeAreaHeight * 0.02),
              child: line(context),
            ),
            Padding(
              padding: xPadding(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      titleWithCircle(context, "イベント"),
                      nText("",
                          color: Colors.white.withOpacity(0.5),
                          fontSize: safeAreaWidth / 30,
                          bold: 700),
                    ],
                  ),
                  addButton(context, onTap: () async {
                    screenTransitionToTop(context, OnAddEventPage(
                      onAdd: (value) {
                        // final filtere = filteredAndSortedEvents(
                        //     [...storeData.eventList, value]);
                        // storeData.eventList.value = [...filtere];
                      },
                    ));
                  })
                ],
              ),
            ),
            SizedBox(
              height: safeAreaHeight * 0.01,
            ),
            if (storeData.eventList.isEmpty) ...{
              Container(
                alignment: Alignment.center,
                height: safeAreaHeight * 0.2,
                child: storeNotPost(context, null, "イベントがありません"),
              )
            } else ...{
              SizedBox(
                  height: safeAreaHeight * 0.2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0;
                            i < storeData.eventList.length;
                            i++) ...{
                          Padding(
                            key: ValueKey(i),
                            padding: EdgeInsets.all(safeAreaWidth * 0.02),
                            child: storeEventWidget(context,
                                data: storeData.eventList[i], onDelete: () {
                              showBottomMenu(context, onDelete: () {});
                            }),
                          )
                        }
                      ],
                    ),
                  ))
            },
            SizedBox(
              height: safeAreaHeight * 0.03,
            )
          ],
        ),
      ),
    );
  }

  void updateUserData(WidgetRef ref, StoreData storeData, String storyId) {
    final userDataNotifier = ref.read(userDataNotifierProvider.notifier);
    userDataNotifier.addStoreData(StoreData(
        storyList:
            storeData.storyList.where((story) => story.id != storyId).toList(),
        logo: storeData.logo,
        id: storeData.id,
        name: storeData.name,
        address: storeData.address,
        businessHours: storeData.businessHours,
        searchWord: storeData.searchWord,
        eventList: storeData.eventList,
        location: storeData.location));
  }
}
